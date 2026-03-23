#!/bin/bash

# get bam list that has the path to each sample for telseq
# this code adds the path to the bams at the beginning of each line and adds .bam at the end of each line and outputs to new file
awk '{print "/home/rrunyan1/vast/data/c_elegans/WI/alignments/"$0".bam"}' elegans_strains.txt > elegans_bams.txt
awk '{print "/home/rrunyan1/vast/data/c_briggsae/WI/alignments/"$0".bam"}' briggsae_strains.txt > briggsae_bams.txt
awk '{print "/home/rrunyan1/vast/data/c_tropicalis/WI/alignments/"$0".bam"}' tropicalis_strains.txt > tropicalis_bams.txt
