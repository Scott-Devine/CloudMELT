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

## globals

# the suffixes of the secondary files that need to be symlinked into the working
# directory along with the primary BAM file
my $RUNTIME_SUFFIXES = {
    'Preprocess' => ['','.bai'],
    'IndivAnalysis' => ['','.bai','.disc','.disc.bai','.fq'],
};

## main program

# track which MELT Runtime is being invoked
my $melt_runtime = undef;

my $new_args = [];
my $num_args = scalar(@ARGV);

for (my $i = 0;$i < $num_args; ++$i) {
    push(@$new_args, $ARGV[$i]);

    if ($ARGV[$i] =~ /^Preprocess|IndivAnalysis$/) {
	$melt_runtime = $ARGV[$i];
    }
    elsif ($ARGV[$i] eq '-bamfile') {
	my $bamfile = $ARGV[$i+1];
	push(@$new_args, basename($bamfile));

	foreach my $suffix (@{$RUNTIME_SUFFIXES->{$melt_runtime}}) {
	    # NOTE: the ln command will succeed even if the source file does not exist
	    my $ln_cmd = ["ln", "-s", $bamfile . $suffix, "."];
	    my $ln_exitval = &run_sys_command(\@$ln_cmd);
	    exit($ln_exitval) if $ln_exitval != 0;
	}

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
