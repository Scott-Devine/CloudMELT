#!/bin/bash
sudo mkdir /mnt/ephemeral/tmp
sudo ln -s /mnt/ephemeral/tmp /root/
sudo mkdir /root/.docker
sudo cp config.json /root/.docker/
mkdir .docker
mv config.json .docker/
# <aws_ecr_host> = AWS private Elastic Container Registry host
docker pull <aws_ecr_host>.us-east-1.amazonaws.com/umigs/melt:hg38-latest
