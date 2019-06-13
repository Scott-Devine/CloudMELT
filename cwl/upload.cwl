cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    ramMin: 2000
    coresMin: 1

baseCommand: ['upload_file.pl']

stdout: upload-stdout.txt
stderr: upload-stderr.txt

inputs:
  s3_bucket_uri:
    type: string?
    inputBinding:
      position: 1
      prefix: --s3_bucket_uri
  file:
    type: File
    inputBinding:
      position: 2
      prefix: --file

outputs:
  upload_stdout:
    type: stdout
  upload_stderr:
    type: stderr
    