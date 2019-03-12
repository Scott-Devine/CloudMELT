cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    tmpdirMin: 20000
    ramMin: 2500
    coresMin: 1

baseCommand: hostname

stdout: hostname-test.txt

inputs:
  file:
    type: File

outputs:
  ls_stdout:
    type: stdout
