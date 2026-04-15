#!/bin/bash
#SBATCH --job-name=20260414_mosdepth_briggsae
#SBATCH --partition=parallel
#SBATCH --account=eande106
#SBATCH --time=02:00:00
#SBATCH --mail-user=rrunyan1@jh.edu
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=4
#SBATCH --array=1-15
#SBATCH --output=/home/rrunyan1/andersen_lab/output/%x/%A_%a.out

# activate mosdepth conda environment
source activate /home/rrunyan1/data-eande106/software/conda_envs/mosdepth

# change based on species script is being run on
SPECIES="elegans" # options: elegans, briggsae, tropicalis

# select each bamlist file as an array job
BAMLIST_LIST="/home/rrunyan1/Rose/isotype_reference_strains_lists/bamlist_lists/${SPECIES}_allout15_bamlist_list.txt" # list of each sub bamlist
# print current line of bamlist list file and delete the rest to perform script on that line (bamlist) only, repeat for each line of file to do script for each bamlist
CURRENT_BAMLIST=$(sed "${SLURM_ARRAY_TASK_ID}q;d" $BAMLIST_LIST) # each job in the array will be one sub bamlist

# set paths
BAMLIST="/home/rrunyan1/Rose/isotype_reference_strains_lists/split_bamlists/${SPECIES}_allout15/${CURRENT_BAMLIST}" # path to sub bamlist the job is using
OUT_DIR="/home/rrunyan1/Rose/results/mosdepth/${SPECIES}/output" # path to output directory
mkdir -p ${OUT_DIR} # make output directory if it doesn't exist already

# read file line by line and for each line, perform operation
while read -r BAM_PATH;
do 

    PREFIX=$(basename "${BAM_PATH}" .bam)

    mosdepth \
    --no-per-base \
    --by 1000 \
    "${OUT_DIR}/${PREFIX}" \
    "${BAM_PATH}"

done < "${BAMLIST}"

# deactivate conda environment
conda deactivate

