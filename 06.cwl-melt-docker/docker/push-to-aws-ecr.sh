#!/bin/bash

#(aws ecr get-login --no-include-email --region us-east-1)
#  -> returns docker login command to run

docker build -t umigs/melt .
docker tag umigs/melt:latest 205226202704.dkr.ecr.us-east-1.amazonaws.com/umigs/melt:latest
docker push 205226202704.dkr.ecr.us-east-1.amazonaws.com/umigs/melt:latest

