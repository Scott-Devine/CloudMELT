cwlVersion: v1.0
class: Workflow

requirements:
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  melt_jar_file: File
  reads_bam_files:
    type:
      type: array
      items: File
    secondaryFiles:
      - .bai
  me_bed_files:
    type:
      type: array
      items: File
  ref_fasta_file:
    type: File
    secondaryFiles:
      - .fai
  expected_insert_size: int?
  max_reads_in_mem: int?
  min_contig_len: int?

outputs:
  vcf_files:
    type:
      type: array
      items: File
    outputSource: melt_del/vcf_file

steps:
  melt_del:
    run: melt-del.cwl
    scatter: me_bed_file
    in:
      melt_jar_file: melt_jar_file
      ref_fasta_file: ref_fasta_file
      reads_bam_files: reads_bam_files
      me_bed_file: me_bed_files
    out: [vcf_file]
