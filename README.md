
<img align="right" src="https://user-images.githubusercontent.com/85964718/156792644-1da58b56-f4f4-4d95-91c6-5dc4a337a694.png">


# Endothelial Cell RNA-seq Data: Differential Expression and Functional Enrichment Analyses to Study Phenotypic Switching

A user-friendly bioinformatics workflow to take raw data produced by RNA sequencing to interpretable results. The workflow described here was performed using Ubuntu 20.04.2 LTS, a Linux distribution. A 64-bit machine with at least 32Gb RAM is recommended for the majority of the steps in the workflow.

<br />

The published protocol can be found under [<ins>Chapter 29</ins>](<https://doi.org/10.1007/978-1-0716-2059-5_29>) of [<ins>Angiogenesis Methods and Protocols 2022</ins>](<https://doi.org/10.1007/978-1-0716-2059-5>).

<br />

## Table of Contents
<ol>
  <li>
    <a href="https://github.com/vasc-bioinf/rnaseq_exp/blob/main/README.md#bioinformatics-workflow">Bioinformatics Workflow</a>
  </li>
  <li>
    <a href="https://github.com/vasc-bioinf/rnaseq_exp/blob/main/README.md#software-and-r-packages">Software and R Packages</a>
  </li>
  <li>
    <a href="https://github.com/vasc-bioinf/rnaseq_exp#workspace-preparation">Workspace Preparation</a>
  </li>
  <li>
    <a href="https://github.com/vasc-bioinf/rnaseq_exp#software-installation">Software Installation</a>
  </li>
  <li>
    <a href="https://github.com/vasc-bioinf/rnaseq_exp/blob/main/README.md#raw-reads-download">Raw Reads Download</a>
  </li>
  <li>
    <a href="https://github.com/vasc-bioinf/rnaseq_exp/blob/main/README.md#reference-genome-download">Reference Genome Download</a>
  </li>
  <li>
    <a href="https://github.com/vasc-bioinf/rnaseq_exp/blob/main/README.md#begin">Begin!</a>
  </ol>

<br />
  
## Bioinformatics Workflow

The steps of the workflow are shown in the flowchart. The tools used are in yellow boxes, the data required/produced in white boxes and file formats in purple, blue, dark green, orange and grey boxes. Results obtained are in light green boxes.

<br />
<div align="center">
  <img src="images/bioinformatics_workflow.png">
  </a>
</div>

<br />

## Software and R Packages

Below is a list of the software and R packages used in workflow with the corresponding URL.

<br />

<div align="center">
  
| Software | URL |
| --- | --- |
Ubuntu | https://ubuntu.com/
FastQC | https://www.bioinformatics.babraham.ac.uk/projects/fastqc/
Cutadapt | https://github.com/marcelm/cutadapt
STAR | https://github.com/alexdobin/STAR
Qualimap | http://qualimap.conesalab.org/
Subread (featureCounts) | http://subread.sourceforge.net/
R | https://www.r-project.org/
Rstudio | https://www.rstudio.com/
DESeq2 | https://bioconductor.org/packages/release/bioc/html/DESeq2.html
clusterProfiler | https://bioconductor.org/packages/release/bioc/html/clusterProfiler.html
pathview | http://www.bioconductor.org/packages/release/bioc/html/pathview.html
ReactomePA | https://bioconductor.org/packages/release/bioc/html/ReactomePA.html
enrichplot | https://bioconductor.org/packages/release/bioc/html/enrichplot.html
biomaRt | https://bioconductor.org/packages/release/bioc/html/biomaRt.html
ggplot2 | https://ggplot2.tidyverse.org/
GO | http://geneontology.org/
KEGG | https://www.genome.jp/kegg/
Reactome | https://reactome.org/
GSEA | https://www.gsea-msigdb.org/gsea/index.jsp
  
</div>
<div>

<br />

## Workspace Preparation

The commands used in the workflow, as seen in [software_downloads](software_downloads/) and [pipeline_commands](pipeline_commands/) use relevant file paths. Throughout the workflow, when a path containing "user" is shown (e.g., /home/user/rnaseq_exp), "user" represents the user's name and should be replaced by it.

Key directories to be made prior to software installation and raw data download.

1. Change directory to 'user'
   ```sh
   cd /home/user
   ```
  
2. Make a new directory called 'rnaseq_exp'
   ```sh
   mkdir rnaseq_exp
   ```

3. Change directory to 'rnaseq_exp'
   ```sh
   cd rnaseq_exp
   ```
  
4. Make new directories called 'output', 'raw_data', resources', 'programs'
   ```sh
   mkdir output raw_data resources programs
   ```


<br />

## Software Installation
The required software and R packages can be installed by following the commands in the files within the [software_downloads](software_downloads/) directory.

Refer to section 3.2 of the [published protocol](<https://doi.org/10.1007/978-1-0716-2059-5_29>) for more information.

<br />


## Raw Reads Download

A publicly available HUVEC dataset was used from a published study [Andrade J et al (2021) Control of endothelial quiescence by FOXO-regulated metabolites. Nat Cell Biol 23(4):413–423](<https://www.nature.com/articles/s41556-021-00637-6>).

The raw data in FASTQ format was obtained from the European Nucleotide Archive project [PRJNA679567](https://www.ebi.ac.uk/ena/browser/view/PRJNA679567?show=reads). Select the 'Download All' button above the 'FASTQ FTP' column and save in the raw_data directory created above.

Follow the commands in [pipeline_commands/1_raw_data_decompression.txt](<https://github.com/vasc-bioinf/rnaseq_exp/blob/main/pipeline_commands/1_raw_data_decompression.txt>) to decompress the raw read files.

Refer to section 3.2.9 of the [published protocol](<https://doi.org/10.1007/978-1-0716-2059-5_29>) for more information.

<br />

## Reference Genome Download

<br />

The reference genome in FASTA format and the annotation of the reference genome in GTF or GFF format are required.

Both can be obtained from [Ensembl FTP Download](<http://www.ensembl.org/info/data/ftp/index.html>) via an FTP client.

See the figure below to download the required files. Save in the resources directory created above.

Follow the commands in [pipeline_commands/2_ref_genome_anno_decompression.txt](<https://github.com/vasc-bioinf/rnaseq_exp/blob/main/pipeline_commands/2_ref_genome_anno_decompression.txt>) to decompress the genome files.

Refer to section 3.2.10 of the [published protocol](<https://doi.org/10.1007/978-1-0716-2059-5_29>) for more information.

<br />
  
<div align="center">
  <img src="images/reference_genome_download.png">
  </a>
</div>

<br />

## Begin!

Once the required software and R packages have been installed, the workspace created, the raw reads and the genome files downloaded and decompressed the analysis can begin.

Follow the command files in [pipeline_commands](<https://github.com/vasc-bioinf/rnaseq_exp/tree/main/pipeline_commands>) in conjunction with the [published protocol](<https://doi.org/10.1007/978-1-0716-2059-5_29>) to successfully complete the analysis.

The Notes section of the [published protocol](<https://doi.org/10.1007/978-1-0716-2059-5_29>), as well as the main text comments on errors that may arise throughout the workflow. These may help with troubleshooting.

<p align="right">(<a href="#top">back to top</a>)</p>

