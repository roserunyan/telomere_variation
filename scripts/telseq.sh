#!/bin/bash
#SBATCH --job-name=20260320_telseq_elegans
#SBATCH --partition=parallel
#SBATCH --account=eande106
#SBATCH --time=03:00:00
#SBATCH --mail-user=rrunyan1@jh.edu
#SBATCH --mail-type=ALL
#SBATCH --nodes=1
#SBATCH --output=/home/rrunyan1/andersen_lab/output/%x/%A_%a.out

# estimate telomere lengths for c. elegans 

conda activate /home/rrunyan1/data-eande106/software/conda_envs/telseq

BAMLIST="/home/rrunyan1/vast/projects/Rose/isotype_reference_strains_lists/elegans_bams.txt"
OUT_DIR="/home/rrunyan1/vast/projects/Rose/results/telseq"

telseq -m -o ${OUT_DIR}/elegans.telseq.txt -f ${BAMLIST}

conda deactivate
