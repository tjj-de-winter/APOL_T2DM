#!/bin/bash

if [ $# -ne 6 ]
then
    echo "Please, give as input"
    echo "1) input fastq file (single file) read 1"
    echo "2) outprefix"
    echo "3) genome folder"
    echo "4) path to STAR"
    echo "5) path to samtools"
    echo "6) Library tag"
    exit
fi

inputfq=$1
outprefix=$2
genome=$3
p2star=$4
p2samtools=$5
tag=$6

# map single-end reads to a reference genome

${p2star}/STAR --runThreadN 8 --genomeDir ${genome} --readFilesIn ${inputfq} --readFilesCommand zcat --outFilterMultimapNmax 20 --outSAMmapqUnique 60 --outSAMunmapped Within --outSAMtype BAM Unsorted --outSAMattributes All --outFileNamePrefix ${outprefix}

rm -r ${outprefix}_STARtmp
rm ${outprefix}Log.progress.out

# Select only uniquely mapped reads

# Sort

${p2samtools}/samtools sort -o ${outprefix}Aligned.sortedByCoord.out.bam -@ 8 ${outprefix}Aligned.out.bam

# filter

${p2samtools}/samtools view -q 60 ${outprefix}Aligned.sortedByCoord.out.bam -b -o ${outprefix}Aligned.sortedByCoord.filtered.bam
