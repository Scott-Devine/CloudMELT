#!/usr/bin/env perl

=head1 NAME

upload_file.pl - Upload a file to an S3 bucket.

=head1 SYNOPSIS

  upload_file.pl
   --file=/path/to/file_to_upload.ext
 [ --s3_bucket_uri=s3://temp_storage1 ]

=back

=head1 DESCRIPTION

Upload a file to an S3 bucket. Does nothing if no --s3_bucket_uri is specified.

=cut

use strict;
use Getopt::Long qw(:config no_ignore_case no_auto_abbrev pass_through);
use Pod::Usage;

# --------------------------------------------
## input
# --------------------------------------------
my $options = {};
&GetOptions($options,
	    "s3_bucket_uri=s",
	    "file=s",
            "help|h",
            "man|m") || pod2usage();

# check parameters/set defaults 
&check_parameters($options);

my $s3_bucket_uri = $options->{'s3_bucket_uri'};
my $file = $options->{'file'};

# --------------------------------------------
## main program
# --------------------------------------------

if (!defined($s3_bucket_uri)) {
    print STDERR "INFO - no --s3_bucket_uri specified, nothing to do\n";
} else {
    print STDERR "INFO - uploading $file to $s3_bucket_uri\n";
    &run_sys_command("aws s3 cp $file ${s3_bucket_uri}/", 1);
}

exit(0);

# --------------------------------------------
## subroutines
# --------------------------------------------

sub check_parameters {
  my $options = shift;
    
  ## make sure required parameters were passed
  my @required = qw();
  for my $option ( @required ) {
    unless ( defined $options->{$option} ) {
      die("--$option is a required option");
    }
  }

  ## check s3_bucket exists 
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
