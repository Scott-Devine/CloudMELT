#!/usr/bin/perl

use strict;
use FileHandle;
use File::Spec;

## globals
my $USAGE = "Usage: $0 config_file sample_list dest_dir sample_regex";

## input
my $config_file = shift || die $USAGE;
my $sample_list_file = shift || die $USAGE;
my $dest_dir = shift || die $USAGE;
my $sample_regex = shift || '([A-Z0-9]+)\.mapped';

## main program

# read sample_list_file, parse out sample ids
my $sample_list = [];
my $samples = {};

my $fh = FileHandle->new();
$fh->open($sample_list_file) || die "unable to read $sample_list_file";
while (my $line = <$fh>) {
    chomp($line);
    if ($line =~ /\S/) {
	my($sample) = ($line =~ /$sample_regex/);
	die "couldn't parse sample id from $line" if (!defined($sample));
	die "duplicate sample id $sample" if (defined($samples->{$sample}));
       	push(@$sample_list, { 'uri' => $line, 'sample' => $sample });
	$samples->{$sample} = 1;
    }
}
$fh->close();
print STDERR "INFO - read " . scalar(@$sample_list) . " sample(s) from $sample_list_file\n";

# read config_file
my $config = "";
$fh->open($config_file) || die "unable to read $config_file";
while (my $line = <$fh>) {
    next if ($line =~ /^reads_bam_uri/);
    $config .= $line;
}
$fh->close();

# write step 1 master config file
my $mcfh = FileHandle->new();
my $master_path = File::Spec->catfile($dest_dir, "step-1.yml");
$mcfh->open(">$master_path") || die "unable to write to $master_path";
print $mcfh <<CONFIG;
cwl_files:
 - { class: File, path: ../melt-split-pre-mosdepth-cov-ind.cwl }
 - { class: File, path: ../melt-pre.cwl }
 - { class: File, path: ../melt-cov-mosdepth.cwl }
 - { class: File, path: ../mosdepth.cwl }
 - { class: File, path: ../melt-ind.cwl }
melt_config_files:
CONFIG

# write per-sample config files
foreach my $u (@$sample_list) {
    print STDERR "INFO - writing step 1 config files for $u->{'sample'}\n";
    my $sample_config = "step-1-pre-" . $u->{'sample'} . ".yml";
    my $sample_config_path = File::Spec->catfile($dest_dir, $sample_config);
    my $cfh = FileHandle->new();
    $cfh->open(">$sample_config_path") || die "unable to write to $sample_config_path";
    $cfh->print("reads_bam_uri: " . $u->{'uri'}. "\n");
    $cfh->print($config);
    $cfh->close();
    $mcfh->print(" - { class: File, path: $sample_config }\n");
}

$mcfh->close();
exit(0);

