#!/bin/bash

# Store the current working directory
DIR=`pwd`

# Source environment variables
# This includes variables used by the bots, including:
# TWITTER_CONSUMER_KEY
# TWITTER_ACCESS_TOKEN_SECRET
# TWITTER_CONSUMER_SECRET
# TWITTER_ACCESS_TOKEN_KEY
# DBPW (your postgresql password)
# TWITTERDB (the database you are using for this bot)
# DBUSER (your postgresql user name)

# These variables are exported in my home directory, in a file called 'env'. Change the line below if your environment variables are exported in a different file 
source $HOME/env

# Local variables used by this script. Change the values here if your log file and twitter bots are in different locations.
LOG="$HOME/projects/python/twitter-bots/logs/cron_bots.log"
TWITTER_BOTS_DIR="$HOME/projects/python/twitter-bots/"
FOLLOWERSBOT_DIR="follower-count/"
CONSCIOUSNESSBOT_DIR="consciousness-bot/"
FRIENDLYBOT_DIR="greetings/"


/bin/echo >>$LOG
/bin/echo "===========================================" >>$LOG
/bin/echo "Running twitter bots" >>$LOG
/bin/date >>$LOG
/bin/echo "===========================================" >>$LOG
/bin/echo >>$LOG


# Run followers bot
# Stores current count of my followers in db
echo "Running followers bot" >>$LOG
echo "---------------------" >>$LOG
cd $TWITTER_BOTS_DIR$FOLLOWERSBOT_DIR
source venv/bin/activate
python follower_count.py 2>&1 >>$LOG
deactivate

# Run consciousness bot
# Updates twitter status with inspirational message
echo "Running consciousness bot" >>$LOG
echo "-------------------------" >>$LOG
cd $TWITTER_BOTS_DIR$CONSCIOUSNESSBOT_DIR
source venv/bin/activate
python consciousness_bot.py 2>&1 >>$LOG
deactivate

# Run friendly bot
# Thanks the last 5 new followers and makes friends
echo "Running friendly bot" >>$LOG
echo "---------------------" >>$LOG
cd $TWITTER_BOTS_DIR$FRIENDLYBOT_DIR
source venv/bin/activate
python greetings.py 2>&1 >>$LOG
deactivate

# Change back to the original working directory
cd $DIR
