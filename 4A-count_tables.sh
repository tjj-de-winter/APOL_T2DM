#!/bin/bash

# This script first splits merged bam files based on readgroup and cell ID and makes a gene-cell count matrix for all the single cells.    

if [ $# -ne 4 ]
then     
    echo "Please, give as input"
    echo "1) The bam file (with path)"
    echo "2) genome reference file (gtf)"
    echo "3) Feature to count, e.g. three_prime_utr_or_mitogene or gene, etc."
    echo "4) outpath"
    exit
fi

inbam=$1
gtf=$2 # /exports/ana-scarlab/group_references/ensembl/human/102/Homo_sapiens.GRCh38.102.minusINS-IGF2_uniq3utr_fromstop_MTgenes.gtf
feature=$3 # 'three_prime_utr_or_mitogene'
outpath=$4

bam=$(echo ${inbam} | awk -F '/' '{print $NF}')
p2bam=${inbam%${bam}}
outpath=${outpath%/}
mkdir -p ${outpath}
outpbam=${outpath}/split_${bam%.bam}
mkdir -p ${outpbam}
p2samtools=$(which samtools)
p2samtools=${p2samtools%/samtools}
p2featurecounts=$(which featureCounts)
p2featurecounts=${p2featurecounts%/featureCounts}
p2scripts=/exports/ana-scarlab/tdwinter/bin
donorID=$(${p2samtools}/samtools view -h $bam | head -n300 | grep "@RG" | awk -F "ID:|\t" '{print $3}')

if [ -z "$donorID" ]
then
      echo "No donor ID, please add a readgroup to the bam file"
      exit
fi

# split bam files on cell ID
jobid=split
jsplit=1
jsplit=$(sbatch --export=All -c 1 -N 1 -J ${jobid} -e split_${donorID}.err -o split_${donorID}.out -t 10-12:00:00 --mem=100G --wrap="${p2scripts}/split_bam_edit.sh $bam $p2bam $outpbam $p2samtools")
jsplit=$(echo $jsplit | awk '{print $NF}')
echo split submitted $jsplit

# Count genes
jobid=count
jcount=2
jcount=$(sbatch --export=All -c 1 -N 1 -J ${jobid} -e count_${donorID}.err -o count_${donorID}.out -t 12:00:00 --mem=100G --dependency=afterany:$jsplit --wrap="${p2scripts}/count_genes.sh ${outpbam} ${gtf} ${feature} ${outpath} ${donorID}")
jcount=$(echo $jcount | awk '{print $NF}')
echo count submitted $jcount

exit





 



 

