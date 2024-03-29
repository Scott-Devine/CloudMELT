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
  min_coverage: float?
  bwa_used: boolean?
  excluded_chromosomes: string?
  exome_mode: boolean?
  min_contig_len: int?
  phred64: boolean?
  read_length: int?
  max_reads_in_mem: int?

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

steps:
  get_bam_file:
    run:
      class: CommandLineTool
      baseCommand: ['curl']
      arguments: ['-O']
      inputs:
        reads_bam_uri:
          type: string
          inputBinding:
            position: 1
      outputs:
       reads_bam_file:
          type: File
          outputBinding:
            glob: "*.bam"
    in:
      reads_bam_uri: reads_bam_uri
    out: [reads_bam_file]

  get_bai_file:
    run:
      class: CommandLineTool
      baseCommand: ['curl']
      arguments: ['-O']
      inputs:
        reads_bam_uri:
          type: string
          inputBinding:
            position: 1
            valueFrom: $(inputs.reads_bam_uri + ".bai")
      outputs:
       reads_bai_file:
          type: File
          outputBinding:
            glob: "*.bai"
    in:
      reads_bam_uri: reads_bam_uri
    out: [reads_bai_file]

  preprocess:
    run: melt-pre.cwl
    in:
      ref_fasta_file: ref_fasta_file
      reads_bam_file: get_bam_file/reads_bam_file
      reads_bai_file: get_bai_file/reads_bai_file
    out: [dr_bam_file, fastq_file]

  user_coverage:
    run: melt-cov-user.cwl
    in:
      reads_bam_file: get_bam_file/reads_bam_file
      coverage: min_coverage
    out: [estimated_coverage, estimated_coverage_file]

  ind:
    run: melt-ind.cwl
    scatter: transposon_zip_file
    in:
      reads_bam_file: get_bam_file/reads_bam_file
      reads_bai_file: get_bai_file/reads_bai_file
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
