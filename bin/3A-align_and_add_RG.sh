#!/bin/bash

if [ $# -ne 4 ]
then
    echo "Please, give as input"
    echo "1) single fastq file name (as FILENAME_cbc_trimmed.fq.gz)"
    echo "2) library tag"
    echo "3) donor ID"
    echo "4) indexed genome folder (star)"
    exit
fi

inputfq=$1
#library_tag=$2
donor_ID=$3
genome=$4

library_tag=x

outprefix=${inputfq%_cbc_trimmed.fq.gz}_
samplename=${donor_ID}
p2scripts=/exports/ana-scarlab/tdwinter/bin
p2star=/exports/ana-scarlab/bin/STAR-2.7.7a/bin/Linux_x86_64
p2samtools=/exports/ana-scarlab/bin/samtools-1.11
p2picard=/exports/ana-scarlab/bin/picard-2.25.0
p2java=$(which java)
p2java=${p2java%/java}

# check java version, needs to be JDK version 8

v="$(${p2java}/java -version 2>&1)"
version=$(echo ${v} | awk -F "." '/version/ {print $2}')
if [ ${version} -ne "8" ]
then
    echo "Java JDK needs to be version 8"
    exit
fi

# STAR mapping
jobid=star
jstar=1
jstar=$(sbatch --export=All -c 8 -J ${jobid} -e ${jobid}_${outprefix}.err -o ${jobid}_${outprefix}.out -t 2-24:00:00 --mem=300G --wrap="${p2scripts}/star_allign.sh ${inputfq} ${outprefix} ${genome} ${p2star} ${p2samtools} ${library_tag}")
jstar=$(echo $jstar | awk '{print $NF}')

# Add Readgroup to filtered coordinated bam file
jobid=readgroup
jrg=2
jrg=$(sbatch --export=All -c 1 -N 1 -J ${jobid} -e ${jobid}_${outprefix}.err -o ${jobid}_${outprefix}.out -t 24:00:00 --mem=300G --dependency=afterany:$jstar --wrap="${p2java}/java -jar ${p2picard}/picard.jar AddOrReplaceReadGroups I=${outprefix}Aligned.sortedByCoord.filtered.bam O=${outprefix}.Aligned.sortedByCoord.filtered.RG.bam RGID=${samplename} RGLB=${samplename} RGPL=ILLUMINA RGPU=${samplename} RGSM=${samplename} USE_JDK_DEFLATER=true")
jrg=$(echo $jrg | awk '{print $NF}')

exit
