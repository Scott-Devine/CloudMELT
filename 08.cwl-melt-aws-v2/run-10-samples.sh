#!/bin/bash

#export RUNNER='toil-cwl-runner --retryCount 0'
export RUNNER='toil-cwl-runner --retryCount 0 --logLevel DEBUG'

# Mac OS X - specific workaround for Docker tasks
#export TMPDIR="/private${TMPDIR}"

# --------------------------------------------
# Test on AWS with mesos
# LINE1, ALU for 10 samples
# t2.medium (0.0464), i3.large (0.156) 
# combined cost = 0.2024/hour
# --------------------------------------------

#NA12829, NA12830, NA12842, NA12843, NA12872, NA12873, NA12874, NA12878, NA12889, NA12890 

# -----
# coverage - pre - ind
# -----

# single i3.large static
# real308m45.384s
# user2m1.456s
# sys0m16.607s

# 416M of output files
# 250GB unreclaimed on worker node

#for SAMPLE in NA12829 NA12830 NA12842 NA12843 NA12872 NA12873 NA12874 NA12878 NA12889 NA12890
#do
#  time $RUNNER \
#   --jobStore aws:us-east-1:toil-tjs1 \
#   --logFile melt-split-step-1.log \
#   --batchSystem mesos \
#  melt-split-step-1.cwl 10-samples-config/step-1-$SAMPLE.yml
#done
#exit

# -----
# group - LINE1
# -----

# all LINE1 files:
#perl -ne 'chomp; print " - { class: File, path: /toil/$_ }\n" if /LINE1/;' < step-1-files.txt

# aligned files only:
#perl -ne 'chomp; print " - { class: File, path: /toil/$_ }\n" if /LINE1/ && /final/ && /\.bam$/;' < step-1-files.txt

# real4m18.881s
# user0m5.147s
# sys0m0.830s

#time $RUNNER \
# --jobStore aws:us-east-1:toil-tjs1 \
# --logFile melt-split-step-2-LINE1.log \
# --batchSystem mesos \
#melt-split-step-2.cwl 10-samples-config/step-2-LINE.yml

# -----
# group - ALU
# -----

#real9m34.602s
#user0m7.111s
#sys0m1.168s

#time $RUNNER \
# --jobStore aws:us-east-1:toil-tjs1 \
# --logFile melt-split-step-2-ALU.log \
# --batchSystem mesos \
#melt-split-step-2.cwl 10-samples-config/step-2-ALU.yml
#exit

# -----
# gen
# -----

# first 3 only:
# real25m53.157s
# user0m19.676s
# sys0m3.054s

# last 7:
#
# real66m40.485s
# user0m37.103s
# sys0m4.644s

#for SAMPLE in NA12829 NA12830 NA12842 NA12843 NA12872 NA12873 NA12874 NA12878 NA12889 NA12890
#do
#  time $RUNNER \
#   --jobStore aws:us-east-1:toil-tjs1 \
#   --logFile melt-split-step-3-$SAMPLE.log \
#   --batchSystem mesos \
#   melt-split-step-3.cwl 10-samples-config/step-3-$SAMPLE.yml
#done

# -----
# vcf - LINE1
# -----

#real0m24.310s
#user0m2.374s
#sys0m0.334s

time $RUNNER \
 --jobStore aws:us-east-1:toil-tjs1 \
 --logFile melt-split-step-4-LINE.log \
 --batchSystem mesos \
 melt-split-step-4.cwl 10-samples-config/step-4-LINE.yml
exit

# -----
# vcf - ALU
# -----

#real0m27.013s
#user0m2.485s
#sys0m0.339s

#time $RUNNER \
# --jobStore aws:us-east-1:toil-tjs1 \
# --logFile melt-split-step-4-ALU.log \
# --batchSystem mesos \
#melt-split-step-4.cwl 10-samples-config/step-4-ALU.yml

