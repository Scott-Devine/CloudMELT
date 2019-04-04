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
  geno_files:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: step3b/geno_files

steps:

  step3b:
    run: melt-split-step-3b.cwl
    scatter: transposon
    in:
      cwl_files: cwl_files
      transposon: transposons
    out: [geno_files]
