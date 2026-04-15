#!/bin/bash

# get bam list that has the path to each sample for telseq
# this code adds the path to the bams at the beginning of each line and adds .bam at the end of each line and outputs to new file
awk '{print "/home/rrunyan1/vast/data/c_elegans/WI/alignments/"$0".bam"}' elegans_strains.txt > elegans_bams.txt
awk '{print "/home/rrunyan1/vast/data/c_briggsae/WI/alignments/"$0".bam"}' briggsae_strains.txt > briggsae_bams.txt
awk '{print "/home/rrunyan1/vast/data/c_tropicalis/WI/alignments/"$0".bam"}' tropicalis_strains.txt > tropicalis_bams.txt

# Make bamlist for each bam in the highest power mapping panel
cd /home/rrunyan1/Rose/isotype_reference_strains_lists/high_power_mapping_panels
awk '{print "/home/rrunyan1/vast/data/c_elegans/WI/alignments/"$0".bam"}' ce_allout15_strains.txt > /home/rrunyan1/Rose/isotype_reference_strains_lists/bamlists/elegans_allout15_bams.txt
