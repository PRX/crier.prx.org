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

# get all the env vars to put into the task definition
env_vars=""
while read line
do
  env_vars="$env_vars{\"name\": \"${line%=*}\", \"value\": \"${line#*=}\"}"
  export "DEPLOY_$line"
done < ".env.${ENV:-staging}"
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
  service=${BASE_NAME}-${bn}-${ENV:-staging}
  of=$(get_abs_filename "build/ecs/task_definitions/$service.json")

  # always registers, will create a new revision if already exists
  render_template $tf | jq "." > $of
  aws ecs register-task-definition --cli-input-json file://$of
  aws logs create-log-group --log-group-name ecs-${service} --region ${DEPLOY_AWS_REGION}
  aws logs put-retention-policy --log-group-name ecs-${service} --retention-in-days ${LOG_RETENTION_DAYS}
done
