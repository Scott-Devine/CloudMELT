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
  estimated_coverage_file:
    type: File
    outputSource: coverage2file/estimated_coverage_file

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
      hints:
        DockerRequirement:
          dockerImageId: 205226202704.dkr.ecr.us-east-1.amazonaws.com/umigs/melt:latest
      inputs:
        cov_file:
          type: File
          inputBinding:
            position: 1
        min_coverage: float?
      baseCommand: ['mosdepth2cov.py']
      stdout: coverage.txt
      outputs:
        estimated_coverage:
          type: float
          outputBinding:
            glob: coverage.txt
            loadContents: true
            outputEval: $(Math.max(inputs.min_coverage, Math.ceil(parseFloat(self[0].contents))))
    in:
      min_coverage: min_coverage
      cov_file: mosdepth/global_dist_file
    out: [estimated_coverage]

  coverage2file:
    run:
      class: CommandLineTool
      requirements:
        InlineJavascriptRequirement: {}
      baseCommand: ['echo']
      stdout: $(inputs.bam_file.basename + ".est_coverage.txt")
      inputs:
        bam_file:
          type: File
        coverage:
          type: float
          inputBinding:
            position: 1

      outputs:
        estimated_coverage_file:
          type: File
          outputBinding:
            glob: $(inputs.bam_file.basename + ".est_coverage.txt")
    in:
      bam_file: bam_file
      coverage: mosdepth2coverage/estimated_coverage
    out: [estimated_coverage_file]
