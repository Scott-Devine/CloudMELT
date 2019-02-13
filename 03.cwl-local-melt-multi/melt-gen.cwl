cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    ramMin: 2000
    tmpdirMin: 20000
    outdirMin: 5000
    coresMin: 1
  InitialWorkDirRequirement:
    listing:
      - $(inputs.reads_bam_file)
      - $(inputs.pre_geno_file)

baseCommand: ["java", "-Xmx2G"]

stdout: melt-gen-stdout.txt
stderr: melt-gen-stderr.txt

inputs:
  melt_jar_file:
    type: File
    inputBinding:
      position: 0
      prefix: -jar
  melt_runtime:
    type: string
    default: Genotype
    inputBinding:
      position: 1
  reads_bam_file:
    type: File
    inputBinding:
      position: 2
      prefix: -bamfile
    secondaryFiles:
     - .bai
  min_contig_len:
     type: int?
     default: 1000000
     inputBinding:
       position: 3
       prefix: -d
  expected_insert_size:
    type: int
    default: 500
    inputBinding:
      position: 4
      prefix: -e
  ref_fasta_file:
    type: File
    inputBinding:
      position: 5
      prefix: -h
    secondaryFiles:
     - .fai
  phred64:
    type: boolean?
    default: false
    inputBinding:
      position: 6
      prefix: -q
  transposon_zip_file:
    type: File
    inputBinding:
      position: 7
      prefix: -t
  max_reads_in_mem:
    type: int?
    default: 5000
    inputBinding:
      position: 8
      prefix: -z
  working_dir:
    type: string?
    default: ./
    inputBinding:
      position: 9
      prefix: -w
  discovery_dir:
    type: string?
    default: ./
    inputBinding:
      position: 10
      prefix: -p
  pre_geno_file:
    type: File
outputs:
  melt_gen_stdout:
    type: stdout
  melt_gen_stderr:
    type: stderr
  geno_file:
    type: File
    outputBinding: 
      glob: ["*.LINE1.tsv", "*.SVA.tsv", "*.ALU.tsv"]
