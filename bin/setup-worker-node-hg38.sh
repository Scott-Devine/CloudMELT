#!/bin/bash
sudo mkdir /mnt/ephemeral/tmp
sudo ln -s /mnt/ephemeral/tmp /root/
sudo mkdir /root/.docker
sudo cp config.json /root/.docker/
mkdir .docker
mv config.json .docker/
# replace with your own Elastic Container Registry:
docker pull 205226202704.dkr.ecr.us-east-1.amazonaws.com/umigs/melt:hg38-latest
