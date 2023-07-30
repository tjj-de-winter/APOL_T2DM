#!/bin/bash

# split cells based on cell id

if [ $# -ne 4 ]
then
    echo "Please, give as input"
    echo "1) The bam file name"
    echo "2) Path to bam file"
    echo "3) output path split bam files"
    echo "4) path to samtools"
    exit
fi

bam=$1
p2bam=$2
outpbam=$3
p2samtools=$4

p2bam=${p2bam%/}

donorID=$(${p2samtools}/samtools view -h $bam | head -n400 | grep "@RG" | awk -F "ID:|\t" '{print $3}')

if [ -z "$donorID" ]
then
      echo "No donor ID, please add a readgroup to the bam file"
      exit
fi


mkdir -p $outpbam

cells=$(samtools view ${p2bam}/${bam} | awk -F "SM:|\t" '{print $2}' | sort | uniq)
for cell in $cells
	do
	samtools view -H ${p2bam}/${bam} > ${outpbam}/${donorID}_${cell}.sam
done

samtools view ${p2bam}/${bam} | awk -v path=${outpbam}/${donorID} '{cell=substr($1,index($1,"SM:")+3,length($1)); print $0 >> path"_"cell".sam"}'

for s in $(ls ${outpbam}/*sam)
	do
	samtools view -h -b $s > ${s%.sam}.bam
    	rm $s	
done
	
exit
