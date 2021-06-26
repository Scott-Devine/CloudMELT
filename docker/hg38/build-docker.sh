#!/bin/bash
cp ../MELTv2.1.5fast.tar.gz ./
cp ../reference/GRCh38* ./
cp ../commas_to_newlines.sh ./
cp ../mosdepth2cov.py ./
cp ../bowtie2-2.3.4.3-linux-x86_64.zip ./
cp ../cwltool_then_clean_tmp ./
cp ../get_bam_and_bai.pl ./
cp ../upload_file.pl ./
docker build -t umigs/cloud-melt-hg38-v1.0.1 .
rm GRCh38* commas_to_newlines.sh mosdepth2cov.py MELTv2.1.5fast.tar.gz bowtie2-2.3.4.3-linux-x86_64.zip cwltool_then_clean_tmp get_bam_and_bai.pl upload_file.pl
