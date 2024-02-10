#!/usr/bin/env nextflow

===================
= assembleSmAll
===================
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    nf-core/genomeassembler
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/keckstrom/assembleSmAll
    Website: https://keckstrom.github.io/
----------------------------------------------------------------------------------------
*/


// User supplied input parameters
params.samplesheet = ""
params.flowcellType = ""
params.expectedSize = ""
params.buscoModel = ""
params.shortType = "" // optional, values should be se or pe
params.outdir = "" // location of top-level output directory

// Modifiable parameters
params.qc_outdir = "$params.outdir/qc_files"
params.trimmed_reads_long = "$params.outdir/trimmed_reads"
params.trimmed_reads_short = "$params.outdir/trimmed_reads/short_reads"
params.assemblies = "$params.outdir/assemblies"
params.annotations = "$params.outdir/assemblies/annotations"

// Import processes + modules
nextflow.enable.dsl = 2
include { multiqc } from "$baseDir/modules/multiqc"
include { run_flye } from "$baseDir/modules/flye"

// Log information
log.info """/
=======================
assembleSmAll: small+ genome assembly & annotation workflow
=======================
samplesheet:    ${params.samplesheet}
outdir:        ${params.outdir}
flowcell_type:    ${params.flowCellType}
"""
.stripIndent()

workflow{
///////////////////////////
// Raw Read QC + Filtering
///////////////////////////
Channel
    .fromPath("${params.samplesheet}").splitCsv(header:true, sep: ',')
    .map{row -> tuple(row.sampleID,file(row.ONTfastq),file(row.shortFastqR1),file(row.shortFastqR2))}
    .set { samplesheet_ch }
samplesheet_ch.view()

run_nanoplot (samples_ch)
run_nanofilt (samples_ch)

run_multiqc (nanofilt_ch)

run_fastp () 

///////////////////////////
// Flye Assembly
///////////////////////////


run_flye(nanofilt_ch, "${params.expectedSize})")
run_flye.out.flye_output.set{ flye_output_ch }


///////////////////////////
// Medaka
///////////////////////////



///////////////////////////
// Polypolish: Optional
///////////////////////////

///////////////////////////
// Annotation
///////////////////////////
run_prokka ( genomes_ch )


///////////////////////////
// BUSCO
///////////////////////////

run_busco (genomes_ch)

///////////////////////////
// Functional Profiling
///////////////////////////
run_arbricate ( genomes_ch )
run_antismash ( genomes_ch )
run_ampir ( genomes_ch ) 


}




