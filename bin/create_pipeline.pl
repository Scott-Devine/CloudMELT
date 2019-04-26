#!/usr/bin/env perl

=head1 NAME

create_pipeline.pl - Create a CloudMELT pipeline to run a MELT-Split analysis on AWS EC2.

=head1 SYNOPSIS

  create_pipeline.pl
         --sample_uri_list=./sample_list.txt
         --config_dir=./melt-config
         --workflow_dir=./melt-workflow
         --toil_jobstore='aws:us-east-1:tj1'
         --docker_image_uri=123456789.ecr.us-east-1.amazonaws.com/umigs/melt:hg19-latest
         --coverage_method=mosdepth|user
       [ --sample_regex='([A-Z0-9]+)\.mapped'
         --cloud_melt_home=/path/to/CloudMELT
         ]

=back

=head1 DESCRIPTION

Creates a CloudMELT pipeline to run a MELT-Split analysis on AWS EC2.

=head1 CONTACT

  Jonathan Crabtree
  jcrabtree@som.umaryland.edu

=cut

use strict;
use Getopt::Long qw(:config no_ignore_case no_auto_abbrev pass_through);
use FileHandle;
use File::Spec;
use Pod::Usage;

# --------------------------------------------
## globals
# --------------------------------------------
my $DEFAULT_SAMPLE_REGEX = '([A-Z0-9]+)\.mapped';
my $TOIL_INPUT_DIR = "../";
my $TOIL_OUTPUT_DIR = "/toil/";

# coverage methods and corresponding step 1 file
my $COVERAGE_METHODS = {
    'mosdepth' => 'melt-split-pre-mosdepth-cov-ind.cwl',
    'user' => 'melt-split-pre-user-cov-ind.cwl',
};

# list of workflow steps and associated files
my $STEPS = [
    { 
	'name' => 'step1', 
	'cwl' => 'melt-split-step-1.cwl',
	'config_in' => 'step-1-pre.yml', 
	'files' =>
	    ['melt-split-step-1b.cwl',
	     'melt-split-pre-mosdepth-cov-ind.cwl', # includes both coverage methods
	     'melt-split-pre-user-cov-ind.cwl',
	     'melt-pre.cwl',
	     'melt-cov-mosdepth.cwl',
	     'mosdepth.cwl',
	     'melt-cov-user.cwl',
	     'melt-ind.cwl']
    },
    { 
	'name' => 'step2',
	'cwl' => 'melt-split-step-2.cwl',
	'config_in' => 'step-2-grp.yml',
	'files' => 
	    [ 'melt-split-step-2b.cwl',
	      'melt-grp.cwl',
	      'step-input-type.yml']
    },
    {
	'name' => 'step3',
	'cwl' => 'melt-split-step-3.cwl',
	'config_in' => 'step-3-gen.yml',
	'files' => 
	    [ 'melt-split-step-3b.cwl',
	      'melt-split-gen.cwl',
	      'melt-gen.cwl',
	      'transposon-file-type.yml',
	      'step-input-type.yml']
    },
    { 
	'name' => 'step4',
	'cwl' => 'melt-split-step-4.cwl',
	'config_in' => 'step-4-vcf.yml',
	'files' =>
	    [ 'melt-split-step-4b.cwl',
	      'melt-vcf.cwl',
	      'step-input-type.yml']
    }
    ];

# index by name
my $STEPS_H = {};
map { $STEPS_H->{$_->{'name'}} = $_; } @$STEPS;

# --------------------------------------------
## input
# --------------------------------------------
my $options = {};
&GetOptions($options,
	    "sample_uri_list=s",
	    "config_dir=s",
	    "workflow_dir=s",
	    "toil_jobstore=s",
	    "docker_image_uri=s",
	    "coverage_method=s",
	    "sample_regex=s",
	    "cloud_melt_home=s",
            "help|h",
            "man|m") || pod2usage();

# check parameters/set defaults 
&check_parameters($options);

# --------------------------------------------
## main program
# --------------------------------------------

# create output directory for config files
my $config_out = File::Spec->catfile($options->{'workflow_dir'}, 'config');
mkdir $config_out;

my $cwl_dir = File::Spec->catfile($options->{'cloud_melt_home'}, 'cwl');
die "$cwl_dir does not exist or is not a directory" if ((!-e $cwl_dir) || (!-d $cwl_dir));

# --------------------------------------------
# read sample_uri_list, parse sample ids
# --------------------------------------------
my $sample_regex = $options->{'sample_regex'};
my $sample_uri_list  = $options->{'sample_uri_list'};
my $sample_list = [];
my $samples = {};
my $prefixes = {};

my $fh = FileHandle->new();
$fh->open($sample_uri_list) || die "unable to read $sample_uri_list";
while (my $line = <$fh>) {
    chomp($line);
    if ($line =~ /\S/) {
	my($sample) = ($line =~ /$sample_regex/);
	die "couldn't parse sample id from $line using --sample_regex $sample_regex" if (!defined($sample));
	die "duplicate sample id $sample" if (defined($samples->{$sample}));
	my($prefix) = ($line =~ /([^\/]+)\.(bam|cram)$/);
	die "couldn't parse file prefix from $line" if (!defined($prefix));
	die "duplicate prefix $prefix" if (defined($prefixes->{$prefix}));
       	push(@$sample_list, { 'uri' => $line, 'sample' => $sample, 'prefix' => $prefix });
	$samples->{$sample} = 1;
    }
}
$fh->close();
print STDERR "INFO - read " . scalar(@$sample_list) . " sample(s) from $sample_uri_list\n";

# --------------------------------------------
# read config_files, parse transposons
# --------------------------------------------
my $transposons = [];
my $in_transposons = 0;

foreach my $step (@$STEPS) {
    my $cpath = $step->{'config_in_path'};
    $step->{'config'} = "";

    $fh->open($cpath) || die "unable to read $step config file $cpath";
    while (my $line = <$fh>) {
	next if ($line =~ /^reads_bam_uri/);
	$step->{'config'} .= $line;

	# parse transposons from step-1-pre
	if ($step->{'name'} eq 'step1') {
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
    if ($step->{'name'} eq 'step1') {
	print STDERR "INFO - read " . scalar(@$transposons) . " transposon(s) from " . $cpath . ": ";
	print STDERR join(", ", map { $_->{'name'} } @$transposons) . "\n";
    }
    $fh->close();
}

# --------------------------------------------
# init master config files
# --------------------------------------------
my $m_fhs = {};
foreach my $step (@$STEPS) {
    my $sname = $step->{'name'};
    my $fh = $m_fhs->{$sname} = FileHandle->new();
    my $path = File::Spec->catfile($config_out, "${sname}.yml");
    $fh->open(">$path") || die "unable to write to $path";
    print $fh "cwl_files:\n";
    print $fh join("\n", map {" - { class: File, path: ../" . $_ . "}"} @{$step->{'files'}});
    print $fh "\n";
    if ($step == 1) {
	print $fh "melt_config_files:\n";
    } else {
	print $fh "transposons:\n";
    }
}

# step 2 output files - pre_geno.tsv files
my $pre_geno_files = [];
foreach my $t (@$transposons) {
    push(@$pre_geno_files, "{ class: File, path: ../" . $t->{'name'} . ".pre_geno.tsv }");
}

# --------------------------------------------
# write per-sample config files
# --------------------------------------------
foreach my $u (@$sample_list) {
    print STDERR "INFO - writing step 1 config files for $u->{'sample'}\n";

    # step 1
    my $sample_config = "step-1-pre-" . $u->{'sample'} . ".yml";
    my $sample_config_path = File::Spec->catfile($config_out, $sample_config);
    my $cfh = FileHandle->new();
    $cfh->open(">$sample_config_path") || die "unable to write to $sample_config_path";
    $cfh->print("reads_bam_uri: " . $u->{'uri'}. "\n");
    $cfh->print($STEPS_H->{'step1'}->{'config'});
    $cfh->close();
    $m_fhs->{'step1'}->print(" - { class: File, path: $sample_config }\n");

    # step 3
    my $step3_config = "step-3-gen-" . $u->{'sample'} . ".yml";
    my $step3_config_path = File::Spec->catfile($config_out, $step3_config);
    my $cfh = FileHandle->new();
    $cfh->open(">$step3_config_path") || die "unable to write to $step3_config_path";
    $cfh->print("reads_bam_uri: " . $u->{'uri'}. "\n");
    $cfh->print($STEPS_H->{'step3'}->{'config'});
    $cfh->close();

    $m_fhs->{'step3'}->print(" - { melt_config_file: { class: File, path: $step3_config }, input_files: [");
    $m_fhs->{'step3'}->print(join(",", @$pre_geno_files));
    $m_fhs->{'step3'}->print(" ]}\n");
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

# --------------------------------------------
# write per-transposon config files
# --------------------------------------------
foreach my $t (@$transposons) {

    # step 2
    my $step2_config = "step-2-grp-" . $t->{'name'} . ".yml";
    my $step2_config_path = File::Spec->catfile($config_out, $step2_config);
    my $cfh = FileHandle->new();
    $cfh->open(">$step2_config_path") || die "unable to write to $step2_config_path";

    # step2 master file
    $m_fhs->{'step2'}->print(" - { melt_config_file: { class: File, path: $step2_config }, input_files: [");

    # step2 template
    $cfh->print($STEPS_H->{'step2'}->{'config'});

    # add transposon_zip_file
    $cfh->print("transposon_zip_file: { class: File, path: " . $t->{'zip_file'} . "}\n");

    my $step2_input_files = [];

    my $aligned_bam_files = &$get_step1_files($t->{'name'}, ['aligned.final.sorted.bam']);
    my $aligned_bai_files = &$get_step1_files($t->{'name'}, ['aligned.final.sorted.bam.bai']);
    &$print_file_list($cfh, 'aligned_bam_files', $aligned_bam_files, $TOIL_OUTPUT_DIR);
    push(@$step2_input_files, @$aligned_bam_files);
    push(@$step2_input_files, @$aligned_bai_files);

    my $hum_breaks_bam_files = &$get_step1_files($t->{'name'}, ['hum_breaks.sorted.bam']);
    my $hum_breaks_bai_files = &$get_step1_files($t->{'name'}, ['hum_breaks.sorted.bam.bai']);
    &$print_file_list($cfh, 'hum_breaks_bam_files', $hum_breaks_bam_files, $TOIL_OUTPUT_DIR);
    push(@$step2_input_files, @$hum_breaks_bam_files);
    push(@$step2_input_files, @$hum_breaks_bai_files);

    my $pulled_bam_files = &$get_step1_files($t->{'name'}, ['pulled.sorted.bam']);
    my $pulled_bai_files = &$get_step1_files($t->{'name'}, ['pulled.sorted.bam.bai']);
    &$print_file_list($cfh, 'pulled_bam_files', $pulled_bam_files, $TOIL_OUTPUT_DIR);
    push(@$step2_input_files, @$pulled_bam_files);
    push(@$step2_input_files, @$pulled_bai_files);

    my $tmp_bed_files = &$get_step1_files($t->{'name'}, ['tmp.bed']);
    &$print_file_list($cfh, 'tmp_bed_files', $tmp_bed_files, $TOIL_OUTPUT_DIR);
    push(@$step2_input_files, @$tmp_bed_files);
    $cfh->close();

    # step2 master file
    &$print_comma_delim_file_list($m_fhs->{'step2'}, 'input_files', $step2_input_files, $TOIL_INPUT_DIR);
    $m_fhs->{'step2'}->print("]}\n");

    # step4 template
    my $step4_config = "step-4-vcf-" . $t->{'name'} . ".yml";
    my $step4_config_path = File::Spec->catfile($config_out, $step4_config);
    my $cfh = FileHandle->new();
    $cfh->open(">$step4_config_path") || die "unable to write to $step4_config_path";
    $cfh->print($STEPS_H->{'step4'}->{'config'});
    # add transposon_zip_file
    $cfh->print("transposon_zip_file: { class: File, path: " . $t->{'zip_file'} . "}\n");

    # step4 master file
    $m_fhs->{'step4'}->print(" - { melt_config_file: { class: File, path: $step4_config }, input_files: [");

    my $step4_input_files = [];
    my $geno_files = &$get_step1_files($t->{'name'}, ['tsv']);
    # pre_geno_file
    $cfh->print("pre_geno_file: { class: File, path: /toil/" . $t->{'name'} . ".pre_geno.tsv }\n");
    push(@$step4_input_files, $t->{'name'} . ".pre_geno.tsv");

    # geno files
    &$print_file_list($cfh, 'geno_files', $geno_files, $TOIL_OUTPUT_DIR);
    push(@$step4_input_files, @$geno_files);
    $cfh->close();

    # step4 master file
    &$print_comma_delim_file_list($m_fhs->{'step4'}, 'input_files', $step4_input_files, $TOIL_INPUT_DIR);
    $m_fhs->{'step4'}->print("]}\n");
    
}

# close master filehandles
map { $_->close() } values %$m_fhs; 

# --------------------------------------------
# copy cwl files into workflow dir
# --------------------------------------------
my $files_copied = {};

# keyword-based substitutions
my $cwl_subs = {
    'COVERAGE_CWL_FILE' => $COVERAGE_METHODS->{$options->{'coverage_method'}},
    'DOCKER_IMAGE_URI' => $options->{'docker_image_uri'},
};

# copy CWL file, performing keyword substitutions as needed
my $copy_cwl_file = sub {
    my($from_file, $to_file) = @_;
    my $ifh = FileHandle->new();
    $ifh->open($from_file) || die "unable to read from $from_file";

    my $ofh = FileHandle->new();
    $ofh->open(">$to_file") || die "unable to write to $to_file";
    
    while (my $line = <$ifh>) {
	# <keyword> in CWL file triggers keyword substitution
	# assumes at most one substitution per line
	if ($line =~ /\<([A-Z_]+)\>/) {
	    my $key = $1;
	    if (!defined($cwl_subs->{$key})) {
		die "no substitution found for keyword $key";
	    }
	    $line =~ s/\<([A-Z_]+)\>/$cwl_subs->{$key}/e;
	    die "multiple substitutions found in $from_file" if ($line =~ /\<([A-Z_]+)\>/);
	}
	print $ofh $line;
    }
    
    map { $_->close() } ($ifh, $ofh);
};

foreach my $step (@$STEPS) {
    foreach my $file ($step->{'cwl'}, @{$step->{'files'}}) {
	next if (defined($files_copied->{$file}));
	my $from_path = File::Spec->catfile($cwl_dir, $file);
	my $to_path = File::Spec->catfile($options->{'workflow_dir'}, $file);
	die "$from_path not found" if (!-e $from_path);
	print STDERR "INFO - copying $from_path to $to_path\n";
	die "$to_path already exists - please remove and rerun" if (-e $to_path);
	&$copy_cwl_file($from_path, $to_path);
	$files_copied->{$file} = 1;
    }
}

# --------------------------------------------
# create helper script(s)
# --------------------------------------------

# create run-workflow.sh
my $run_file = "run-workflow.sh";
my $run_path = File::Spec->catfile($options->{'workflow_dir'}, $run_file);
my $rfh = FileHandle->new();
$rfh->open(">$run_path") || die "couldn't write to $run_path";
$rfh->print("#!/bin/bash\n\n");
$rfh->print("export RUNNER='toil-cwl-runner --retryCount 0'\n\n");

foreach my $step (@$STEPS) {
    my $sname = $step->{'name'};
    my $cwl = $step->{'cwl'};
    my $conf_path = File::Spec->catfile($config_out, "${sname}.yml");
    $rfh->print("# $sname\n");
    $rfh->print("time \$RUNNER ");
    $rfh->print("--jobStore '" . $options->{'toil_jobstore'} . "' ");
    $rfh->print(" --logFile melt-split-${sname}.log ");
    $rfh->print(" --batchSystem mesos ");
    $rfh->print(" $cwl $conf_path ");
    $rfh->print("\n\n");
}
$rfh->close();

# --------------------------------------------
# create tarball
# --------------------------------------------
my $wf_dir = $options->{'workflow_dir'};
print STDERR "INFO - creating ${wf_dir}.tar.gz\n";
&run_sys_command("tar czvf ${wf_dir}.tar.gz $wf_dir");

exit(0);

# --------------------------------------------
## subroutines
# --------------------------------------------
sub check_parameters {
  my $options = shift;
    
  ## make sure required parameters were passed
  my @required = qw(sample_uri_list config_dir workflow_dir toil_jobstore docker_image_uri coverage_method);
  for my $option ( @required ) {
    unless ( defined $options->{$option} ) {
      die("--$option is a required option");
    }
  }

  ## check that a valid coverage_method is specified
  if (!defined($COVERAGE_METHODS->{$options->{'coverage_method'}})) {
      die($options->{'coverage_method'} . " is not a valid input for --coverage_method");
  }

  ## check that config_dir exists
  for my $opt ('config_dir') {
      die "--$opt=$options->{$opt} does not exist" if (!-e $options->{$opt});
      die "--$opt=$options->{$opt} is not a directory" if (!-d $options->{$opt});
  }

  if (!-e $options->{'workflow_dir'}) {
      print STDERR "$options->{'workflow_dir'} does not exist, creating it now\n";
      mkdir $options->{'workflow_dir'};
  }

  ## check for config files in config_in
  foreach my $step (@$STEPS) {
      my $conf_file = $step->{'config_in'};
      my $conf_path = $step->{'config_in_path'} = File::Spec->catfile($options->{'config_dir'}, $conf_file);
      die "config file $conf_path not found" if (!-e $conf_path);
  }

  ## check cloud_melt_home
  if (!defined($options->{'cloud_melt_home'})) {
      if (!defined($ENV{'CLOUD_MELT_HOME'})) {
	  die "--cloud_melt_home not defined and \$CLOUD_MELT_HOME env var not defined";
      }
      $options->{'cloud_melt_home'} = $ENV{'CLOUD_MELT_HOME'};
  }

  ## defaults
  $options->{'sample_regex'}= $DEFAULT_SAMPLE_REGEX if (!defined($options->{'sample_regex'}));

}

sub run_sys_command {
  my($cmd) = @_;
  system($cmd);

  # check for errors, halt if any are found
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
  die $err if (defined($err));
}
