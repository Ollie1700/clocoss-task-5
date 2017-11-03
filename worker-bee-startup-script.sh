#!/bin/bash
logfile=$$.log;
exec > $logfile 2>&1;

echo "Installing dependencies...";
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -;
sudo apt-get install -y nodejs;
sudo apt-get install -y git;

NODE_V=`node -v`;
NPM_V=`npm -v`;
GIT_V=`git --version`;

echo "Node installed: $NODE_V";
echo "NPM installed: $NPM_V";
echo "GIT installed: $GIT_V";

echo "Downloading client code...";

git clone https://github.com/portsoc/clocoss-master-worker;
cd clocoss-master-worker;
npm install;

echo "Client code downloaded!";

echo "Getting server params...";

secretKey=`curl -s -H "Metadata-Flavor: Google"  \
           "http://metadata.google.internal/computeMetadata/v1/instance/attributes/secret"`;
serverip=`curl -s -H "Metadata-Flavor: Google"  \
   "http://metadata.google.internal/computeMetadata/v1/instance/attributes/serverip"`;

echo "Secret key: $secretKey";
echo "Server IP: $serverip";

echo "Starting worker...";
npm run client $secretKey $serverip:8080;
