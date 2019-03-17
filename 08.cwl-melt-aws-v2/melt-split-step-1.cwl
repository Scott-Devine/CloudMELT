cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    ramMin: 1910
    tmpdirMin: 15000
    outdirMin: 15000
    coresMin: 1
  DockerRequirement:
    dockerImageId: 205226202704.dkr.ecr.us-east-1.amazonaws.com/umigs/melt
    dockerOutputDirectory: /toil
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing: |
      ${
        var all_files = new Array();
        all_files = all_files.concat(inputs.cwl_files);
        return all_files;
       }

baseCommand: ["cwltool"]
arguments: ["--debug", "melt-split-pre-mosdepth-cov-ind.cwl"]

inputs:
  melt_config_file:
    type: File
    inputBinding:
      position: 1
  cwl_files:
    type:
      type: array
      items: File

outputs:
  estimated_coverage_file:
    type: File
    outputBinding:
      glob: "*.est_coverage.txt"
  aligned_bam_files:
    type:
      type: array
      items: File
    secondaryFiles: [".bai"]
    outputBinding:
      glob: "*aligned.final.sorted.bam"
  hum_breaks_bam_files:
    type:
      type: array
      items: File
    secondaryFiles: [".bai"]
    outputBinding:
      glob: "*hum_breaks.sorted.bam"
  pulled_bam_files:
    type:
      type: array
      items: File
    secondaryFiles: [".bai"]
    outputBinding:
      glob: "*pulled.sorted.bam"
  tmp_bed_files:
    type:
      type: array
      items: File
    outputBinding:
      glob: "*.tmp.bed"
