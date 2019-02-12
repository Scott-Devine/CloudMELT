cwlVersion: v1.0
class: CommandLineTool

requirements:

  ResourceRequirement:
    ramMin: 5725
    tmpdirMin: 20000
    outdirMin: 5000
    coresMin: 1
  InitialWorkDirRequirement:
    listing:
      - $(inputs.reads_bam_file)
      - $(inputs.disc_bam_file)
      - $(inputs.fastq_file)

baseCommand: ["java", "-Xmx6G"]
stdout: melt-ind-stdout.txt
stderr: melt-ind-stderr.txt
inputs:
  melt_jar_file:
    type: File
    inputBinding:
      position: 0
      prefix: -jar
  melt_runtime:
    type: string
    default: IndivAnalysis
    inputBinding:
      position: 1
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
  reads_bam_file:
    type: File
    inputBinding:
      position: 4
      prefix: -bamfile
    secondaryFiles:
     - .bai
  disc_bam_file:
    type: File
    secondaryFiles:
     - .bai
  fastq_file: 
    type: File
  bowtie2_path:
    type: File?
    inputBinding:
      position: 5
      prefix: -bowtie
  coverage_estimate:
    type: float
    inputBinding:
      position: 6
      prefix: -c
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
  aligned_bam_bai_files:
    type: 
      type: array
      items: File
    outputBinding: 
      glob: "*aligned.final.sorted.bam*"
  hum_breaks_bam_bai_files:
    type:
      type: array
      items: File
    outputBinding: 
      glob: "*hum_breaks.sorted.bam*"
  pulled_bam_bai_files:
    type: 
      type: array
      items: File
    outputBinding: 
      glob: "*pulled.sorted.bam*"
  bed_files:
    type: 
      type: array
      items: File
    outputBinding: 
      glob: "*.tmp.bed"
