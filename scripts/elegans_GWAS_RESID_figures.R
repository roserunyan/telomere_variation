##────────────────────────────────────────────────
##  Telomere Length QTL Figure Script
##────────────────────────────────────────────────

# Load libraries
library(tidyverse)
library(data.table)
library(dplyr)
library(ggplot2)
library(tidyr)
library(stringr)
library(ggrepel)

# Set working directory
setwd("~/Rose")

#────────────────────────────────────────────────
# MAN PLOT
#────────────────────────────────────────────────

# Load data
#gwas_raw <- read_tsv(
#    "/home/rrunyan1/Rose/results/nemascan/elegans/LOCO/Mapping/Raw/TELOMERE_RESID_lmm-exact.loco.mlma",
#  col_types = cols()
#) 


qtl_peaks <- read_tsv(
  "/home/rrunyan1/Rose/results/nemascan/elegans/LOCO/Mapping/Processed/QTL_peaks_loco.tsv"
)
# isolate chr II QTL 
qtl_chrII <- qtl_peaks %>%
  filter(CHROM == "II") %>%
  arrange(desc(log10p)) %>%
  slice(1)

region_start <- qtl_chrII$startPOS / 1e6
region_end   <- qtl_chrII$endPOS  / 1e6

# Load aggregate mapping
d.all <- fread("/home/rrunyan1/Rose/results/nemascan/elegans/LOCO/Mapping/Processed/processed_TELOMERE_RESID_AGGREGATE_mapping_loco.tsv") %>%
  distinct(marker, .keep_all = TRUE)

# Remove mitochondria if present
d.all <- d.all %>%
  filter(CHROM != "MtDNA")

# Add log10p if not already present
if(!"log10p" %in% colnames(d.all)){
  d.all <- d.all %>%
    mutate(log10p = -log10(P))
}

# Compute thresholds
#────────────────────────────────────────
# Bonferroni (based on unique markers)
BF <- -log10(0.05 / nrow(d.all %>% distinct(marker)))

# Load independent test count from NemaScan
total_independent_tests <- read.table(
  "/home/rrunyan1/Rose/results/nemascan/elegans/Genotype_Matrix/total_independent_tests.txt"
)
EIGEN <- -log10(0.05 / total_independent_tests[[1]])

# Assign significance
d.all2 <- d.all %>%
  mutate(sig = case_when(
    log10p > BF ~ "BF",
    log10p > EIGEN & log10p <= BF ~ "EIGEN",
    TRUE ~ "NONSIG"
  ))

sig.colors <- c("BF" = "red",
                "EIGEN" = "#EE4266",
                "NONSIG" = "black")

sig.df <- tibble(
  name = c("BF", "EIGEN"),
  sig  = c(BF, EIGEN)
)
# Add gene labels
genes <- data.frame(
  CHROM = c("III", "II", "III", "II", "IV", "I", "V"),
  start = c(7131880, 14524173, 13780215, 14362019, 5541627, 8660831, 13191702),
  end   = c(7133678, 14525108, 13781133, 14365179, 5544748, 8663104, 13193538),
  gene  = c("pot-1", "pot-2", "pot-3", "tebp-1", "tebp-2", "mrt-1", "sun-1")
)
genes$mid <- (genes$start + genes$end) / 2 / 1e6
y_bottom <- -1
genes <- genes[order(genes$CHROM, genes$mid), ]
genes$rank <- ave(genes$mid, genes$CHROM, FUN = seq_along)
genes$y <- -0.2 - 0.3 * genes$rank

# Manhattan plot
manhattan_plot <- ggplot(d.all2) +
  theme_bw() +
  # geom_rect(
  #   data = tibble(
  #     CHROM = "V",
  #     xmin = region_start,
  #     xmax = region_end,
  #     ymin = -Inf,
  #     ymax = Inf
  #   ),
  #   aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
  #   fill = "rosybrown1",
  #   alpha = 0.25,
  #   inherit.aes = FALSE
  # ) +
  geom_point(aes(
    x = POS / 1e6,
    y = log10p,
    colour = sig,
    alpha = sig
  ), size = 0.7) +
  scale_alpha_manual(values = c("BF" = 1,
                                "EIGEN" = 1,
                                "NONSIG" = 0.25)) +
  scale_colour_manual(values = sig.colors) +
  geom_hline(data = sig.df,
             aes(yintercept = sig, linetype = name)) +
  scale_linetype_manual(values = c("BF" = 1, "EIGEN" = 3)) +
  facet_grid(~CHROM, scales = "free_x") +
  labs(
    x = "Genomic position (Mb)",
    y = expression(-log[10](italic(p)))
  ) +
  #coord_cartesian(ylim = c(-1, NA), clip = "off") +
  theme_bw(base_size = 11) +
  theme(
    legend.position = "none",
    panel.grid = element_blank(),
    strip.text.x = element_text(size = 9),
    axis.text.x = element_blank(),
    axis.ticks.x = element_line()
  ) #+
#  geom_text(
#    data = genes,
#    aes(x = mid-2, y = y, label = gene),
#    inherit.aes = FALSE,
#    size = 3
#  ) +
#  geom_segment(
#    data = genes,
#    aes(x = mid, xend = mid,
#        y = -0.3, yend = 0.05),
#    inherit.aes = FALSE,
#    color = "black",
#    size = 0.5
#  )
manhattan_plot

ggplot2::ggsave(
  filename = "/home/rrunyan1/Rose/plots/elegans/elegans_man_plot_RESID.png",
  plot = manhattan_plot,
  width = 4.5,      # in inches
  height = 2.5,     # in inches
  dpi = 300       # high resolution
)
#────────────────────────────────────────────────
# P x G
#────────────────────────────────────────────────
peak_snp <- qtl_chrII$marker   
#trait_data <- read_csv("/vast/eande106/projects/Maya/alcohol_sensitivity/data/20240609_rawdata_Fig1_2.csv") 
trait_data <- read_tsv("~/Rose/results/nemascan/elegans/Phenotypes/pr_TELOMERE_RESID.tsv")
allele_data <- read.delim('/home/rrunyan1/Rose/results/nemascan/elegans/LOCO/Mapping/Processed/processed_TELOMERE_RESID_AGGREGATE_mapping_loco.tsv')
allele_peak <- allele_data %>%
  filter(marker == peak_snp)
# Merge and format allele data
combined_data <- merge(trait_data, allele_peak, by = "strain") %>%
  mutate(
    allele = factor(dplyr::recode(as.character(allele), "-1" = "REF", "1" = "ALT"), levels = c("REF", "ALT")),
    value = TELOMERE_RESID
  )

# PxG plot
pxg_plot <- combined_data %>%
  filter(!is.na(allele)) %>%
  ggplot(aes(x = allele, y = value)) +
  
  geom_boxplot(
    fill = NA,                
    color = "black",
    alpha = 0.7,
    width = 0.5,
    outlier.shape = NA        # avoid duplicate points
  ) +
  
  ggbeeswarm::geom_beeswarm(
    shape = 21,
    size = 0.9,
    fill = "black",
    color = "black",
    alpha = 0.4
  ) +
  
  scale_x_discrete(labels = c("REF", "ALT")) +   
  
  labs(
    x = "Genotype",
    y = "Estimated Telomere Length"
    #title = paste("GWAS Marker")
  ) +
  theme_bw(base_size = 11) +
  theme(
    legend.position = "none",
    panel.grid = element_blank(),
    axis.text.x = element_text(size = 12),   
    axis.ticks.x = element_line(),
    plot.title = element_text(hjust = 0.5, face = "bold")
  ) #+ coord_cartesian(ylim = c(0, 1))

pxg_plot
ggplot2::ggsave(
  filename = "/home/rrunyan1/Rose/plots/elegans/pxg_plot.png",
  plot = pxg_plot,
  width = 5,      # in inches
  height = 5,     # in inches
  dpi = 300       # high resolution
)

#────────────────────────────────────────────────
# Gene map
#────────────────────────────────────────────────

### -----------------------------
### 1. Load NemaScan outputs
### -----------------------------

# ld <- data.table::fread("/vast/eande106/projects/Maya/alcohol_sensitivity/data/processed/LOCO/Fine_Mappings/Data/alcohol_sensitivity.V.16616122.17602325.LD_loco.tsv")

annotations <- data.table::fread("/home/rrunyan1/Rose/results/nemascan/elegans/LOCO/Fine_Mappings/Data/TELOMERE_RESID_II_13369935-15259044_bcsq_genes_loco.tsv")

# genomatrix <- data.table::fread("/vast/eande106/projects/Maya/alcohol_sensitivity/data/processed/LOCO/Fine_Mappings/Data/alcohol_sensitivity.V.16616122-17602325.ROI_Genotype_Matrix_loco.tsv")

finemap <- data.table::fread("/home/rrunyan1/Rose/results/nemascan/elegans/LOCO/Fine_Mappings/Data/TELOMERE_RESID.II.13369935.15259044.finemap_inbred.loco.fastGWA")


# 
# # --- 1. Standardize CHROM in annotations ---
# annotations[, CHROM_num := fifelse(CHROM %in% c("V", "5"), 5L, as.integer(CHROM))]

# # --- 2. Merge finemap with annotations ---
# finemap_annot <- merge(
#   finemap,
#   annotations[, .(CHR = CHROM_num, POS, MARKER, GENE_NAME, WBGeneID, START_POS, END_POS, STRAND, PEAK_MARKER)],
#   by = c("CHR", "POS"),
#   all.x = TRUE
# )

# --- 3. LD with peak SNP ---
peak_variant <- annotations$PEAK_MARKER[1]  
peak_variant <- gsub("^5:", "", peak_variant)
finemap$VARIANT_LOG10p <- -log10(finemap$P)
# Define a small offset for the arrows (5% of max -log10(p))
max_logp <- max(finemap$VARIANT_LOG10p, na.rm = TRUE) * 0.05

# Make sure both are data.tables
setDT(finemap)
setDT(annotations)

# Keep only one row per POS in annotations
annotations_unique <- unique(annotations[, .(POS, CONSEQUENCE)])

# Merge CONSEQUENCE into finemap
finemap <- annotations_unique[finemap, on = "POS"]

# Check
head(finemap[, .(POS, CONSEQUENCE)])
# finemap_annot <- merge(
#   ld,
#   finemap_annot[, .(CHR, POS, SNP, GENE_NAME, WBGeneID, START_POS, END_POS)],
#   by.x = c("CHR_B", "BP_B"),
#   by.y = c("CHR", "POS"),
#   all.x = TRUE
# )

xs <- min(annotations$POS)
xe <- max(annotations$POS)
# --- 4. Prepare gene arrows for plotting ---
#gene_arrows <- annotations[CHROM_num == unique(finemap_annot$CHR)]
#gene_arrows[, ypos := -0.5]  # genes below x-axis

# Make sure peak_variant is numeric
peak_variant <- as.numeric(peak_variant)
peak_variant <- peak_variant / 1e6

gene_plot <- ggplot(annotations) +
  # vertical line for the peak variant
  geom_vline(xintercept = peak_variant, linetype = "dashed", color = "black") +
  
  # gene/transcript arrows
  geom_segment(aes(
    x = ifelse(STRAND == "+", TRANSCRIPTION_START_POS/1e6, TRANSCRIPTION_END_POS/1e6),
    xend = ifelse(STRAND == "+", TRANSCRIPTION_END_POS/1e6, TRANSCRIPTION_START_POS/1e6),
    y = VARIANT_LOG10p,
    yend = VARIANT_LOG10p
  ),
  arrow = arrow(length = unit(5, "points")),
  size = 1) +
  
  # SNP consequences
  geom_segment(aes(
    x = POS/1e6,
    xend = POS/1e6,
    y = VARIANT_LOG10p + max_logp,
    yend = VARIANT_LOG10p - max_logp,
    color = CONSEQUENCE
  ), data = finemap) +
  
  scale_color_manual(
    values = c(
      "synonymous" = "green",
      "missense" = "red",
      "splice_region" = "red",
      "intergenic" = "gray80",
      "intron" = "gray30",
      "5_prime_utr" = "orange",
      "3_prime_utr" = "orange",
      "Linker" = "gray80"
    ),
    breaks = c("intergenic", "synonymous", "intron", "3_prime_utr", "5_prime_utr", "missense", "splice_region"),
    name = "EFFECT"
  ) +
  
  labs(
    x = "Genomic position (Mb)",
    y = expression(-log[10](italic(p)))
  ) +
  theme_bw(base_size = 11) +
  xlim(c(xs/1e6, xe/1e6)) +
  theme(
    legend.position = "bottom",
    legend.title = element_text(size = 10),       # smaller legend title
    legend.text = element_text(size = 8),         # smaller legend text
    legend.key.size = unit(0.5, "cm"),           # smaller color boxes
    panel.grid = element_blank()
  )
gene_plot
# Save the plot
ggplot2::ggsave(
  filename = "/home/rrunyan1/Rose/plots/elegans/gene_plot.png",
  plot = gene_plot,
  width = 7.5,
  height = 5,
  dpi = 300
)


#############
# LD Plot #
############

library(genetics) 
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)
library(readr)
library(glue)
library(purrr)

gm <- read.table('/vast/eande106/projects/Maya/alcohol_sensitivity/data/processed/Genotype_Matrix/Genotype_Matrix.tsv', header = TRUE)
processed_mapping <- read.delim('/vast/eande106/projects/Maya/alcohol_sensitivity/data/processed/LOCO/Mapping/Processed/alcohol_sensitivity_AGGREGATE_qtl_region_loco.tsv', stringsAsFactors=FALSE)
TRAIT <- 'alcohol_sensitvity'

snp_df <- processed_mapping %>% na.omit()

ld_snps <- dplyr::filter(gm, CHROM %in% snp_df$CHROM, POS %in% snp_df$peakPOS)


if ( nrow(ld_snps) > 1 ) {
  
  ld_snps <- data.frame(snp_id = paste(ld_snps$CHROM, ld_snps$POS,
                                       sep = "_"), data.frame(ld_snps)[, 5:ncol(ld_snps)])
  
  sn <- list()
  
  for (i in 1:nrow(ld_snps)) {
    sn[[i]] <- genetics::genotype(as.character(gsub(1, "T/T",
                                                    gsub(-1, "A/A", ld_snps[i, 4:ncol(ld_snps)]))))
  }
  
  test <- data.frame(sn)
  colnames(test) <- (ld_snps$snp_id)
  ldcalc <- t(genetics::LD(test)[[4]])^2
  diag(ldcalc) <- 1
  
  ldcalc %>%
    as.data.frame() %>%
    dplyr::mutate(QTL1 = rownames(.),
                  trait = TRAIT) %>%
    tidyr::pivot_longer(cols = -c(QTL1, trait), names_to = "QTL2", values_to = "r2") %>%
    dplyr::filter(!is.na(r2)) %>%
    dplyr::select(QTL1, QTL2, everything()) %>%
    ggplot(., mapping = aes(x = QTL1, y = QTL2)) + 
    theme_classic() +
    geom_tile(aes(fill = r2),colour = "black", size = 3) + 
    geom_text(aes(label = round(r2, 4))) + 
    scale_fill_gradient(low="#2031c4", high="#ffe45c", limits = c(0, 1), name = expression(r^2)) + 
    theme(axis.title = element_blank(),
          axis.text = element_text(colour = "black")) + 
    labs(title = paste0("Linkage Disequilibrium: ",TRAIT))
  
  ggsave(filename = paste0('/vast/eande106/projects/Maya/alcohol_sensitivity/plots/LD_plot.png'), width = 10, height = 7)
}


# Table stats
pdf_path <- "/vast/eande106/projects/Maya/alcohol_sensitivity/plots/snp_df_for_LD.pdf"
processed_mapping$peakPOS <- as.integer(as.character(processed_mapping$peakPOS))
snp_df <- processed_mapping %>%
  na.omit() %>%
  dplyr::mutate(POS = peakPOS) %>%
  dplyr::select(-trait, -peak_id, -narrow_h2)
show_cols <- c("CHROM", "marker", "log10p", "startPOS", "peakPOS", "endPOS")
show_cols <- intersect(show_cols, colnames(snp_df))
table_df_fig <- snp_df[, show_cols, drop = FALSE]
pdf(file = pdf_path, width = 6, height = 3)  # landscape A4/letter
grid::grid.newpage()
#grid::grid.text("SNPs used for LD", y = unit(0.98, "npc"), gp = grid::gpar(fontsize = 16, fontface = "bold"))
grid.table(table_df_fig, rows = NULL)   # grid.table from gridExtra
dev.off()

