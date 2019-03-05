FROM openjdk:8-jre-slim
MAINTAINER Jonathan Crabtree <jcrabtree@som.umaryland.edu>

# install MELT into /opt:
COPY MELTv2.1.5.tar.gz /opt/
RUN cd opt/ && \
  tar xzvf MELTv2.1.5.tar.gz && \
  rm MELTv2.1.5.tar.gz

# install filtered AluY file
COPY AluY.deletion.filtered.bed /opt/AluY.deletion.filtered.bed

# TODO - install Bowtie2 into /opt

CMD ["/bin/bash"]
