cwlVersion: v1.0
class: Workflow

requirements:
  InlineJavascriptRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: transposon-file-type.yml

inputs:
  reads_bam_uri: string
  ref_fasta_file:
    type: File
    secondaryFiles:
      - .fai
  s3_bam_bucket_uri: string
  transposon_files:
    type:
      type: array
      items: transposon-file-type.yml#TransposonPreGeno
  min_contig_len: int?
  expected_insert_size: int?
  phred64: boolean?
  max_reads_in_mem: int?

outputs:
  geno_files:
    type:
      type: array
      items: File
    outputSource: group/geno_file

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
          type: string
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

  group:
    run: melt-gen.cwl
    scatter: transposon_file
    in:
      reads_bam_file: get_bam_and_bai_file/reads_bam_file
      reads_bai_file: get_bam_and_bai_file/reads_bai_file
      min_contig_len: min_contig_len
      expected_insert_size: expected_insert_size
      ref_fasta_file: ref_fasta_file
      phred64: phred64
      max_reads_in_mem: max_reads_in_mem
      transposon_file: transposon_files

    out: [geno_file]
