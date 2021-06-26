cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    ramMin: 2000
    tmpdirMin: 20000
    outdirMin: 5000
    coresMin: 1
  SchemaDefRequirement:
    types:
      - $import: transposon-file-type.yml
  InitialWorkDirRequirement:
    listing:
      - $(inputs.reads_bam_file)
      - $(inputs.reads_bai_file)
      - $(inputs.transposon_file.pre_geno)
      - $(inputs.transposon_file.zip)

baseCommand: ["java", "-Xmx2G", "-jar", "/opt/MELTv2.1.5fast/MELT.jar", "Genotype"]

stdout: melt-gen-stdout.txt
stderr: melt-gen-stderr.txt

arguments:
  - prefix: -bamfile
    valueFrom: $(inputs.reads_bam_file)
  - prefix: -t
    valueFrom: $(inputs.transposon_file.zip)

inputs:
  reads_bam_file: File
  reads_bai_file: File
  min_contig_len:
     type: int?
     default: 1000000
     inputBinding:
       position: 3
       prefix: -d
  expected_insert_size:
    type: int?
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
  transposon_file:
    type: transposon-file-type.yml#TransposonPreGeno
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
outputs:
  melt_gen_stdout:
    type: stdout
  melt_gen_stderr:
    type: stderr
  geno_file:
    type: File
    outputBinding: 
      glob: ["*.LINE1.tsv", "*.SVA.tsv", "*.ALU.tsv", "*.HERVK.tsv"]
