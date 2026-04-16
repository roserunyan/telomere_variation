# Rose Runyan's Rotation Project
## March 16 2026 - May 8 2026

## Project overview:
### Variation in telomere lengths across 3 Caenorhabditis species: *c. elegans, c. briggsae,* and *c. tropicalis*.
This project is based on a study published from the lab previously: [The Genetic Basis of Natural Variation in Caenorhabditis elegans Telomere Length](https://academic.oup.com/genetics/article/204/1/371/6066292#supplementary-data). This study compared telomere lengths of lab and wild strains of *C. elegans* and found that mutations in pot2 on chromosome II causes the natural variation in telomere length. But telomere length did not seem to have a fitness impact.

However, this study was limited by analysis of only *C. elegans* and my rotation project aims to include multiple species using one reference strain per isotype to limit skewing of results due to very similar strains.

## Steps
### Estimate telomere lengths of each isotype using [telseq](https://github.com/zd1/telseq)
This scans BAMs for canonical telomeric repeats and caluclates the lengths based on density of these reads relative to the total number of reads. It considers them telomeres when there are at least 7 of these repeats.

1. Install telseq by cloning git repository, change the information to be compatible with *Caenorhabditis*, and configure.
    - installed in ```data-eande106/software/telseq```

2. Create a list of isotype reference strains for each species
    - script: ```scripts/strain_list.sh```
    - output: ```isotype_reference_strains_lists/<species>_strains.txt```

3. Create a bam list to use in telseq for each species
    - script: ```scripts/bamlist.sh```
    - output: ```isotype_reference_strains_lists/<species>_bams```

4. Split the bamlists and make a list of the split bamlists to run 1 job per sublist of BAMs
    - Each bamlist was split so that each sublist contains the paths to 50 BAM files

4. Run telseq
    - This script was run one time for each species. It is an array job, where each job was ran on one sublist (bamlist list) that contains the path to 50 BAM files. The array range was 1- # of sublsits, which is unique for each species
    - script: ```scripts/telseq.sh```
    - output: ```results/telseq/<species>/<sublist_name>.telseq.txt```
    - The output is one file per job, each file containing the information for the 50 BAMs in the associated sublist

5. Concatenate files to have one tsv per species
    - Concatenate the files, add the strain names, and add a header to produce a tsv file
    - final tsvs in ```results/telseq/<species>/<species>.telseq.tsv```

6. Visualize results
    - Look at distribution of data
    - Make strain vs. telomere length plot
    - script: ``scripts/telomere_lengths_plot.R`` R version: 4.3.1
    - plots: ``results/telseq/<species>/<species>_strain_vs_telo-length.png`` and ``results/telseq/<species>/<species>_telo-length_dsitribution.png``

### Residualize telomere length estimates
Since sequencing depth could potentially impact the calculated telomere lengths, we resizualize the telomere lengths by fitting telomere length to PCs derived from variance in sequencing depth and subtracting this from the telomere length estimates. \
These steps were performed based off of [Nakao et al. (2026)](https://www.nature.com/articles/s41588-026-02567-1) and [Taub et al. (2021)](https://www.clinicalkey.com/#!/content/playContent/1-s2.0-S2666979X21001051?returnurl=https:%2F%2Flinkinghub.elsevier.com%2Fretrieve%2Fpii%2FS2666979X21001051%3Fshowall%3Dtrue&referrer=)

1. Estimate read depth with [mosdepth](https://github.com/brentp/mosdepth)
    - script: ``scripts/mosdepth.sh``
    - only performed on high power mapping panel strains and only those will be considered for downstream steps
    - use split bamlist method as described above and in ``notebook.md`` to reduce compute time
    - although this may not be neccessary since computing power is not high
    
2. Create BED file with hyperdivergent regions to exclude from anlaysis
    - must merge regions in existing BEDfile since it is strain specific
    - script: ``scripts/bedtools-merge.sh``

3. Rename chromosome numbers and remove MtDNA to be compatible with NGS-PCA
    - chromosome name from I to chr1

4. Calculate PCs with [NGS-PCA](https://github.com/PankratzLab/NGS-PCA)
    - script: ``scripts/ngs-pca.sh``

5. Run a linear regression model with PCs explaining over 0.1% of the read depth variance 
    - script: ``scripts/residualize_telomeres.R``
    - 2 samples do not have telomere length estimates: ECA245 and ECA249, so telseq was wun on them and their data was added to the LM

6. Run telseq for the 2 samples without telomere length estimates





### Perform GWA using [NemaScan](https://github.com/AndersenLab/NemaScan) to see where the variation in the total length could be coming from
These are the steps to run the Andersen lab NemaScan nextflow pipeline that will perform the GWA

1. Create a phenotype txt file for each spcies to input into nextflow
    - First column is strain, second column is length estimate
    - Remove any strains not in the highest power mapping panel

2. Run GWA nextflow pipeline for each species separately
    - script: ``scripts/nemascan.sh`` in tmux session
        - first command line argument is the species the script will run on. Example: ``./nemascan.sh elegans``


