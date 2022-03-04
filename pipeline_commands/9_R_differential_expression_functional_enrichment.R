# SECTION 3.8 DIFFERENTIAL EXPRESSION ANALYSIS: DESEQ2

# 3.8.1 WORKSPACE PREPARATION

#Setting the working directory
setwd("/home/user/rnaseq_exp/output/deseq2_funcenrich/")

#Loading all required packages.
library(DESeq2)
library(ggplot2)
library(clusterProfiler)
library(pathview)
library(ReactomePA)
library(biomaRt)

# 3.8.2 READ AND PREPARE THE DATA

#Reading the featureCounts data.
read_counts_file <-file.path("/home/user/rnaseq_exp/output/featurecounts/counts.txt")
read_counts <- read.table(read_counts_file, header = TRUE, stringsAsFactors = FALSE)

#Setting the row names of the counts file to be the gene IDs.
rownames(read_counts)<-read_counts$Geneid

#Removing all unnecessary data.
counts <- read_counts[-c(1:6)]

#Printing the top lines of the counts.
head(counts)

#Renaming the columns based on the group
colnames(counts)<-c("gCTL1", "gCTL2", "gCTL3", "gMYC1", "gMYC2", "gMYC3")

#Printing the top lines of the data frame after renaming columns
head(counts)

#Create an experimental design matrix.
groups <- data.frame(row.names=colnames(counts))
groups$status <- c("control", "control", "control", "cMYC_KO", "cMYC_KO", "cMYC_KO")
groups$status <- as.factor(groups$status)

#Print the groups variable to display the sample information matrix.
groups

#Check the columns and row names match. The output should be TRUE.
counts<-counts[, rownames(groups)]
all(rownames(groups) == colnames(counts))

# 3.8.3 NORMALIZED COUNTS AND RUNNING DIFFERENTIAL EXPRESSION ANALYSIS

#Build the dds object.
dds <- DESeqDataSetFromMatrix(countData = counts, colData = groups, design = ~ status)

#Calculating the library size factor.
dds <- estimateSizeFactors(dds)

#Printing the size factors for each sample.
sizeFactors(dds)

#Extracting the normalized counts and saving it as a CSV file.
normalized_counts <- counts(dds, normalized=TRUE)
normalized_counts <- as.data.frame(normalized_counts)
write.csv(as.data.frame(normalized_counts), file=file.path("normalized_counts.csv"))

#Running the analysis.
dds$status <- relevel(dds$status, ref = "control")
dds <- DESeq(dds)

#Calculate the results for cMYC_KO against control.
contrast <- c("status", "cMYC_KO", "control")
res <- results(dds, contrast=contrast, alpha = 0.05)

#Identify the coefficient for log2FC shrinkage.
resultsNames(dds)

#Calculate the shrunk log2FC results.
resLFC <- lfcShrink(dds, res = res, coef = "status_cMYC_KO_vs_control", type = "apeglm")

#Print the top lines of the shrunken log2FC results.
head(resLFC)

#Summary of shrunken log2FC results.
summary(resLFC)

# 3.8.4 EXTRACTING AND VISUALISING DIFFERENTIAL EXPRESSION ANALYSIS RESULTS

#Building a data frame of the shrunken DE results.
de_res <- as.data.frame(resLFC)

#Building a Mart object.
mart_data <- useEnsembl("genes", dataset = "hsapiens_gene_ensembl")

#Converting ENSEMBL IDs to gene symbols.
ens_to_symbol <- getBM(attributes = c("ensembl_gene_id","hgnc_symbol"), values = rownames(de_res), filters = "ensembl_gene_id", mart = mart_data)

#Removing duplicate results resulting from multiple mapping of ENSEMBL IDs.
ens_to_symbol <- ens_to_symbol[!duplicated(ens_to_symbol$ensembl_gene_id), ]

#Adding the gene symbols to the shrunken DE results data
frame.
de_res$symbol <- ens_to_symbol$hgnc_symbol[match(rownames(de_res), ens_to_symbol$ensembl_gene_id)]

#Order the results by the adjusted p-value and write to a CSV file.
de_res <- de_res[order(de_res$padj), ]
write.csv(as.data.frame(de_res), file=file.path("de_results.csv"))

#Set the user thresholds.
fc_threshold <- log2(1.5)
padj_threshold <- 0.05

#CSV file for all significant DEGs ordered by adjusted
p-value.
de_res_sig <- subset(de_res, padj < padj_threshold & abs(log2FoldChange) > fc_threshold)
write.csv(as.data.frame(de_res_sig), file=file.path("significant_de_results.csv"))

#Print the top lines of all significant DEG results.
head(de_res_sig)

#CSV file for all significant upregulated DEGs ordered bylog2FC
up_res_sig <- subset(de_res, padj < padj_threshold & log2FoldChange > fc_threshold)
up_res_sig <- up_res_sig[order(-up_res_sig$log2FoldChange),]
write.csv(as.data.frame(up_res_sig), file=file.path("significant_up_de_results.csv"))

#Print the top lines of the upregulated DEG results.
head(up_res_sig)

#CSV file for all significant downregulated DEGs ordered by log2FC.
down_res_sig <- subset(de_res, padj < padj_threshold & log2FoldChange < -fc_threshold)
down_res_sig <- down_res_sig[order(down_res_sig$log2FoldChange),]
write.csv(as.data.frame(down_res_sig), file=file.path("significant_down_de_results.csv"))

#Print the top lines of the downregulated DEG results.
head(down_res_sig)

#Add a column to the data that specifies if a gene is Upregulated, Downregulated, or Not differentially expressed.
de_res_plot <- de_res
de_res_plot$direction <- "Not Differentially Expressed"
de_res_plot$direction[de_res_plot$log2FoldChange >fc_threshold & de_res_plot$padj < padj_threshold] <- "Upregulated"
de_res_plot$direction[de_res_plot$log2FoldChange <-fc_threshold & de_res_plot$padj < padj_threshold] <- "Downregulated"

#Volcano plot of results.
volcano <- ggplot(data=de_res_plot, aes(log2FoldChange, -log10(padj))) +
geom_point(aes(col=direction), size=0.2) +
scale_colour_manual(name="Differential Expression", values = setNames(c("red", "blue", "grey"), c("Upregulated", "Downregulated", "Not Differentially Expressed"))) +
geom_vline(xintercept = c(fc_threshold, fc_threshold*-1), linetype = "dashed") +
geom_hline(yintercept = -log10(padj_threshold), linetype = "dashed") +
ggtitle("Volcano Plot")
ggsave("volcano.png",volcano, dpi = 300, width = 10, height= 10)




# SECTION 3.9 FUNCTIONAL ENRICHMENT ANALYSIS: clusterProfiler

# 3.9.1 DECLARING VARIABLES

#All significant differentially expressed genes.
all_DEGs <- rownames(de_res_sig)

#Upregulated differentially expressed genes.
up_DEGs <- rownames(up_res_sig)

#Downregulated differentially expressed genes.
down_DEGs <- rownames(down_res_sig)

#Reference gene list.
reference <- rownames(de_res)

# 3.9.2 GO FUNCTIONAL ENRICHMENT ANALYSIS

#Functional enrichment analysis against GO for all significant DEGs.
all_enrichGO<-enrichGO(all_DEGs, OrgDb = "org.Hs.eg.db", keyType = "ENSEMBL", ont = "BP", universe = reference)

#Write the functional analysis results to a CSV file.
all_enrichGO_data <- data.frame(all_enrichGO)
write.csv(all_enrichGO_data, file=file.path("all_enrichGOBP.csv"))

#Functional enrichment analysis against GO for significant upregulated DEGs.
up_enrichGO <- enrichGO(up_DEGs, OrgDb = "org.Hs.eg.db", keyType = "ENSEMBL", ont = "BP", universe = reference)

#Write the functional analysis results to a CSV file.
up_enrichGO_data <- data.frame(up_enrichGO)
write.csv(up_enrichGO_data, file=file.path("up_enrichGOBP.csv"))

#Functional enrichment analysis against GO for significant downregulated DEGs.
down_enrichGO <- enrichGO(down_DEGs, OrgDb = "org.Hs.eg.db", keyType = "ENSEMBL", ont = "BP", universe = reference)

#Write the functional analysis results to a CSV file.
down_enrichGO_data <- data.frame(down_enrichGO)
write.csv(down_enrichGO_data, file=file.path("down_enrichGOBP.csv"))

#Dot plot of the top 50 enriched GO Biological Process terms ordered by gene ratio for all significant DEGs.
GOBP_dotplot <- dotplot(all_enrichGO, showCategory=50)
ggsave("all_enrichGO_dotplot.png", GOBP_dotplot, dpi=300, width=15, height=14)

# 3.9.3 KEGG FUNCTIONAL ENRICHMENT ANALYSIS

#Convert gene ID to entrez to be able to run KEGG and Reactome enrichment.
all_symbol_entrez <- bitr(all_DEGs, fromType = "ENSEMBL", toType = "ENTREZID", OrgDb = "org.Hs.eg.db")
all_entrez <- all_symbol_entrez$ENTREZID
up_symbol_entrez <- bitr(up_DEGs, fromType = "ENSEMBL", toType = "ENTREZID", OrgDb = "org.Hs.eg.db")
up_entrez <- up_symbol_entrez$ENTREZID
down_symbol_entrez <- bitr(down_DEGs, fromType = "ENSEMBL", toType = "ENTREZID", OrgDb = "org.Hs.eg.db")
down_entrez <- down_symbol_entrez$ENTREZID
reference_symbol_entrez <- bitr(reference, fromType = "ENSEMBL", toType = "ENTREZID", OrgDb = "org.Hs.eg.db")
reference_entrez <- reference_symbol_entrez$ENTREZID

#Functional enrichment analysis against KEGG for all significant DEGs.
all_enrichKEGG <- enrichKEGG(all_entrez, organism = "hsa", universe = reference_entrez)

#Writing the functional analysis results to a CSV file.
all_enrichKEGG_data <- data.frame(all_enrichKEGG)
write.csv(all_enrichKEGG_data, file=file.path("all_enrichKEGG.csv"))

#Functional enrichment analysis against KEGG for significant upregulated DEGs.
up_enrichKEGG <- enrichKEGG(up_entrez, organism = "hsa", universe = reference_entrez)

#Write the functional analysis results to a CSV file.
up_enrichKEGG_data <- data.frame(up_enrichKEGG)
write.csv(up_enrichKEGG_data, file=file.path("up_enrichKEGG.csv"))

#Functional enrichment analysis against KEGG for significant downregulated DEGs.
down_enrichKEGG <- enrichKEGG(down_entrez, organism = "hsa", universe = reference_entrez)

#Write the functional analysis results to a CSV file.
down_enrichKEGG_data <- data.frame(down_enrichKEGG)
write.csv(down_enrichKEGG_data, file=file.path("down_enrichKEGG.csv"))

#Dot plot of the KEGG reults ordered by gene ratio for all significant DEGs.
KEGG_dotplot <- dotplot(all_enrichKEGG , showCategory=50)
ggsave("all_enrichKEGG_dotplot.png", KEGG_dotplot, dpi =300, width = 15, height = 14)

#Extracting the Entrez ids and corresponding log2FC values.
all_symbol_entrez$log2FC <- de_res_sig$log2FoldChange[match(all_symbol_entrez$ENSEMBL, rownames(de_res_sig))]
entrez_log2FC <- all_symbol_entrez$log2FC
names(entrez_log2FC) <- all_symbol_entrez$ENTREZID

#Printing the top lines of the extracted Entrez ids and log2FCvalues.
head(entrez_log2FC)

#Setting the working directory to the pathview output directory.
setwd("/home/user/rnaseq_exp/output/pathview")

#Creating a KEGG pathway figure for the enriched pathway hsa04110.
hsa04110 <- pathview(gene.data = entrez_log2FC, pathway.id = "hsa04110", species = "hsa")

#Using a function to create figures for all significantly enriched KEGG pathways.
KEGG_pathview <- function(x){pathview(gene.data = entrez_log2FC, pathway.id = all_enrichKEGG$ID[x], species = "hsa")}
KEGG_pathview()

#Returning the working directory to the DESeq2 output file.
setwd("/home/user/rnaseq_exp/output/deseq2_funcenrich/")

# 3.9.4 REACTOME FUNCTIONAL ENRICHMENT ANALYSIS

#Functional enrichment analysis against Reactome for all significant DEGs.
all_enrichReactome <- enrichPathway(all_entrez, organism = "human", universe = reference_entrez)

#Write the functional analysis results to a CSV file.
all_enrichReactome_data <- data.frame(all_enrichReactome)
write.csv(all_enrichReactome_data, file=file.path("all_enrichReactome.csv"))

#Functional enrichment analysis against Reactome for significant upregulated DEGs.
up_enrichReactome <- enrichPathway(up_entrez, organism = "human", universe = reference_entrez)

#Write the functional analysis results to a CSV file.
up_enrichReactome_data <- data.frame(up_enrichReactome)
write.csv(up_enrichReactome_data, file=file.path("up_enrichReactome.csv"))

#Functional enrichment analysis against Reactome for significant downregulated DEGs.
down_enrichReactome <- enrichPathway(down_entrez, organism = "human", universe = reference_entrez)

#Write the functional analysis results to a CSV file.
down_enrichReactome_data <- data.frame(down_enrichReactome)
write.csv(down_enrichReactome_data, file=file.path("down_enrichReactome.csv"))

#Bar plot of the top 30 Reactome results ranked by p.adjust.
Reactome_barplot <- barplot(all_enrichReactome, showCategory= 30, x = "GeneRatio")
ggsave("all_enrichReactome_barplot.png", Reactome_barplot, dpi=300, width=15, height=14)

# 3.9.5 R PACKAGE VERSIONS

#Information on the package versions used in the analysis.
sessionInfo()
