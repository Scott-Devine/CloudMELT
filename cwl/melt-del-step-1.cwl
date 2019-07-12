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
    type:
      type: array
      items: File

outputs:
  del_tsv_files:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: step1b/del_tsv_files

steps:

  step1b:
    run: melt-del-step-1b.cwl
    scatter: melt_config_file
    in:
      melt_config_file: melt_config_files
      cwl_files: cwl_files
    out: [del_tsv_files]
