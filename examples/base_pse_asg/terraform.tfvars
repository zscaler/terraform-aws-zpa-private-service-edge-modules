## This is only a sample terraform.tfvars file.
## Uncomment and change the below variables according to your specific environment

#####################################################################################################################
##### Variables 5-22 are populated automatically if terraform is ran via ZSPSE bash script.  ##### 
##### Modifying the variables in this file will override any inputs from ZSPSE               #####
#####################################################################################################################

#####################################################################################################################
##### Optional: ZPA Provider Resources. Skip to step 3. if you already have an  #####
##### Service Edge Group + Provisioning Key.                                    #####
#####################################################################################################################

## 1. ZPA Service Edge Provisioning Key variables. Uncomment and replace values as desired for your deployment.
##    For any questions populating the below values, please reference: 
##    https://registry.terraform.io/providers/zscaler/zpa/latest/docs/resources/zpa_provisioning_key

#enrollment_cert                                = "Service Edge"
#provisioning_key_name                          = "new_key_name"
#provisioning_key_enabled                       = true
#provisioning_key_max_usage                     = 50

## 2. ZPA Service Edge Group variables. Uncomment and replace values as desired for your deployment. 
##    For any questions populating the below values, please reference: 
##    https://registry.terraform.io/providers/zscaler/zpa/latest/docs/resources/zpa_service_edge_group

#pse_group_name                     = "new_group_name"
#pse_group_description              = "group_description"
#pse_group_enabled                  = true
#pse_group_country_code             = "US"
#pse_group_latitude                 = "37.3382082"
#pse_group_longitude                = "-121.8863286"
#pse_group_location                 = "San Jose, CA, USA"
#pse_group_upgrade_day              = "SUNDAY"
#pse_group_upgrade_time_in_secs     = "66600"
#pse_group_override_version_profile = true
#pse_group_version_profile_id       = "2"
#pse_is_public                      = "FALSE"
#zpa_trusted_network_name           = "Corporate-Network (zscalertwo.net)"   ### this variable is optional. leave commented out if not used  


#####################################################################################################################
##### Optional: ZPA Provider Resources. Skip to step 5. if you added values for steps 1. and 2. #####
##### meaning you do NOT have a provisioning key already.                                       #####
#####################################################################################################################

## 3. By default, this script will create a new Service Edge Group Provisioning Key.
##     Uncomment if you want to use an existing provisioning key (true or false. Default: false)

#byo_provisioning_key                           = true

## 4. Provide your existing provisioning key name. Only uncomment and modify if yo uset byo_provisioning_key to true

#byo_provisioning_key_name                      = "example-key-name"


#####################################################################################################################
##### Custom variables. Only change if required for your environment  #####
#####################################################################################################################

## 5. AWS region where Service Edge resources will be deployed. This environment variable is automatically populated if running ZSPSE script
##    and thus will override any value set here. Only uncomment and set this value if you are deploying terraform standalone. (Default: us-west-2)

#aws_region                                     = "us-west-2"

## 6. By default, Service Edge will deploy via the Zscaler Latest AMI. Setting this to false will deploy the latest Amazon Linux 2 AMI instead"

#use_zscaler_ami                                = false

## 7. Service Edge AWS EC2 Instance size selection. Uncomment psevm_instance_type line with desired vm size to change.
##    (Default: m5.large)

#psevm_instance_type                             = "t3.xlarge"  # recommended only for test/non-prod use
#psevm_instance_type                             = "m5.large"
#psevm_instance_type                             = "m5.xlarge"
#psevm_instance_type                             = "m5.2xlarge"
#psevm_instance_type                             = "m5.4xlarge"

## 8. The number of Service Edge Subnets to create in sequential availability zones. Available input range 1-3 (Default: 2)
##    **** NOTE - This value will be ignored if byo_vpc / byo_subnets

#az_count                                       = 2

## 9. The minumum number of Service Edges to maintain in an Autoscaling group. (Default: 2)
##    Recommendation is to maintain HA/Zonal resliency for production deployments

#min_size                                   = 2

## 10. The maximum number of Service Edges to maintain in an Autoscaling group. (Default: 4)

#max_size                                   = 4

## 11. Enable/Disable public IP addresses on Service Edge instances. Default is false. Setting this to true will result in the following: 
##    Dynamic Public IP address on the Service Edge VM Instance will be enabled; 
##    No EIP or NAT Gateway resources will be created; 
##    The Service Edge Route Table default route next-hop will be set as the IGW

##    Note: Service Edge has no external inbound network dependencies, so the recommendation is to leave this set to false and utilize a NAT Gateway
##    for internet egress. Only enable this if you are certain you really want it for you environment.

#associate_public_ip_address                    = true

## 12. Network Configuration:

##    IPv4 CIDR configured with VPC creation. All Subnet resources (Public / Service Edge) will be created based off this prefix
##    /24 subnets are created assuming this cidr is a /16. If you require creating a VPC smaller than /16, you may need to explicitly define all other 
##     subnets via public_subnets and pse_subnets variables

##    Note: This variable only applies if you let Terraform create a new VPC. Custom deployment with byo_vpc enabled will ignore this

#vpc_cidr                                       = "10.1.0.0/16"

##    Subnet space. (Minimum /28 required. Default is null). If you do not specify subnets, they will automatically be assigned based on the default cidrsubnet
##    creation within the VPC CIDR block. Uncomment and modify if byo_vpc is set to true but byo_subnets is left false meaning you want terraform to create 
##    NEW subnets in that existing VPC. OR if you choose to modify the vpc_cidr from the default /16 so a smaller CIDR, you may need to edit the below variables 
##    to accommodate that address space.

##    ***** Note *****
##    It does not matter how many subnets you specify here. this script will only create in order 1 or as many as defined in the az_count variable
##    Default/Minumum: 1 - Maximum: 3
##    Example: If you change vpc_cidr to "10.2.0.0/24", set below variables to cidrs that fit in that /24 like pse_subnets = ["10.2.0.0/27","10.2.0.32/27"] etc.

#public_subnets                                 = ["10.x.y.z/24","10.x.y.z/24"]
#pse_subnets                                     = ["10.x.y.z/24","10.x.y.z/24"]

## 13. Tag attribute "Owner" assigned to all resoure creation. (Default: "zszpa-admin")

#owner_tag                                      = "username@company.com"

## 14. By default, this script will apply 1 Security Group per Service Edge instance. 
##     Uncomment if you want to use the same Security Group for ALL Service Edges (true or false. Default: false)

#reuse_security_group                           = true

## 15. By default, this script will apply 1 IAM Role/Instance Profile per Service Edge instance. 
##     Uncomment if you want to use the same IAM Role/Instance Profile for ALL Service Edges (true or false. Default: false)

#reuse_iam                                      = true

## 16. The amount of time until EC2 Auto Scaling performs the first health check on new instances after they are put into service. (Default: 300 seconds/5 minutes)

#health_check_grace_period                  = 300

## 17. If set to true, add a warm pool to the specified Auto Scaling group. See [warm_pool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#warm_pool).
##     Uncomment to enable. (Default: false)

#warm_pool_enabled                          = true

## 18. Sets the instance state to transition to after the lifecycle hooks finish. Valid values are: Stopped (default), Running or Hibernated. Ignored when 'warm_pool_enabled' is false
##     Uncomment the desired value

#warm_pool_state                            = "Stopped"
#warm_pool_state                            = "Running"
#warm_pool_state                            = "Hibernated"

## 19. Specifies the minimum number of instances to maintain in the warm pool. This helps you to ensure that there is always a certain number of warmed instances available to handle traffic spikes. Ignored when 'warm_pool_enabled' is false
##     Uncomment and specify a desired minimum number of Service Edges to maintain deployed in a warm pool

#warm_pool_min_size                         = 1

## 20. Specifies the total maximum number of instances that are allowed to be in the warm pool or in any state except Terminated for the Auto Scaling group. Ignored when 'warm_pool_enabled' is false
##     Uncomment and specify a desired maximum number of Service Edges to maintain deployed in a warm pool

#warm_pool_max_group_prepared_capacity      = 2

## 21. Specifies whether instances in the Auto Scaling group can be returned to the warm pool on scale in
##     Uncomment to enable. (Default: false)

#reuse_on_scale_in                          = true

## 22. Target value number for autoscaling policy CPU utilization target tracking. ie: trigger a scale in/out to keep average CPU Utliization percentage across all instances at/under this number
##     (Default: 50%)

#target_cpu_util_value                      = 50
