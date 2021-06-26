cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    ramMin: 6000
    tmpdirMin: 20000
    outdirMin: 5000
    coresMin: 1
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - $(inputs.reads_bam_file)
      - $(inputs.reads_bai_file)

baseCommand: ["java", "-Xmx2G", "-jar", "/opt/MELTv2.1.5fast/MELT.jar", "Deletion-Genotype"]

stdout: melt-del-stdout.txt
stderr: melt-del-stderr.txt

inputs:
  reads_bam_file:
    type: File
    inputBinding:
      position: 4
      prefix: -bamfile
  reads_bai_file:
    type: File
  me_bed_file:
    type: File
    inputBinding:
      position: 5
      prefix: -bed
  expected_insert_size:
    type: int?    
    inputBinding:
      position: 6
      prefix: -e
  ref_fasta_file:
    type: File
    inputBinding:
      position: 7
      prefix: -h
    secondaryFiles:
     - .fai
  max_reads_in_mem:
    type: int?
    inputBinding:
      position: 8
      prefix: -z
  working_dir:
    type: string?
    default: ./
    inputBinding:
      position: 14
      prefix: -w
outputs:
  melt_gen_stdout:
    type: stdout
  melt_gen_stderr:
    type: stderr
  del_tsv_file:
    type: File
    outputBinding: 
      glob: "*.tsv"
      outputEval: |
        ${
          var bed_file = inputs.me_bed_file.basename;
          var new_suffix = bed_file.replace(/\.deletion(\.filtered)?\.bed$/, '.del.tsv');
          self[0].basename = inputs.reads_bam_file.basename.replace(/\.bam$/, "." + new_suffix);
          return self[0];
        }
