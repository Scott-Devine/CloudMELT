#!/bin/bash

#export RUNNER='toil-cwl-runner --retryCount 0'
export RUNNER='toil-cwl-runner --retryCount 0 --logLevel DEBUG'

# Mac OS X - specific workaround for Docker tasks
#export TMPDIR="/private${TMPDIR}"

# --------------------------------------------
# test locally on toil Docker image
# NA12878 chr22 subset LINE1, ALU
# --------------------------------------------

# coverage - pre -ind
#time $RUNNER --logLevel DEBUG melt-split-step-1.cwl config/melt-split-step-1.yml

# group
#time $RUNNER --logLevel DEBUG melt-split-step-2.cwl config/melt-split-step-2.yml
#time $RUNNER --logLevel DEBUG melt-split-step-2.cwl config/melt-split-step-2-alu.yml

# gen
#time $RUNNER --logLevel DEBUG melt-split-step-3.cwl config/melt-split-step-3.yml

# vcf
#time $RUNNER --logLevel DEBUG melt-split-step-4.cwl config/melt-split-step-4.yml
#time $RUNNER --logLevel DEBUG melt-split-step-4.cwl config/melt-split-step-4-alu.yml

# --------------------------------------------
# test on AWS with mesos
# NA12878 chr22 subset LINE1, ALU
# --------------------------------------------

# -----
# coverage - pre -ind
# -----
# real1m23.770s
# user0m2.723s
# sys0m0.364s
#time $RUNNER \
# --jobStore aws:us-east-1:toil-tjs1 \
# --logFile melt-split-step-1.log \
# --batchSystem mesos \
#melt-split-step-1.cwl config/melt-split-step-1.yml

# -----
# group - LINE1
# -----
# real0m26.630s
# user0m2.339s
# sys0m0.326s
#time $RUNNER \
# --jobStore aws:us-east-1:toil-tjs1 \
# --logFile melt-split-step-2.log \
# --batchSystem mesos \
#melt-split-step-2.cwl config/melt-split-step-2.yml

# -----
# group - ALU
# -----
# real0m31.280s
# user0m2.408s
# sys0m0.337s
#time $RUNNER \
# --jobStore aws:us-east-1:toil-tjs1 \
# --logFile melt-split-step-2.log \
# --batchSystem mesos \
#melt-split-step-2.cwl config/melt-split-step-2-alu.yml

# -----
# gen
# -----
# real0m34.231s
# user0m2.375s
# sys0m0.308s
#time $RUNNER \
# --jobStore aws:us-east-1:toil-tjs1 \
# --logFile melt-split-step-3.log \
# --batchSystem mesos \
# melt-split-step-3.cwl config/melt-split-step-3.yml

# -----
# vcf - LINE1
# -----
# real0m22.728s
# user0m2.248s
# sys0m0.320s
#time $RUNNER \
# --jobStore aws:us-east-1:toil-tjs1 \
# --logFile melt-split-step-4.log \
# --batchSystem mesos \
# melt-split-step-4.cwl config/melt-split-step-4.yml

# -----
# vcf - ALU
# -----
# real0m24.516s
# user0m2.282s
# sys0m0.300s
#time $RUNNER \
# --jobStore aws:us-east-1:toil-tjs1 \
# --logFile melt-split-step-4.log \
# --batchSystem mesos \
#melt-split-step-4.cwl config/melt-split-step-4-alu.yml

# total time =~ 3:43

# --------------------------------------------
# test on AWS with mesos
# NA12878 entire LINE1, ALU, SVA
# --------------------------------------------

# -----
# coverage - pre -ind
# -----
# real47m42.116s
# user0m16.756s
# sys0m2.153s
# - produced 25MB of files
# mkdir step-1-files
# mv NA12878* step-1-files/
# perl -pi.bak -e 's#\.\.\/NA12878\.chr22#../step-1-files/NA12878.mapped.ILLUMINA.bwa.CEU.low_coverage.20121211#;' *-step-2*.yml
# perl -pi.bak -e 's#NA12878\.chr22#NA12878.mapped.ILLUMINA.bwa.CEU.low_coverage.20121211#;' *-step-2*.yml

#time $RUNNER \
# --jobStore aws:us-east-1:toil-tjs1 \
# --logFile melt-split-step-1.log \
# --batchSystem mesos \
#melt-split-step-1.cwl NA12878-config/melt-split-step-1.yml

# -----
# group - LINE1
# -----

#real1m19.240s
#user0m2.684s
#sys0m0.368s
# - 23K output

#time $RUNNER \
# --jobStore aws:us-east-1:toil-tjs1 \
# --logFile melt-split-step-2.log \
# --batchSystem mesos \
#melt-split-step-2.cwl NA12878-config/melt-split-step-2.yml

# -----
# group - ALU
# -----

#real2m33.342s
#user0m2.992s
#sys0m0.419s
# - 103K output

#time $RUNNER \
# --jobStore aws:us-east-1:toil-tjs1 \
# --logFile melt-split-step-2.log \
# --batchSystem mesos \
#melt-split-step-2.cwl NA12878-config/melt-split-step-2-alu.yml

# -----
# group - SVA
# -----

#real0m30.393s
#user0m2.415s
#sys0m0.325s

#time $RUNNER \
# --jobStore aws:us-east-1:toil-tjs1 \
# --logFile melt-split-step-2.log \
# --batchSystem mesos \
#melt-split-step-2.cwl NA12878-config/melt-split-step-2-sva.yml

# -----
# gen
# -----

#real19m26.760s
#user0m7.910s
#sys0m0.976s

time $RUNNER \
 --jobStore aws:us-east-1:toil-tjs1 \
 --logFile melt-split-step-3.log \
 --batchSystem mesos \
 melt-split-step-3.cwl NA12878-config/melt-split-step-3.yml

# -----
# vcf - LINE1
# -----

#real0m22.407s
#user0m2.252s
#sys0m0.333s

#time $RUNNER \
# --jobStore aws:us-east-1:toil-tjs1 \
# --logFile melt-split-step-4.log \
# --batchSystem mesos \
# melt-split-step-4.cwl NA12878-config/melt-split-step-4.yml

# -----
# vcf - ALU
# -----

#real0m23.522s
#user0m2.303s
#sys0m0.286s

#time $RUNNER \
# --jobStore aws:us-east-1:toil-tjs1 \
# --logFile melt-split-step-4.log \
# --batchSystem mesos \
#melt-split-step-4.cwl NA12878-config/melt-split-step-4-alu.yml

# -----
# vcf - SVA
# -----

#real0m22.501s
#user0m2.287s
#sys0m0.312s

#time $RUNNER \
# --jobStore aws:us-east-1:toil-tjs1 \
# --logFile melt-split-step-4.log \
# --batchSystem mesos \
#melt-split-step-4.cwl NA12878-config/melt-split-step-4-sva.yml
