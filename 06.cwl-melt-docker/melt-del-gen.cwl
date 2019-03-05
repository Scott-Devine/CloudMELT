cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    ramMin: 2000
    tmpdirMin: 20000
    outdirMin: 5000
    coresMin: 1

baseCommand: ["java", "-Xmx2G", "-jar", "/opt/MELTv2.1.5/MELT.jar", "Deletion-Genotype"]

stdout: melt-del-stdout.txt
stderr: melt-del-stderr.txt

hints:
  DockerRequirement:
    dockerImageId: umigs/cloud-melt-v1.0.0

inputs:
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
