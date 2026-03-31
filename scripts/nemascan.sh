#!/bin/bash

module load python/anaconda
source activate /data/eande106/software/conda_envs/nf24_env

SPECIES="elegans"

nextflow run -latest andersenlab/nemascan \
--vcf 20250625 \
--traitfile /home/rrunyan1/Rose/results/telseq/${SPECIES}/${SPECIES}_telo_lengths.tsv \
--species c_${SPECIES} \
--out /home/rrunyan1/Rose/results/nemascan/${SPECIES}
#Choose between c_elegans, c_tropicalis or c_briggsae

#nextflow run -latest andersenlab/nemascan -profile mappings --vcf 20210121 --traitfile input_data/c_elegans/phenotypes/PC1.tsv
