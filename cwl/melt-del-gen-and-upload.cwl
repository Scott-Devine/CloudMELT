cwlVersion: v1.0
class: Workflow

requirements:
  InlineJavascriptRequirement: {}
  SubworkflowFeatureRequirement: {}

inputs:
  reads_bam_file: File
  reads_bai_file: File
  me_bed_file: File
  expected_insert_size: int?    
  ref_fasta_file:
    type: File
    secondaryFiles:
     - .fai
  max_reads_in_mem: int?
  s3_output_bucket_uri: string?

outputs:
  del_tsv_file:
    type: File
    outputSource: del_gen/del_tsv_file
  upload_stdout:
    type: File
    outputSource: upload/upload_stdout

steps:
  del_gen:
    run: melt-del-gen.cwl
    in:
      reads_bam_file: reads_bam_file
      reads_bai_file: reads_bai_file
      me_bed_file: me_bed_file
      expected_insert_size: expected_insert_size
      ref_fasta_file: ref_fasta_file
      max_reads_in_mem: max_reads_in_mem
    out: [del_tsv_file]

  upload:
    run: upload.cwl
    in:
      s3_bucket_uri: s3_output_bucket_uri
      file: del_gen/del_tsv_file
    out: [upload_stdout, upload_stderr]


