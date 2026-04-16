# Roses's rotation notebook
## March 16 2026 - May 8 2026
This notebook contains details not present in ```README.md``` that may be helpful for replicating this project. 

## Directory from previous telomere variation study
```/home/rrunyan1/vast/LabData/FinishedPapers/2016_sp_Cook_sp_et_sp_al._sp_Genetics```

## Steps to installing telseq
1. Clone telseq repository
    ```
    cd data-eande106/software/telseq
    git clone https://github.com/zd1/telseq.git
    cd telseq/src
    ./autogen.sh 
    ```
2. edit ```data-eande106/software/telseq/telseq/src/Telseq/telseq.h``` with *Caenorhabditis* information
    - ```const unsigned int GENOME_LENGTH_AT_TEL_GC =  5808700```
    - ```const uint64_t TELOMERE_ENDS = 12```

3. Compile (confiugre with older version of Bamtools as telseq not compatible with new versions)
    ```
    ./configure --with-bamtools=/data/apps/extern/BamTools/2.5.2
    make
    ```

## Run Telseq
### Split the bamlists and make a list of the split bamlists to run 1 job per sublist of BAMs
```
SPECIES="elegans" # change to elegans, briggsae, or tropicalis and run afte changing it each time
cd /home/rrunyan1/Rose/isotype_reference_strains_lists/bamlists
split -l 50 ${SPECIES}$_bams.txt
mv x* ../split_bamlists/${SPECIES}
cd ../split_bamlists/${SPECIES}
ls > ../../bamlist_lists/${SPECIES}_bamlist_list.txt
```

### C. Briggsae strains with "UNKNOWN" telomere lengths, BAM file doesn't exist
```
EG6268
JU1257  
JU1344  
JU2597  
JU2747  
JU2767  
JU2801  
JU3272  
QG2849  
```

### Concatenate files to have one tsv per species
```
SPECIES="elegans" # change to elegans, briggsae, or tropicalis
cd /home/rrunyan1/Rose/results/telseq/${SPECIES}
grep -h -v "^ReadGroup" x*.telseq.txt >> ${SPECIES}.telseq.txt
paste /home/rrunyan1/Rose/isotype_reference_strains_lists/strainlists/${SPECIES}_strains.txt ${SPECIES}.telseq.txt > ${SPECIES}.telseq.tsv.tmp
rm ${SPECIES}.telseq.txt
telseq -h > header.tsv
echo -e "Strain\t$(cat header.tsv)" | cat - ${SPECIES}.telseq.tsv.tmp  > ${SPECIES}.telseq.tsv
rm header.tsv
rm ${SPECIES}.telseq.tsv.tmp
```


## Residualize telomere length estimates
### Estimate read depth with mosdepth
1. Install mosdepth 0.3.13
```conda create --prefix /home/rrunyan1/data-eande106/software/conda_envs/mosdepth mosdepth ```
2. Create new bamlist for high mapping panel
    - script: ``scripts/bamlist.sh``
3. Split bamlist into smaller bamlists
    ```
    SPECIES="elegans" # change to elegans, briggsae, or tropicalis and run afte changing it each time
    cd /home/rrunyan1/Rose/isotype_reference_strains_lists/bamlists
    split -l 25 ${SPECIES}_allout15_bams.txt
    mv x* ../split_bamlists/${SPECIES}_allout15
    cd ../split_bamlists/${SPECIES}_allout15
    ls > ../../bamlist_lists/${SPECIES}_allout15_bamlist_list.txt
    ```
4. Run mosdepth
    - script: ``scripts/mosdepth.sh``
5. Repeat for renamed strains
    - some strains were renamed and were not included in the mosdepth analysis, so performed again on jsut those samples: ```isotype_reference_strains_lists/bamlists/elegans_allout15_bams_missing.txt```
5. Move all bedfiles into own directory


### Rename chromosome numbers to be compatible with NGS-PCA and remove MtDNA
    ```
    cd /home/rrunyan1/Rose/results/mosdepth/elegans/output/bed_files
    for file in *.bed.gz; do
        zcat "$file" | \
        awk '{
            if ($1=="MtDNA") next;
            if ($1=="I") $1="chr1";
            else if ($1=="II") $1="chr2";
            else if ($1=="III") $1="chr3";
            else if ($1=="IV") $1="chr4";
            else if ($1=="V") $1="chr5";
            else if ($1=="X") $1="chrX";
        
            print
        }' | gzip > ../bed_files_renamed/"$file"
    done
    ```
### Create BEDfile with hyperdivergent regions to exclude
1. Install bedtools v2.31.1
    ```conda create --prefix /home/rrunyan1/data-eande106/software/conda_envs/bedtools bedtools ```

### Calculate PCs with NGS-PCA
Install NGS-PCA by downloading jar file into ``/home/rrunyan1/data-eande106/software/NGS-PCA``





## Perform GWA
### Create phenotype file for each species
Strain in one column, telomere length in the next \
```
SPECIES="tropicalis" # change to elegans, briggsae, or tropicalis
cd /home/rrunyan1/Rose/results/telseq/${SPECIES}
cut -f 1,8 ${SPECIES}.telseq.tsv > ${SPECIES}_telo_lengths.tsv
```


### Configure bash profile to run nextflow pipeline
Add the following text to ```~/.bash_profile```
```
export NXF_CACHE_DIR=$HOME
export NXF_SINGULARITY_CACHEDIR=/vast/eande106/singularity
export NXF_SINGULARITY_LIBRARYDIR=/vast/eande106/singularity
export NXF_WORK=/scratch4/eande106/Rose
```

### Running a tmux session
Start tmux session: ```tmux new -s TelomereNemaScan``` \
Detach from session with ctrl-B, d, to keep running in background then reattach: ```tmux attach -t TelomereNemaScan``` \
When it finishes, exit with ```exit```




Remove any strain not in the highest power mapping panel
For strain in elegans_telo_length.tsv$

print all matches in file 2 that match file 1
file1="/home/rrunyan1/Rose/isotype_reference_strains_lists/high_power_mapping_panels/ce_allout15_strains.txt"
file2="/home/rrunyan1/Rose/results/telseq/elegans/elegans_telo_lengths.tsv"

cut -f1 ${file2} | grep -Fx -f ${file1} - | wc -l


# see if longer elegans in this list so we can verify actually that long??
/home/rrunyan1/vast/data/c_elegans/genomes/WI_PacBio_assemblies/hifi

# see which bams missing from high mapping data
list="/home/rrunyan1/Rose/isotype_reference_strains_lists/bamlists/elegans_allout15_bams.txt"
while read -r file; do
    if [ -e "$file" ]; then
        echo "$file Exists"
    else
        echo "$file Does not exist"
    fi
done < "$list" | less -S

# bed file to exclude regions and must do intersect thing
/home/rrunyan1/vast/data/c_elegans/WI/divergent_regions/20250625/20250625_c_elegans_divergent_regions_strain.bed.gz
