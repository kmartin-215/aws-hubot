#!/usr/bin/env bash

export hubotSlack=$(/root/.local/bin/aws secretsmanager --region us-east-1 get-secret-value --secret-id hubot)

export hubotToken=$(echo ${hubotSlack} | /usr/bin/jq '.SecretString | fromjson | .hubotSlackToken' | /bin/sed 's/\"//g')
export hubotName=$(echo ${hubotSlack} | /usr/bin/jq '.SecretString | fromjson | .hubotSlackBotname' | /bin/sed 's/\"//g')

# Set the HUBOT_SLACK_TOKEN env vars
if [[ -z "${HUBOT_SLACK_TOKEN}" ]]; then
  # Not detected, so setting via AWS Secrets
  export HUBOT_SLACK_TOKEN=${hubotToken}
else
  # Detected existing, probably set by a developer via docker run
  echo "HUBOT_SLACK_TOKEN environment variable already exists:"
fi

# Set the HUBOT_SLACK_TOKEN environment variable
if [[ -z "${HUBOT_SLACK_BOTNAME}" ]]; then
  # Not detected, so setting via AWS Secrets
  export HUBOT_SLACK_BOTNAME=${hubotName}
else
  # Detected existing, probably set by a developer via docker run
  echo "HUBOT_SLACK_TOKEN environment variable already exists:"
fi

# Start Hubot
/opt/hubot/node_modules/hubot/bin/hubot --adapter slack

