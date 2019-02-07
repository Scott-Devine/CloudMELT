cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    ramMin: 1910
    tmpdirMin: 20000
    outdirMin: 5000
    coresMin: 1

baseCommand: ["/Users/jcrabtree/MELT/03.cwl-local-melt-multi/melt-wrapper.pl", java, "-Xmx2G"]
stdout: melt-pre-stdout.txt
stderr: melt-pre-stderr.txt
inputs:
  melt_jar_file:
    type: File
    inputBinding:
      position: 0
      prefix: -jar
  melt_runtime:
    type: string
    default: Preprocess
    inputBinding:
      position: 1
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
outputs:
  melt_pre_stdout:
    type: stdout
  melt_pre_stderr:
    type: stderr
  dr_bam_file:
    type: File
    outputBinding: 
      glob: $(inputs.reads_bam_file.basename).disc
  dr_bai_file:
    type: File
    outputBinding:
      glob: $(inputs.reads_bam_file.basename).disc.bai
  fastq_file:
    type: File
    outputBinding:
      glob: $(inputs.reads_bam_file.basename).fq
