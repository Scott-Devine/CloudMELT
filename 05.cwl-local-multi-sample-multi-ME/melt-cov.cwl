cwlVersion: v1.0
class: Workflow

inputs:
  bam_file:
    type: File
    secondaryFiles: ['.bai']
  min_coverage:
    type: float?
    default: 1
outputs:
  coverage_file:
    type: File
    outputSource: mosdepth2coverage/estimated_coverage_file

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
        min_coverage: float?
      baseCommand: ['/Users/jcrabtree/MELT/03.cwl-local-melt-multi/mosdepth2cov.py']
      stdout: coverage.txt
      outputs:
        estimated_coverage_file:
          type: File
          outputBinding:
            glob: coverage.txt
            loadContents: true
            outputEval: $(Math.max(inputs.min_coverage, Math.ceil(parseFloat(self[0].contents))))

    in:
      cov_file: mosdepth/global_dist_file
      min_coverage: min_coverage
    out: [estimated_coverage_file]
