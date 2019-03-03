#!/bin/bash

# Updated by yas 2019/03/02
# Created by yas 2019/03/01

echo
echo -n 'Checking environment variables... '

if [ "x${SSH_PRIVATE_KEY:-}" = 'x' ]; then
  echo
  echo "The variable not specified: 'SSH_PRIVATE_KEY'"
  exit 1
fi

if [ "x${LOCALE:-}" = 'x' ]; then
  echo
  echo "The variable not specified: 'LOCALE' (e.g. LOCALE='en_US.UTF-8')"
  exit 1
fi

if [ "x${TIMEZONE:-}" = 'x' ]; then
  echo
  echo "The variable not specified: 'TIMEZONE' (e.g. TIMEZONE='America/Los_Angeles')"
  exit 1
fi

echo 'Done'
echo

echo 'Updating Raspberry PI... '
echo
sudo apt -y update && sudo apt -y upgrade && sudo apt -y dist-upgrade && sudo apt -y autoremove && sudo apt -y autoclean

echo -n 'Enabling sshd service... '
sudo touch /tmp/ssh
sudo cp /tmp/ssh /boot/

echo 'Done'
echo

echo -n "Creating SSH keys ('~/.ssh/authorized_keys' and '/root/.ssh/authorized_keys')... "
if [ ! -e ~/.ssh ]; then
  mkdir -p ~/.ssh
fi
cat << SSH_PRIVATE_KEY >> ~/.ssh/authorized_keys
${SSH_PRIVATE_KEY}
SSH_PRIVATE_KEY

if [ ! -e /root/.ssh ]; then
  sudo mkdir -p /root/.ssh
fi
sudo mkdir -p /root/.ssh/
sudo cp ~/.ssh/authorized_keys /root/.ssh/

echo 'Done'
echo

echo -n "Setting up the command prompt ('~/.bashrc')... "
cat << 'PS' >> ~/.bashrc

export txt1='\[\033[38;05;202m\]'  # Red
export txt2='\[\033[38;05;211m\]'  # Pink
export txt3='\[\033[38;05;204m\]'  # Shocking Pink
export txt4='\[\033[00;38m\]'      # White

export txtrst='\[\033[00m\]'       # Reset

# Rose
PS1="${txt1}[${txt2}\$(date +%m/%d) \$(date +%H:%M)${txt1}][${txt3}\u${txt1}@${txt3}\h${txt1}:${txt4}\w${txt1}]${txt4}\$ ${txtrst}"
PS
. ~/.bashrc

echo 'Done'
echo

echo -n 'Setting up /boot/config.txt... '
sudo rm -fr /tmp/config.txt
sudo cat /boot/config.txt > /tmp/config.txt
echo 'avoid_warnings=2' >> /tmp/config.txt
sudo cp /tmp/config.txt /boot/
export TMP=$(cat /boot/cmdline.txt); export TMP="${TMP} logo.nologo"; echo ${TMP} > /tmp/cmdline.txt; sudo cp /tmp/cmdline.txt /boot/

echo 'Done'
echo

echo -n 'Setting up /etc/crontab... '
sudo rm -fr /tmp/crontab
sudo cat /etc/crontab > /tmp/crontab
sudo echo "0 0 * * * root sudo apt -y update && sudo apt -y upgrade && sudo apt -y dist-upgrade && sudo apt -y autoremove && sudo apt -y autoclean" >> /tmp/crontab
sudo cp /tmp/crontab /etc/

echo 'Done'
echo

echo "Setting up /etc/local.gen ('${LOCALE}')..."
if [ "x${LOCALE}" != 'xen_GB.UTF-8' ]; then
  sudo sed -i -e 's/en_GB.UTF-8 UTF-8/# en_GB.UTF-8 UTF-8/g' /etc/locale.gen
  sudo sed -i -e "s/# ${LOCALE} UTF-8/${LOCALE} UTF-8/g" /etc/locale.gen
  sudo locale-gen ${LOCALE}
  sudo update-locale ${LOCALE}
fi

echo -n "Setting up /etc/environment ('LC_ALL' and 'LANG')... "
sudo rm -fr /etc/environment
echo "LC_ALL=${LOCALE}" > /tmp/environment
echo "LANG=${LOCALE}">> /tmp/environment
sudo cp /tmp/environment /etc/

echo 'Done'
echo

echo -n "Setting up /etc/localtime ('${TIMEZONE}')... "
sudo rm /etc/localtime
sudo ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

echo 'Done'
echo

echo -n 'Setting up /etc/issue and /etc/issue.net... '
sudo cat << 'ISSUE' > /tmp/issue
Raspbian GNU/Linux 9
\s \m \r \v
\d \t

\n (\l): \4{wlan0}

ISSUE
sudo cp /tmp/issue /etc/
sudo cp /tmp/issue /etc/issue.net

echo 'Done'
echo

echo 'Done: Raspberry PI Installation'
echo