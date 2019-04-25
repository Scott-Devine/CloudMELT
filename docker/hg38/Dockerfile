FROM openjdk:8-jre-slim
MAINTAINER Jonathan Crabtree <jcrabtree@som.umaryland.edu>

# install MELT into /opt:
COPY MELTv2.1.5.tar.gz /opt/
RUN cd /opt && \
  tar xzvf MELTv2.1.5.tar.gz && \
  rm MELTv2.1.5.tar.gz

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

# hg38 reference FASTA
COPY GRCh38_full_analysis_set_plus_decoy_hla.fa /opt/MELTv2.1.5/reference/
COPY GRCh38_full_analysis_set_plus_decoy_hla.fa.fai /opt/MELTv2.1.5/reference/

RUN curl -L -O https://github.com/brentp/mosdepth/releases/download/v0.2.5/mosdepth && chmod ugo+x mosdepth && mv mosdepth /usr/local/bin/

RUN chmod go+rwx /root

COPY commas_to_newlines.sh mosdepth2cov.py cwltool_then_clean_tmp /usr/local/bin/

CMD ["/bin/bash"]
