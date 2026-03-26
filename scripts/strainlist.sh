#!/bin/bash

# get list of isotype reference strain for each species

ELEGANS="/vast/eande106/data/c_elegans/WI/concordance/20250625"
BRIGGSAE="/vast/eande106/data/c_briggsae/WI/concordance/20250626"
TROPICALIS="/vast/eande106/data/c_tropicalis/WI/concordance/20250627"

OUT_DIR="/home/rrunyan1/vast/projects/Rose/isotype_reference_strains_lists"

# extract the column with isotype reference strain and remove the header | sort and print only unique values
awk 'NR>1 {print $4}' ${ELEGANS}/isotype_groups.tsv | sort -u | less -S > ${OUT_DIR}/elegans_strains.txt
awk 'NR>1 {print $4}' ${BRIGGSAE}/isotype_groups.tsv | sort -u | less -S > ${OUT_DIR}/briggsae_strains.txt
awk 'NR>1 {print $4}' ${TROPICALIS}/isotype_groups.tsv | sort -u | less -S > ${OUT_DIR}/tropicalis_strains.txt