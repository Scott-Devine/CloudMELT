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
        all_files = all_files.concat(inputs.transposon.input_files);
        return all_files;
       }
  SchemaDefRequirement:
    types:
      - $import: step-input-type.yml

baseCommand: ["cwltool_then_clean_tmp"]
arguments:
  - valueFrom: "melt-split-gen.cwl"
  - valueFrom: $(inputs.transposon.melt_config_file)

inputs:
  cwl_files:
    type:
      type: array
      items: File
  transposon: step-input-type.yml#StepInput

outputs:
  geno_files:
    type:
      type: array
      items: File
    outputBinding: 
      glob: ["*.LINE1.tsv", "*.SVA.tsv", "*.ALU.tsv", "*.HERVK.tsv"]

