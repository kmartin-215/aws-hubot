#!/usr/bin/env bash

hubotSlack=$(aws secretsmanager --region us-east-1 get-secret-value --secret-id hubotSlackCreds)

hubotToken=$(echo ${hubotSlack} | jq '.SecretString.hubotSlackToken | fromjson | .hubotSlackToken')
hubotName=$(echo ${hubotSlack} | jq '.SecretString | fromjson | .hubotSlackBotname')

export HUBOT_SLACK_TOKEN=${hubotToken}
export HUBOT_SLACK_BOTNAME=${hubotName}

/opt/hubot/node_modules/hubot/bin/hubot --adapter slack

