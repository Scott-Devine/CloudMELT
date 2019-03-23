cwlVersion: v1.0
class: Workflow

requirements:
  InlineJavascriptRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}

inputs:
  cwl_files:
    type:
      type: array
      items: File
  melt_config_files:
    type: File
    inputBinding:
      position: 1

outputs:
  geno_files:
    type:
      type: array
      items: File
    outputBinding: 
      glob: ["*.LINE1.tsv", "*.SVA.tsv", "*.ALU.tsv", "*.HERVK.tsv"]

  step1b:
    run: melt-split-step-3b.cwl
    scatter: melt_config_file
    in:
      melt_config_file: melt_config_files
      cwl_files: cwl_files
    out: [geno_files]
