FROM openjdk:8-jre-slim
MAINTAINER Jonathan Crabtree <jcrabtree@som.umaryland.edu>

# install MELT into /opt:
COPY MELTv2.1.5fast.tar.gz /opt/
RUN cd /opt && \
  tar xzvf MELTv2.1.5fast.tar.gz && \
  rm MELTv2.1.5fast.tar.gz

# install Bowtie2 into /opt
COPY bowtie2-2.3.4.3-linux-x86_64.zip /opt/

RUN cd /opt && \
  unzip bowtie2-2.3.4.3-linux-x86_64.zip && \
  ln -s bowtie2-2.3.4.3-linux-x86_64 bowtie2 && \
  rm bowtie2-2.3.4.3-linux-x86_64.zip

# Bowtie2 Perl dependencies
RUN apt-get update && apt-get install -y libsys-hostname-long-perl

# install cwltool
RUN apt-get install -y curl python-pip nodejs
RUN pip install virtualenv && virtualenv ~/venv && pip install cwlref-runner

# install filtered AluY file
COPY AluY.deletion.filtered.bed /opt/MELTv2.1.5fast/add_bed_files/1KGP_Hg19/

# install HERVK file
COPY HERVK_MELT.zip /opt/MELTv2.1.5fast/me_refs/1KGP_Hg19/

# hg19 reference FASTA
COPY hs37d5.fa /opt/MELTv2.1.5fast/reference/
COPY hs37d5.fa.fai /opt/MELTv2.1.5fast/reference/

# mosdepth
RUN curl -LO https://github.com/brentp/mosdepth/releases/download/v0.2.5/mosdepth && chmod ugo+x mosdepth && mv mosdepth /usr/local/bin/

# samtools and dependencies
RUN apt-get install -y libncurses5-dev zlib1g-dev libbz2-dev liblzma-dev libcurl4-gnutls-dev libssl-dev
RUN curl -LO https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 \
 && tar xjf samtools-1.9.tar.bz2 \
 && cd samtools-1.9 \
 && ./configure --prefix=/opt/samtools-1.9 \
 && make \
 && make install \ 
 && cp /opt/samtools-1.9/bin/* /usr/local/bin/

RUN chmod go+rwx /root

COPY commas_to_newlines.sh mosdepth2cov.py cwltool_then_clean_tmp get_bam_and_bai.pl upload_file.pl /usr/local/bin/

# install AWS CLI
RUN apt-get install -y awscli

CMD ["/bin/bash"]
