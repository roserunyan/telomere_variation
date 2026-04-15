#!/bin/bash
#SBATCH --job-name=20260415_bedtools-merge_ce
#SBATCH --partition=parallel
#SBATCH --account=eande106
#SBATCH --time=03:00:00
#SBATCH --mail-user=rrunyan1@jh.edu
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=2
#SBATCH --output=/home/rrunyan1/andersen_lab/output/%x/%A_%a.out

# load conda environment
source activate /home/rrunyan1/data-eande106/software/conda_envs/bedtools

# change based on species script is being run on
SPECIES="elegans" # options: elegans, briggsae, tropicalis
# CHANGE DATE FOR NEXT STRAINS

REGIONS_BED="/home/rrunyan1/vast/data/c_${SPECIES}/WI/divergent_regions/20250625/20250625_c_${SPECIES}_divergent_regions_strain.bed.gz"
OUT_DIR="/home/rrunyan1/Rose/isotype_reference_strains_lists/hyper_divergent_regions/${SPECIES}"
mkdir -p ${OUT_DIR} # make output directory if it doesn't exist already

# run bedtools to merge overlapping regions
bedtools merge -i ${REGIONS_BED} > ${OUT_DIR}/20250625_c_${SPECIES}_divergent_regions_strain.merge.bed

# deactivate conda environment
conda deactivate
