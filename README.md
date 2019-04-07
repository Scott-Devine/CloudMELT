
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
  not already have one. The IAM AWS permissions required to run Toil workflows are 
  enumerated/discussed in https://jira.igs.umaryland.edu/browse/ENG-3589.
  
2. A local installation of Toil  
  This tutorial assumes that Toil has been installed locally, as described in the Toil 
  [installation documentation][toil_install]. Note that it must be installed with at
  least the following Toil "extras" to enable support for running CWL workflows on Amazon 
  EC2: `aws,mesos,cwl`  
  
  **NOTE FOR IGS USERS:** Toil has been installed on all IGS machines at ??? (TODO)

3. Familiarity with the [MELT][melt] software.
  
[toil_aws_prep]: https://toil.readthedocs.io/en/latest/running/cloud/amazon.html
[toil_install]: https://toil.readthedocs.io/en/latest/gettingStarted/install.html
[toil_aws]: https://toil.readthedocs.io/en/latest/running/cloud/amazon.html#runningaws
[melt]: http://melt.igs.umaryland.edu

## Running a MELT-Split analysis

This section provides a detailed walkthrough of running CloudMELT on 10 low-coverage samples
from the 1000 Genomes Project. All of the necessary configuration files to run this example
can be found in [examples/1000genomes-10-samples/][example].

[example]: examples/1000genomes-10-samples/

### Obtain a copy of the CloudMELT code

Obtain a copy of the CloudMELT code by downloading the latest release from the GitHub
[releases page][rel_page] or by cloning the current master branch of the repository 
using the green "Clone or download" dropwdown menu towards the top of the [GitHub page][melt_github].
Set an environment variable, CLOUD_MELT_HOME, to the location of the code e.g., 

```
user@local_machine$ export CLOUD_MELT_HOME /home/username/CloudMELT
```

**NOTE FOR IGS USERS:** The CloudMELT code has been installed on all IGS machines at ??? (TODO)

[rel_page]: https://github.com/jonathancrabtree/CloudMELT/releases
[melt_github]: https://github.com/jonathancrabtree/CloudMELT

### Create a local working directory

Create a directory to hold the CloudMELT workflow and the output files that you'll download
from AWS once the workflow has run:

```
user@local_machine$ mkdir cloud_melt_run
user@local_machine$ cd cloud_melt_run
```

### Download/create BAM file list

Download the following file to your local working directory: [examples/1000genomes-10-samples/sample_uris.txt][sample_list].
It contains 10 low-coverage samples from the 1000 Genomes Project, all of them hosted on S3.

[sample_list]: examples/1000genomes-10-samples/sample_uris.txt

Or, use your favorite editor to create a list of BAM files to process. Currently these must be specified
as http or https URIs that can be retrieved from an AWS EC2 instance via `curl` or `wget`. For example, here are
two of the low-coverage BAM files from the above list, which consists of 10 samples from the 1000 Genomes
data hosted on Amazon S3:

```
http://s3.amazonaws.com/1000genomes/phase3/data/NA12829/alignment/NA12829.mapped.ILLUMINA.bwa.CEU.low_coverage.20130415.bam
http://s3.amazonaws.com/1000genomes/phase3/data/NA12830/alignment/NA12830.mapped.ILLUMINA.bwa.CEU.low_coverage.20130415.bam
```

__NOTE:__ CloudMELT assumes that each .bam file in the list has a corresponding .bai file and will
attempt to construct a URI for the .bai file by appending ".bai" to the end of each .bam URI.

__NOTE:__ It is preferable to use BAM files hosted on S3 for CloudMELT to minimize download times
when the pipeline is running.

### Create/download CloudMELT configuration files

CloudMELT is configured using the same YAML (.yml) file format supported by the Common Workflow Language.
For MELT-Split the user must provide a .yml configuration file for each of the 4 steps of the MELT-Split
pipeline (Preprocessing/IndividualAnalysis, GroupAnalysis, Genotyping, and MakeVCF). Download the 4 
configuration files for our 10 sample example from [examples/1000genomes-10-samples/config.in/][config_dir]
and place them into a subdirectory called "config.in" (or simply copy this directory from the CloudMELT 
source/repository into your working directory):

 1. [step-1-pre.yml]
 2. [step-2-grp.yml]
 3. [step-3-gen.yml]
 4. [step-4-vcf.yml]

[config_dir]: examples/1000genomes-10-samples/config.in/
[step-1-pre.yml]: examples/1000genomes-10-samples/config.in/step-1-pre.yml
[step-2-grp.yml]: examples/1000genomes-10-samples/config.in/step-2-grp.yml
[step-3-gen.yml]: examples/1000genomes-10-samples/config.in/step-3-gen.yml
[step-4-vcf.yml]: examples/1000genomes-10-samples/config.in/step-4-vcf.yml

Let's look at the content of these files for the 10-sample 1000 Genomes example:

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

Note that:

* Each item in a configuration file (e.g., ref_fasta_file) corresponds to a MELT command-line argument, although the names have been
changed to be more descriptive.
* Just as some MELT-Split steps require the same inputs (e.g., ref_fasta_file, ref_bed_file/genes_bed_file), some arguments are repeated across the config files and should be kept consistent.
* All of the file paths that start with "/opt" or "/toil" are paths _in the Docker container_ in which MELT, Bowtie, and mosdepth are installed (TODO - add link to Docker container docs).
* The predefined reference files start with "/opt" whereas files generated in a previous step (e.g., LINE1.pre_geno.tsv) start with "/toil".
* MELT (and the corresponding CWL workflows) support other parameters that aren't used in these particular config files. To see all of the parameters for a 
particular workflow step, check the `inputs` section of thee corresponding .cwl file e.g., [cwl/melt-grp.cwl]
* These example configuration files use hs37d5 as the human reference sequence.
* MELT-Split is being run here on only two mobile element types: LINE1 and ALU. SVA and HERVK are also available and any combination of the 4 may be specified in the config files.

### Run `create_pipeline.pl` to create the CloudMELT pipeline

Assuming that the 4 configuration files are in a subdirectory named `config.in` and the 
10 sample URI list is in  a file named `sample_uris.txt`, the following command will 
create (but not run) a pipeline to process these samples:

```
user@local_machine$ $CLOUD_MELT_HOME/bin/create_pipeline.pl --sample_uri_list=sample_uris.txt \
 --config_dir=./config.in \
 --workflow_dir=./melt-workflow \
 --toil_jobstore='aws:us-east-1:tj1'
```

This command can also be found in the `create_pipeline.sh` shell script in the example directory.
It should create a new directory, `melt-workflow` and populate it with the files necessary to run
the workflow. It will then create a gzipped tar file from that directory, `melt-workflow.tar.gz`

Note that:
* The `toil_jobstore` is tied to a specific AWS region (us-east-1 in this case)
* The script `melt-workflow/run-workflow.sh` will execute the four steps of the workflow on the AWS/Toil leader node.
If, for example, you wish to check the output of step 1 before running step 2, this is the script that should
be edited (e.g., to exit after step 1 and then, once the output has been verified, to run steps 2-4, but skip
step 1.)
* If any edits are made to `run-workflow.sh` or any of the other files in `melt-workflow`, the tar file will
have to be rebuilt before uploading it to the Toil leader node on AWS.

### Run Toil command to create a static compute cluster on EC2

Currently CloudMELT only supports static Toil clusters, meaning that the size and composition of the AWS 
cluster is fixed for the duration of the workflow. (Toil also supports dynamic cluster provisioning, in
which cluster nodes are started and stopped as needed as the workflow progresses.)

-Link to page showing EC2 spot instance costs
-Link to page showing which instances are compatible with the core os AMI

[ec2_instances]: https://aws.amazon.com/ec2/faqs/ 
[core_os_ami]: https://aws.amazon.com/marketplace/pp/B01H62FDJM/

### Create and upload workflow tarball

-Edit workflow master script as needed (optional)

Create a tarball that contains all of the workflow and configuration files:

```
tar czvf workflow.tar.gz cwl/* run-workflow.sh config.out
```

Upload the tarball to the Toil leader node using `rsync-cluster`:

```
toil rsync-cluster -z us-east-1a tcm1 ./workflow.tar.gz :/root/
```

### Log in to docker and distribute config.json

Run the following command on the local machine to show the `docker login` command needed to access Amazon ECR (Elastic Container Registry):

```
user@local_machine$ aws ecr get-login --region us-east-1 --no-include-email
```

Note that this command and several of the other AWS commands require the selection of an AWS region. Use 
the AWS/EC2 region in which you plan to run the MELT jobs (us-east-1 in this example). The above command
should print a `docker login` command to the terminal. Copy this command to the clipboard.

Next, connect to the Toil leader node and run the copied `docker login` command:

```
user@local_machine$ toil ssh-cluster -z us-east-1a tcm1
root@aws_toil_leader$ docker login <etc. etc.>
```

If the `docker login` command is successful you should now have a `/root/.docker/config.json` file 
on the Toil leader node. Exit the ssh session with the leader node.

TODO - copy config.json to each worker node in turn

### Run setup script on each worker node
 The script:
   -creates /mnt/ephemeral/tmp and symlinks it to /root/tmp
    -this ensures that the cwltool jobs that run on each instance will use the ephemeral storage (i.e., large SSD)
   -runs docker login
   -pulls the docker image containing MELT, Bowtie, and the reference database(s)

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

