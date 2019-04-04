cwlVersion: v1.0
class: CommandLineTool

requirements:
  InlineJavascriptRequirement: {}

baseCommand: ['echo']
stdout: $(inputs.reads_bam_file.basename + ".est_coverage.txt")
inputs:
  reads_bam_file:
    type: File
  coverage:
    type: float
    inputBinding:
      position: 1
outputs:
  estimated_coverage:
    type: float
    outputBinding:
      outputEval: ${ return inputs.coverage; }
  estimated_coverage_file:
    type: File
    outputBinding:
      glob: $(inputs.reads_bam_file.basename + ".est_coverage.txt")
