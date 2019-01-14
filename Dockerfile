FROM node:10.1.0


MAINTAINER Kevin Martin <21.kmart@gmail.com>


# Install jq to handle JSON and Python 3 as well as pip
RUN apt-get update && apt-get install \
    jq \
    python3 \
    python3-pip \
    -qq > /dev/null


# Install the AWS CLI
RUN pip3 install --quiet awscli --upgrade --user


# Add an export command at the end of your profile and reload
RUN export PATH=~/.local/bin:$PATH


# Create our Hubot directories
RUN mkdir -p /opt/hubot \
    mkdir -p /opt/hubot/scripts


# Copy files to working directory
COPY *.* /opt/hubot/


# Set the working directory to /opt/hubot
WORKDIR /opt/hubot


# Install the dependancies
RUN npm install coffee-script -g && npm install


# Copy scripts to the scripts directory
COPY ./scripts/*.* /opt/hubot/scripts/


# Start the bot
CMD ["npm", "start"]