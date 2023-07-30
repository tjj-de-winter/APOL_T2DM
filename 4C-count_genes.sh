#!/bin/bash

# count genes of bam files using feature counts

if [ $# -ne 5 ]
then
    echo "Please, give as input"
    echo "1) The path to folder with split bam files"
    echo "2) genome reference file (gtf)"
    echo "3) Feature to count, e.g. three_prime_utr_or_mitogene or gene, etc."
    echo "4) outpath"
    echo "5) name of file/donor"
    exit
fi

p2splitbam=$1 # a folder with all the split bam files (e.g. per cell) to count 
gtf=$2 # /exports/ana-scarlab/group_references/ensembl/human/102/Homo_sapiens.GRCh38.102.minusINS-IGF2_uniq3utr_MTgenes_Featurecount-annotation.gtf 
feature=$3 # 'three_prime_utr_or_mitogene'
outpath=$4
name=$5

p2splitbam=${p2splitbam%/}
outpath=${outpath%/}

mkdir -p $outpath

outfile=${outpath}/${name}_count-table.txt # output from featurecounts
outtsv=${outpath}/${name}_count-matrix.tsv # cleaned output

ls ${p2splitbam}/*.bam | awk '{printf "%s", $0 " "} END {print ""}' > ${p2splitbam}/${name}_cells2count.txt; c2c=${p2splitbam}/${name}_cells2count.txt;

featureCounts -a $gtf -o ${outfile} -t $feature -g gene_name `cat $c2c`

cat ${outfile} | grep -v "#" | awk -F "\t|;" '{print $1 ">" $2 "\t" $0}' | cut -f1,8- | sed "s,${p2splitbam}/,,g" | sed "s/.bam//g" > ${outtsv}

exit
