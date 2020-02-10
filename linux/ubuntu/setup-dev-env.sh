#!/bin/bash
# ubuntu 18.04 LTS
# Setting up a development environment
# root demand
if [ `whoami` != "root" ];then
  echo 'Permission Denied! Please use the administrator to execute it.'
  exit
fi
# Resource url list
chromeURL=https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
vscodeURL=https://update.code.visualstudio.com/latest/linux-deb-x64/stable

# Resource download location
srcDir=download

echo '## Downloading Google Chrome deb'
wget -P $srcDir $chromeURL
echo '## Installing Google Chrome'
dpkg -i "$srcDir/`basename $chromeURL`"

echo '## Downloading VSCode deb'
vscodeURL=`curl -s $vscodeURL | grep -Po http.*?deb`
wget -P $srcDir $vscodeURL
echo '## Installing VSCode'
dpkg -i "$srcDir/`basename $vscodeURL`"

echo '## Installing Typora'
wget -qO - https://typora.io/linux/public-key.asc | apt-key add -
add-apt-repository 'deb https://typora.io/linux ./'
apt update
apt install -y typora

echo '## Installing Git'
echo | apt-add-repository ppa:git-core/ppa
apt update
apt install -y git
echo '## Configuring Git'
read -p 'Input git user.name: ' username
git config --global user.name $username
read -p 'Input git user.email: ' email
git config --global user.email $email
git config --global credential.helper store

echo '## Add Node.js 12.x LTS Release PPA'
curl -sL https://deb.nodesource.com/setup_12.x | bash -
echo '## Installing Node.js 12.x'
apt install -y nodejs

echo '## Install MongoDB Community Edition'
wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | apt-key add -
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.2.list
apt update
apt install -y mongodb-org
echo '## Start MongoDB'
systemctl start mongod
systemctl enable mongod