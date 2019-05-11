#!/bin/bash
cp ../../tarballs/MELTv2.1.5.tar.gz ./
cp ../../add_bed_files/1KGP_Hg19/AluY.deletion.filtered.bed ./
cp ../../me_refs/1KGP_HG19/HERVK_MELT.zip ./
cp ../../reference/hs37d5.fa* ./
cp ../commas_to_newlines.sh ./
cp ../mosdepth2cov.py ./
cp ../bowtie2-2.3.4.3-linux-x86_64.zip ./
cp ../cwltool_then_clean_tmp ./
cp ../get_bam_and_bai.pl ./
cp ../../MELT-r38-v4-jc.jar ./
docker build -t umigs/cloud-melt-hg19-v1.0.0 .
rm hs37d5.fa* commas_to_newlines.sh mosdepth2cov.py MELTv2.1.5.tar.gz AluY.deletion.filtered.bed HERVK_MELT.zip bowtie2-2.3.4.3-linux-x86_64.zip cwltool_then_clean_tmp get_bam_and_bai.pl MELT-r38-v4-jc.jar 
