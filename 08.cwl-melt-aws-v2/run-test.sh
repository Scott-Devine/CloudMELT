#!/bin/bash

export RUNNER='toil-cwl-runner --retryCount 0'
# Mac OS X - specific workaround for Docker tasks
export TMPDIR="/private${TMPDIR}"

# --------------------------------------------
# pre-mosdepth-cov-ind - scatter by sample
# --------------------------------------------

# chr22 subset, LINE1 only
#$RUNNER melt-split-pre-mosdepth-cov-ind.cwl config/melt-split-pre-mosdepth-cov-ind-NA12878.chr22.LINE1.yml

# chr22 subset, all 4 MEs
#$RUNNER melt-split-pre-mosdepth-cov-ind.cwl config/melt-split-pre-mosdepth-cov-ind-NA12878.chr22.all.yml

# --------------------------------------------
# grp - scatter by transposon
# --------------------------------------------

# TODO - add script to generate .yml files and cwltoil commands

# chr22 subset, LINE1 only
$RUNNER melt-grp.cwl config/melt-grp-NA12878.chr22.LINE1.yml

# --------------------------------------------
# gen - scatter by sample
# --------------------------------------------

# TODO

# --------------------------------------------
# vcf - scatter by transposon
# --------------------------------------------

# TODO
