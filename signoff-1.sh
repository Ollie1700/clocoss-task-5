#!/bin/bash

N=$1;

if [ -z "$N" ]
then
        echo "Please provide a number as a parameter."
        exit;
fi

if ! [[ "$N" =~ ^[0-9]+$ ]]
then
        echo "The provided parameter must be an integer";
        exit;
fi

secretKey=`openssl rand -base64 32`;
workerName="ollie-worker-bee";

echo "Installing dependencies...";
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - > /dev/null 2>&1;
sudo apt-get -qq install nodejs > /dev/null 2>&1;
sudo apt-get -qq install git > /dev/null 2>&1;
echo "Dependencies installed!";

echo "Cloning master worker...";
git clone https://github.com/portsoc/clocoss-master-worker > /dev/null 2>&1;
cd clocoss-master-worker;
echo "Installing master worker...";
npm install --silent > /dev/null 2>&1;

gcloud config set compute/zone europe-west1-c;

echo "Creating $N instance(s) in the background...";

for i in `seq 1 $N`;
do
        gcloud compute instances create "$workerName"-"$i" \
        --machine-type f1-micro \
        --tags http-server,https-server \
        --metadata secret=$secretKey,serverip=`curl -s -H "Metadata-Flavor: Google" \
                                               "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip"` \
        --metadata-from-file \
          startup-script=../worker-bee-startup-script.sh \
        --quiet > /dev/null 2>&1 &
done;

echo "Starting server... (remember that VMs are being generated in the background, please wait a few minutes before expecting results)";
npm run server $secretKey;

echo "Removing server code...";
cd ..;
sudo rm clocoss-master-worker -r;
echo "Server removed!";

echo "Killing workers...";
for i in `seq 1 $N`;
do
        gcloud compute instances delete "$workerName"-"$i" --quiet;
done;

echo "All workers have been terminated!";
echo "Work complete!";
echo "Script by UP690316.";
