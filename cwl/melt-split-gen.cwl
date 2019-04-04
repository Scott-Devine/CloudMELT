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

  group:
    run: melt-gen.cwl
    scatter: transposon_file
    in:
      reads_bam_file: get_bam_file/reads_bam_file
      reads_bai_file: get_bai_file/reads_bai_file
      min_contig_len: min_contig_len
      expected_insert_size: expected_insert_size
      ref_fasta_file: ref_fasta_file
      phred64: phred64
      max_reads_in_mem: max_reads_in_mem
      transposon_file: transposon_files

    out: [geno_file]
