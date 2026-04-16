#!/bin/bash
#SBATCH --job-name=20260415_ngs-pca_elegans
#SBATCH --partition=parallel
#SBATCH --account=eande106
#SBATCH --time=02:00:00
#SBATCH --mail-user=rrunyan1@jh.edu
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=2
#SBATCH --output=/home/rrunyan1/andersen_lab/output/%x/%A_%a.out

# Define jar file
jar="/home/rrunyan1/data-eande106/software/NGS-PCA/ngspca-0.02-SNAPSHOT.jar"

# change based on species script is being run on
SPECIES="elegans" # options: elegans, briggsae, tropicalis

# set paths
MOSDEPTH_REGIONS="/home/rrunyan1/Rose/results/mosdepth/${SPECIES}/output/bed_files_renamed"
OUT_DIR="/home/rrunyan1/Rose/results/NGS-PCA/${SPECIES}"
mkdir -p ${OUT_DIR} # make output directory if it doesn't exist already
EXCLUDE_REGIONS="/home/rrunyan1/Rose/isotype_reference_strains_lists/hyper_divergent_regions/${SPECIES}/20250625_c_${SPECIES}_divergent_regions_strain.merge.bed"
# CHANGE DATE FOR OTHER SPECIES

# Run NGS-PCA to find variation in sequencing depth
numPCs=200

java -Xmx60G -jar ${jar} \
  --input ${MOSDEPTH_REGIONS} \
  --outputDir ${OUT_DIR}/${SPECIES} \
  --numPC $numPCs \
  -sampleEvery 0 \
  --iters 3 \
  --oversample 10 \
  --bedExclude ${EXCLUDE_REGIONS}