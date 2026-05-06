##################################
### Strain vs. telomere length ###
##################################

# set path to libraries if not set up
.libPaths(c("/home/rrunyan1/data-eande106/software/R_lib_4.2.1", .libPaths()))

# load libraries
library(tidyverse)
library(ggplot2)
library(tidyr)
library(readr)
library(dplyr)

# set working directory
setwd("~/Rose")

# load strain and telomere length estimate TSV elegans
elegans <- read_delim(
  "~/Rose/results/telseq/elegans/elegans_telo_lengths_high-map.tsv",
  col_names = TRUE, delim = "\t"
)

# load in telomere length data and high mapping strains and merge
briggsae_all <- read_delim(
  "~/Rose/results/telseq/briggsae/briggsae_telo_lengths.tsv",
  col_names = TRUE, delim = "\t"
)
briggsae_high_map <- read_delim(
  "~/Rose/isotype_reference_strains_lists/high_power_mapping_panels/cb_allout25_strains.txt",
  col_names = FALSE, delim = "\t"
)
names(briggsae_high_map) <- c("Strain")
# merge, only keeping high mapping panel strains
cb_high_map_telos <- merge(briggsae_high_map, briggsae_all, by = "Strain", all.x = TRUE)
cb_high_map_telos$LENGTH_ESTIMATE
cb_high_map_telos$Strain[is.na(cb_high_map_telos$LENGTH_ESTIMATE)] #GXW0022, PB420 are NA 
# remove any samples that are NA or UNKNOWN, fix later
cb_high_map_telos <- cb_high_map_telos %>%
  filter(!is.na(LENGTH_ESTIMATE), LENGTH_ESTIMATE != "UNKNOWN") # excludes 7 samples
#save tsv
write_tsv(cb_high_map_telos, "~/Rose/results/telseq/briggsae/briggsae_telo_lengths_high-map.tsv") # save to file


# load in tropicalis telomere length data
tropicalis <- read_delim(
  "~/Rose/results/telseq/tropicalis/tropicalis_telo_lengths.tsv",
  col_names = TRUE, delim = "\t")
ct_high_map <- read_delim(
  "~/Rose/isotype_reference_strains_lists/high_power_mapping_panels/ct_allout5_strains.txt",
  col_names = FALSE, delim = "\t")
names(ct_high_map) <- c("Strain")
# merge, only keeping high mapping panel strains
ct_high_map_telos <- merge(ct_high_map, tropicalis, by = "Strain", all.x = TRUE)
ct_high_map_telos$LENGTH_ESTIMATE
ct_high_map_telos$Strain[is.na(ct_high_map_telos$LENGTH_ESTIMATE)] # No NA or UNKNOWN!
#save tsv
write_tsv(ct_high_map_telos, "~/Rose/results/telseq/tropicalis/tropicalis_telo_lengths_high-map.tsv") # save to file


# order data from smallest to largest, lock strains in this order for plotting
elegans <- elegans %>%
  arrange(TELOMERE_LENGTH) %>%
  mutate(strain = factor(strain, levels = strain))

cb_high_map_telos <- cb_high_map_telos %>%
  mutate(LENGTH_ESTIMATE = as.numeric(LENGTH_ESTIMATE)) %>% # make column numeric so orders correctly
  arrange(LENGTH_ESTIMATE) %>%
  mutate(Strain = factor(Strain, levels = Strain))

ct_high_map_telos <- ct_high_map_telos %>%
  arrange(LENGTH_ESTIMATE) %>%
  mutate(Strain = factor(Strain, levels = Strain))

# plot strain vs telomere length
elegans_plot <- ggplot(elegans, aes(x = strain, y = TELOMERE_LENGTH, label = ifelse(strain == "N2", "N2", ""))) +
  geom_point() +
  geom_text(vjust = -1, size = 4) +
  labs(
    x = "Strain",
    y = "Telomere Length Estimate (kb)",
    title = "c. elegans telomere length estimates"
  ) +
  coord_cartesian(ylim = c(0, 100), clip = "off") +
  scale_x_discrete(expand = expansion(mult = c(0.01, 0.02))) +
  theme_classic() +
  theme(
    axis.text.x = element_blank(),
    axis.text.y = element_text(size = 10),
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14),
    axis.title = element_text(size = 16)
  )

elegans_plot

briggsae_plot <- ggplot(briggsae, aes(x = Strain, y = LENGTH_ESTIMATE)) +
  geom_point() +
  labs(
    x = "Strain",
    y = "Telomere Length Estimate (kb)",
    title = "c. briggsae telomere length estimates"
  ) +
  ylim(0, 20) +
  scale_x_discrete(expand = expansion(mult = c(0.01, 0.03))) +
  theme_classic() +
  theme(
    axis.text.x = element_blank(),
    axis.text.y = element_text(size = 10),
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14),
    axis.title = element_text(size = 16)
  )
briggsae_plot

tropicalis_plot <- ggplot(tropicalis, aes(x = Strain, y = LENGTH_ESTIMATE)) +
  geom_point() +
  labs(
    x = "Strain",
    y = "Telomere Length Estimate (kb)",
    title = "c. tropicalis telomere length estimates"
  ) +
  ylim(0, 35) +
  scale_x_discrete(expand = expansion(mult = c(0.01, 0.03))) +
  theme_classic() +
  theme(
    axis.text.x = element_blank(),
    axis.text.y = element_text(size = 10),
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14),
    axis.title = element_text(size = 16)
  )
tropicalis_plot
# print plot to view
print(elegans_plot)
print(briggsae_plot)
print(tropicalis_plot)

# save plot
ggsave("/home/rrunyan1/Rose/results/telseq/elegans/elegans_strain_vs_telo-length.png", plot= elegans_plot, width = 8, height = 4)
ggsave("/home/rrunyan1/Rose/plots/briggsae/briggsae_strain_vs_telo-length.png", plot= briggsae_plot, width = 8, height = 4)
ggsave("/home/rrunyan1/Rose/plots/tropicalis/tropicalis_strain_vs_telo-length.png", plot= tropicalis_plot, width = 8, height = 4)

# look at distribution of data
elegans_distr_plot <- ggplot(data = elegans, aes(x = TELOMERE_LENGTH)) +
  geom_histogram(binwidth = 1) +
  geom_vline(aes(xintercept = median(TELOMERE_LENGTH)), color = "red") +
  labs(
    x = "Telomere length estimate (kb)", 
    y = "Count", 
    #title = "c. elegans telomere length distrubution"
    ) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
  theme_classic() +
theme(
  axis.title.x = element_text(size = 14),
  axis.title.y = element_text(size = 14),
  axis.title = element_text(size = 16)
)
elegans_distr_plot

briggsae_distr_plot <- ggplot(data = cb_high_map_telos, aes(x = LENGTH_ESTIMATE)) +
  geom_histogram(binwidth = 0.5) +
  geom_vline(aes(xintercept = median(LENGTH_ESTIMATE)), color = "red") +
  labs(
    x = "Telomere length estimate (kb)", 
    y = "Count", 
    #title = "c. elegans telomere length distrubution"
  ) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
  theme_classic() +
  theme(
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14),
    axis.title = element_text(size = 16)
  )
briggsae_distr_plot

tropicalis_distr_plot <- ggplot(data = ct_high_map_telos, aes(x = LENGTH_ESTIMATE)) +
  geom_histogram(binwidth = 0.5) +
  geom_vline(aes(xintercept = median(LENGTH_ESTIMATE)), color = "red") +
  labs(
    x = "Telomere length estimate (kb)", 
    y = "Count", 
    #title = "c. elegans telomere length distrubution"
  ) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
  theme_classic() +
  theme(
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14),
    axis.title = element_text(size = 16)
  )
tropicalis_distr_plot


# save plot
ggsave("/home/rrunyan1/Rose/plots/elegans/elegans_telo-length_distribution.png", plot= elegans_distr_plot, width = 8, height = 4)
ggsave("/home/rrunyan1/Rose/plots/briggsae/briggsae_telo-length_distribution.png", plot= briggsae_distr_plot, width = 8, height = 4)
ggsave("/home/rrunyan1/Rose/plots/tropicalis/tropicalis_telo-length_distribution.png", plot= tropicalis_distr_plot, width = 8, height = 4)

# print medians
median(elegans$TELOMERE_LENGTH) #11.68
median(cb_high_map_telos$LENGTH_ESTIMATE) # 4.23253
median(ct_high_map_telos$LENGTH_ESTIMATE) # 10.5978
