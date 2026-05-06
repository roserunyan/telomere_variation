#!/bin/bash

# Run this script in tmux session
# activate conda environment if not already activaed: 
    # source activate /data/eande106/software/conda_envs/nf24_env

# Command line arguement should be elegans, briggsae, or tropicalis
SPECIES=$1

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
--traitfile /home/rrunyan1/Rose/results/NGS-PCA/${SPECIES}/${SPECIES}_telo_lengths.resid.tsv \
--species c_${SPECIES} \
--out /home/rrunyan1/Rose/results/nemascan/${SPECIES}
