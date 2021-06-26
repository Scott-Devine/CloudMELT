cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    ramMin: 1910
    tmpdirMin: 15000
    outdirMin: 15000
    coresMin: 1
  InitialWorkDirRequirement:
    listing:
      - $(inputs.reads_bam_file)
      - $(inputs.reads_bai_file)

baseCommand: [java, "-Xmx2G", "-jar", "/opt/MELTv2.1.5fast/MELT.jar", "Preprocess"]
stdout: melt-pre-stdout.txt
stderr: melt-pre-stderr.txt

inputs:
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
  reads_bai_file:
    type: File

outputs:
  melt_pre_stdout:
    type: stdout
  melt_pre_stderr:
    type: stderr
  dr_bam_file:
    type: File
    outputBinding: 
      glob: $(inputs.reads_bam_file.basename).disc
    secondaryFiles: ['.bai']
  fastq_file:
    type: File
    outputBinding:
      glob: $(inputs.reads_bam_file.basename).fq
