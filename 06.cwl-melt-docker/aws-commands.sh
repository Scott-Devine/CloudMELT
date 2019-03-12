#!/bin/bash

# no need to override defaults:
#export TOIL_DOCKER_REGISTRY=quay.io/ucsc_cgl
#export TOIL_DOCKER_NAME=toil
#export TOIL_APPLIANCE_SELF=quay.io/ucsc_cgl/toil:3.18.0 

# t2.medium - 2 vCPU, 4GiB mem, EBS only, $0.0464/hour
# t2.xlarge - 4 vCPU, 16GiB, EBS only, $0.1856/hour
# m5d.large - 2 vCPU, 8 GiB RAM, 75 SSD, $0.113/hour
# m5d.xlarge - 4 vCPU, 16GiB RAM, 150 SSD, 0.226/hour  - The specified instance type can only be used in a VPC

# on personal account:
#  aws configure
#  set ~/.boto
#  ssh-add ~/.ssh/kp2.pem
#toil launch-cluster tc1 --vpcSubnet subnet-05f89e33c58ec0cc5 --leaderNodeType t2.medium --zone us-east-1a --keyPairName kp2

# on umigs-melt account:
#  aws configure
#  set ~/.boto
#  ssh-add ~/.ssh/igsjonathancrabtreekp1.pem
toil launch-cluster tcm1 --leaderNodeType t2.medium --zone us-east-1a --keyPairName kp1

# connect to cluster
toil ssh-cluster -z us-east-1a tcm1

# tear down cluster
toil destroy-cluster -z us-east-1a tcm1

# Upload workflow files
# mosdepth test workflow
tar czvf mosdepth-wf.tar.gz mosdepth.cwl run-mosdepth.sh NA12878.chr22.chrX/mosdepth.yml
toil rsync-cluster -z us-east-1a tcm1 mosdepth-wf.tar.gz :/root/

# MELT-Deletion test
tar czvf melt-del-wf.tar.gz melt-del*.cwl run-NA12878.chr22.chrX.sh NA12878.chr22.chrX/melt-del*.yml
toil rsync-cluster -z us-east-1a tcm1 melt-del-wf.tar.gz :/root/

# Docker/ECR

# list ECR repos
#  aws ecr describe-repositories
#  aws ecr describe-images --repository-name umigs/melt

# get ECR login token
#  aws ecr get-login --region us-east-1 --no-include-email
#  -paste command into toil leader node

# retrieve MELT image
#  docker pull 091045347386.dkr.ecr.us-east-1.amazonaws.com/umigs/melt/umigs/melt

