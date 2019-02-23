cwlVersion: v1.0
class: Workflow

inputs:
  bam_file:
    type: File
    secondaryFiles: ['.bai']
outputs:
  estimated_coverage:
    type: float
    outputSource: mosdepth2coverage/estimated_coverage

steps:
  mosdepth:
    run: mosdepth.cwl
    in: 
      bam_file: bam_file
    out: [global_dist_file]

  mosdepth2coverage:
    run:
      class: CommandLineTool
      requirements:
        InlineJavascriptRequirement: {}
      inputs:
        cov_file:
          type: File
          inputBinding:
            position: 1
      baseCommand: ['/Users/jcrabtree/MELT/03.cwl-local-melt-multi/mosdepth2cov.py']
      stdout: coverage.txt
      outputs:
        estimated_coverage:
          type: float
          outputBinding:
            glob: coverage.txt
            loadContents: true
            outputEval: $(Math.ceil(parseFloat(self[0].contents)))

    in:
      cov_file: mosdepth/global_dist_file
    out: [estimated_coverage]
