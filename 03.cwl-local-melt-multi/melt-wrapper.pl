#!/usr/bin/env perl

# MELT wrapper for Toil/CWL that ensures that MELT will produce output files
# in the working directory, not the input directory.
#
# Example usage:
# 
# melt-wrapper.pl java -Xmx2G -jar MELT.jar Preprocess -h reference.fa -bamfile /path/to/cwl/inputdir/sample1.bam
#
# The wrapper will symlink /path/to/cwl/inputdir/sample1.bam and its corresponding
# .bai file to the current/working directory and then run MELT on the symlinks in 
# the working directory.
#
use strict;
use File::Basename;

my $new_args = [];
my $num_args = scalar(@ARGV);

for (my $i = 0;$i < $num_args; ++$i) {
    push(@$new_args, $ARGV[$i]);

    if ($ARGV[$i] eq '-bamfile') {
	my $bamfile = $ARGV[$i+1];
	# NOTE: these ln commands will succeed even if the source file does not exist
	# link BAM
	my $ln_cmd1 = ["ln", "-s", $bamfile, "."];
	my $ln_exitval1 = &run_sys_command(\@$ln_cmd1);
	exit($ln_exitval1) if $ln_exitval1 != 0;
	# link BAI
	my $ln_cmd2 = ["ln", "-s", $bamfile . ".bai", "."];
	my $ln_exitval2 = &run_sys_command(\@$ln_cmd2);
	exit($ln_exitval2) if $ln_exitval2 != 0;
	push(@$new_args, basename($bamfile));
	# skip the next argument
	++$i;
    }
}

# run MELT and return its exit value
my $melt_exitval = &run_sys_command($new_args);
exit($melt_exitval);

sub run_sys_command {
    my($cmd) = @_;
    system(@$cmd);
    my $exitval = undef;

    if ($? == -1) {
	print STDERR "$0 failed to execute: $!\n";
	$exitval = 1;
    }
    elsif ($? & 127) {
	print STDERR "$0 child died with signal %d, %s coredump\n", ($? & 127),  ($? & 128) ? 'with' : 'without';
	$exitval = 1;
    }
    else {
	$exitval = $? >> 8;
    }
    return $exitval;
}
