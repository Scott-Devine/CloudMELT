#!/usr/bin/env perl

# Rewrite the .tmp.bed files produced by MELT IndividualAnalysis to ensure 
# that GroupAnalysis generates reproducible results. Without this workaround
# certain versions of MELT (including v2.0.5 - v2.1.5) may produce different
# output when run on different machines.
# 
# When run on a directory that contains the .tmp.bed files from IndividualAnalysis
# the script does the following:
#
# 1. Make a backup copy of each .tmp.bed file.
# 2. Sort the .tmp.bed files by name.
# 3. Concatenate the .tmp.bed files in that order to produce a new file, <me_name>.all.tmp.bed.
# 4. Replace one of the original .tmp.bed files with <me_name>.all.tmp.bed
# 5. Truncate all of the other .tmp.bed files to zero length.
# 
# This ensures that MELT GroupAnalysis will process the samples in the order
# determined by the sort in step 2, rather than the order determined by the
# Java API call to list the files in a directory (which is not guaranteed to
# be consistent.)

use strict;
use FileHandle;
use File::Spec;

## globals
my $USAGE = "Usage: $0 me_name tmp_bed_dir";

## input
my $me_name = shift || die $USAGE;
my $dir = shift || die $USAGE;
die "couldn't find specified directory - $dir" if (!-e $dir);
die "specified path ($dir) is not a directory" if (!-d $dir);

## main program

# read .tmp.bed files in current directory
opendir(RD, $dir);
my @bed_files = grep(/\.${me_name}\.tmp\.bed$/, readdir(RD));
closedir(RD);
my $nbf = scalar(@bed_files);
print STDERR "INFO - read $nbf .tmp.bed file(s) from $dir\n";

# 1. Make a backup copy of each .tmp.bed file.
foreach my $bf (@bed_files) {
    my $from_path = File::Spec->catfile($dir, $bf);
    my $to_path = File::Spec->catfile($dir, $bf . ".bak");
    &run_sys_command("cp $from_path $to_path", 1);
}

# 2. Sort the .tmp.bed files by name.
my @sorted_bed_files = sort @bed_files;

# 3. Concatenate the .tmp.bed files in that order to produce a new file, <me_name>.all.tmp.bed.
my $all_tmp_bed = $me_name . ".all.tmp.bed";
my $all_tmp_bed_path = File::Spec->catfile($dir, $all_tmp_bed);
die "$all_tmp_bed_path already exists" if (-e $all_tmp_bed_path);
my $afh = FileHandle->new();
$afh->open(">$all_tmp_bed_path") || die "unable to write to $all_tmp_bed_path";
my $bfh = FileHandle->new();

foreach my $bf (@sorted_bed_files) {
    my $bf_path = File::Spec->catfile($dir, $bf);
    $bfh->open($bf_path) || die "unable to read from $bf_path";
    while (my $line = <$bfh>) {
	print $afh $line;
    }
    $bfh->close();
}
$afh->close();

# 4. Replace one of the original .tmp.bed files with <me_name>.all.tmp.bed
my $to_path = File::Spec->catfile($dir, $sorted_bed_files[0]);
&run_sys_command("cp $all_tmp_bed_path $to_path", 1);
shift(@sorted_bed_files);

# 5. Truncate all of the other .tmp.bed files to zero length.
foreach my $bf (@sorted_bed_files) {
    my $bf_path = File::Spec->catfile($dir, $bf);
    &run_sys_command("rm $bf_path", 1);
    &run_sys_command("touch $bf_path", 1);
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
