#!/bin/bash
################################################################################
# Zscaler Private Service Edge User Data Script (Zscaler Marketplace AMI)
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

%{ if onboarding_method == "provisioning_key" ~}
################################################################################
# Provisioning key onboarding
################################################################################
echo "=== ZPA Provisioning Key Registration ==="

# Stop the Service Edge service which was auto-started at boot time
systemctl stop zpa-service-edge 2>/dev/null || true

# Write the provisioning key created via the ZPA provider to the service edge.
# Keep the key between double quotes.
echo "${provisioning_key}" > /opt/zscaler/var/service-edge/provision_key
chmod 644 /opt/zscaler/var/service-edge/provision_key

# Start the Service Edge service to enroll it in the ZPA cloud
systemctl start zpa-service-edge

echo "=== Provisioning Key Registration Complete, starting yum update ==="
nohup yum update -y > /var/log/yum-update.log 2>&1 &

%{ else ~}
################################################################################
# OAuth2 onboarding
################################################################################

# Get instance ID and region from EC2 metadata service
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" 2>/dev/null)
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null)
AVAILABILITY_ZONE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone 2>/dev/null)
REGION=$(echo "$AVAILABILITY_ZONE" | sed 's/[a-z]$//')

echo "=== ZPA OAuth Token Registration ==="
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

# Ensure zpa-service-edge service is running (generates OAuth token)
systemctl start zpa-service-edge 2>/dev/null || true

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
  aws ssm put-parameter \
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

echo "=== OAuth Registration Complete, starting yum update ==="

# Run yum update in background (doesn't block OAuth token registration)
nohup yum update -y > /var/log/yum-update.log 2>&1 &
%{ endif ~}
