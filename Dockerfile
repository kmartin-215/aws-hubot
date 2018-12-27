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
RUN mkdir -p /opt/hubot \
    mkdir -p /opt/hubot/scripts \
    mkdir -p /opt/hubot/help


# Copy files to the directories
COPY *.* /opt/hubot/
COPY ./scripts/*.* /opt/hubot/scripts/
COPY ./help/*.* /opt/hubot/help/


# Install the dependancies
RUN cd /opt/hubot && npm install


# Set the working directory to /opt/hubot
WORKDIR /opt/hubot


# Start the bot
CMD ["npm", "start"]