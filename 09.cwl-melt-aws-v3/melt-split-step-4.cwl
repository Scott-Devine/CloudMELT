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
  vcf_files:
    type:
      type: array
      items: File
    outputSource: step4b/vcf_file

steps:

  step4b:
    run: melt-split-step-4b.cwl
    scatter: transposon
    in:
      cwl_files: cwl_files
      transposon: transposons
    out: [vcf_file]

