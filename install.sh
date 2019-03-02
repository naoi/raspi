#!/bin/bash

# Created by yas 2019/03/01

export SSH_PRIVATE_KEY=''

if [ "x${SSH_PRIVATE_KEY}" = 'x' ]; then
  echo "The variable not specified: 'SSH_PRIVATE_KEY'"
  exit 1
fi

echo
echo 'Updating Raspberry PI...'
sudo apt -y update; sudo apt -y upgrade; sudo apt -y dist-upgrade; sudo apt -y autoremove; sudo apt -y autoclean

echo
echo 'Creating SSH keys...'
mkdir -p ~/.ssh/
echo "${SSH_PRIVATE_KEY}" >> ~/.ssh/authorized_keys
sudo mkdir -p /root/.ssh/
sudo cp ~/.ssh/authorized_keys /root/.ssh/

echo
echo 'Setting up command prompt...'
cat << PS >> '.bashrc'

export txt1='\[\033[38;05;202m\]'  # Red
export txt2='\[\033[38;05;211m\]'  # Pink
export txt3='\[\033[38;05;204m\]'  # Shocking Pink
export txt4='\[\033[00;38m\]'      # White

export txtrst='\[\033[00m\]'       # Reset

# Rose
PS1="${txt1}[${txt2}\$(date +%m/%d) \$(date +%H:%M)${txt1}][${txt3}\u${txt1}@${txt3}\h${txt1}:${txt4}\w${txt1}]${txt4}\$ ${txtrst}"
PS
. ~/.bashrc

echo
echo 'Setting up /boot/config.txt...'
sudo rm -fr /tmp/config.txt; sudo cat /boot/config.txt > /tmp/config.txt; echo 'avoid_warnings=2' >> /tmp/config.txt; sudo cp /tmp/config.txt /boot/
export TMP=$(cat /boot/cmdline.txt); export TMP="${TMP} logo.nologo"; echo ${TMP} > /tmp/cmdline.txt; sudo cp /tmp/cmdline.txt /boot/

echo
echo 'Setting up /etc/crontab...'
sudo rm -fr /tmp/crontab; sudo cat /etc/crontab > /tmp/crontab; sudo echo "0 0 * * * root sudo apt -y update; sudo apt -y upgrade; sudo apt -y dist-upgrade; sudo apt -y autoremove; sudo apt -y autoclean" >> /tmp/crontab; sudo cp /tmp/crontab /etc/

echo
echo 'Setting up /etc/environment (LC_ALL, LANG)...'
sudo rm -fr /etc/environment
echo 'LC_ALL=en_US.UTF-8' > /tmp/environment
echo 'LANG=en_US.UTF-8'>> /tmp/environment
sudo cp /tmp/environment /etc/

echo
echo 'Setting up /etc/issue...'
sudo cat << ISSUE > '/tmp/issue'
Raspbian GNU/Linux 9
\s \m \r \v
\d \t

\n (\l): \4{wlan0}

ISSUE
sudo cp /tmp/issue /etc/
