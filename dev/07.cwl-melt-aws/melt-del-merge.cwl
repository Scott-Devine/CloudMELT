cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    ramMin: 2000
    tmpdirMin: 20000
    outdirMin: 5000
    coresMin: 1
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing: |
      ${
        var all_files = new Array();
        all_files = all_files.concat(inputs.tsv_files);
        return all_files;
       }

baseCommand: ["java", "-Xmx2G", "-jar", "/opt/MELTv2.1.5/MELT.jar", "Deletion-Merge"]

stdout: melt-del-merge-stdout.txt
stderr: melt-del-merge-stderr.txt

hints:
  DockerRequirement:
    dockerImageId: 205226202704.dkr.ecr.us-east-1.amazonaws.com/umigs/melt:latest

inputs:
  tsv_files:
    type:
      type: array
      items: File
  mergelist:
    type: File
    inputBinding:
      position: 2
      prefix: -mergelist
  me_bed_file:
    type: File
    inputBinding:
      position: 3
      prefix: -bed
  ref_fasta_file:
    type: File
    inputBinding:
      position: 4
      prefix: -h
    secondaryFiles:
     - .fai
  min_contig_len:
     type: int?
     default: 1000000
     inputBinding:
       position: 5
       prefix: -d
  output_dir:
    type: string?
    default: ./
    inputBinding:
      position: 6
      prefix: -o
outputs:
  melt_gen_merge_stdout:
    type: stdout
  melt_gen_merge_stderr:
    type: stderr
  vcf_file:
    type: File
    outputBinding: 
      glob: "*.final_comp.vcf"
      outputEval: |
        ${
          var bed_file = inputs.me_bed_file.basename;
          self[0].basename = bed_file.replace(/\.bed$/, '.DEL.vcf');
          return self[0];
        }
