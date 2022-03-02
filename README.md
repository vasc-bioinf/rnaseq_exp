# Endothelial Cell RNA-seq Data: Differential Expression and Functional Enrichment Analyses to Study Phenotypic Switching

A user-friendly bioinformatics workflow to take raw data produced by RNA sequencing to interpretable results.

The full document can be found under [Chapter 29](<https://doi.org/10.1007/978-1-0716-2059-5_29>) of Angiogenesis Methods and Protocols 2022 <https://doi.org/10.1007/978-1-0716-2059-5>.

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="https://github.com/vasc-bioinf/rnaseq_exp/blob/main/README.md#bioinformatics-workflow">Bioinformatics workflow</a>
    </li>
    <li>
      <a href="https://github.com/vasc-bioinf/rnaseq_exp/blob/main/README.md#software-and-r-packages">Software and R packages</a>
    </details>

  
  
## Bioinformatics workflow

The steps of the workflow are shown in the flowchart. The tools used are in yellow boxes, the data required/produced in white boxes and file formats in purple, blue, dark green, orange and grey boxes. Results obtained are in light green boxes.

<br />
<div align="center">
  <img src="images/bioinformatics_workflow.png">
  </a>
</div>
<br />

## Software and R packages

Below is a list of the software and R packages used in workflow with the corresponding URL.

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

<br />

## Workspace preparation

The commands used in workflow, as seen in [software_downloads](software_downloads/) and [pipeline_commands](pipeline_commands/)
