#!/usr/bin/env perl

=head1 NAME

get_bam_and_bai.pl - Retrieve and/or produce the .bam and .bai files for a sample.

=head1 SYNOPSIS

  get_bam_and_bai.pl
   --bam_or_cram_uri=(http|s3|ftp|https)://someplace/sample1.bam
 [ --ref_fasta=/path/to/reference_fasta_for_cram_conversion.fsa
   --s3_bucket_uri=s3://temp_storage1
   ] 

=back

=head1 DESCRIPTION

Retrieve and/or produce the .bam and .bai files for a sample.
Selects a download method (curl for http/ftp/https, AWS cli for s3://),
and performs CRAM to BAM conversion and BAM indexing when necessary.
When given an S3 bucket name the script will first check to see if the
requested .bam and .bai files are in that bucket. If not it will 
retrieve/compute them as normal and then save a copy in the named bucket.
Note that the S3 bucket must exist already and be writable by the user.

=cut

use strict;
use Getopt::Long qw(:config no_ignore_case no_auto_abbrev pass_through);
use Pod::Usage;

# --------------------------------------------
## globals
# --------------------------------------------

# --------------------------------------------
## input
# --------------------------------------------
my $options = {};
&GetOptions($options,
	    "bam_or_cram_uri=s",
	    "ref_fasta=s",
	    "s3_bucket_uri=s",
            "help|h",
            "man|m") || pod2usage();

# check parameters/set defaults 
&check_parameters($options);

my $bam_or_cram_uri = $options->{'bam_or_cram_uri'};
my $ref_fasta = $options->{'ref_fasta'};
my $s3_bucket_uri = $options->{'s3_bucket_uri'};

# --------------------------------------------
## main program
# --------------------------------------------

my($basename) = ($bam_or_cram_uri =~ /\/([^\/]+)$/);
my $bam_basename = $basename;
if ($bam_basename =~ /\.cram$/) {
    $bam_basename =~ s/\.cram$/.bam/;
}
my $bai_basename = $bam_basename . '.bai';

# check cache for final .bam and .bai files
my $upload_to_cache = 0;
if (defined($s3_bucket_uri)) {
    my $cached_bam_uri = $s3_bucket_uri . "/" . $bam_basename;
    my $cached_bai_uri = $s3_bucket_uri . "/" . $bai_basename;

    # .bam and .bai files both found in cache bucket
    if (&s3_uri_exists($cached_bam_uri) && &s3_uri_exists($cached_bai_uri)) {
	print STDERR "INFO - reading $cached_bam_uri from cache at $s3_bucket_uri\n";
	&run_sys_command("aws s3 cp $cached_bam_uri ./", 1);
	&run_sys_command("aws s3 cp $cached_bai_uri ./", 1);
	exit(0);
    }

    print STDERR "INFO - cache present but files not found - will upload them when done\n";

    # bucket defined, but files not found: they should be uploaded when done
    $upload_to_cache = 1;
}

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
if ($basename =~ /\.bam$/) {
    if ($is_s3_uri) {
	&run_sys_command("aws s3 cp ${bam_or_cram_uri}.bai ./", 0);
    } else {
	&run_sys_command("curl -O ${bam_or_cram_uri}.bai", 0);
    }
}
elsif ($basename =~ /\.cram$/) {
    die "can't convert CRAM to BAM without reference FASTA" if (!defined($ref_fasta));
    &run_sys_command("samtools view -T $ref_fasta -o $bam_basename $basename");
    $basename = $bam_basename;
} 
else {
    die "unrecognized sequence file type (not BAM or CRAM) for " . $bam_or_cram_uri;
}

# 3. if no BAM index, create one with samtools
if (! -e $bai_basename) {
    &run_sys_command("samtools index $basename");
}

# upload results to cache
if ($upload_to_cache) {
    print STDERR "INFO - uploading $basename to cache at $s3_bucket_uri\n";
    &run_sys_command("aws s3 cp $basename ${s3_bucket_uri}/", 1);
    &run_sys_command("aws s3 cp $bai_basename ${s3_bucket_uri}/", 1);
}

exit(0);

# --------------------------------------------
## subroutines
# --------------------------------------------

sub check_parameters {
  my $options = shift;
    
  ## make sure required parameters were passed
  my @required = qw(bam_or_cram_uri);
  for my $option ( @required ) {
    unless ( defined $options->{$option} ) {
      die("--$option is a required option");
    }
  }

  ## ensure ref_fasta exists
  if (defined($options->{'ref_fasta'})) {
      my $ref_fasta = $options->{'ref_fasta'};
      if (!-e $ref_fasta || !-r $ref_fasta) {
	  die("ref_fasta file $ref_fasta does not exist or could not be read.")
      }
  }

  ## check s3_bucket exists 
  # TODO - and is writable?
  if (defined($options->{'s3_bucket_uri'})) {
      my $s3_bucket_uri = $options->{'s3_bucket_uri'};
      if (!&s3_uri_exists($s3_bucket_uri)) {
	  die "S3 bucket $s3_bucket_uri does not exist or could not be read.";
      }
  }
}

# check whether S3 URI exists
sub s3_uri_exists {
    my($s3_uri) = @_;
    my $err = &run_sys_command("aws s3 ls $s3_uri", 0);
    if ($err =~ /child exited with/) { 
	return 0;
    }
    return 1;
}

sub run_sys_command {
  my($cmd, $halt_on_err) = @_;
  print STDERR "INFO - running $cmd\n";
  system($cmd);

  # check for errors, optional halt if any are found
  my $err = undef;
  if ($? == -1) {
    $err = "failed to execute: $!";
  }
  elsif ($? & 127) {
    $err = sprintf("child died with signal %d, %s coredump", ($? & 127), ($? & 128) ? 'with' : 'without');
  }
  else {
    my $exit_val = $? >> 8;
    $err = sprintf("child exited with value %d", $exit_val) if ($exit_val != 0);
  }
  die $err if (defined($err) && $halt_on_err);
  return $err;
}
