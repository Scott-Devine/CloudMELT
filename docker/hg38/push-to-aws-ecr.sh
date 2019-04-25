#!/bin/bash

#(aws ecr get-login --no-include-email --region us-east-1)
#  -> returns docker login command to run

docker tag umigs/cloud-melt-hg38-v1.0.0:latest 205226202704.dkr.ecr.us-east-1.amazonaws.com/umigs/melt:hg38-latest
docker push 205226202704.dkr.ecr.us-east-1.amazonaws.com/umigs/melt:hg38-latest
