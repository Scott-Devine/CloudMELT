#!/bin/bash

#(aws ecr get-login --no-include-email --region us-east-1)
#  -> returns docker login command to run

# <aws_ecr_host> = AWS private Elastic Container Registry host
docker tag umigs/cloud-melt-hg38-v1.0.1:latest <aws_ecr_host>.us-east-1.amazonaws.com/umigs/melt:hg38-latest
docker push <aws_ecr_host>.us-east-1.amazonaws.com/umigs/melt:hg38-latest

