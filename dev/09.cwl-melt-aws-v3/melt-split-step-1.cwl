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
  estimated_coverage_files:
    type:
      type: array
      items: File
    outputSource: step1b/estimated_coverage_file
  aligned_bam_files:
    type:
      type: array
      items: 
        type: array
        items: File
    secondaryFiles: [".bai"]
    outputSource: step1b/aligned_bam_files
  hum_breaks_bam_files:
    type:
      type: array
      items:
        type: array
        items: File
    secondaryFiles: [".bai"]
    outputSource: step1b/hum_breaks_bam_files
  pulled_bam_files:
    type:
      type: array
      items:
        type: array
        items: File
    secondaryFiles: [".bai"]
    outputSource: step1b/pulled_bam_files
  tmp_bed_files:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: step1b/tmp_bed_files

steps:

  step1b:
    run: melt-split-step-1b.cwl
    scatter: melt_config_file
    in:
      melt_config_file: melt_config_files
      cwl_files: cwl_files
    out: [estimated_coverage_file, aligned_bam_files, hum_breaks_bam_files, pulled_bam_files, tmp_bed_files]
