cwlVersion: v1.0
class: Workflow

requirements:
  ScatterFeatureRequirement: {}

inputs:
  reads_bam_files:
    type:
      type: array
      items: File
    secondaryFiles:
      - .bai
  me_bed_file:
    type: File
  ref_fasta_file:
    type: File
    secondaryFiles:
      - .fai
  expected_insert_size: int?
  max_reads_in_mem: int?
  min_contig_len: int?

outputs:
  vcf_file:
    type: File
    outputSource: melt_del_merge/vcf_file

steps:
  melt_del_gen:
    run: melt-del-gen.cwl
    scatter: reads_bam_file
    in:
      ref_fasta_file: ref_fasta_file
      reads_bam_file: reads_bam_files
      me_bed_file: me_bed_file
    out: [tsv_file]

  make_mergelist:
    run:
      class: CommandLineTool
      baseCommand: ['/Users/jcrabtree/MELT/04.cwl-local-multi-sample/commas_to_newlines.sh']
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
      tsv_files: melt_del_gen/tsv_file
    out: [file_list]

  melt_del_merge:
    run: melt-del-merge.cwl
    in:
      tsv_files: melt_del_gen/tsv_file
      mergelist: make_mergelist/file_list
      ref_fasta_file: ref_fasta_file
      me_bed_file: me_bed_file
    out: [vcf_file]
