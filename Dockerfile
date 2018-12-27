FROM node:10.1.0


MAINTAINER Kevin Martin <21.kmart@gmail.com>


# Install jq to handle JSON and Python 3 as well as pip
RUN apt-get update && apt-get install -y \
    jq \
    python3 \
    python3-pip


# Install the AWS CLI
RUN pip install awscli --upgrade --user


# Create our Hubot directories
RUN mkdir -p /opt/hubot
RUN mkdir -p /opt/hubot/scripts


# Copy files to the directories
COPY *.* /opt/hubot/


# Set the NPM Registry
# In production we will use an AWS repository or Nexus


# Install the dependancies
RUN cd /opt/hubot && npm install


# Set the working directory to /opt/bot
WORKDIR /opt/hubot


# Start the bot
CMD ["npm", "start"]