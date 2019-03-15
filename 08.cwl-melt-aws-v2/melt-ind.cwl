cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    ramMin: 8000
    tmpdirMin: 20000
    outdirMin: 5000
    coresMin: 1
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - $(inputs.reads_bam_file)
      - $(inputs.reads_bai_file)
      - $(inputs.dr_bam_file)
      - $(inputs.fastq_file)

baseCommand: ["java", "-Xmx6G", "-jar", "/opt/MELTv2.1.5/MELT.jar", "IndivAnalysis"]

stdout: melt-ind-stdout.txt
stderr: melt-ind-stderr.txt

hints:
  DockerRequirement:
    dockerImageId: 205226202704.dkr.ecr.us-east-1.amazonaws.com/umigs/melt:latest

arguments:
  - prefix: -bamfile
    valueFrom: $(inputs.reads_bam_file)
  - prefix: -bowtie
    valueFrom: /opt/bowtie2/bowtie2 

inputs:
  reads_bam_file: File
  reads_bai_file: File
  dr_bam_file:
    type: File
    secondaryFiles: [".bai"]
  fastq_file: File
  estimated_coverage:
    type: float
    inputBinding:
      position: 1
      prefix: -c
  bwa_used:
    type: boolean?
    default: true
    inputBinding:
      position: 2
      prefix: -a
  excluded_chromosomes:
    type: string?
    inputBinding:
      position: 3
      prefix: -b
  min_contig_len:
     type: int?
     default: 1000000
     inputBinding:
       position: 7
       prefix: -d
  exome_mode:
    type: boolean?
    inputBinding:
      position: 8
      prefix: -exome
  ref_fasta_file:
    type: File
    inputBinding:
      position: 9
      prefix: -h
    secondaryFiles:
     - .fai
  phred64:
    type: boolean?
    default: false
    inputBinding:
      position: 10
      prefix: -q
  read_length:
    type: int?
    default: 100
    inputBinding:
      position: 11
      prefix: -r
  transposon_zip_file:
    type: File
    inputBinding:
      position: 12
      prefix: -t
  max_reads_in_mem:
    type: int?
    default: 5000
    inputBinding:
      position: 13
      prefix: -z
  working_dir:
    type: string?
    default: ./
    inputBinding:
      position: 14
      prefix: -w
outputs:
  melt_ind_stdout:
    type: stdout
  melt_ind_stderr:
    type: stderr
  aligned_bam_file:
    type: File
    outputBinding: 
      glob: "*aligned.final.sorted.bam"
    secondaryFiles: ['.bai']
  hum_breaks_bam_file:
    type: File
    outputBinding: 
      glob: "*hum_breaks.sorted.bam"
    secondaryFiles: ['.bai']
  pulled_bam_file:
    type: File
    outputBinding: 
      glob: "*pulled.sorted.bam"
    secondaryFiles: ['.bai']
  tmp_bed_file:
    type: File
    outputBinding: 
      glob: "*.tmp.bed"
