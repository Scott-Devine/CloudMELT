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
        all_files.push(inputs.pre_geno_file);
        all_files = all_files.concat(inputs.geno_files);
        return all_files;
       }

baseCommand: ["java", "-Xmx2G", "-jar", "/opt/MELTv2.1.5/MELT.jar", "MakeVCF"]

stdout: melt-vcf-stdout.txt
stderr: melt-vcf-stderr.txt

hints:
  DockerRequirement:
    dockerImageId: umigs/cloud-melt-v1.0.0

inputs:
  remove_ac0_sites:
    type: boolean?
    default: false
    inputBinding:
      position: 2
      prefix: -ac
  genotyping_dir:
    type: string?
    default: ./
    inputBinding:
      position: 3
      prefix: -genotypingdir
  ref_fasta_file:
    type: File
    inputBinding:
      position: 4
      prefix: -h
    secondaryFiles:
     - .fai
  no_call_percent:
    type: int?
    default: 25
    inputBinding:
      position: 5
      prefix: -j
  output_dir:
    type: string?
    default: ./
    inputBinding:
      position: 6
      prefix: -o
  discovery_dir:
    type: string?
    default: ./
    inputBinding:
      position: 7
      prefix: -p
  makevcf_stdev_cutoff:
    type: float?
    default: 2.0
    inputBinding:
      position: 8
      prefix: -s
  transposon_zip_file:
    type: File
    inputBinding:
      position: 9
      prefix: -t
  working_dir:
    type: string?
    default: ./
    inputBinding:
      position: 10
      prefix: -w
  pre_geno_file:
    type: File
  geno_files:
    type:
      type: array
      items: File

outputs:
  melt_vcf_stdout:
    type: stdout
  melt_vcf_stderr:
    type: stderr
  vcf_file:
    type: File
    outputBinding: 
      glob: "*.final_comp.vcf"
