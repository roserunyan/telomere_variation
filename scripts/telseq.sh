#!/bin/bash
#SBATCH --job-name=20260326_telseq_tropicalis
#SBATCH --partition=parallel
#SBATCH --account=eande106
#SBATCH --time=06:00:00
#SBATCH --mail-user=rrunyan1@jh.edu
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=2
#SBATCH --array=1-13
#SBATCH --output=/home/rrunyan1/andersen_lab/output/%x/%A_%a.out

###################################################
### estimate telomere lengths for C. tropicalis ###
###################################################

# load required modules
module load gcc BamTools/2.5.2

# change based on species script is being run on
SPECIES="tropicalis" # options: elegans, briggsae, tropicalis

# select each bamlist file as an array job
BAMLIST_LIST="/home/rrunyan1/Rose/isotype_reference_strains_lists/bamlist_lists/${SPECIES}_bamlist_list.txt" # list of each sub bamlist
# print current line of bamlist list file and delete the rest to perform script on that line (bamlist) only, repeat for each line of file to do script for each bamlist
CURRENT_BAMLIST=$(sed "${SLURM_ARRAY_TASK_ID}q;d" $BAMLIST_LIST) # each job in the array will be one sub bamlist

# set paths
TELSEQ="/home/rrunyan1/data-eande106/software/telseq/telseq/src/Telseq/telseq" # path to telseq software
BAMLIST="/home/rrunyan1/Rose/isotype_reference_strains_lists/split_bamlists/${SPECIES}/${CURRENT_BAMLIST}" # path to sub bamlist the job is using
OUT_DIR="/home/rrunyan1/Rose/results/telseq/${SPECIES}" # path to output directory
mkdir -p ${OUT_DIR} # make output directory if it doesn't exist already

# run telseq
${TELSEQ} -z 'TTAGGC' -u -f ${BAMLIST} -o ${OUT_DIR}/${CURRENT_BAMLIST}.telseq.txt


