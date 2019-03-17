cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    ramMin: 1910
    tmpdirMin: 15000
    outdirMin: 15000
    coresMin: 1
  DockerRequirement:
    dockerImageId: umigs/cloud-melt-v1.0.0
    dockerOutputDirectory: /toil
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing: |
      ${
        var all_files = new Array();
        all_files = all_files.concat(inputs.cwl_files);
        all_files = all_files.concat(inputs.input_files);
        return all_files;
       }

baseCommand: ["cwltool"]
arguments: ["--debug", "melt-grp.cwl"]

inputs:
  melt_config_file:
    type: File
    inputBinding:
      position: 1
  cwl_files:
    type:
      type: array
      items: File
  input_files:
    type:
      type: array
      items: File

outputs:
  pre_geno_file:
    type: File
    outputBinding: 
      glob: "*pre_geno.tsv"
