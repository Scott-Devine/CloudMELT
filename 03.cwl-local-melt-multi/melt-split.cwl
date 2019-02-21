cwlVersion: v1.0
class: Workflow

requirements:
  SubworkflowFeatureRequirement: {}

inputs:
  melt_jar_file: File
  bwa_used: boolean?
  bowtie2_path: File?
  excluded_chromosomes: string?
  exome_mode: boolean?
  ref_fasta_file:
    type: File
    secondaryFiles:
      - .fai
  min_contig_len: int?
  phred64: boolean?
  reads_bam_file:
     type: File
     secondaryFiles:
      - .bai
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
  pre_ind_cov:
    run: melt-split-pre-ind-cov.cwl
    in:
      melt_jar_file: melt_jar_file
      ref_fasta_file: ref_fasta_file
      reads_bam_file: reads_bam_file
      genes_bed_file: genes_bed_file
      bwa_used: bwa_used
      excluded_chromosomes: excluded_chromosomes
      bowtie2_path: bowtie2_path
      coverage_estimate:
        default: 8
      min_contig_len: min_contig_len
      exome_mode: exome_mode
      phred64: phred64
      read_length: read_length
      transposon_zip_file: transposon_zip_file
      max_reads_in_mem: max_reads_in_mem
    out: [aligned_bam_file, hum_breaks_bam_file, pulled_bam_file, tmp_bed_file]

  grp:
    run: melt-grp.cwl
    in:
      aligned_bam_file: pre_ind_cov/aligned_bam_file
      hum_breaks_bam_file: pre_ind_cov/hum_breaks_bam_file
      pulled_bam_file: pre_ind_cov/pulled_bam_file
      tmp_bed_file: pre_ind_cov/tmp_bed_file
      melt_jar_file: melt_jar_file
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
    in:
      pre_geno_file: grp/pre_geno_file
      melt_jar_file: melt_jar_file
      reads_bam_file: reads_bam_file
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
      geno_file: gen/geno_file
      melt_jar_file: melt_jar_file
      remove_ac0_sites: remove_ac0_sites
      ref_fasta_file: ref_fasta_file
      no_call_percent: no_call_percent
      makevcf_stdev_cutoff: makevcf_stdev_cutoff
      transposon_zip_file: transposon_zip_file

    out: [vcf_file]
