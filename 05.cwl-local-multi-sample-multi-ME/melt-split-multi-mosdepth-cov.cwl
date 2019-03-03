cwlVersion: v1.0
class: Workflow

requirements:
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: preproc-bam-type.yml

inputs:
  melt_jar_file: File
  ref_fasta_file:
    type: File
    secondaryFiles:
      - .fai
  reads_bam_files:
    type:
      type: array
      items: File
    secondaryFiles:
      - .bai
  transposon_zip_files:
    type:
      type: array
      items: File
  genes_bed_file: File
  bwa_used: boolean?
  bowtie2_path: File?
  excluded_chromosomes: string?
  exome_mode: boolean?
  min_contig_len: int?
  phred64: boolean?
  read_length: int?
  max_reads_in_mem: int?
  expected_insert_size: int?
  filter_lt_srs: int?
  priors_vcf: File?
  no_call_percent: int?
  remove_ac0_sites: boolean?
  group_stdev_cutoff: int?
  makevcf_stdev_cutoff: float?
  min_coverage: float?

outputs:
  vcf_files:
    type:
      type: array
      items: File
    outputSource: ind_grp_gen_vcf/vcf_file

steps:
  preprocess_coverage:
    run: melt-split-pre-mosdepth-cov.cwl
    scatter: reads_bam_file
    in:
      melt_jar_file: melt_jar_file
      ref_fasta_file: ref_fasta_file
      reads_bam_file: reads_bam_files
      min_coverage: min_coverage
    out: [preprocessed_bam_file]

  ind_grp_gen_vcf:
    run: melt-split-ind-grp-gen-vcf.cwl
    scatter: transposon_zip_file
    in:
      melt_jar_file: melt_jar_file
      preprocessed_bam_files: preprocess_coverage/preprocessed_bam_file
      ref_fasta_file: ref_fasta_file
      bwa_used: bwa_used
      bowtie2_path: bowtie2_path
      excluded_chromosomes: excluded_chromosomes
      exome_mode: exome_mode
      min_contig_len: min_contig_len
      phred64: phred64
      genes_bed_file: genes_bed_file
      read_length: read_length
      max_reads_in_mem: max_reads_in_mem
      transposon_zip_file: transposon_zip_files
      expected_insert_size: expected_insert_size
      filter_lt_srs: filter_lt_srs
      priors_vcf: priors_vcf
      no_call_percent: no_call_percent
      remove_ac0_sites: remove_ac0_sites
      group_stdev_cutoff: group_stdev_cutoff
      makevcf_stdev_cutoff: makevcf_stdev_cutoff

    out: [vcf_file]
