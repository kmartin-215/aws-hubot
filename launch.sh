#!/usr/bin/env bash

hubotToken=$(aws secretsmanager --region us-east-1 get-secret-value --secret-id HUBOT_SLACK_TOKEN | jq '.SecretString.hubotSlackToken')
hubotName=$(aws secretsmanager --region us-east-1 get-secret-value --secret-id HUBOT_SLACK_BOTNAME | jq '.SecretString.hubotSlackBotname')

export HUBOT_SLACK_TOKEN=${hubotToken}
export HUBOT_SLACK_BOTNAME=${hubotName}

/opt/hubot/node_modules/hubot/bin/hubot --adapter slack
