#!/bin/bash

# Run this script in tmux session
source activate /data/eande106/software/conda_envs/nf24_env

# Only change this variable and nothing else to either elegans, briggsae, or tropicalis
SPECIES="briggsae"

# change to working directory where .nextflow.log will be output
cd /home/rrunyan1/Rose/analysis/nemascan/${SPECIES}

# choose VCF file to use based on species
if [[ ${SPECIES} == "elegans" ]]; then
    VCF="20250625"
elif [[ ${SPECIES} == "briggsae" ]]; then
    VCF="20250626"
elif [[ ${SPECIES} == "tropicalis" ]]; then
    VCF="20250627"
fi

# run NemaScan
nextflow run -latest andersenlab/nemascan \
--vcf ${VCF} \
--traitfile /home/rrunyan1/Rose/results/telseq/${SPECIES}/${SPECIES}_telo_lengths.tsv \
--species c_${SPECIES} \
--out /home/rrunyan1/Rose/results/nemascan/${SPECIES}
