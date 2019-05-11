cwlVersion: v1.0
class: Workflow

requirements:
  ResourceRequirement:
    ramMin: 2000
    tmpdirMin: 20000
    outdirMin: 5000
    coresMin: 1
  InlineJavascriptRequirement: {}

inputs:
  tsv_files:
    type:
      type: array
      items: File
  me_bed_file:
    type: File
  ref_fasta_file:
    type: File
    secondaryFiles:
     - .fai
  min_contig_len:
     type: int?
     default: 1000000
  output_dir:
    type: string?
    default: ./

outputs:
  vcf_file:
    type: File
    outputSource: melt_del_merge/vcf_file

steps:
  make_mergelist:
    run:
      class: CommandLineTool
      baseCommand: ['commas_to_newlines.sh']
      stdout: files_list.txt

      requirements:
        InlineJavascriptRequirement: {}
        InitialWorkDirRequirement:
          listing:
            - entryname: files.txt
              entry: |
                ${
                  var res = new Array();
                  inputs.tsv_files.forEach(function(e) {
                    res.push(e.basename);
                  });
                  return res.join(",");
                 }

      inputs:
        tsv_files:
          type:
            type: array
            items: File
        file:
          type: string
          default: "files.txt"
          inputBinding:
            position: 1

      outputs:
        file_list:
          type: File
          outputBinding:
            glob: files_list.txt
    in:
      tsv_files: tsv_files
    out: [file_list]

  melt_del_merge:
    run:
      class: CommandLineTool
      baseCommand: ["java", "-Xmx2G", "-jar", "/opt/MELTv2.1.5/MELT.jar", "Deletion-Merge"]

      stdout: melt-del-merge-stdout.txt
      stderr: melt-del-merge-stderr.txt

      requirements:
        InitialWorkDirRequirement:
          listing: |
            ${
              var all_files = new Array();
              all_files = all_files.concat(inputs.tsv_files);
              return all_files;
             }

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
            glob: "*.vcf"
            outputEval: |
              ${
                var bed_file = inputs.me_bed_file.basename;
                self[0].basename = bed_file.replace(/\.deletion(\.filtered)?\.bed$/, '.del.vcf');
                return self[0];
              }

    in:
      tsv_files: tsv_files
      mergelist: make_mergelist/file_list
      ref_fasta_file: ref_fasta_file
      me_bed_file: me_bed_file
    out: [vcf_file]









