# assembleSmAll
demo workflow for assembly of ONT and/or short reads for bacterial (and maybe small fungal genome exclu. annotation, can add as a subworkflow or module later)


Goal: create basic workflow based on Genome Assembly Tutorial (in Notion)
  * Raw read QC
  * Filtering
  * Assembly
  * Polishing + Error Correction
  * Post-assembly metrics
  * Annotation
  * Produce QC + stats reports

Build with Docker, make Singularity options
Want it to be pretty lightweight, producing files that can be used in downstream + additional workflows with low barrier to entry, ability to run in variety of compute envs
  * make a config for slurm, but also just a config for running on a local machine with decent specs

### To do:

#### Input parameters to include:
* input raw ONT reads
* kit version for ONT
* input raw Illumina reads (optional)
* output directory
* BUSCO model to use, the `-l` parameter
* expected genome size
* reference genome for comparison (optional for FASTANI, may just drop this)


#### Containers:
- Flye
- Racon + dependencies (miniasm)

#### Modules to Create:

**QC + Filtering**
- NanoPlot + NanoFilt
- FastQC
- MultiQC
- trim_galore (if Illumina)


**Assembly + Polishing**
- Flye (check if there have been improvements/updates?) -> good, most flexible option for many genome sizes 
- Racon x 3-4 rounds (make option to set rounds?)
- medaka x 3-4 rounds
- Pilon (make optional if Illumina reads present)
    - requires mapping short reads to genome, sorting, then running pilon

**Post-assembly**
- BUSCO


**Annotation**
decide about keeping

- If bacteria = prokka
- If fungi = funnannotate (may be more cumbersome to containerize than its worth)
