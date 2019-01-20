# aws-hubot
Hubot (Slack) running on AWS ECS Fargate using Amazon's Secrets Manager for credentials. 

## Before You Begin
Make sure you have the following in place
*   An AWS CLI Account (Admin)
    *   [Instructions](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html)
*   A working version of the AWS CLI on your local computer
    *   [Instructions](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
*   Docker running on your local computer
    *   [Instructions](https://docs.docker.com/docker-for-windows/install/)

**Note:** We will be using "us-east-1" for this example. If you would like to use a different region, make sure 
    Fargate is available in the region.
## Deployment

### Setup all of your variables
```
# Set the region variable
export AWS_DEFAULT_REGION=us-east-1

# Set your Account ID variable
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')

# Set your repo name / bot name
export IMAGE_REPO_NAME=yourBotNameGoesHere

# Set your tag for the repo (ie. 1.0.0)
export IMAGE_TAG=yourTagGoesHere

# Set your Stack Name
export STACK_NAME=yourStackNameGoesHere
```

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
aws secretsmanager --region $AWS_DEFAULT_REGION create-secret --name $IMAGE_REPO_NAME \
    --description $IMAGE_REPO_NAME" Secrets" \
    --secret-string file://secrets.json
```
*   Verify that the secret was created successfully
```
aws secretsmanager --region $AWS_DEFAULT_REGION get-secret-value --secret-id $IMAGE_REPO_NAME
```

### Amazon Elastic Container Registry

*   Create an Amazon Elastic Container Registry (ECR)
```
aws ecr create-repository --repository-name $IMAGE_REPO_NAME
```
*   Build your Docker Image
```
docker build -t $IMAGE_REPO_NAME:$IMAGE_TAG .
```
*   Tag your image
```
docker tag $IMAGE_REPO_NAME:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
```
*   Log into Amazon ECR
```
export AWS_ECR_LOGIN=$(aws ecr get-login --no-include-email) && $AWS_ECR_LOGIN
```
*   Now you can push your image to Amazon ECR
```
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
```

### Amazon Elastic Container Service

*   Deploy our basic stack using a CloudFormation template
```
aws cloudformation deploy --stack-name=$STACK_NAME --template-file=aws/chatops-stack.yml --parameter-overrides 
ServiceName=$IMAGE_REPO_NAME ImageTag=$IMAGE_TAG --capabilities=CAPABILITY_IAM
```
## Testing Locally
```
docker run -it -e HUBOT_SLACK_TOKEN=yourTokenGoesHere -e HUBOT_SLACK_BOTNAME=yourBotNameGoesHere hubot:1.0.0 bash
echo $HUBOT_SLACK_TOKEN
echo $HUBOT_SLACK_BOTNAME
npm start

# NOTES:
#/root/.local/bin/aws --version
#/root/.local/bin/aws configure
```