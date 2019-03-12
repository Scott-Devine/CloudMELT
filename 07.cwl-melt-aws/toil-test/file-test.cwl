cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    tmpdirMin: 20000
    ramMin: 2500
    coresMin: 1

baseCommand: ls
arguments: ["-l"]

stdout: file-test-stdout.txt

inputs:
  file:
    type: File
    inputBinding:
      position: 1

outputs:
  ls_stdout:
    type: stdout
