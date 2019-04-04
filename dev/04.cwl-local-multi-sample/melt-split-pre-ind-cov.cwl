cwlVersion: v1.0
class: Workflow

requirements:
  SubworkflowFeatureRequirement: {}

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
  reads_bam_file:
    type: File
    secondaryFiles:
      - .bai
  min_contig_len: int?
  phred64: boolean?
  read_length: int?
  genes_bed_file: File
  max_reads_in_mem: int?
  transposon_zip_file: File
  min_coverage: float

outputs:
  aligned_bam_file:
    type: File
    outputSource: indiv_analysis/aligned_bam_file
    secondaryFiles: ['.bai']
  hum_breaks_bam_file:
    type: File
    outputSource: indiv_analysis/hum_breaks_bam_file
    secondaryFiles: ['.bai']
  pulled_bam_file:
    type: File
    outputSource: indiv_analysis/pulled_bam_file
    secondaryFiles: ['.bai']
  tmp_bed_file:
    type: File
    outputSource: indiv_analysis/tmp_bed_file
  estimated_coverage:
    type: float
    outputSource: dummy_coverage/estimated_coverage 

steps:
  preprocess:
    run: melt-pre.cwl
    in:
      melt_jar_file: melt_jar_file
      ref_fasta_file: ref_fasta_file
      reads_bam_file: reads_bam_file
    out: [dr_bam_file, fastq_file]

  dummy_coverage:
    run:
      class: CommandLineTool
      requirements:
        InlineJavascriptRequirement: {}
      baseCommand: ['echo']
      stdout: coverage.txt
      inputs:
        coverage:
          type: float
          inputBinding:
            position: 1
      outputs:
        estimated_coverage:
          type: float
          outputBinding:
            glob: coverage.txt
            loadContents: true
            outputEval: $(inputs.coverage)
    in:
      coverage: min_coverage
    out: [estimated_coverage]

  indiv_analysis:
    run: melt-ind.cwl
    in:
      melt_jar_file: melt_jar_file
      bwa_used: bwa_used
      excluded_chromosomes: excluded_chromosomes
      reads_bam_file: reads_bam_file
      disc_bam_file: preprocess/dr_bam_file
      fastq_file: preprocess/fastq_file
      bowtie2_path: bowtie2_path
      coverage_estimate: dummy_coverage/estimated_coverage
      min_contig_len: min_contig_len
      exome_mode: exome_mode
      ref_fasta_file: ref_fasta_file
      phred64: phred64
      read_length: read_length
      transposon_zip_file: transposon_zip_file
      max_reads_in_mem: max_reads_in_mem
    out: [aligned_bam_file, hum_breaks_bam_file, pulled_bam_file, tmp_bed_file]
