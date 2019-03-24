cwlVersion: v1.0
class: Workflow

requirements:
  InlineJavascriptRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: step-input-type.yml

inputs:
  cwl_files:
    type:
      type: array
      items: File
  transposons:
    type:
      type: array
      items: step-input-type.yml#StepInput

outputs:
  pre_geno_files:
    type:
      type: array
      items: File
    outputSource: step2b/pre_geno_file

steps:

  step2b:
    run: melt-split-step-2b.cwl
    scatter: transposon
    in:
      cwl_files: cwl_files
      transposon: transposons
    out: [pre_geno_file]

