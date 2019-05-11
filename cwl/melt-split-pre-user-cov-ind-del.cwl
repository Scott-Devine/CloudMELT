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
  transposon_zip_files:
    type:
      type: array
      items: File
  me_bed_files:
    type:
      type: array
      items: File
  min_coverage: float?
  bwa_used: boolean?
  excluded_chromosomes: string?
  exome_mode: boolean?
  min_contig_len: int?
  phred64: boolean?
  read_length: int?
  max_reads_in_mem: int?
  expected_insert_size: int?

outputs:
  estimated_coverage_file:
    type: File
    outputSource: user_coverage/estimated_coverage_file
  aligned_bam_files:
    type:
      type: array
      items: File
    secondaryFiles: [".bai"]
    outputSource: ind/aligned_bam_file
  hum_breaks_bam_files:
    type:
      type: array
      items: File
    secondaryFiles: [".bai"]
    outputSource: ind/hum_breaks_bam_file
  pulled_bam_files:
    type:
      type: array
      items: File
    secondaryFiles: [".bai"]
    outputSource: ind/pulled_bam_file
  tmp_bed_files:
    type:
      type: array
      items: File
    outputSource: ind/tmp_bed_file
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
        ref_fasta_file:
          type: File
          inputBinding:
            position: 2
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
    out: [reads_bam_file, reads_bai_file]

  preprocess:
    run: melt-pre.cwl
    in:
      ref_fasta_file: ref_fasta_file
      reads_bam_file: get_bam_and_bai_file/reads_bam_file
      reads_bai_file: get_bam_and_bai_file/reads_bai_file
    out: [dr_bam_file, fastq_file]

  user_coverage:
    run: melt-cov-user.cwl
    in:
      reads_bam_file: get_bam_and_bai_file/reads_bam_file
      coverage: min_coverage
    out: [estimated_coverage, estimated_coverage_file]

  ind:
    run: melt-ind.cwl
    scatter: transposon_zip_file
    in:
      reads_bam_file: get_bam_and_bai_file/reads_bam_file
      reads_bai_file: get_bam_and_bai_file/reads_bai_file
      dr_bam_file: preprocess/dr_bam_file
      fastq_file: preprocess/fastq_file
      ref_fasta_file: ref_fasta_file
      transposon_zip_file: transposon_zip_files
      estimated_coverage: user_coverage/estimated_coverage
      bwa_used: bwa_used
      excluded_chromosomes: excluded_chromosomes
      min_contig_len: min_contig_len
      exome_mode: exome_mode
      phred64: phred64
      read_length: read_length
      max_reads_in_mem: max_reads_in_mem
    out: [aligned_bam_file, hum_breaks_bam_file, pulled_bam_file, tmp_bed_file]

  del:
    run: melt-del-gen.cwl
    scatter: me_bed_file
    in:
      reads_bam_file: get_bam_and_bai_file/reads_bam_file
      reads_bai_file: get_bam_and_bai_file/reads_bai_file
      ref_fasta_file: ref_fasta_file
      me_bed_file: me_bed_files
      expected_insert_size: expected_insert_size
      max_reads_in_mem: max_reads_in_mem
    out: [del_tsv_file]
