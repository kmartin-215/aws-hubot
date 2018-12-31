# aws-hubot
Hubot running on AWS ECS Fargate

## Before You Begin
Make sure you have the following in place
*   An AWS CLI Account (Admin)
    *   [Instructions](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html)
*   A working version of the AWS CLI on your local computer
    *   [Instructions](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
*   Docker running on your local computer
    *   [Instructions](https://docs.docker.com/docker-for-windows/install/)
*   A working version of the AWS ECS CLI on your local computer
    *   [Instructions](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html)

**Note:** We will be using "us-east-1" for this example. If you would like to use a different region, make sure 
    Fargate is available in the region and swap out references to `us-east-1` throughout the example.
## Deployment

### Amazon Secrets Manager
*   Create a `secrets.json` file for use with AWS Secrets Manager
```
{
    "hubotSlackToken": "yourTokenGoesHere",
    "hubotSlackBotname": "yourBotNameGoesHere"
}
```
*   Create a new secret in the AWS Secret Manager
```
aws secretsmanager --region us-east-1 create-secret --name hubotSlackCreds \
    --description "Hubot Slack Credentials" \
    --secret-string file://secrets.json
```
*   Verify that the secret was created successfully
```
aws secretsmanager --region us-east-1 get-secret-value --secret-id hubotSlackCreds
```

### Amazon Elastic Container Registry

*   Create an Amazon Elastic Container Registry (ECR)
```
aws ecr create-repository --repository-name aws-hubot
```
*   Build your Docker Image
```
docker build -t aws-hubot:1.0.0 .
```
*   Tag your image
```
docker tag aws-hubot:1.0.0 aws_account_id.dkr.ecr.us-east-1.amazonaws.com/aws-hubot:1.0.0
```
*   Log into Amazon ECR
```
# First get your login details
aws ecr get-login --no-include-email

# Output
docker login -u AWS -p <password> -e none https://<aws_account_id>.dkr.ecr.<region>.amazonaws.com

# Using the output from above you can now log in (you may want to omit the -p <password> and type it manually)
docker login -u AWS -e none https://<aws_account_id>.dkr.ecr.<region>.amazonaws.com

Type your password in when prompted
```
*   Now you can push your image to Amazon ECR

    **Note:** You will need to replace `aws_account_id` below with your actual AWS Account ID
```
docker push aws_account_id.dkr.ecr.us-east-1.amazonaws.com/aws-hubot:1.0.0
```

### Amazon Elastic Container Service

*   Create the task execution role
```
aws iam --region us-east-1 create-role --role-name ecsTaskExecutionRole --assume-role-policy-document file://task-execution-assume-role.json
```
*   Attach the task execution role policy
```
aws iam --region us-east-1 attach-role-policy --role-name ecsTaskExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
```
*   Create a cluster configuration
```
ecs-cli configure --cluster aws-hubot --region us-east-1 --default-launch-type FARGATE --config-name aws-hubot
```
*   Create an ECS CLI profile using your access key and secret key 
    
    **Note:** Replace AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY with your own values
```
ecs-cli configure profile --access-key AWS_ACCESS_KEY_ID --secret-key AWS_SECRET_ACCESS_KEY --profile-name aws-hubot
```
*   Create an Amazon ECS cluster

    **Note:** Record these three (3) output value IDs for tasks below
```
ecs-cli up

# Output
VPC created: vpc-XXXXXXXXXXXXXXXXX
Subnet created: subnet-XXXXXXXXXXXXXXXXX
Subnet created: subnet-XXXXXXXXXXXXXXXXX
```
*   Create a security group using the VPC ID from the previous output above

    **Note:** Record the GroupID output for tasks below
```
aws ec2 create-security-group --group-name "aws-hubot" --description "AWS-Hubot Security Group" --vpc-id "Your VPC ID Goes Here"

# Output
sg-XXXXXXXXXXXXXXXXX
```
*   Edit the ecs-params.yml file

    **Note:** Change/update these three (3) values using the results from output above
```
      subnets:
      - "Your Subnet ID 1"
      - "Your Subnet ID 2"
      security_groups:
      - "Your Security Group ID"
```
*   Edit the docker-compose.yml file and replace `aws_account_id` with your account ID
```
    image: aws_account_id.dkr.ecr.us-east-1.amazonaws.com/aws-hubot:1.0.0
```
*   Deploy your cluster
```
ecs-cli compose --project-name aws-hubot service up --create-log-groups --cluster-config aws-hubot
```

## Validation
*   View the containers that are running in the service

    **Note:** Record the task-id value displayed in the output for the container for tasks below
```
ecs-cli compose --project-name aws-hubot service ps --cluster-config aws-hubot

#  Example task-id value might look like: a06a6642-12c5-4006-b1d1-00302423423

```
*   View the logs for the task
```
ecs-cli logs --task-id yourTaskIdGoesHere --follow --cluster-config aws-hubot
```