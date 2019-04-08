
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
  You will need an AWS account set up to run Toil jobs. First, follow the directions from the
  Toil documentation, specifically the section entitled ["Preparing your AWS environment"][toil_aws_prep]
  Note that if the account you're using does not have full administrative privileges then
  you may need to ask your AWS administrator to grant you a number of IAM privileges before 
  you will be able to launch AWS clusters with Toil.  
  
  **NOTE FOR IGS USERS:** You may already have an AWS account with an AWS Access Key ID and AWS
  Secret Access Key provided by your AWS administrator. In this case simply omit the relevant
  steps from "Preparing your AWS environment." You will probably still need to subscribe to 
  the Container Linux by CoreOS AMI and may also need to generate an RSA key pair if you do
  not already have one. The IAM AWS permissions required to run Toil workflows are 
  enumerated/discussed in https://jira.igs.umaryland.edu/browse/ENG-3589.
 
2. A local installation of the AWS command line tools (AWS CLI)

  See [https://aws.amazon.com/cli/][https://aws.amazon.com/cli/] for details.
 
3. A local installation of Toil  
  This tutorial assumes that Toil has been installed locally, as described in the Toil 
  [installation documentation][toil_install]. Note that it must be installed with at
  least the following Toil "extras" to enable support for running CWL workflows on Amazon 
  EC2: `aws,mesos,cwl`  
  
  **NOTE FOR IGS USERS:** Toil has been installed on all IGS machines at ??? (TODO)

4. Familiarity with the [MELT][melt] software.
  
[toil_aws_prep]: https://toil.readthedocs.io/en/latest/running/cloud/amazon.html
[toil_install]: https://toil.readthedocs.io/en/latest/gettingStarted/install.html
[toil_aws]: https://toil.readthedocs.io/en/latest/running/cloud/amazon.html#runningaws
[melt]: http://melt.igs.umaryland.edu

## Running a MELT-Split analysis

This section provides a detailed walkthrough of running CloudMELT on 10 low-coverage samples
from the 1000 Genomes Project. All of the necessary configuration files to run this example
can be found in the GitHub repo, at [examples/1000genomes-10-samples/][example].

[example]: examples/1000genomes-10-samples/

### Obtain a copy of the CloudMELT code

Obtain a copy of the CloudMELT code by downloading the latest release from the GitHub
[releases page][rel_page] or by cloning the current master branch of the repository 
using the green "Clone or download" dropwdown menu towards the top of the [GitHub page][melt_github].
Set an environment variable, CLOUD_MELT_HOME, to the location of the downloaded code e.g., 

```
user@local_machine$ export CLOUD_MELT_HOME=/home/username/CloudMELT
```

**NOTE FOR IGS USERS:** The CloudMELT code has been installed on all IGS machines at ??? (TODO)

[rel_page]: https://github.com/jonathancrabtree/CloudMELT/releases
[melt_github]: https://github.com/jonathancrabtree/CloudMELT

### Create a local working directory

Create a directory to hold the CloudMELT workflow and the output files that you'll download
from AWS once the workflow has completed:

```
user@local_machine$ mkdir cloud_melt_run
user@local_machine$ cd cloud_melt_run
```

### Download/create BAM file list

Download the following file to your local working directory: [examples/1000genomes-10-samples/sample_uris.txt][sample_list].
It contains 10 low-coverage samples from the 1000 Genomes Project, all of them BAM files hosted on S3.

[sample_list]: examples/1000genomes-10-samples/sample_uris.txt

Or, use your favorite editor to create a list of BAM files to process. Currently these must be specified
as http or https URIs that an AWS EC2 instance can retrieve via `curl` or `wget`. For example, here are
two of the low-coverage BAM files from the above list:

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
source/repository directly into your working directory):

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
* All of the file paths that start with "/opt" or "/toil" are paths _in the Docker container_ in which MELT, Bowtie, and mosdepth are installed.
* The predefined reference files start with "/opt" whereas files generated in a previous step (e.g., LINE1.pre_geno.tsv) start with "/toil".
* MELT (and the corresponding CWL workflows) support other parameters that aren't used in these particular config files. To see all of the parameters for a 
particular workflow step, check the `inputs` section of the corresponding .cwl file e.g., [cwl/melt-grp.cwl][cwl/melt-grp.cwl]
* These example configuration files use hs37d5 as the human reference sequence and the hg19 reference annotation.
* MELT-Split is being run here on only two mobile element types: LINE1 and ALU. SVA and HERVK are also available and any combination of the 4 may be specified in the config files.

### Run `create_pipeline.pl` to create the CloudMELT pipeline

Assuming that the 4 configuration files are in a subdirectory named `config.in` and the 
10 sample URI list is in  a file named `sample_uris.txt`, the following command will 
create (but not run) a pipeline to process these samples:

```
user@local_machine$ $CLOUD_MELT_HOME/bin/create_pipeline.pl \
 --sample_uri_list=sample_uris.txt \
 --config_dir=./config.in \
 --workflow_dir=./melt-workflow \
 --toil_jobstore='aws:us-east-1:tj1'
```

This command can also be found in the [create_pipeline.sh][examples/1000genomes-10-samples/create_pipeline.sh] 
shell script in the example directory. It should create a new directory, `melt-workflow` and populate it 
with the files necessary to run the workflow. It will then create a gzipped tar file from that directory, 
`melt-workflow.tar.gz`

Note that:
* The `toil_jobstore` is tied to a specific AWS region (`us-east-1` in this case)
* The script `melt-workflow/run-workflow.sh` will execute the four steps of the workflow on the AWS/Toil leader node.
If, for example, you wish to check the output of step 1 before running step 2, this script should be edited so that
it exits after running step 1 (and then, once the output has been verified, to run the remaining steps from 2-4.) In 
this particular case you may wish to split the run script into two or more parts.
* If any edits are made to `run-workflow.sh` or any of the other files in `melt-workflow`, the tar file will
have to be rebuilt before uploading it to the Toil leader node on AWS.

### Run Toil command to create a static compute cluster on EC2

Currently CloudMELT only supports static Toil clusters, meaning that
the size (number of AWS instances) and composition (instance types) of
the AWS cluster is fixed for the duration of the workflow. Toil also
supports dynamic cluster provisioning, in which cluster nodes are
started and stopped as needed as the workflow progresses, but this 
feature is not yet supported in CloudMELT.

Since Toil relies on the Container Linux by CoreOS AMI, only
instance types supported by that AMI can be used (see the [CoreOS AMI page][core_os_ami]
for a complete list). In addition, CloudMELT requires that the instances have SSD-backed
ephemeral storage, meaning that only instance types with local SSD storage can be used.
The "i3" series of storage-optimized instance types all have SSD support. It is not 
absolutely necessary for the Toil leader node to have SSD storage, although it's 
recommended that at least a `t2.medium` instance be used for the leader - Toil prefers to
have at least 4 GiB of memory on the leader node.

For example, here is a Toil command to create a static cluster named `tcm1` in the `us-east-1a`
zone with a leader node of type `t2.medium` and a single worker node of type `i3.xlarge`. 
At the time of this writing such an on-demand cluster will cost approximately 36 cents per hour to operate:

```
toil launch-cluster tcm1 --leaderNodeType t2.medium --zone us-east-1a --keyPairName kp1 --nodeTypes i3.xlarge -w 1
```

Detailed information on instance types and on-demand instance pricing can be found on the [Amazon EC2 Pricing][on_demand_pricing] page.

Note that:
* "tcm1" is the cluster name - you will need this to run commands on the cluster later
* The `--zone` specified (e.g., `us-east-1a`) must match the AWS region (e.g., `us-east-1`) provided to the pipeline creation script.
* The `--keyPairName` must identify an ssh key pair associated with your AWS account: it will be used to allow you to connect to the
Toil leader node and worker node(s).

[on_demand_pricing]: https://aws.amazon.com/ec2/pricing/on-demand/
[core_os_ami]: https://aws.amazon.com/marketplace/pp/B01H62FDJM/

### Upload workflow tarball

Recall that the `create_pipeline.pl` that you ran in a previous step created a tarball (e.g., `melt-workflow.tar.gz`)
containing all of the workflow files. Use the following Toil command to upload the workflow tarball to the Toil
leader node:

```
toil rsync-cluster -z us-east-1a tcm1 ./melt-workflow.tar.gz :/root/
```

## Set up worker nodes

Two things need to happen on each worker node before running a MELT workflow:
1. Log in to Docker and retrieve the access-restricted MELT Docker image from Amazon ECR
2. Create symlink from /mnt/ephemeral/tmp (SSD storage) to /root/tmp

These steps are partially automated by a script but you will need to identify the public IP addresses of
the AWS worker nodes (using the AWS console) in order to copy files to and run commands on the Toil
worker nodes.

### Log in to docker and distribute config.json

First, run the following command on the local machine to show the `docker login` command needed to 
retrieve the MELT Docker image from Amazon's ECR (Elastic Container Registry):

```
user@local_machine$ aws ecr get-login --region us-east-1 --no-include-email
```

Note that this command and several of the other AWS commands require
the selection of an AWS region. Use the AWS/EC2 region in which you
plan to run the MELT jobs (`us-east-1` in this example). The above
command should print a `docker login` command to the terminal. Copy
this entire command to the clipboard.

Next, connect to the Toil leader node and paste the entire `docker login` command onto
the leader node's terminal:

```
user@local_machine$ toil ssh-cluster -z us-east-1a tcm1
root@aws_toil_leader$ docker login <etc. etc.>
```

If the `docker login` command is successful you should now have a `/root/.docker/config.json` file 
on the Toil leader node. Exit the ssh session with the leader node to return to the local machine.

The following commands must now be run for each worker node in turn (a list of the worker
nodes and their public IP addresses can be obtained from the AWS console's list of [Running Instances][aws_ec2_instances]

[aws_ec2_instances]: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:sort=desc:dnsName

1. Copy `config.json` to each worker node:
```
user@local_machine$ scp config.json core@<aws_instance_public_ip>:
```
2. Run the setup script on each worker node (this will create the symlink and pull the MELT Docker image):
```
user@local_machine$ scp $CLOUD_MELT_HOME/bin/setup-worker-node.sh core@<aws_instance_public_ip>:
user@local_machine$ ssh core@<aws_instance_public_ip> './setup-worker-node.sh'
```

TODO - add script to run setup steps in parallel for larger clusters

### Run toil ssh-cluster to connect to Toil leader node

```
user@local_machine$ toil ssh-cluster -z us-east-1a tcm1
```

### Uncompress tarball (on Toil leader node)

```
root@aws_toil_leader$ cd /root
root@aws_toil_leader$ tar xzf melt-workflow.tar.gz
root@aws_toil_leader$ cd melt-workflow
```

### Run workflow master script (on Toil leader node)

```
root@aws_toil_leader$ time ./run-workflow.sh
```

Make sure that if you wish to check the step 1 output before proceeding with step 2 that the 
`run-workflow.sh` script has been updated accordingly.

### Monitor workflow progress

As the workflow runs messages will be printed to the terminal as Toil launches and completes 
jobs. One can also ssh directly to the worker nodes and use `top` and/or `ps` to see what 
part of the pipeline is running. On a cluster of this type the example 10 genome analysis 
should take around 2.5 hours to run and cost less than $1.00.

__NOTE:__ Running a pipeline as a background process has not yet been tested, so for now it
is recommended that the `ssh-cluster` and subsequent `run-workflow.sh` commands be run from
a machine with a stable internet connection that will not be taken offline until the workflow
completes.

### Create tarball of all the files to be saved (on Toil leader node)

Once the workflow completes, create a tarball of all the output and/or intermediate files
that should be preserved after the cluster is shutdown. At the very least this should 
include the final VCF files and perhaps also the *pre_geno.tsv files:

```
root@aws_toil_leader$ tar czvf melt-results.tar.gz *.vcf *.tsv
```

### Log out of Toi leader and run rsync-cluster to transfer results back to local machine

Once the tarball has been created log out of the toil leader node and run the 
following `rsync-cluster` to transfer the tarball back to the local machine:

```
user@local_machine$ toil rsync-cluster -z us-east-1a tcm1 :/root/melt-results.tar.gz ./
```

### Run toil destroy-cluster to shut down the toil cluster

Once the result files have been safely transferred and verified the cluster can be
shut down:

```
user@local_machine$ toil destroy-cluster -z us-east-1a tcm1
```

__NOTE:__ AWS charges will continue to accrue until the cluster is shut down, so 
_do not_ skip this step or the next one, ensuring that the EC2 instances have
been terminated.

### Check AWS EC2 page to ensure that the machines have been shut down

Check the AWS console's [Running Instances][aws_ec2_instances] page to ensure that all of the 
cluster nodes terminated. If they do not shut down automatically they can be halted and deleted
from the AWS console (though this should not be necessary.)

[aws_ec2_instances]: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:sort=desc:dnsName





 -AWS EC2 page
 -AWS S3 page
 -AWS billing page

### Apply GroupAnalysis workaround after step 1 (optional)
 TODO - fold this into the initial configuration script

## Running a MELT-Deletion analysis

TODO - current workflow supports only MELT-Split.

## Recovering from workflow failure

TODO 

May need to delete the job store before restarting.

## Handling AWS instance limits.

Include link to customer support form.

TODO

## Building/exporting CloudMELT Docker container

TODO

## Limitations/Caveats

* Current pipeline assumes sample BAM files can be retrieved via HTTP GET
* Current pipeline (and MELT) supports only BAM input files, not CRAM input files
* BAM/CRAM files must be downloaded twice, once in step 1 and once in step 3.

