FROM openjdk:8-jre-slim
MAINTAINER Jonathan Crabtree <jcrabtree@som.umaryland.edu>

# install MELT into /opt:
COPY MELTv2.1.5.tar.gz /opt/
RUN cd /opt && \
  tar xzvf MELTv2.1.5.tar.gz && \
  rm MELTv2.1.5.tar.gz

# install filtered AluY file
COPY AluY.deletion.filtered.bed /opt/AluY.deletion.filtered.bed

# install HERVK file
COPY HERVK_MELT.zip /opt/MELTv2.1.5/me_refs/1KGP_HG19/

# install Bowtie2 into /opt
COPY bowtie2-2.3.4.3-linux-x86_64.zip /opt/

RUN cd /opt && \
  unzip bowtie2-2.3.4.3-linux-x86_64.zip && \
  ln -s bowtie2-2.3.4.3-linux-x86_64 bowtie2 && \
  rm bowtie2-2.3.4.3-linux-x86_64.zip

# Bowtie2 Perl dependencies
RUN apt-get update && apt-get install -y libsys-hostname-long-perl

CMD ["/bin/bash"]
