##################################
### Strain vs. telomere length ###
##################################

# set path to libraries if not set up
.libPaths(c("/home/rrunyan1/data-eande106/software/R_lib_4.2.1", .libPaths()))

# load libraries
library(ggplot2)
library(tidyr)
library(readr)
library(dplyr)

# set working directory
setwd("~/Rose")

# load strain and telomere length estimate TSV
elegans <- read_delim(
  "~/Rose/results/telseq/elegans/elegans_telo_lengths.tsv",
  col_names = TRUE, delim = "\t"
)

briggsae <- read_delim(
  "~/Rose/results/telseq/briggsae/briggsae_telo_lengths.tsv",
  col_names = TRUE, delim = "\t"
)

tropicalis <- read_delim(
  "~/Rose/results/telseq/tropicalis/tropicalis_telo_lengths.tsv",
  col_names = TRUE, delim = "\t"
)


# order data from smallest to largest, lock strains in this order for plotting
elegans <- elegans %>%
  arrange(LENGTH_ESTIMATE) %>%
  mutate(Strain = factor(Strain, levels = Strain))

briggsae <- briggsae %>%
  filter(LENGTH_ESTIMATE != "UNKNOWN") %>% # remove unknown values
  mutate(LENGTH_ESTIMATE = as.numeric(LENGTH_ESTIMATE)) %>% # make column numeric so orders correctly
  arrange(LENGTH_ESTIMATE) %>%
  mutate(Strain = factor(Strain, levels = Strain))

tropicalis <- tropicalis %>%
  arrange(LENGTH_ESTIMATE) %>%
  mutate(Strain = factor(Strain, levels = Strain))

# plot strain vs telomere length
elegans_plot <- ggplot(elegans, aes(x = Strain, y = LENGTH_ESTIMATE, label = ifelse(Strain == "N2", "N2", ""))) +
  geom_point() +
  geom_text(vjust = -1) +
  labs(
    x = "Strain",
    y = "Telomere Length Estimate (kb)",
    title = "c. elegans telomere length estimates"
  ) +
  ylim(0, 100) +
  theme(axis.text.x = element_blank())

briggsae_plot <- ggplot(briggsae, aes(x = Strain, y = LENGTH_ESTIMATE)) +
  geom_point() +
  labs(
    x = "Strain",
    y = "Telomere Length Estimate (kb)",
    title = "c. briggsae telomere length estimates"
  ) +
  ylim(0, 100) +
  theme(axis.text.x = element_blank())

tropicalis_plot <- ggplot(tropicalis, aes(x = Strain, y = LENGTH_ESTIMATE)) +
  geom_point() +
  labs(
    x = "Strain",
    y = "Telomere Length Estimate (kb)",
    title = "c. tropicalis telomere length estimates"
  ) +
  ylim(0, 100) +
  theme(axis.text.x = element_blank())

# print plot to view
print(elegans_plot)
print(briggsae_plot)
print(tropicalis_plot)

# save plot
ggsave("~/Rose/results/telseq/elegans/elegans_strain_vs_telo-length.png", plot= elegans_plot, width = 8, height = 4)
ggsave("~/Rose/results/telseq/briggsae/briggsae_strain_vs_telo-length.png", plot= briggsae_plot, width = 8, height = 4)
ggsave("~/Rose/results/telseq/tropicalis/tropicalis_strain_vs_telo-length.png", plot= tropicalis_plot, width = 8, height = 4)

# look at distribution of data
elegans_distr_plot <- ggplot(data = elegans, aes(x = LENGTH_ESTIMATE)) +
  geom_histogram(binwidth = 0.5) +
  geom_vline(aes(xintercept = median(LENGTH_ESTIMATE)), color = "red") +
  labs(x = "Telomere Length Estimate (kb)", y = "Number of strains") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
  theme_classic()

briggsae_distr_plot <- ggplot(data = briggsae, aes(x = LENGTH_ESTIMATE)) +
  geom_histogram(binwidth = 0.5) +
  geom_vline(aes(xintercept = median(LENGTH_ESTIMATE)), color = "red") +
  labs(x = "Telomere Length Estimate (kb)", y = "Number of strains") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
  theme_classic()

tropicalis_distr_plot <- ggplot(data = tropicalis, aes(x = LENGTH_ESTIMATE)) +
  geom_histogram(binwidth = 0.5) +
  geom_vline(aes(xintercept = median(LENGTH_ESTIMATE)), color = "red") +
  labs(x = "Telomere Length Estimate (kb)", y = "Number of strains") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
  theme_classic()

# print plot to view
print(elegans_distr_plot)
print(briggsae_distr_plot)
print(tropicalis_distr_plot)

# save plot
ggsave("~/Rose/results/telseq/elegans/elegans_telo-length_distribution.png", plot= elegans_distr_plot, width = 8, height = 4)
ggsave("~/Rose/results/telseq/briggsae/briggsae_telo-length_distribution.png", plot= briggsae_distr_plot, width = 8, height = 4)
ggsave("~/Rose/results/telseq/tropicalis/tropicalis_telo-length_distribution.png", plot= tropicalis_distr_plot, width = 8, height = 4)

# print medians
median(elegans$LENGTH_ESTIMATE)
median(briggsae$LENGTH_ESTIMATE)
median(tropicalis$LENGTH_ESTIMATE)
