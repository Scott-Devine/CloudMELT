cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    ramMin: 5725
    tmpdirMin: 20000
    outdirMin: 5000
    coresMin: 1
  InlineJavascriptRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: preproc-bam-type.yml
  InitialWorkDirRequirement:
    listing:
      - $(inputs.preprocessed_bam_file.reads_bam_file)
      - $(inputs.preprocessed_bam_file.reads_bai_file)
      - $(inputs.preprocessed_bam_file.dr_bam_file)
      - $(inputs.preprocessed_bam_file.dr_bai_file)
      - $(inputs.preprocessed_bam_file.fastq_file)

baseCommand: ["java", "-Xmx6G"]

stdout: melt-ind-stdout.txt
stderr: melt-ind-stderr.txt

arguments:
  - prefix: -jar
    valueFrom: $(inputs.melt_jar_file)
  - prefix: 
    valueFrom: "IndivAnalysis"
  - prefix: -bamfile
    valueFrom: $(inputs.preprocessed_bam_file.reads_bam_file)
  - prefix: -c
    valueFrom: $(inputs.preprocessed_bam_file.estimated_coverage)

inputs:
  melt_jar_file:
    type: File
  preprocessed_bam_file:
    type: preproc-bam-type.yml#PreprocessedBAM
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
  bowtie2_path:
    type: File?
    inputBinding:
      position: 5
      prefix: -bowtie
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
