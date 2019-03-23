#!/usr/bin/perl

use strict;
use FileHandle;
use File::Spec;

## globals
my $USAGE = "Usage: $0 step1_conf step2_conf sample_list dest_dir sample_regex";

my $OUTDIR = "/toil/";
my $INDIR = "../";

# cwl and yml files needed by each step
my $CWL_FILES = {
    'step1' => ['melt-split-pre-mosdepth-cov-ind.cwl',
		'melt-pre.cwl',
		'melt-cov-mosdepth.cwl',
		'mosdepth.cwl',
		'melt-ind.cwl'],
    'step2' => [ 'melt-grp.cwl',
		 'step-input-type.yml'],
    'step3' => [ 'melt-split-gen.cwl',
		 'melt-gen.wl',
		 'transposon-file-type.yml'],
    'step4' => [ 'melt-vcf.cwl' ]
};

## input
my $config_files = {};
$config_files->{'step1'} = shift || die $USAGE;
$config_files->{'step2'} = shift || die $USAGE;
my $sample_list_file = shift || die $USAGE;
my $dest_dir = shift || die $USAGE;
my $sample_regex = shift || '([A-Z0-9]+)\.mapped';

## main program

# --------------------------------------------
# read sample_list_file, parse sample ids
# --------------------------------------------
my $sample_list = [];
my $samples = {};
my $prefixes = {};

my $fh = FileHandle->new();
$fh->open($sample_list_file) || die "unable to read $sample_list_file";
while (my $line = <$fh>) {
    chomp($line);
    if ($line =~ /\S/) {
	my($sample) = ($line =~ /$sample_regex/);
	die "couldn't parse sample id from $line" if (!defined($sample));
	die "duplicate sample id $sample" if (defined($samples->{$sample}));
	my($prefix) = ($line =~ /([^\/]+)\.bam$/);
	die "couldn't parse file prefix from $line" if (!defined($prefix));
	die "duplicate prefix $prefix" if (defined($prefixes->{$prefix}));
       	push(@$sample_list, { 'uri' => $line, 'sample' => $sample, 'prefix' => $prefix });
	$samples->{$sample} = 1;
    }
}
$fh->close();
print STDERR "INFO - read " . scalar(@$sample_list) . " sample(s) from $sample_list_file\n";

# --------------------------------------------
# read config_files, parse transposons
# --------------------------------------------
my $transposons = [];
my $configs = {};
my $in_transposons = 0;

foreach my $step ('step1', 'step2') {
    my $cfile = $config_files->{$step};
    $configs->{$step} = "";

    $fh->open($cfile) || die "unable to read $step config file $cfile";
    while (my $line = <$fh>) {
	next if ($line =~ /^reads_bam_uri/);
	$configs->{$step} .= $line;

	# parse transposons from step-1-pre
	if ($step eq 'step1') {
	    if ($line =~ /transposon_zip_files:/) {
		$in_transposons = 1;
		next;
	    } elsif ($in_transposons && $line =~ /^\S/) {
		$in_transposons = 0;
		next;
	    }
	    if ($in_transposons) {
		if ($line =~ /path:\s*(\S+\/([^\/]+)_MELT\.zip)/) {
		    push(@$transposons, {'zip_file' => $1, 'name' => $2 });
		} else {
		    die "unable to parse transposon zip file from $line";
		}
	    }
	}
    }
}

print STDERR "INFO - read " . scalar(@$transposons) . " transposon(s) from " . $config_files->{'step1'} . "\n";
$fh->close();

# --------------------------------------------
# init master config files
# --------------------------------------------
my $m_fhs = {};
foreach my $step (1..4) {
    my $fh = $m_fhs->{"step${step}"} = FileHandle->new();
    my $path = File::Spec->catfile($dest_dir, "step-${step}.yml");
    $fh->open(">$path") || die "unable to write to $path";
    print $fh "cwl_files:\n";
    print $fh join("\n", map {" - { class: File, path: ../" . $_ . "}"} @{$CWL_FILES->{"step${step}"}});
    print $fh "\n";
    print $fh "melt_config_files:\n" if ($step != 2);
}

# per-sample config files
foreach my $u (@$sample_list) {
    print STDERR "INFO - writing step 1 config files for $u->{'sample'}\n";

    # step 1
    my $sample_config = "step-1-pre-" . $u->{'sample'} . ".yml";
    my $sample_config_path = File::Spec->catfile($dest_dir, $sample_config);
    my $cfh = FileHandle->new();
    $cfh->open(">$sample_config_path") || die "unable to write to $sample_config_path";
    $cfh->print("reads_bam_uri: " . $u->{'uri'}. "\n");
    $cfh->print($configs->{'step1'});
    $cfh->close();
    $m_fhs->{'step1'}->print(" - { class: File, path: $sample_config }\n");
}

# report files that should be returned by step1 for a specific transposon
my $get_step1_files = sub {
    my($transposon, $suffixes) = @_;
    my $files = [];
    foreach my $sample (@$sample_list) {
	my $prefix = $sample->{'prefix'};
	foreach my $suffix (@$suffixes) {
	    push(@$files, join(".", $prefix, $transposon, $suffix));
	}
    }
    return $files;
};
  
my $print_file_list = sub {
    my($fh, $name, $files, $prefix) = @_;
    $fh->print("${name}:\n");
    foreach my $file (@$files) {
	$fh->print(" - { class: File, path: ${prefix}${file} }\n");
    }
};

my $print_comma_delim_file_list = sub {
    my($fh, $name, $files, $prefix) = @_;
    $fh->print(join(",", map {"{ class: File, path: ${prefix}$_ }"} @$files));
};


# per-transposon config files
$m_fhs->{'step2'}->print("transposons:\n");

foreach my $t (@$transposons) {

    # step 2
    my $transposon_config = "step-2-grp-" . $t->{'name'} . ".yml";
    my $transposon_config_path = File::Spec->catfile($dest_dir, $transposon_config);
    my $cfh = FileHandle->new();
    $cfh->open(">$transposon_config_path") || die "unable to write to $transposon_config_path";

    # step2 master file
    $m_fhs->{'step2'}->print(" - { melt_config_file: { class: File, path: $transposon_config }, input_files: [");

    # step2 template
    $cfh->print($configs->{'step2'});

    # add transposon_zip_file
    $cfh->print("transposon_zip_file: { class: File, path: " . $t->{'zip_file'} . "}\n");

    my $step2_input_files = [];

    my $aligned_bam_files = &$get_step1_files($t->{'name'}, ['aligned.final.sorted.bam']);
    my $aligned_bai_files = &$get_step1_files($t->{'name'}, ['aligned.final.sorted.bam.bai']);
    &$print_file_list($cfh, 'aligned_bam_files', $aligned_bam_files, $OUTDIR);
    push(@$step2_input_files, @$aligned_bam_files);
    push(@$step2_input_files, @$aligned_bai_files);

    my $hum_breaks_bam_files = &$get_step1_files($t->{'name'}, ['hum_breaks.sorted.bam']);
    my $hum_breaks_bai_files = &$get_step1_files($t->{'name'}, ['hum_breaks.sorted.bam.bai']);
    &$print_file_list($cfh, 'hum_breaks_bam_files', $hum_breaks_bam_files, $OUTDIR);
    push(@$step2_input_files, @$hum_breaks_bam_files);
    push(@$step2_input_files, @$hum_breaks_bai_files);

    my $pulled_bam_files = &$get_step1_files($t->{'name'}, ['pulled.sorted.bam']);
    my $pulled_bai_files = &$get_step1_files($t->{'name'}, ['pulled.sorted.bam.bai']);
    &$print_file_list($cfh, 'pulled_bam_files', $pulled_bam_files, $OUTDIR);
    push(@$step2_input_files, @$pulled_bam_files);
    push(@$step2_input_files, @$pulled_bai_files);

    my $tmp_bed_files = &$get_step1_files($t->{'name'}, ['tmp.bed']);
    &$print_file_list($cfh, 'tmp_bed_files', $tmp_bed_files, $OUTDIR);
    push(@$step2_input_files, @$tmp_bed_files);
    $cfh->close();

    # step2 master file
    &$print_comma_delim_file_list($m_fhs->{'step2'}, 'input_files', $step2_input_files, $INDIR);
    $m_fhs->{'step2'}->print("]}\n");
}

# close master filehandles
map { $_->close() } values %$m_fhs; 

exit(0);

