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
    (**Note:** You will need to replace `aws_account_id` below with your actual AWS Account ID)
```
docker push aws_account_id.dkr.ecr.us-east-1.amazonaws.com/aws-hubot:1.0.0
```

### Amazon Elastic Container Service

*   Work In Progress
