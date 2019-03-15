cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    tmpdirMin: 20000
    ramMin: 14000
    coresMin: 1
  InitialWorkDirRequirement:
    listing:
      - $(inputs.bam_file)
      - $(inputs.bai_file)

baseCommand: /usr/local/bin/mosdepth
arguments: ["-n", "--fast-mode", "-t", "4", "--by", "1000", "output"]

stdout: melt-cov-stdout.txt
stderr: melt-cov-stderr.txt

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/mosdepth:0.2.4--he527e40_0

inputs:
  bam_file:
    type: File
    inputBinding:
      position: 1
  bai_file:
    type: File
outputs:
  cov_stdout:
    type: stdout
  cov_stderr:
    type: stderr
  global_dist_file:
    type: File
    outputBinding: 
      glob: "*.global.dist.txt"
  region_dist_file:
    type: File
    outputBinding: 
      glob: "*.region.dist.txt"
