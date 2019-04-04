cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    ramMin: 3825
    tmpdirMin: 20000
    outdirMin: 5000
    coresMin: 1
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing: |
      ${
        var all_files = new Array();
        all_files = all_files.concat(inputs.aligned_bam_files);
        all_files = all_files.concat(inputs.hum_breaks_bam_files);
        all_files = all_files.concat(inputs.tmp_bed_files);
        return all_files;
       }

baseCommand: ["java", "-Xmx4G"]
stdout: melt-grp-stdout.txt
stderr: melt-grp-stderr.txt
inputs:
  melt_jar_file:
    type: File
    inputBinding:
      position: 0
      prefix: -jar
  melt_runtime:
    type: string
    default: GroupAnalysis
    inputBinding:
      position: 1
  bwa_used:
    type: boolean?
    default: true
    inputBinding:
      position: 2
      prefix: -a
  group_stdev_cutoff:
     type: int?
     inputBinding:
       position: 3
       prefix: -cov
  ref_fasta_file:
    type: File
    inputBinding:
      position: 4
      prefix: -h
    secondaryFiles:
     - .fai
  ref_bed_file:
    type: File
    inputBinding:
      position: 5
      prefix: -n
  phred64:
    type: boolean?
    default: false
    inputBinding:
      position: 6
      prefix: -q
  read_length:
    type: int?
    default: 100
    inputBinding:
      position: 7
      prefix: -r
  filter_lt_srs:
     type: int?
     default: -1
     inputBinding:
       position: 8
       prefix: -sr
  transposon_zip_file:
    type: File
    inputBinding:
      position: 9
      prefix: -t
  priors_vcf:
    type: File?
    inputBinding:
      position: 10
      prefix: -v
  max_reads_in_mem:
    type: int?
    default: 5000
    inputBinding:
      position: 11
      prefix: -z
  working_dir:
    type: string?
    default: ./
    inputBinding:
      position: 12
      prefix: -w
  discovery_dir:
    type: string?
    default: ./
    inputBinding:
      position: 13
      prefix: -discoverydir
  aligned_bam_files:
    type:
      type: array
      items: File
    secondaryFiles: ['.bai']
  hum_breaks_bam_files:
    type:
      type: array
      items: File
    secondaryFiles: ['.bai']
  pulled_bam_files:
    type:
      type: array
      items: File
    secondaryFiles: ['.bai']
  tmp_bed_files:
    type:
      type: array
      items: File
outputs:
  melt_grp_stdout:
    type: stdout
  melt_grp_stderr:
    type: stderr
  pre_geno_file:
    type: File
    outputBinding: 
      glob: "*pre_geno.tsv"
