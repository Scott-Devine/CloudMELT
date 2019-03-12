#!/bin/bash

# Contrary to the Toil documentation, running these commands appears to break
# Toil/Mesos:

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade
sudo apt-get -y install git
sudo pip install mesos.cli
sudo apt-get install s3cmd

virtualenv --system-site-packages venv
source venv/bin/activate
