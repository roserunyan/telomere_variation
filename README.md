# Rose Runyan's Rotation Project
## March 16 2026 - May 8 2026

## Project overview:
### Variation in telomere lengths across 3 Caenorhabditis species: *c. elegans, c. briggsae,* and *c. tropicalis*.
This project is based on a study published from the lab previously: [The Genetic Basis of Natural Variation in Caenorhabditis elegans Telomere Length](https://academic.oup.com/genetics/article/204/1/371/6066292#supplementary-data). This study compared telomere lengths of lab and wild strains of *C. elegans* and found that mutations in pot2 on chromosome II causes the natural variation in telomere length. But telomere length did not seem to have a fitness impact.

However, this study was limited by analysis of only *C. elegans* and my rotation project aims to include multiple species using one reference strain per isotype to limit skewing of results due to very similar strains.

## Steps
### Estimate telomere lengths of each isotype using [telseq](https://github.com/zd1/telseq)
This scans BAMs for canonical telomeric repeats and caluclates the lengths based on density of these reads relative to the total number of reads. It considers them telomeres when there are at least 7 of these repeats.

1. Install telseq by cloning git repository and changing the information to be compatible with *C. elegans*
    - see ```Steps to installing telseq``` in ```notebook.md``` for more details
    - installed in ```data-eande106/software/telseq```

2. create a list of isotype reference strains for each species
    - script: ```scripts/strain_list.sh```
    - output: ```isotype_reference_strains_lists/<species>_strains.txt```

3. create bam list to use in telseq for each species
    - script: ```scripts/bamlist.sh```
    - output: ```isotype_reference_strains_lists/<species>_bams```

### 2. Perform GWA using [NemaScan](https://github.com/AndersenLab/NemaScan) to see where the variation in the total length could be coming from

## Results

## Organization

## Data Sources

