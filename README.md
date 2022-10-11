# Screenshot Uploader

This installs a MacOS launchtl daemon that watches a folder for new screenshots to arrive and then uploads them to AWS S3.

## Installation

### Install Shottr

Download Shottr and install it.

[![Shottr Screenshot App](https://kyn.ac/SCR-20221011-kzs.png)](https://shottr.cc/)

### Install the uploader

```shell
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/MindgymAcademy/kyna-screenshots-uploader/HEAD/install.sh)"
```

This will ask for your computer's password, AWS credentials, and the AWS bucket to upload to. Here at Kyna,
we upload to a bucket called `kyna.ac`.

### Configure Shottr

Configure Shottr to:

- Save screenshots in Documents/screenshots (this should be created by the uploader installer)
- Launch at Startup (recommended)
- Show the editor when a screenshot was made (recommended)

[![](https://kyn.ac/SCR-20221011-l1b.png)](https://kyn.ac/SCR-20221011-l1b.png)

In the Advanced section, turn off the confirmation notifications for the smoothest experience with the upload tool.

[![](https://kyn.ac/SCR-20221011-l8y.png)](https://kyn.ac/SCR-20221011-l8y.png)

### Try it out

Now, press <kbd>⌘</kbd> + <kbd>⇧</kbd> + <kbd>2</kbd> and take a screenshot. Make sure there's no sensitive content on
it (you can blur!), and press save. You should get a notification when your upload is done, and the URL to the image should
be copied to your clipboard. You can paste it directly into Slack, your tutorials, etc.

[![](https://kyn.ac/SCR-20221011-l7m.png)](https://kyn.ac/SCR-20221011-l7m.png)
