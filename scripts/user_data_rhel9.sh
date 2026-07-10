#!/usr/bin/bash
################################################################################
# RHEL9 Private Service Edge User Data Script
# Supports both Fixed VMs and Auto Scaling Groups, and both onboarding methods:
#   - oauth            : retrieve OAuth2 user code from /etc/issue and publish it
#                        to SSM Parameter Store for Terraform to enroll.
#   - provisioning_key : write the ZPA provisioning key to the service edge and
#                        let it self-enroll. No SSM interaction required.
#
# NOTE: This is a Terraform template file. Template variables are substituted by
# Terraform before script execution. Shellcheck warnings about undefined
# variables can be ignored.
################################################################################

# Sleep to allow the system to initialize
sleep 15

# Create the Zscaler repository file
touch /etc/yum.repos.d/zscaler.repo
cat > /etc/yum.repos.d/zscaler.repo <<-EOT
[zscaler]
name=Zscaler Private Access Repository
baseurl=https://yum.private.zscaler.com/yum/el9
enabled=1
gpgcheck=1
gpgkey=https://yum.private.zscaler.com/yum/el9/gpg
EOT

# Sleep to allow the repo file to be registered
sleep 60

# Install Private Service Edge packages
yum install -y zpa-service-edge

%{ if onboarding_method == "provisioning_key" ~}
################################################################################
# Provisioning key onboarding
################################################################################

# Stop the Service Edge service which was auto-started at boot time
systemctl stop zpa-service-edge

# Write the provisioning key created via the ZPA provider to the service edge.
# Keep the key between double quotes.
echo "${provisioning_key}" > /opt/zscaler/var/provision_key
chmod 644 /opt/zscaler/var/provision_key

# Run a yum update to apply the latest patches
yum update -y

# Start the Service Edge service to enroll it in the ZPA cloud
systemctl start zpa-service-edge

# Wait for the Service Edge to download the latest build, then restart
sleep 60
systemctl stop zpa-service-edge
systemctl start zpa-service-edge

%{ else ~}
################################################################################
# OAuth2 onboarding
################################################################################

# Install unzip
yum install -y unzip

# Download and install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install --update -i /usr/bin/aws-cli -b /usr/bin

# Verify AWS CLI installation
/usr/bin/aws --version

# Start zpa-service-edge service to generate OAuth token
systemctl start zpa-service-edge

# Get instance ID and region from EC2 metadata service
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" 2>/dev/null)
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null)
AVAILABILITY_ZONE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone 2>/dev/null)
REGION=$(echo "$AVAILABILITY_ZONE" | sed 's/[a-z]$//')

echo "Instance ID: $INSTANCE_ID, Region: $REGION"

# Construct SSM Parameter name based on deployment type
%{ if is_asg ~}
# ASG: Instance-ID based parameter name
SSM_PARAMETER_NAME="${ssm_parameter_prefix}-$INSTANCE_ID"
%{ else ~}
# Fixed VM: Pre-defined parameter name from Terraform
SSM_PARAMETER_NAME="${ssm_parameter_name}"
%{ endif ~}
echo "SSM Parameter: $SSM_PARAMETER_NAME"

# Wait for OAuth token to be generated (retry up to 30 times, 10 seconds each = 5 minutes)
MAX_RETRIES=30
RETRY_COUNT=0
OAUTH_TOKEN=""

while [ "$RETRY_COUNT" -lt "$MAX_RETRIES" ]; do
  # Try to retrieve OAuth token from /etc/issue
  OAUTH_TOKEN=$(cat /etc/issue 2>/dev/null | grep -Eo '[A-Z0-9]{5}-[A-Z0-9]{5}' | head -n 1)

  if [ -n "$OAUTH_TOKEN" ]; then
    echo "OAuth token retrieved: $OAUTH_TOKEN"
    break
  fi

  echo "Waiting for OAuth token to be generated (attempt $((RETRY_COUNT + 1))/$MAX_RETRIES)..."
  sleep 10
  RETRY_COUNT=$((RETRY_COUNT + 1))
done

# UPDATE/CREATE the SSM parameter with the OAuth token
if [ -n "$OAUTH_TOKEN" ]; then
  /usr/bin/aws ssm put-parameter \
    --name "$SSM_PARAMETER_NAME" \
    --value "$OAUTH_TOKEN" \
    --type "SecureString" \
    --overwrite \
    --region "$REGION" 2>&1 | tee -a /var/log/oauth-token-registration.log

  if [ $? -eq 0 ]; then
    echo "SUCCESS: OAuth token stored in SSM: $SSM_PARAMETER_NAME"
  else
    echo "ERROR: Failed to store OAuth token in SSM"
  fi
else
  echo "ERROR: Failed to retrieve OAuth token after $MAX_RETRIES attempts"
fi

# Now do yum update (takes a long time, but OAuth token already stored)
yum update -y
%{ endif ~}
