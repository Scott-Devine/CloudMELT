cwlVersion: v1.0
class: Workflow

requirements:
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: preproc-bam-type.yml

inputs:
  preprocessed_bam_files:
    type:
      type: array
      items: preproc-bam-type.yml#PreprocessedBAM
  bwa_used: boolean?
  excluded_chromosomes: string?
  exome_mode: boolean?
  ref_fasta_file:
    type: File
    secondaryFiles:
      - .fai
  min_contig_len: int?
  phred64: boolean?
  genes_bed_file: File
  read_length: int?
  max_reads_in_mem: int?
  transposon_zip_file: File
  expected_insert_size: int?
  filter_lt_srs: int?
  priors_vcf: File?
  no_call_percent: int?
  remove_ac0_sites: boolean?
  group_stdev_cutoff: int?
  makevcf_stdev_cutoff: float?

outputs: 
  vcf_file:
    type: File
    outputSource: vcf/vcf_file

steps:
  ind:
    run: melt-ind.cwl
    scatter: preprocessed_bam_file
    in:
      preprocessed_bam_file: preprocessed_bam_files
      ref_fasta_file: ref_fasta_file
      transposon_zip_file: transposon_zip_file
      bwa_used: bwa_used
      excluded_chromosomes: excluded_chromosomes
      min_contig_len: min_contig_len
      exome_mode: exome_mode
      phred64: phred64
      read_length: read_length
      max_reads_in_mem: max_reads_in_mem
    out: [aligned_bam_file, hum_breaks_bam_file, pulled_bam_file, tmp_bed_file]

  grp:
    run: melt-grp.cwl
    in:
      aligned_bam_files: ind/aligned_bam_file
      hum_breaks_bam_files: ind/hum_breaks_bam_file
      pulled_bam_files: ind/pulled_bam_file
      tmp_bed_files: ind/tmp_bed_file
      bwa_used: bwa_used
      group_stdev_cutoff: group_stdev_cutoff
      ref_fasta_file: ref_fasta_file
      ref_bed_file: genes_bed_file
      phred64: phred64
      read_length: read_length
      filter_lt_srs: filter_lt_srs
      transposon_zip_file: transposon_zip_file
      priors_vcf: priors_vcf
      max_reads_in_mem: max_reads_in_mem
    out: [pre_geno_file]

  gen:
    run: melt-gen.cwl
    scatter: preprocessed_bam_file
    in:
      pre_geno_file: grp/pre_geno_file
      preprocessed_bam_file: preprocessed_bam_files
      min_contig_len: min_contig_len
      expected_insert_size: expected_insert_size
      ref_fasta_file: ref_fasta_file
      phred64: phred64
      transposon_zip_file: transposon_zip_file
      max_reads_in_mem: max_reads_in_mem
    out: [geno_file]

  vcf:
    run: melt-vcf.cwl
    in:
      pre_geno_file: grp/pre_geno_file
      geno_files: gen/geno_file
      remove_ac0_sites: remove_ac0_sites
      ref_fasta_file: ref_fasta_file
      no_call_percent: no_call_percent
      makevcf_stdev_cutoff: makevcf_stdev_cutoff
      transposon_zip_file: transposon_zip_file

    out: [vcf_file]
