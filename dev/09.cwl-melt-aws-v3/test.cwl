cwlVersion: v1.0
class: CommandLineTool

requirements:
  InlineJavascriptRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: step2-input-type.yml

inputs:
  transposons:
    type:
      type: array
      items: step2-input-type.yml#Step2Input

outputs:
  dummy_output:
    type: File
    outputBinding:
      glob: "output.txt"

baseCommand: ["touch"]
arguments: ['output.txt']
