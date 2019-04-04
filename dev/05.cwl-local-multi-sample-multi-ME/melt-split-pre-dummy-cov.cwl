cwlVersion: v1.0
class: Workflow

requirements:
  SubworkflowFeatureRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: preproc-bam-type.yml

inputs:
  melt_jar_file: File
  ref_fasta_file:
    type: File
    secondaryFiles:
      - .fai
  reads_bam_file:
    type: File
    secondaryFiles:
      - .bai
  coverage: float

outputs:
  preprocessed_bam_file:
    type: preproc-bam-type.yml#PreprocessedBAM
    outputSource: make_output_rec/preprocessed_bam

steps:
  preprocess:
    run: melt-pre.cwl
    in:
      melt_jar_file: melt_jar_file
      ref_fasta_file: ref_fasta_file
      reads_bam_file: reads_bam_file
    out: [dr_bam_file, fastq_file]

  dummy_coverage:
    run:
      class: CommandLineTool
      requirements:
        InlineJavascriptRequirement: {}
      baseCommand: ['echo']
      stdout: $(inputs.reads_bam_file.basename + ".est_coverage.txt")
      inputs:
        reads_bam_file:
          type: File
          secondaryFiles:
            - .bai
        coverage:
          type: float
          inputBinding:
            position: 1
      outputs:
        estimated_coverage_file:
          type: File
          outputBinding:
            glob: $(inputs.reads_bam_file.basename + ".est_coverage.txt")
    in:
      reads_bam_file: reads_bam_file
      coverage: coverage
    out: [estimated_coverage_file]

  make_output_rec:
    run:
      class: CommandLineTool
      requirements:
        InlineJavascriptRequirement: {}
      baseCommand: ['echo']
      inputs:
        reads_bam_file:
          type: File
        dr_bam_file:
          type: File
        fastq_file:
          type: File
        estimated_coverage_file:
          type: File
          inputBinding:
            loadContents: true
      outputs:
        preprocessed_bam:
          type: preproc-bam-type.yml#PreprocessedBAM
          outputBinding:
            outputEval: |
              ${
                return { 
                  "reads_bam_file": inputs.reads_bam_file,
                  "reads_bai_file": inputs.reads_bam_file.secondaryFiles[0],
                  "dr_bam_file": inputs.dr_bam_file,
                  "dr_bai_file": inputs.dr_bam_file.secondaryFiles[0],
                  "fastq_file": inputs.fastq_file,
                  "estimated_coverage_file": inputs.estimated_coverage_file,
                  "estimated_coverage": parseFloat(inputs.estimated_coverage_file.contents)
                };
              }

    in:
      reads_bam_file: reads_bam_file
      dr_bam_file: preprocess/dr_bam_file
      fastq_file: preprocess/fastq_file
      estimated_coverage_file: dummy_coverage/estimated_coverage_file
    out: [ preprocessed_bam ]
