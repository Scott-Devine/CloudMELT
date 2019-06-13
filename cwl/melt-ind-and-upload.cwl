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
  dr_bam_file:
    type: File
    secondaryFiles: [".bai"]
  fastq_file: File
  estimated_coverage: float
  bwa_used: boolean?
  excluded_chromosomes: string?
  min_contig_len: int?
  exome_mode: boolean?
  ref_fasta_file:
    type: File
    secondaryFiles:
     - .fai
  phred64: boolean?
  read_length: int?
  transposon_zip_file: File
  max_reads_in_mem: int?
  s3_output_bucket_uri: string?

outputs:
  aligned_bam_file:
    type: File
    outputSource: ind/aligned_bam_file 
  hum_breaks_bam_file:
    type: File
    outputSource: ind/hum_breaks_bam_file 
  pulled_bam_file:
    type: File
    outputSource: ind/pulled_bam_files 
  tmp_bed_file:
    type: File
    outputSource: ind/tmp_bed_file 
  upload_aligned_stdout:
    type: File
    outputSource: upload/upload_aligned_stdout
  upload_breaks_stdout:
    type: File
    outputSource: upload/upload_breaks_stdout
  upload_pulled_stdout:
    type: File
    outputSource: upload/upload_pulled_stdout
  upload_bed_stdout:
    type: File
    outputSource: upload/upload_bed_stdout

steps:
  ind:
    run: melt-ind.cwl
    in:
      reads_bam_file: reads_bam_file
      reads_bai_file: reads_bai_file
      dr_bam_file: dr_bam_file
      fastq_file: fastq_file
      estimated_coverage: estimated_coverage
      bwa_used: bwa_used
      excluded_chromosomes: excluded_chromosomes
      min_contig_len: min_contig_len
      exome_mode: exome_mode
      ref_fasta_file: ref_fasta_file
      phred64: phred64
      read_length: read_length
      transposon_zip_file: transposon_zip-file
      max_reads_in_mem: max_reads_in_mem
    out: [aligned_bam_file, hum_breaks_bam_file, pulled_bam_file, tmp_bed_file]

  upload_aligned:
    run: upload.cwl
    in:
      s3_bucket_uri: s3_output_bucket_uri
      file: ind/aligned_bam_file
    out: [upload_stdout, upload_stderr]

  upload_breaks:
    run: upload.cwl
    in:
      s3_bucket_uri: s3_output_bucket_uri
      file: ind/hum_breaks_bam_file
    out: [upload_stdout, upload_stderr]

  upload_pulled:
    run: upload.cwl
    in:
      s3_bucket_uri: s3_output_bucket_uri
      file: ind/pulled_bam_file
    out: [upload_stdout, upload_stderr]

  upload_bed:
    run: upload.cwl
    in:
      s3_bucket_uri: s3_output_bucket_uri
      file: ind/tmp_bed_file
    out: [upload_stdout, upload_stderr]
