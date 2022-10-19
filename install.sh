#!/bin/bash

SUDO=''
if (( $EUID != 0 )); then
    SUDO='/usr/bin/sudo'
fi

echo "Installing dependencies..."

if [ ! -f /usr/local/bin/python3 ]
then
  if (which brew)
  then
    echo "Great, you have Homebrew installed, continuing to install python3..."
    brew install -q python
  else
    echo "You need Homebrew installed for this to work. Please visit https://brew.sh to install it."
    exit 1
  fi
fi

/usr/local/bin/pip3 install watchdog boto3

echo "Creating screenshots directory..."
/bin/mkdir -p $HOME/Documents/screenshots

echo "Setting up AWS authentication profile..."
/bin/mkdir -p $HOME/.aws
/usr/bin/touch $HOME/.aws/credentials
/usr/bin/touch $HOME/.aws/config

if /usr/bin/grep -Fq "[kyna-screenshots]" "$HOME/.aws/credentials"
then
  echo "AWS profile already exists, skipping."
else
  echo
  echo "You need to be authenticated to upload the screenshots.
    If you are not sure what to answer to these questions,
    please ask your colleagues on Slack."
  echo
  echo "What is your AWS ACCESS_KEY_ID? (just paste it):"
  read access_key_id
  echo
  echo "What is your AWS SECRET_ACCESS_KEY? (just paste it):"
  read secret_access_key
  echo "
[kyna-screenshots]
aws_access_key_id = $access_key_id
aws_secret_access_key = $secret_access_key
" >> $HOME/.aws/credentials
fi

if /usr/bin/grep -Fq "[kyna-screenshots]" "$HOME/.aws/config"
then
  echo "AWS config already exists, skipping."
else
  echo "Configuring AWS region..."
  echo "

[kyna-screenshots]
region=eu-central-1
" >> $HOME/.aws/config
fi

echo
echo "To which bucket do you want to upload?"
read bucket_name

daemon_dir="/usr/local/kyna-screenshots/bin"
daemon_file="kyna-screenshot-uploader"

echo
echo "Installing uploader..."
echo "NOTE: This may ask for your computer password"

if [ -f /tmp/$daemon_file ]
then
  /bin/rm /tmp/$daemon_file
fi
/usr/bin/curl --silent -o /tmp/$daemon_file https://raw.githubusercontent.com/MindgymAcademy/kyna-screenshots-uploader/HEAD/upload-screenshots > /dev/null

$SUDO /bin/mkdir -p $daemon_dir
$SUDO /bin/cp /tmp/$daemon_file $daemon_dir/$daemon_file

if [ -f /usr/local/bin/$daemon_file ]
then
  $SUDO /bin/rm /usr/local/bin/$daemon_file
fi

$SUDO /bin/ln -s $daemon_dir/$daemon_file /usr/local/bin

echo
echo "Installing launchd plist..."

/bin/mkdir -p $HOME/Library/LaunchAgents

if [ -f $HOME/Library/LaunchAgents/ac.kyna.screenshots.plist ]
then
  /bin/launchctl stop ac.kyna.screenshots
  /bin/launchctl unload $HOME/Library/LaunchAgents/ac.kyna.screenshots.plist
fi

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>Label</key>
    <string>ac.kyna.screenshots</string>
    <key>ProgramArguments</key>
    <array>
        <string>$daemon_dir/$daemon_file</string>
        <string>$bucket_name</string>
    </array>
    <key>StandardOutPath</key>
    <string>/tmp/ac.kyna.screenshots.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/ac.kyna.screenshots.log</string>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
" > $HOME/Library/LaunchAgents/ac.kyna.screenshots.plist

/bin/launchctl load -w $HOME/Library/LaunchAgents/ac.kyna.screenshots.plist

if (ps aux | grep $daemon_file | grep "$bucket_name")
then
  echo "Screen shot uploader installed to LaunchAgents."
  echo "
  ******************************************************
  * Step 1. Download Shottr from https://shottr.cc/    *
  * Step 2. Set Shottr's Screenshots folder to save to *
  *         ~/Documents/screenshots                    *
  *         And After Screenshot to Show + Show Editor *
  * Step 3. Make a screenshot (⌘+⇧+2), annotate it,    *
  *         save it. The URL should be copied and you  *
  *         can paste it in Slack, course materials,   *
  *         etc! Have fun and make sure to not upload  *
  *         sensitive information (you can blur!)      *
  ******************************************************

  Thank you for installing the uploader!
  "
else
  echo "Something went wrong and the uploader did not start properly. Please check: the logfile:"
  echo
  /bin/cat /tmp/ac.kyna.screenshots.log
  echo
  echo "If that does not help you, please open an issue here: https://github.com/MindgymAcademy/kyna-screenshots-uploader/issues"
  echo
  echo "Thank you!"
  exit 1
fi
