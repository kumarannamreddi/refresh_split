#!/usr/bin/bash

echo -e "applying the refresh changes ..............."

##exec &> refresh.log

export TF_VAR_oraclesid=$1
export TF_VAR_input_tags=CTE_CUSTOMER
export TF_VAR_pem_file=/home/ec2-user/.ssh/ctestmt.pem
terraform init
terraform plan
terraform apply -auto-approve
terraform output
VOLUME_IDS=terraform output volumetags
for i in "${!VOLUME_IDS}"
do
  echo "${i}"
done
