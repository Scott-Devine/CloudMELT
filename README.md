
# CloudMELT

## Overview

CloudMELT is a set of [CWL][cwl] (Common Workflow Language) workflows and associated utility 
scripts to facilitate running large multi-sample [MELT][melt] jobs (MELT-Split and MELT-Deletion)
in the cloud on [Amazon EC2][ec2]. It uses [Toil][toil] to create an AWS/EC2 compute cluster and
distribute CWL-encoded MELT jobs to the worker nodes in that cluster.

[ec2]: https://aws.amazon.com/ec2/
[cwl]: https://www.commonwl.org/
[melt]: http://melt.igs.umaryland.edu
[toil]: http://toil.ucsc-cgl.org/

# Running MELT on AWS EC2

## Prerequisites

1. A correctly-configured AWS account  
  You will need an AWS account set up to run Toil jobs. First, follow the directions in the
  Toil documentation in the section entitled ["Preparing your AWS environment"][toil_aws_prep]
  Note that if the account you're using does not have full administrative privileges then
  you may need to ask your AWS administrator to grant you a number of IAM privileges before 
  you will be able to launch AWS clusters with Toil.  
  
  **NOTE FOR IGS USERS:** You may already have an AWS account with an AWS Access Key ID and AWS
  Secret Access Key provided by your AWS administrator. In this case simply omit the relevant
  steps from "Preparing your AWS environment." You will probably still need to subscribe to 
  the Container Linux by CoreOS AMI and may also need to generate an RSA key pair if you do
  not already have one. The IAM AWS permissions required to run Toil workflows are enumerated/
  discussed in https://jira.igs.umaryland.edu/browse/ENG-3589.
  
2. A local installation of Toil  
  This tutorial assumes that Toil has been installed locally, as described in the Toil 
  [installation documentation][toil_install]. Note that it must be installed with at
  least the following Toil "extras" to enable support for running CWL workflows on Amazon 
  EC2: `aws,mesos,cwl`  
  
  **NOTE FOR IGS USERS:** Toil has been installed on all IGS machines at ??? (TODO)
  
[toil_aws_prep]: https://toil.readthedocs.io/en/latest/running/cloud/amazon.html
[toil_install]: https://toil.readthedocs.io/en/latest/gettingStarted/install.html
[toil_aws]: https://toil.readthedocs.io/en/latest/running/cloud/amazon.html#runningaws

## Running a MELT-Split analysis

This section provides a detailed walkthrough of running CloudMELT on 10 low-coverage samples
from the 1000 Genomes Project. All of the necessary configuration files can be found in 
[examples/1000genomes-10-samples/][example].

[example]: examples/1000genomes-10-samples/

### Obtain a copy of the CloudMELT code

Obtain a copy of this repository by downloading the latest release from the 
[releases page][rel_page] or by cloning the current master branch of the repository 
using the green "Clone or download" dropwdown menu towards the top of the [GitHub page][melt_github].

**NOTE FOR IGS USERS:** The CloudMELT code has been installed on all IGS machines at ??? (TODO)

[rel_page]: https://github.com/jonathancrabtree/CloudMELT/releases
[melt_github]: https://github.com/jonathancrabtree/CloudMELT

### Create a local working directory

Create a directory to hold the CloudMELT workflow and output files from AWS:

```
user@local_machine$ mkdir cloud_melt_run
user@local_machine$ cd cloud_melt_run
```

### Download/create BAM file list

Download the following file to your local working directory: [examples/1000genomes-10-samples/sample_uris.txt][sample_list].
It contains 10 low-coverage samples from the 1000 Genomes Project, all of them hosted on S3.

[sample_list]: examples/1000genomes-10-samples/sample_uris.txt

Or, use your favorite editor to create a list of BAM files to process. Currently these must be specified
as http or https URIs that can be retrieved from an AWS node via `curl` or `wget`. For example, here are
two of the low-coverage BAM files from the above list, which consists of 10 samples from the 1000 Genomes
data hosted on Amazon S3:

```
http://s3.amazonaws.com/1000genomes/phase3/data/NA12829/alignment/NA12829.mapped.ILLUMINA.bwa.CEU.low_coverage.20130415.bam
http://s3.amazonaws.com/1000genomes/phase3/data/NA12830/alignment/NA12830.mapped.ILLUMINA.bwa.CEU.low_coverage.20130415.bam
```

__NOTE:__ CloudMELT assumes that each .bam file in the list has a corresponding .bai file and will
attempt to construct a URI for the .bai file by appending ".bai" to the end of the .bam URI.

__NOTE:__ It is preferable to use BAM files hosted on S3 for CloudMELT to minimize download times
when the pipeline is running.

### Create/download CloudMELT configuration files

CloudMELT is configured using the same YAML (.yml) file format supported by the Common Workflow Language.
For MELT-Split the user must provide a .yml configuration file for each of the 4 steps of the MELT-Split
pipeline. Download the 4 configuration files for our 10 sample example from [examples/1000genomes-10-samples/config.in/][config_dir]:

 1. [step-1-pre.yml]
 2. [step-2-grp.yml]
 3. [step-3-gen.yml]
 4. [step-4-vcf.yml]

[config_dir]: examples/1000genomes-10-samples/config.in/
[step-1-pre.yml]: examples/1000genomes-10-samples/config.in/step-1-pre.yml
[step-2-grp.yml]: examples/1000genomes-10-samples/config.in/step-2-grp.yml
[step-3-gen.yml]: examples/1000genomes-10-samples/config.in/step-3-gen.yml
[step-4-vcf.yml]: examples/1000genomes-10-samples/config.in/step-4-vcf.yml

Let's look at the content of these files:

step-1-pre.yml:

```
ref_fasta_file:
  class: File
  path: /opt/MELTv2.1.5/reference/hs37d5.fa
genes_bed_file: 
  class: File
  path: /opt/MELTv2.1.5/add_bed_files/1KGP_Hg19/hg19.genes.bed
excluded_chromosomes: hs37d5/NC_007605
transposon_zip_files: 
  - { class: File, path: /opt/MELTv2.1.5/me_refs/1KGP_Hg19/LINE1_MELT.zip }
  - { class: File, path: /opt/MELTv2.1.5/me_refs/1KGP_Hg19/ALU_MELT.zip }
min_coverage: 4
```

step-2-grp.yml:
```
ref_fasta_file:
  class: File
  path: /opt/MELTv2.1.5/reference/hs37d5.fa
ref_bed_file: 
  class: File
  path: /opt/MELTv2.1.5/add_bed_files/1KGP_Hg19/hg19.genes.bed
```

step-3-gen.yml:
```
ref_fasta_file:
  class: File
  path: /opt/MELTv2.1.5/reference/hs37d5.fa
transposon_files:
  - { pre_geno: { class: File, path: /toil/LINE1.pre_geno.tsv }, zip: { class: File, path: /opt/MELTv2.1.5/me_refs/1KGP_Hg19/LINE1_MELT.zip }}
  - { pre_geno: { class: File, path: /toil/ALU.pre_geno.tsv }, zip: { class: File, path: /opt/MELTv2.1.5/me_refs/1KGP_Hg19/ALU_MELT.zip }}
```

step-4-vcf.yml:
```
ref_fasta_file:
  class: File
  path: /opt/MELTv2.1.5/reference/hs37d5.fa
```

### Run CloudMELT script to create pipeline

-edit workflow master script (optional)
-create tarball of the workflow


### Run Toil command to create a static compute cluster on EC2

-Link to page showing EC2 spot instance costs
-Link to page showing which instances are compatible with 

### Log in to docker and distribute config.json

### Run setup script on each worker node
 The script:
   -creates /mnt/ephemeral/tmp and symlinks it to /root/tmp
    -this ensures that the cwltool jobs that run on each instance will use the ephemeral storage (i.e., large SSD)
   -runs docker login
   -pulls the docker image containing MELT, Bowtie, and the reference database(s)

### Run toil rsync-cluster to copy tarball to Toil leader node

### Run toil ssh-cluster to connect to Toil leader node

### Uncompress tarball (on Toil leader node)

### Run workflow master script (on Toil leader node)

### Monitor workflow progress
 -AWS EC2 page
 -AWS S3 page
 -AWS billing page

### Apply GroupAnalysis workaround after step 1 (optional)
 TODO - fold this into the initial configuration script

### Check results after each step of workflow (optional)

### Create tarball of all the files to be saved (on Toil leader node)

### Run toil rsync-cluster to transfer results tarball back to local machine

### Run toil destroy-cluster to shut down the toil cluster

### Check AWS EC2 page to ensure that the machines have been shut down


## Recovering from workflow failure

May need to delete the job store before restarting.


## Handling AWS instance limits.

Include link to customer support form.

## Building/exporting CloudMELT Docker container

## Limitations/Caveats

* Current pipeline assumes sample BAM files can be retrieved via HTTP GET
* Current pipeline (and MELT) supports only BAM input files, not CRAM input files
* BAM/CRAM files must be downloaded twice, once in step 1 and once in step 3.

