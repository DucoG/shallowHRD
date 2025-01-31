# if (!requireNamespace("BiocManager", quietly = TRUE))
#     install.packages("BiocManager")
# 
# BiocManager::install("QDNAseq")
# BiocManager::install("QDNAseq.hg19")
# install.packages("BSgenome.Hsapiens.UCSC.hg19")
# install.packages("BSgenome.Hsapiens.UCSC.hg38")
# BiocManager::install("Biobase")
# BiocManager::install("DNAcopy")
# BiocManager::install("CGHcall")

library("Biobase")
# library("BSgenome.Hsapiens.UCSC.hg19")
library("QDNAseq")
library("DNAcopy") 
library("CGHcall")

##### initialization #####

args = commandArgs(trailingOnly=TRUE)

path_to_bam_file = args[1]
inputPath = normalizePath(path_to_bam_file)

output_relative_Path = args[2]
outputPath = normalizePath(output_relative_Path)

bin_size = args[3]


inputPath
outputPath
bin_size


##### QDNAseq script #####

bin_size = as.numeric(bin_size)

bins <- getBinAnnotations(binSize=bin_size)

readCounts <- binReadCounts(bins, path=inputPath)

saveRDS(readCounts, file=paste0(outputPath, '/', 'readcounts.rds'))

# exportBins(readCounts, file="D038R4_readcount_unfiltered_10kb.tsv", 
#            format="tsv", type=c("copynumber"), logTransform = FALSE)
 
readCountsFiltered <- applyFilters(readCounts,
                                   residual=TRUE, blacklist=TRUE)
 
# exportBins(readCountsFiltered, file="D038R4_readcount_filtered_10kb.tsv", 
#            format="tsv", type=c("copynumber"), logTransform = FALSE)
 
readCountsFiltered <- estimateCorrection(readCountsFiltered)
 
copyNumbers <- correctBins(readCountsFiltered)
 
copyNumbersNormalized <- normalizeBins(copyNumbers)
 
copyNumbersSmooth <- smoothOutlierBins(copyNumbersNormalized)
 
copyNumbersSegmented <- segmentBins(copyNumbersSmooth, transformFun = 'none',
                                    alpha = 0.05, nperm = 10000, p.method = "hybrid",
                                    min.width=5, kmax=25, nmin=200, eta=0.05,
                                    trim = 0.025, undo.splits = "sdundo", undo.SD=1)

saveRDS(copyNumbersSegmented, file=paste0(outputPath, '/', 'segmented.rds'))

 
copyNumbersSegmented <- normalizeSegmentedBins(copyNumbersSegmented)
 
exportBins(copyNumbersSegmented, file=paste0(outputPath,"/","bam_CN.tsv"), format="tsv", type=c("copynumber")) # exporte les données au format VCF DEL and DUP
exportBins(copyNumbersSegmented, file=paste0(outputPath,"/","bam_seg.tsv"), format="tsv", type=c("segments"))
 
X = read.table(paste0(outputPath,"/","bam_CN.tsv"), sep = "\t", header = TRUE)
Y = read.table(paste0(outputPath,"/","bam_CN.tsv"), sep = "\t", header = TRUE)
 
X = cbind(X, Y[,5])
X = X[,-4]
X = X[,-1]
head(X)


colnames(X) <- c("chromosome", "start", "ratio", "ratio_median")
write.table(X, file = paste0(outputPath,"/","bam_ratio.txt"), sep = "\t", row.names = FALSE)
