cwlVersion: v1.0
class: Workflow

requirements:
  InlineJavascriptRequirement: {}
  SubworkflowFeatureRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: transposon-file-type.yml

inputs:
  reads_bam_file: File
  reads_bai_file: File
  min_contig_len: int?
  expected_insert_size: int?
  ref_fasta_file:
    type: File
    secondaryFiles:
     - .fai
  phred64: boolean?
  transposon_file:
    type: transposon-file-type.yml#TransposonPreGeno
  max_reads_in_mem: int?
  s3_output_bucket_uri: string?

outputs:
  geno_file:
    type: File
    outputSource: gen/geno_file
  upload_stdout:
    type: File
    outputSource: upload/upload_stdout

steps:
  gen:
    run: melt-gen.cwl
    in:
      reads_bam_file: reads_bam_file
      reads_bai_file: reads_bai_file
      min_contig_len: min_contig_len
      expected_insert_size: expected_insert_size
      ref_fasta_file: ref_fasta_file
      phred64: phred64
      transposon_file: transposon_file
      max_reads_in_mem: max_reads_in_mem
    out: [geno_file]

  upload:
    run: upload.cwl
    in:
      s3_bucket_uri: s3_output_bucket_uri
      file: gen/geno_file
    out: [upload_stdout, upload_stderr]
