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

2. Create a list of isotype reference strains for each species
    - script: ```scripts/strain_list.sh```
    - output: ```isotype_reference_strains_lists/<species>_strains.txt```

3. Create a bam list to use in telseq for each species
    - script: ```scripts/bamlist.sh```
    - output: ```isotype_reference_strains_lists/<species>_bams```

4. Split the bamlists and make a list of the split bamlists to run 1 job per sublist of BAMs
    - See ```notebook.md``` for code
    - Each bamlist was split so that each sublist contains the paths to 50 BAM files

4. Run telseq
    - This script was run one time for each species. It is an array job, where each job was ran on one sublist (bamlist list) that contains the path to 50 BAM files. The array range was 1- # of sublsits, which is unique for each species
    - script: ```scripts/telseq.sh```
    - output: ```results/telseq/<species>/<sublist_name>.telseq.txt```
    - The output is one file per job, each file containing the information for the 50 BAMs in the associated sublist

5. Concatenate output files into one for each species and...

### 2. Perform GWA using [NemaScan](https://github.com/AndersenLab/NemaScan) to see where the variation in the total length could be coming from

## Results

## Organization

## Data Sources


