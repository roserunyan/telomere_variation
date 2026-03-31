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
