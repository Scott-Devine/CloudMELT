#!/usr/bin/env perl

use strict;
use FileHandle;

# Extract reads for a single chromosome from a BAM file for use in MELT.

## globals

my $USAGE = "Usage: $0 refseqid input.bam filtered.bam";

## input
my $refseqid = shift || die $USAGE;
my $input_bam  = shift || die $USAGE;
my $filtered_bam = shift || die $USAGE;

## main program
my $tmp_bam = $filtered_bam . ".tmp";

# copy BAM file header
my $cmd1 = "samtools view -H $input_bam > $tmp_bam";
&run_sys_command($cmd1);

# pass 1 - copy matching reads from BAM
my $cmd2 = "samtools view $input_bam |";
my $ifh = FileHandle->new();
$ifh->open($cmd2);
my $ofh = FileHandle->new();
$ofh->open(">>$tmp_bam");

my $read_ids = {};
my $lnum = 0;

while (my $line = <$ifh>) {
  my @f = split(/\t/, $line);
  if ($f[2] eq $refseqid) {
    $ofh->print($line);
    $read_ids->{$f[0]} = 1;
  }
  ++$lnum;
  print STDERR "pass 1/line $lnum\n" if ($lnum % 100000 == 0);
}

$ifh->close();

# pass 2 - add the reads' mates
$ifh->open($cmd2);
while (my $line = <$ifh>) {
  my @f = split(/\t/, $line);
  if (($f[2] ne $refseqid) && (defined($read_ids->{$f[0]}))) {
    $ofh->print($line);
  }
  ++$lnum;
  print STDERR "pass 2/line $lnum\n" if ($lnum % 100000 == 0);
}
$ofh->close();

# convert SAM back to BAM
my $cmd3 = "samtools view -b -o $filtered_bam $tmp_bam";
&run_sys_command($cmd3);

# remove temporary file
unlink $tmp_bam;

exit(0);

## subroutines

sub run_sys_command {
    my($cmd) = @_;
    system($cmd);
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
