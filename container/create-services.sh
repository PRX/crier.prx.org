#!/usr/bin/env bash

# This script creates:
# * task definitions from the template files
# * cloudwatch logging groups

# It uses the ENV value to know what environment to create task defs for.
# ENV defaults to `staging`

# $1 : file template to replace with env vars
function render_template {
eval "cat <<EOF
$(<$1)
EOF
" 2> /dev/null
}

# $1 : relative filename
function get_abs_filename() {
  if [ -d "${1%/*}" ]; then
    echo "$(cd ${1%/*}; pwd)/${1##*/}"
  fi
}

# load variables from file
while read line; do export "$line"; done < .deploy

environment=${ENV:-staging}

# get all the env vars to put into the task definition
env_vars=""
while read line
do
  env_vars="$env_vars{\"name\": \"${line%=*}\", \"value\": \"${line#*=}\"}"
  export "DEPLOY_$line"
done < ".env.${environment}"
env_vars=$(echo $env_vars | sed -e 's/}{/}, {/g')
env_vars="[ $env_vars ]"
export ENV_JSON=$env_vars

# define the string for the docker image repository
export REPO_STRING="$DEPLOY_AWS_ACCOUNT_ID.dkr.ecr.$DEPLOY_AWS_REGION.amazonaws.com/$BASE_NAME.prx.org:$ECR_VERSION"

# write the task definition file
mkdir -p build/ecs/task_definitions

for tf in container/ecs/task_definitions/*
do
  bn=$(basename "$tf" ".json")
  service=${BASE_NAME}-${bn}-${environment}
  of=$(get_abs_filename "build/ecs/task_definitions/$service.json")

  # always registers, will create a new revision if already exists
  render_template $tf | jq "." > $of

  # create the cloudwatch setup
  echo "aws logs"
  aws logs create-log-group --log-group-name ecs-${service} --region ${DEPLOY_AWS_REGION}
  aws logs put-retention-policy --log-group-name ecs-${service} --retention-in-days ${LOG_RETENTION_DAYS}

  # create the task def
  echo "aws register task definition"
  aws ecs register-task-definition --cli-input-json file://$of

  # if this is a `web` service, create an elb
  loadBalancerOption=
  if [ "$bn" == "web" ]; then

    domainName=tech
    if [ "$environment" == "production" ]; then
      domainName=org
    fi

    vpcId=$(aws ec2 describe-vpcs --filters Name=tag:Environment,Values=${environment} | jq -r '.Vpcs[] | .VpcId')
    subnets=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=${vpcId} | jq -r '.Subnets[] | .SubnetId' | tr '\n' ' ')
    securityGroups=$(aws ec2 describe-security-groups --filters Name=vpc-id,Values=${vpcId} Name=tag:Name,Values=ecs-${environment}-elbs | jq -r '.SecurityGroups[] | .GroupId')
    certArn=$(aws acm list-certificates | jq -r ".CertificateSummaryList[] | select(.DomainName|endswith(\"${domainName}\")) | .CertificateArn")
    listeners="Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=$HOST_PORT Protocol=HTTPS,LoadBalancerPort=443,InstanceProtocol=HTTP,InstancePort=$HOST_PORT,SSLCertificateId=${certArn}"

    echo "create load balancer"
    aws elb create-load-balancer \
      --load-balancer-name ${service} \
      --listeners ${listeners} \
      --subnets ${subnets} \
      --security-groups ${securityGroups} \
      --tags Key=Name,Value=${service} Key=Environment,Value=$ENV

    loadBalancerOption=loadBalancerName=${service},containerName=${BASE_NAME}-${bn},containerPort=$CONTAINER_PORT

    # create the service
    echo "create web service"
    aws ecs create-service \
      --cluster prx-${environment} \
      --service-name ${service} \
      --task-definition ${service} \
      --load-balancers ${loadBalancerOption}\
      --desired-count $DESIRED_COUNT \
      --role ecsServiceRole
  else

    # create the service
    echo "create service"
    aws ecs create-service \
      --cluster prx-${environment} \
      --service-name ${service} \
      --task-definition ${service} \
      --desired-count $DESIRED_COUNT
  fi

done
