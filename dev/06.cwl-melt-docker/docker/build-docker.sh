#!/bin/bash
#cp ../../tarballs/MELTv2.1.5.tar.gz ./
#cp ../../add_bed_files/1KGP_Hg19/05.cwl-local-multi-sample-multi-ME/AluY.deletion.filtered.bed ./
#cp ../../me_refs/1KGP_HG19/HERVK_MELT.zip ./
docker build -t umigs/cloud-melt-v1.0.0 .
