cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    ramMin: 2000
    tmpdirMin: 20000
    outdirMin: 5000
    coresMin: 1

baseCommand: ["java", "-Xmx2G"]

stdout: melt-del-stdout.txt
stderr: melt-del-stderr.txt

inputs:
  melt_jar_file:
    type: File
    inputBinding:
      position: 0
      prefix: -jar
  melt_runtime:
    type: string
    default: Deletion-Genotype
    inputBinding:
      position: 1
  reads_bam_file:
    type: File
    inputBinding:
      position: 4
      prefix: -bamfile
    secondaryFiles:
     - .bai
  me_bed_file:
    type: File
    inputBinding:
      position: 5
      prefix: -bed
  expected_insert_size:
    type: int?    
    inputBinding:
      position: 6
      prefix: -e
  ref_fasta_file:
    type: File
    inputBinding:
      position: 7
      prefix: -h
    secondaryFiles:
     - .fai
  max_reads_in_mem:
    type: int?
    inputBinding:
      position: 8
      prefix: -z
  working_dir:
    type: string?
    default: ./
    inputBinding:
      position: 14
      prefix: -w
outputs:
  melt_gen_stdout:
    type: stdout
  melt_gen_stderr:
    type: stderr
  tsv_file:
    type: File
    outputBinding: 
      glob: "*.tsv"
