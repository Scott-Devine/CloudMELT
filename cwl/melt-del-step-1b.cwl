cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    ramMin: 1910
    tmpdirMin: 15000
    outdirMin: 15000
    coresMin: 1
  DockerRequirement:
    dockerPull: <DOCKER_IMAGE_URI>
    dockerOutputDirectory: <DOCKER_OUTPUT_DIR>
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing: |
      ${
        var all_files = new Array();
        all_files = all_files.concat(inputs.cwl_files);
        return all_files;
       }

baseCommand: ["cwltool_then_clean_tmp"]
arguments: ["melt-del.cwl"]

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
  del_tsv_files:
    type:
      type: array
      items: File
    outputBinding:
      glob: "*.tsv"
