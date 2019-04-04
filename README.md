
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
  
  *NOTE FOR IGS USERS:* You may already have an AWS account with an AWS Access Key ID and AWS
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
  
*NOTE FOR IGS USERS:* Toil has been installed on all IGS machines at ??? (TODO)
  
[toil_aws_prep]: https://toil.readthedocs.io/en/latest/running/cloud/amazon.html
[toil_install]: https://toil.readthedocs.io/en/latest/gettingStarted/install.html
[toil_aws]: https://toil.readthedocs.io/en/latest/running/cloud/amazon.html#runningaws

## Running a MELT-Split analysis

### Obtain a copy of the CloudMELT code

Obtain a copy of this repository by downloading the latest release from the 
[releases page][rel_page] or by cloning the current master branch of the repository 
using the green "Clone or download" dropwdown menu towards the top of the page.

*NOTE FOR IGS USERS:* The CloudMELT code has been installed on all IGS machines at ??? (TODO)

[rel_page]: https://github.com/jonathancrabtree/CloudMELT/releases

### Create a local workspace



### Create list of sample BAM files

### Run script to create configuration files

### Run toil command to create a static compute cluster on EC2

-Link to page showing EC2 spot instance costs
-Link to page showing which instances are compatible with 

### Log in to docker and distribute config.json

### Run setup script on each worker node
 The script:
   -creates /mnt/ephemeral/tmp and symlinks it to /root/tmp
    -this ensures that the cwltool jobs that run on each instance will use the ephemeral storage (i.e., large SSD)
   -runs docker login
   -pulls the docker image containing MELT, Bowtie, and the reference database(s)

### Edit workflow master script (optional)

### Create tarball of the workflow

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


## Limitations/Caveats

* Current pipeline assumes sample BAM files can be retrieved via HTTP GET
* Current pipeline (and MELT) supports only BAM input files, not CRAM input files
* BAM/CRAM files must be downloaded twice, once in step 1 and once in step 3.

