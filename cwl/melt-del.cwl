cwlVersion: v1.0
class: Workflow

requirements:
  InlineJavascriptRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}

inputs:
  reads_bam_uri: string
  ref_fasta_file:
    type: File
    secondaryFiles:
      - .fai
  s3_bam_bucket_uri: string?
  s3_output_bucket_uri: string?
  me_bed_files:
    type:
      type: array
      items: File
  max_reads_in_mem: int?
  expected_insert_size: int?

outputs:
  del_tsv_files:
    type:
      type: array
      items: File
    outputSource: del/del_tsv_file

steps:
  get_bam_and_bai_file:
    run:
      class: CommandLineTool
      baseCommand: ['get_bam_and_bai.pl']
      inputs:
        reads_bam_uri:
          type: string
          inputBinding:
            position: 1
            prefix: --bam_or_cram_uri
        ref_fasta_file:
          type: File
          inputBinding:
            position: 2
            prefix: --ref_fasta
        s3_bam_bucket_uri:
          type: string?
          inputBinding:
            position: 3
            prefix: --s3_bucket_uri
      outputs:
       reads_bam_file:
          type: File
          outputBinding:
            glob: "*.bam"
       reads_bai_file:
          type: File
          outputBinding:
            glob: "*.bai"
    in:
      reads_bam_uri: reads_bam_uri
      ref_fasta_file: ref_fasta_file
      s3_bam_bucket_uri: s3_bam_bucket_uri
    out: [reads_bam_file, reads_bai_file]

  del:
    run: melt-del-gen-and-upload.cwl
    scatter: me_bed_file
    in:
      reads_bam_file: get_bam_and_bai_file/reads_bam_file
      reads_bai_file: get_bam_and_bai_file/reads_bai_file
      ref_fasta_file: ref_fasta_file
      me_bed_file: me_bed_files
      expected_insert_size: expected_insert_size
      max_reads_in_mem: max_reads_in_mem
      s3_output_bucket_uri: s3_output_bucket_uri
    out: [del_tsv_file]
