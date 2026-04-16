##########################################################################
### Linear regression on sequencing depth variance and telomere length ###
##########################################################################

library(tidyverse)

### Plot PC1 and PC2
# load in per sample PC data matrix
elegans_pcs <- read.delim("/vast/eande106/projects/Rose/results/NGS-PCA/elegans/eleganssvd.pcs.txt", header = TRUE)

# Plot first 2 PCs
ggplot(elegans_pcs, aes(x=PC1, y=PC2)) + 
  geom_point() +
  ggtitle("c. elegans PC1 vs. PC2") +
  theme_minimal()

ggsave("/vast/eande106/projects/Rose/results/NGS-PCA/elegans/plots/pc1-pc2.png", width=4, height=4)


### Percent variance explained by each PC
# load in PC singular values
elegans_pcs_single <- read.delim("/vast/eande106/projects/Rose/results/NGS-PCA/elegans/eleganssvd.singularvalues.txt", header = TRUE)

# Caluclate percent variance explain by each PC
var <- elegans_pcs_single$SINGULAR_VALUES^2
sum_var <- sum(var)
percent_var <- (var/sum_var)*100
percent_var # percent variance explained by each PC

high_pcs <- which(percent_var > 0.1)
high_pcs # PCs 1-101 explain over 0.1% of the total variance

### Linear regression on how well sequencing depth variance predict telomere length
# load in telomere length data
telomere_lengths <- read.delim("~/Rose/results/telseq/elegans/elegans_telo_lengths_all.tsv", header = TRUE)
names(telomere_lengths) <- c("SAMPLE", "TELOMERE_LENGTH") # change column name to match matrix

# Remove the period after each sample name
elegans_pcs$SAMPLE <- str_sub(elegans_pcs$SAMPLE, end = -2)

# Add telomere length estimates to PC matrix
elegans_pcs_telo <- merge(elegans_pcs, telomere_lengths, by = "SAMPLE", all.x = TRUE)

# see which samples do not have telomere length estimates
elegans_pcs_telo$TELOMERE_LENGTH
elegans_pcs_telo$SAMPLE[is.na(elegans_pcs_telo$TELOMERE_LENGTH)] # "ECA245" "ECA249"
# run telseq for them 
# Reload telomere length data with those samples and re-merge


df <- df %>% select(-c(col1, col2, col3))



# remove columns after 101
# Run Linear regression model (formula = telomere_length ~ ., data = matrix)
# outputs residuals and this is the "new" telomere length that can be used in GWAS



