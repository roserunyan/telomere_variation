#!/bin/bash
#SBATCH --job-name=20260324_telseq_elegans
#SBATCH --partition=parallel
#SBATCH --account=eande106
#SBATCH --time=24:00:00
#SBATCH --mail-user=rrunyan1@jh.edu
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=4
##SBATCH --array=1-3
#SBATCH --output=/home/rrunyan1/andersen_lab/output/%x/%A_%a.out

# estimate telomere lengths for c. elegans 
module load gcc BamTools/2.5.2

#SPECIES=("elegans", "briggsae", "tropicalis")
CURRENT_SPECIES="elegans"    #${SPECIES[$SLURM_ARRAY_TASK_ID]}   #$(sed "${SLURM_ARRAY_TASK_ID}q;d" $SPECIES)

TELSEQ="/home/rrunyan1/data-eande106/software/telseq/telseq/src/Telseq/telseq"
BAMLIST="/home/rrunyan1/vast/projects/Rose/isotype_reference_strains_lists"
OUT_DIR="/home/rrunyan1/vast/projects/Rose/results/telseq"

${TELSEQ} -m -z 'TTAGGC' -f ${BAMLIST}/${CURRENT_SPECIES}_bams.txt -o ${OUT_DIR}/${CURRENT_SPECIES}.telseq.txt
