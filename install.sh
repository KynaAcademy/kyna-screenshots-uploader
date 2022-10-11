#!/bin/bash

SUDO=''
if (( $EUID != 0 )); then
    SUDO='sudo'
fi

echo "Installing dependencies..."
pip3 install -q watchdog boto3

echo "Creating screenshots directory..."
mkdir -p $HOME/Documents/screenshots

echo "Setting up AWS authentication profile..."
mkdir -p $HOME/.aws
touch $HOME/.aws/credentials
touch $HOME/.aws/config

if grep -Fq "[kyna-screenshots]" "$HOME/.aws/credentials"
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

if grep -Fq "[kyna-screenshots]" "$HOME/.aws/config"
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
curl -o /tmp/$daemon_file https://raw.githubusercontent.com/MindgymAcademy/kyna-screenshots-uploader/HEAD/upload-screenshots
$SUDO mkdir -p $daemon_dir
$SUDO cp /tmp/$daemon_file $daemon_dir/$daemon_file

if [ -f /usr/local/bin/$daemon_file ]
then
  $SUDO rm /usr/local/bin/$daemon_file
fi

$SUDO ln -s $daemon_dir/$daemon_file /usr/local/bin

echo
echo "Installing launchd plist..."

mkdir -p $HOME/Library/LaunchAgents

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

launchctl load $HOME/Library/LaunchAgents/ac.kyna.screenshots.plist

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
"
