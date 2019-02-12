cwlVersion: v1.0
class: Workflow

inputs:
  melt_jar_file: File
  bwa_used: boolean?
  bowtie2_path: File?
  excluded_chromosomes: string?
  exome_mode: boolean?
  ref_fasta_file:
    type: File
    secondaryFiles:
      - .fai
  min_contig_len: int?
  phred64: boolean?
  reads_bam_file:
     type: File
     secondaryFiles:
      - .bai
  read_length: int?
  genes_bed_file: File
  max_reads_in_mem: int?
  mei_list: File
  working_dir: Directory?

outputs:
  dr_bam_file:
    type: File
    outputSource: preprocess/dr_bam_file
  dr_bai_file:
    type: File
    outputSource: preprocess/dr_bai_file
  fastq_file:
    type: File
    outputSource: preprocess/fastq_file

steps:
  preprocess:
    run: melt-pre.cwl
    in:
      melt_jar_file: melt_jar_file
      ref_fasta_file: ref_fasta_file
      reads_bam_file: reads_bam_file
    out: [dr_bam_file, dr_bai_file, fastq_file]



