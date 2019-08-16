# Twitter bot series - running bots with cron

Now that you have a bot or a few, you may want to run them automatically with some regular frequency.

You can find the twitter bots I've created here and have a play:

- [Followers bot](https://github.com/janel-developer/twitter-followers-bot)
- [Consciousness bot](https://github.com/janel-developer/twitter-consciousness-bot)
- [Friendly bot](https://github.com/janel-developer/twitter-friendly-bot)

On Linux or MacOS, we can use the cron daemon to achieve automation. On Windows, you can schedule tasks (or use something like cron if you install a tool meant to act like cron). I won't cover the Windows case here, but you can [learn more about scheduling Windows tasks if that's what you need](https://docs.microsoft.com/en-us/windows/win32/taskschd/task-scheduler-start-page).

In this README, I will cover:

- [Cron daemon and crontab](#the-cron-daemon-and-crontab) - explain how I use the cron daemon and crontab to run my twitter bots each morning
- [Creating a cron job](#creating-a-cron-job) - explain how to create a cron job, and what you need to understand about cron and how it works
- [The twitter bots script](#the-twitter-bots-script) - provide information about the twitter_bots.sh script included here to run the bots
- [Cron and environment variables](#cron-and-environment-variables) - explain how to access environment variables from a script run from cron
- [Running your cron job](#running-your-cron-job) - explain how to run your cron job and where to check for results

## The cron daemon and crontab

The cron daemon runs for each user on the system, and is started by the system startup scripts. It looks for tasks defined for each user using the crontab command.

You can run the crontab command with:
`crontab -e`

The `-e` says to use the default system editor with crontab. For most Linux systems, this is VIM. If you want to use a different editor, you can set the EDITOR before you run `crontab -e`. For example, if you want to use nano, you can run:

`EDITOR=nano; crontab -e`

If you want to see what jobs are in crontab, you can run the command `crontab -l`. To remove a cron job, you can run the editor (`crontab -e`), and delete that line. If you want to remove all cron jobs for a user, you can run `crontab -r` as that user

## Creating a cron job

When you run `crontab -e`, the editor is opened and you can add lines to schedule jobs. You indicate when the job will run, and what script (or executable) will be run.

To run the twitter bots, I'm using the script called twitter_bots.sh, which I have put in my home .local/bin directory. I want it to run every morning at 9am, so this is the line I add to crontab:

**#m h dom mon dow command**

0 9 \* \* \* /home/caadmin/.local/bin/twitter_bots.sh

The fields in order are:

- (m) minute
- (h) hour
- (dom) day of month
- (mon) month
- (dow) day of week
- (command) the executable/script to run

An asterisk (\*) in any of these fields indicates that it is true for all values for that field. For example, since I want my job to run every day, I use \* for the day of month, month, and day of week fields.

For more information about the fields in crontab and formats for values, [read the documentation here](https://help.ubuntu.com/community/CronHowto#Crontab_Lines).

## The twitter bots script

The script included in this repo demonstrates how running the bots can be automated.

Let's look at each part of the script and what it does.

### Setting the shell to use

```
#!/bin/bash
```

By default, cron uses the 'sh' shell. I want to use 'bash', so I set that explicitly with this first line.

### Storing the current working directory

```
 DIR=`pwd`
```

In this script, there are commands to change to the bot directories in order to activate the virtual environment and run the bot. In this line, we're storing the current working directory in a local variable called DIR so that we can change back to that directory when our script is complete.

### Sourcing environment variables

```
source $HOME/env
```

Because of [the way that cron works](#cron-env), we have to set the environment variables used by the bots from our script. These variables hold our secret information, such as our database username and password, our bot database name, and our secret keys and tokens used to access twitter. In my example, I've exported these variables in the file called 'env' in my home directory. By sourcing that env file, I am making the environment variables available to this script and my bots.

Note that the \$HOME variable is available in the environment used by cron, so I can refer to it here.

### Setting local variables

In addition to the environment variables used by the bots, this script also sets some local variables that are used by the script itself:

```
LOG="$HOME/projects/python/twitter-bots/logs/cron_bots.log"
TWITTER_BOTS_DIR="$HOME/projects/python/twitter-bots/"
FOLLOWERSBOT_DIR="follower-count/"
CONSCIOUSNESSBOT_DIR="consciousness-bot/"
FRIENDLYBOT_DIR="greetings/"
```

Let's look at each one:

- **LOG** is used to give the location of the log file where all output from the script and the bots will be stored
- **TWITTER_BOTS_DIR** is the directory where my twitter bots are store. This is the parent directory for each of my bot directories
- **FOLLOWERSBOT_DIR** is the subdirectory of the twitter bots directory that contains the files for my followers bot
- **CONSCIOUSNESSBOT_DIR** is the subdirectory of the twitter bots directory that contains the files for my consciousness bot
- **FRIENDLYBOT_DIR** is the subdirectory of the twitter bots directory that contains the files for my friendly bot

If your directories are different, replace the values in this script with the ones that are correct for you.

### Running each bot

In this example script, all three bots provided in this series so far are run, and each one is run the same way. Here's an example:

```
# Run followers bot
# Stores current count of my followers in db
echo "Running followers bot" >>$LOG
echo "---------------------" >>$LOG
cd $TWITTER_BOTS_DIR$FOLLOWERSBOT_DIR
source venv/bin/activate
python follower_count.py 2>&1 >>$LOG
deactivate
```

Let's look at each part.

```
echo "Running followers bot" >>$LOG
echo "---------------------" >>$LOG
```

These two lines print a header to the log file. All output from the bots are logged in a file, so that I can look back at the execution of the bots and the resuls. These header lines aid readability of the log file.

```
cd $TWITTER_BOTS_DIR$FOLLOWERSBOT_DIR
source venv/bin/activate
```

These two lines change to the bot directory, and activate the virtual environment. If you are not using virtual environments, this would not be necessary.

```
python follower_count.py 2>&1 >>$LOG
```

This line executes the bot, redirecting the output to the log file (both standard error and standard out - [you can learn more about output redirection here](https://www.tutorialspoint.com/unix/unix-io-redirections.htm)). Since I'm using a virtual environment, I don't specify the path for the python executable. I want to use the one that is put in the path by the activation of the virtual environment. If I weren't using a virtual environment, I would specify the full path to the python executable to use.

And finally:

```
deactivate
```

This will deactivate the virtual environment for the bot.

You can include lines like this for each bot you want to execute automatically with your script and the cron job.

## Cron and environment variables

If you run your bot manually, any environment variable exported in your profile or rc file will be available for your bot to use (like the variables we use to access the database and Twitter). _When you run something from cron, however, the environment variables exported in your profile and rc files are not available._

The \$HOME variable is available, so we can use that. Any other variable must be explicitly exported. [There are a number of ways to handle this](https://serverfault.com/questions/337631/crontab-execution-doesnt-have-the-same-environment-variables-as-executing-user), and I've chosen to export them from an env file, and source that file from my script.

## Running your cron job

Remember that for cron to run, your system needs to be turned on and online when the cron job is scheduled to run. You can check your log file to see how things go. If there are problems, cron will write to _/var/log/syslog_ by default, so you can check there for errors if it doesn't appear that your cron job is running.

Hopefully with this information, you can figure out how to automate your own bots. Reach out to me on twitter if you have questions @JanelBrandon12.
