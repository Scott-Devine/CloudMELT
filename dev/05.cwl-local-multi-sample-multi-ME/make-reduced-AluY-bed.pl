#!/usr/bin/perl

use strict;
use FileHandle;

# bed_file is the original full BED file
# tsv_file is a .tsv file created by MELT Deletion-Genotype from that BED file
# output is a filtered BED file with only the MEs in the .tsv

my $USAGE = "Usage: $0 bed_file tsv_file > new_bed_file.bed";

## input
my $bed_file = shift || die $USAGE;
my $tsv_file = shift || die $USAGE;

## main program

# read sequence ids from $tsv_file
my $seq_ids = {};
my $tfh = FileHandle->new();
$tfh->open($tsv_file) || die "unable to read from $tsv_file";
while (my $line = <$tfh>) {
    my @f = split(/\t/, $line);
    $seq_ids->{$f[0]} = 1;
}
$tfh->close();

print STDERR "read " . scalar(keys %$seq_ids) . " sequence id(s) from $tsv_file\n";

# filter $bed_file to remove all sequence ids that don't appear in tsv file
my $bfh = FileHandle->new();
$bfh->open($bed_file) || die "unable to read from $bed_file";

while (my $line = <$bfh>) {
    my @f = split(/\t/, $line);
    if (defined($seq_ids->{$f[0]})) {
	print $line;
    }
}
$bfh->close();

exit(0);
