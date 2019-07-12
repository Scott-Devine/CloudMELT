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
  del_transposons:
    type:
      type: array
      items: step-input-type.yml#StepInput

outputs:
  del_vcf_files:
    type:
      type: array
      items: File
    outputSource: step2b-del/vcf_file

steps:

  step2b-del:
    run: melt-del-step-2b.cwl
    scatter: transposon
    in:
      cwl_files: cwl_files
      transposon: del_transposons
    out: [vcf_file]

