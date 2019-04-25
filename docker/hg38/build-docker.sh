#!/bin/bash
cp ../../tarballs/MELTv2.1.5.tar.gz ./
cp ../../reference/GRCh38* ./
cp ../commas_to_newlines.sh ./
cp ../mosdepth2cov.py ./
cp ../bowtie2-2.3.4.3-linux-x86_64.zip ./
cp ../cwltool_then_clean_tmp ./
docker build -t umigs/cloud-melt-hg38-v1.0.0 .
rm GRCh38* commas_to_newlines.sh mosdepth2cov.py MELTv2.1.5.tar.gz bowtie2-2.3.4.3-linux-x86_64.zip cwltool_then_clean_tmp