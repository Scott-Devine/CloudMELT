#!/bin/bash

#export TOIL_DOCKER_NAME=toil
#export TOIL_DOCKER_REGISTRY=docker.io/umigs
#export TOIL_APPLIANCE_SELF=docker.io/umigs/toil-custom:1.0.0

export RUNNER='toil-cwl-runner --retryCount 0'
#export RUNNER='toil-cwl-runner --retryCount 0 --logLevel DEBUG'

# Mac OS X - specific workaround for Docker tasks
#export TMPDIR="/private${TMPDIR}"

# 10 samples, end-to-end: (1 i3.large/2 proc)
#real294m16.598s
#user1m40.222s
#sys0m16.510s
# avg time per sample - ~29 min  (~49 samples/day/node)
# cost per sample - ~9.9 cents

# 10 samples end-to-end, no mosdepth (1 i3.large/2 proc)
#real268m51.326s
#user1m37.430s
#sys0m16.463s
# avg time per sample - ~27 min (~53 samples/day/node)
# cost per sample - ~9.1 cents

# 10 samples end-to-end, no mosdepth (1 i3.xlarge/4 proc)
#real145m20.091s
#user1m2.646s
#sys0m12.307s
# avg time per sample - ~14.5 min (~99 samples/day/node)
# cost per sample - ~8.7 cents

# 10 samples end-to-end, no mosdepth (2 i3.xlarge/4 proc)
# real91m47.099s
# user0m52.085s
# sys0m9.782s
# avg time per sample - ~9.16m (~157 samples/day/node)
# cost per sample - ~10.2 cents

# 10 samples end-to-end, no mosdepth (1 i3.2xlarge/8 proc)
# real88m36.185s
# user1m0.339s
# sys0m12.249s
# avg time per sample - ~8.9m (~162 samples/day/node)
# cost per sample - ~9.9 cents

# --------------------------------------------
# Test on AWS with mesos
# LINE1, ALU for 10 samples
# t2.medium (0.0464), i3.large (0.156) 
# combined cost = 0.2024/hour
# --------------------------------------------

#toil launch-cluster tcm1 --leaderNodeType t2.medium --zone us-east-1a --keyPairName kp1 --nodeTypes i3.large -w 1
#oaws ecr get-login --region us-east-1 --no-include-email

# --------------------------------------------
# Test on AWS with mesos
# LINE1, ALU for 10 samples
# t2.medium (0.0464), 2 i3.xlarge (0.312 x 2)
# combined cost = 0.6704/hour
# --------------------------------------------

#toil launch-cluster tcm1 --leaderNodeType t2.medium --zone us-east-1a --keyPairName kp1 --nodeTypes i3.xlarge -w 2
# on local machine:
#  aws ecr get-login --region us-east-1 --no-include-email
# run resulting command on cluster
#  toil ssh-cluster -z us-east-1a tcm1
#  docker login ....
# copy config.json file to worker nodes
# toil rsync-cluster -z us-east-1a tcm1 :/root/.docker/config.json ./
# scp config.json core@worker1:
# scp config.json core@worker2:

# on each worker (as core user):
#scp setup-worker-nodes.sh core@worker1:
#ssh core@worker1 './setup-worker-node.sh' 

#scp setup-worker-nodes.sh core@worker2:
#ssh core@worker2 './setup-worker-node.sh' 

# step 1:
#real60m48.493s
#user0m25.360s
#sys0m4.925s

# step 2:
#real10m33.061s
#user0m11.049s
#sys0m2.116s

# step 3:
#real19m51.015s
#user0m10.657s
#sys0m1.744s

# step 4:
#real0m34.527s
#user0m5.018s
#sys0m0.995s

# total:
#real91m47.099s
#user0m52.085s
#sys0m9.782s

# --------------------------------------------
# Test on AWS with mesos
# LINE1, ALU for 10 samples
# t2.medium (0.0464), i3.xlarge (0.312) 
# combined cost = 0.3584/hour
# --------------------------------------------

#toil launch-cluster tcm1 --leaderNodeType t2.medium --zone us-east-1a --keyPairName kp1 --nodeTypes i3.xlarge -w 1

# --------------------------------------------
# Test on AWS with mesos
# LINE1, ALU for 10 samples
# t2.medium (0.0464), i3.2xlarge (0.624) 
# combined cost = 0.6704/hour
# --------------------------------------------

#toil launch-cluster tcm1 --leaderNodeType t2.medium --zone us-east-1a --keyPairName kp1 --nodeTypes i3.2xlarge -w 1

# --------------------------------------------
# setup
# --------------------------------------------

# run docker login on leaderNode
# distribute /root/.docker/config.json to workers

#tar czvf test.tar.gz *.cwl *.yml run-10-samples.sh 10-samples-config.out
#toil rsync-cluster -z us-east-1a tcm1 test.tar.gz :/root/

# --------------------------------------------
# coverage - pre - ind
# --------------------------------------------

# 2 samples:
#real39m34.755s
#user0m15.877s
#sys0m2.850s

# step-1-pre.yml - config file minus the reads_bam_uri
# sample-uris.txt - list of URIs to feed to reads_bam_uri
# 10-samples-config.out/ - location for autogenerated config files
#
#./make-config-files.pl \
#  10-samples-config.in/step-1-pre.yml \
#  10-samples-config.in/step-2-grp.yml \
#  10-samples-config.in/step-3-gen.yml \
#  10-samples-config.in/step-4-vcf.yml \
#  10-samples-config.in/sample_uris.txt \
#  10-samples-config.out/

# 1 sample only:
#./make-config-files.pl \
#  10-samples-config.in/step-1-pre.yml \
#  10-samples-config.in/step-2-grp.yml \
#  10-samples-config.in/step-3-gen.yml \
#  10-samples-config.in/step-4-vcf.yml \
#  10-samples-config.in/sample_uris_1.txt \
#  10-samples-config.out/

time $RUNNER \
  --jobStore aws:us-east-1:toil-tjs1 \
  --logFile melt-split-step-1.log \
  --batchSystem mesos \
melt-split-step-1.cwl 10-samples-config.out/step-1.yml 2> melt-step-times.log

# --------------------------------------------
# group - LINE1, ALU etc.
# --------------------------------------------

#real4m59.087s
#user0m6.503s
#sys0m1.297s

time $RUNNER \
 --jobStore aws:us-east-1:toil-tjs1 \
 --logFile melt-split-step-2.log \
 --batchSystem mesos \
melt-split-step-2.cwl 10-samples-config.out/step-2.yml 2> melt-step-times.log

# --------------------------------------------
# gen
# --------------------------------------------

# 2 samples
#real9m40.937s
#user0m7.121s
#sys0m1.312s

time $RUNNER \
 --jobStore aws:us-east-1:toil-tjs1 \
 --logFile melt-split-step-3.log \
 --batchSystem mesos \
melt-split-step-3.cwl 10-samples-config.out/step-3.yml 2> melt-step-times.log

# --------------------------------------------
# vcf
# --------------------------------------------

# 2 samples:
#real0m35.841s
#user0m4.922s
#sys0m0.980s

time $RUNNER \
 --jobStore aws:us-east-1:toil-tjs1 \
 --logFile melt-split-step-4.log \
 --batchSystem mesos \
 melt-split-step-4.cwl 10-samples-config.out/step-4.yml 2> melt-step-times.log



