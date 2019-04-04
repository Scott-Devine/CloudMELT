
### Overview

CloudMELT is a set of [CWL][cwl] (Common Workflow Language) workflows and associated utility 
scripts to facilitate running large multi-sample [MELT][melt] jobs (MELT-Split and MELT-Deletion)
on [Amazon EC2][ec2].

[ec2]: https://aws.amazon.com/ec2/
[cwl]: https://www.commonwl.org/
[melt]: http://melt.igs.umaryland.edu

### Running MELT-Split on AWS EC2

## Prerequisites

o Correctly-configured AWS account
o Toil installed locally

## Running a MELT-Split analysis

# Create list of sample BAM files

# Run script to create configuration files

# Run toil command to create a static compute cluster on EC2

-Link to page showing EC2 spot instance costs
-Link to page showing which instances are compatible with 

# Log in to docker and distribute config.json

# Run setup script on each worker node
 The script:
   -creates /mnt/ephemeral/tmp and symlinks it to /root/tmp
    -this ensures that the cwltool jobs that run on each instance will use the ephemeral storage (i.e., large SSD)
   -runs docker login
   -pulls the docker image containing MELT, Bowtie, and the reference database(s)

# Edit workflow master script (optional)

# Create tarball of the workflow

# Run toil rsync-cluster to copy tarball to Toil leader node

# Run toil ssh-cluster to connect to Toil leader node

# Uncompress tarball (on Toil leader node)

# Run workflow master script (on Toil leader node)

# Monitor workflow progress
 -AWS EC2 page
 -AWS S3 page
 -AWS billing page

# Apply GroupAnalysis workaround after step 1 (optional)
 TODO - fold this into the initial configuration script

# Check results after each step of workflow (optional)

# Create tarball of all the files to be saved (on Toil leader node)

# Run toil rsync-cluster to transfer results tarball back to local machine

# Run toil destroy-cluster to shut down the toil cluster

# Check AWS EC2 page to ensure that the machines have been shut down


### Recovering from workflow failure

May need to delete the job store before restarting.


### Handling AWS instance limits.

Include link to customer support form.


### Limitations/Caveats

o Current pipeline assumes sample BAM files can be retrieved via HTTP GET
o Current pipeline (and MELT) supports only BAM input files, not CRAM input files
o BAM/CRAM files must be downloaded twice, once in step 1 and once in step 3.