#/bin/bash
set -eu

StackName="test-app-runner"

TemplateFile="apprunner.yaml"

ServiceName="${StackName}"
VpcConnectorName="${StackName}"
SecurityGroupName="${StackName}"

VpcID="vpc-*****************"
SubnetID1="subnet-*****************"
SubnetID2="subnet-*****************"

ImageIdentifier="123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/test-app-runner:latest"

CPU="1 vCPU" # "1024|2048|(1|2) vCPU"
Memory="2 GB" # "2048|3072|4096|(2|3|4) GB"


MaxSize=3
MinSize=2
MaxConcurrency=100

AutoScalingConfiguration=$(cat <<EOF
{
  "AutoScalingConfigurationName": "${StackName}",
  "MinSize": ${MinSize},
  "MaxSize": ${MaxSize},
  "MaxConcurrency": ${MaxConcurrency}
}
EOF
)

AutoScalingConfigurationArn=$( \
  aws apprunner \
  create-auto-scaling-configuration \
  --cli-input-json "${AutoScalingConfiguration}" \
  | jq -r '.AutoScalingConfiguration.AutoScalingConfigurationArn' \
)


aws cloudformation deploy \
  --stack-name ${StackName} \
  --region ap-northeast-1 \
  --template-file ${TemplateFile} \
  --capabilities CAPABILITY_IAM \
  --no-fail-on-empty-changeset \
  --parameter-overrides \
    ServiceName="${ServiceName}" \
    VpcConnectorName="${VpcConnectorName}" \
    SecurityGroupName="${SecurityGroupName}" \
    VpcID="${VpcID}" \
    SubnetID1="${SubnetID1}" \
    SubnetID2="${SubnetID2}" \
    CPU="${CPU}" \
    Memory="${Memory}" \
    AutoScalingConfigurationArn="${AutoScalingConfigurationArn}" \
    ImageIdentifier="${ImageIdentifier}"
