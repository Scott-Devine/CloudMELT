#!/usr/bin/env perl

# Retrieve and/or produce .bam and .bai files for a sample.
# Selects a download method (curl for http/ftp/https),
# and performs CRAM to BAM conversion and BAM indexing when
# necessary.

use strict;

## globals
my $USAGE = "Usage: $0 bam_or_cram_uri [ref_fasta]";

## input
my $bam_or_cram_uri = shift || die $USAGE;
my $ref_fasta = shift;

## main program

my $is_s3_uri = 0;

# check for S3 native URI
if ($bam_or_cram_uri =~ /^s3:/) {
    $is_s3_uri = 1;
} 

# 1. retrieve BAM or CRAM file referenced by $bam_or_cram_uri
if ($is_s3_uri) {
    &run_sys_command("aws s3 cp $bam_or_cram_uri ./", 1);
} else {
    &run_sys_command("curl -O $bam_or_cram_uri", 1);
}

# 2. if BAM, check for corresponding .bai file
my($basename) = ($bam_or_cram_uri =~ /\/([^\/]+)$/);
if ($basename =~ /\.bam$/) {
    if ($is_s3_uri) {
	&run_sys_command("aws s3 cp ${bam_or_cram_uri}.bai ./", 0);
    } else {
	&run_sys_command("curl -O ${bam_or_cram_uri}.bai", 0);
    }
}
elsif ($basename =~ /\.cram$/) {
    die "can't convert CRAM to BAM without reference FASTA" if (!defined($ref_fasta));
    my $bam_basename = $basename;
    $bam_basename =~ s/\.cram$/.bam/;
    &run_sys_command("samtools view -T $ref_fasta -o $bam_basename $basename");
    $basename = $bam_basename;
} 
else {
    die "unrecognized sequence file type (not BAM or CRAM) for " . $bam_or_cram_uri;
}

# 3. if no BAM index, create one with samtools
my $bai_basename = $basename . '.bai';
if (! -e $bai_basename) {
    &run_sys_command("samtools index $basename");
}

exit(0);

## subroutines

sub run_sys_command {
  my($cmd, $halt_on_err) = @_;
  print STDERR "running - $cmd\n";
  system($cmd);

  # check for errors, optional halt if any are found
  my $err = undef;
  if ($? == -1) {
    $err = "failed to execute: $!";
  }
  elsif ($? & 127) {
    $err = sprintf("child died with signal %d, %s coredump\n", ($? & 127), ($? & 128) ? 'with' : 'without');
  }
  else {
    my $exit_val = $? >> 8;
    $err = sprintf("child exited with value %d\n", $exit_val) if ($exit_val != 0);
  }
  die $err if (defined($err) && $halt_on_err);
  return $err;
}
