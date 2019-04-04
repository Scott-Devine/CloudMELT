cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    ramMin: 5722
    tmpdirMin: 20000
    outdirMin: 5000
    coresMin: 1

baseCommand: [java]
stdout: melt-stdout.txt
stderr: melt-stderr.txt
inputs:
  melt_jar_file:
    type: File
    inputBinding:
      position: 0
      prefix: -jar
  melt_runtime:
    type: string
    default: Single
    inputBinding:
      position: 1
  bwa_used:
    type: boolean
    inputBinding:
      position: 2
      prefix: -a
  excluded_chromosomes:
    type: string
    inputBinding:
      position: 3
      prefix: -b
  coverage_estimate:
    type: float
    inputBinding:
      position: 4
      prefix: -c
  ref_fasta_file:
    type: File
    inputBinding:
      position: 5
      prefix: -h
    secondaryFiles:
     - .fai
  reads_bam_file:
    type: File
    inputBinding:
      position: 6
      prefix: -bamfile
    secondaryFiles:
     - .bai
  genes_bed_file:
    type: File
    inputBinding:
      position: 7
      prefix: -n
  mei_list:
    type: File
    inputBinding:
      position: 8
      prefix: -t
  working_dir:
    type: Directory
    inputBinding:
      position: 9
      prefix: -w
outputs:
  melt_stdout:
    type: stdout
  melt_stderr:
    type: stderr
