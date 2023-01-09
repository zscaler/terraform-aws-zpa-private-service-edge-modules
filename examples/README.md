# Zscaler Service Edge Cluster Infrastructure Setup

**Terraform configurations and modules for deploying Zscaler Service Edge Cluster in AWS.**

## Prerequisites (You will be prompted for AWS keys and region during deployment)

### AWS requirements
1. A valid AWS account
2. AWS ACCESS KEY ID
3. AWS SECRET ACCESS KEY
4. AWS Region (E.g. us-west-2)
5. Subscribe and accept terms of using Amazon Linux 2 AMI (for base deployments with workloads + bastion) at [this link](https://aws.amazon.com/marketplace/pp/prodview-zc4x2k7vt6rpu)
6. Subscribe and accept terms of using Zscaler Private Service Edge image at [this link](https://aws.amazon.com/marketplace/pp/prodview-wribnrdlalkme)

### Zscaler requirements
7. A valid Zscaler Private Access subscription and portal access
8. Zscaler ZPA API Keys. Details on how to find and generate ZPA API keys can be located here: https://help.zscaler.com/zpa/about-api-keys#:~:text=An%20API%20key%20is%20required,from%20the%20API%20Keys%20page
- Client ID
- Client Secret
- Customer ID
9. (Optional) An existing Service Edge Group and Provisioning Key. Otherwise, you can follow the prompts in the examples terraform.tfvars to create a new Connector Group and Provisioning Key

See: [Zscaler Service Edge AWS Deployment Guide](https://help.zscaler.com/zpa/service-edge-deployment-guide-amazon-web-services) for additional prerequisite provisioning steps.

## Deploying the cluster
(The automated tool can run only from MacOS and Linux. You can also upload all repo contents to the respective public cloud provider Cloud Shells and run directly from there).   
 
**1. Greenfield Deployments**

(Use this if you are building an entire cluster from ground up.
 Particularly useful for a Customer Demo/PoC or dev-test environment)

```
bash
cd examples
Optional: Edit the terraform.tfvars file under your desired deployment type (ie: base_pse) to setup your Service Edge Group (Details are documented inside the file)
- ./zspse up
- enter "greenfield"
- enter <desired deployment type>
- follow prompts for any additional configuration inputs. *keep in mind, any modifications done to terraform.tfvars first will override any inputs from the zspse script*
- script will detect client operating system and download/run a specific version of terraform in a temporary bin directory
- inputs will be validated and terraform init/apply will automatically exectute.
- verify all resources that will be created/modified and enter "yes" to confirm
```

**Greenfield Deployment Types:**

```
Deployment Type: (base | base_pse | base_pse_asg):
base: Creates 1 new VPC with 1 public subnet and 1 private/workload subnet; 1 IGW; 1 NAT Gateway; 1 Bastion Host in the public subnet assigned an Elastic IP and routing to the IGW; generates local key pair .pem file for ssh access. This template alone will NOT create any Service Edge appliances
base_pse: Base Deployment Type + Creates Service Edge private subnets and Service Edge VMs egressing through the NAT Gateways in their respective availability zones. Please refer to additional requirements in this deployment folder terraform.tfvars file prior to running to step through requirements to create a new Service Edge Group if you do NOT already have one created.
base_pse_asg: Base Deployment Type + Creates Service Edges via Launch Template in an Autoscaling Group. Please refer to additional requirements in this deployment folder terraform.tfvars file prior to running to step through requirements to create a new Service Edge Group if you do NOT already have one created.
```

**2. Brownfield Deployments**

(These templates would be most applicable for production deployments and have more customization options than a "base" deployments). They also do not include a bastion host deployed.

```
bash
cd examples
Optional: Edit the terraform.tfvars file under your desired deployment type (ie: ac) to setup your Service Edge (Details are documented inside the file)
- ./zspse up
- enter "brownfield"
- enter <desired deployment type>
- follow prompts for any additional configuration inputs. *keep in mind, any modifications done to terraform.tfvars first will override any inputs from the zspse script*
- script will detect client operating system and download/run a specific version of terraform in a temporary bin directory
- inputs will be validated and terraform init/apply will automatically exectute.
- verify all resources that will be created/modified and enter "yes" to confirm
```

**Brownfield Deployment Types**

```
Deployment Type: (pse | pse_asg):
pse: Creates 1 new VPC with 2 public subnets and 2 Service Edge private subnets; 1 IGW; 2 NAT Gateways; 2 Service Edge VMs (1 per subnet/AZ) routing to the NAT Gateway in their same AZ; generates local key pair .pem file for ssh access; The number of Service Edges and subnets deployed is customizable; There are also "byo" variables providing the ability to use existing resources (VPC, subnets, IGW, NAT Gateways, IAM, Security Groups, etc.) generates local key pair .pem file for ssh access to all instances. Please refer to additional requirements in this deployment folder terraform.tfvars file prior to running to step through requirements to create a new Service Edge Group if you do NOT already have one created or if you intend to reference any existing byo network resources.
pse_asg: Same resource creation and "byo" options as pse deployment type, but the Service Edges VMs are instead deployed via a Launch Template in Autoscaling Group configuration. Please refer to additional requirements in this deployment folder terraform.tfvars file prior to running to step through requirements to create a new Service Edge Group if you do NOT already have one created or if you intend to reference any existing byo network resources.
```

## Destroying the cluster
```
cd examples
- ./zspse destroy
- verify all resources that will be destroyed and enter "yes" to confirm
```

## Notes
```
1. For auto approval set environment variable **AUTO_APPROVE** or add `export AUTO_APPROVE=1`
2. For deployment type set environment variable **dtype** to the required deployment type or add `export dtype=base_pse`
3. To provide new credentials or region, delete the autogenerated .zspserc file in your current working directory and re-run zspse.
```
