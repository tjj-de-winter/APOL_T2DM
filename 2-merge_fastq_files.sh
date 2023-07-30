#!/bin/bash

# merge a list of files into a single output file, automatic zipping 

file_list=$1 # txt file with one row containing the names of files to merge (no header!)
output=$2 # output file
overwrite=$3 # type '-f' or leave empty 

# check if output file already exists, stop if not forced to overwrite
if [ -f $output ]
then 
	if [ -z $overwrite ]
	then
		echo "file '${output}' already exists"
		exit
	else
		rm $output
	fi
fi

# if output file exist but forced to overwrite check if unzipped file exist and remove

if [ -f ${output%.gz} ]
then
        if [ -z $overwrite ]
        then
                echo "file '${output%.gz}' already exists"
                exit
        else
                rm ${output%.gz}
        fi
fi

# merge files, check if unput exists and whether file is zipped (cat vs zcat) 
for file in $(awk '{print $NF}' $file_list)
do 
	if [ -f $file  ]
	then
		echo ""
	else
		echo "input file '${file}' does not exist"
		rm ${output%.gz}
		exit
	fi

	gz=${file: -3}
	if [ ${gz} != ".gz" ]
	then
		echo "start merging '${file}'"
		cat $file >> ${output%.gz}
	else
		echo "start merging '${file}'"
		zcat $file >> ${output%.gz}
	fi
done

# if output file is written as a zipped file, zip the newly made merged file

gzip=${output: -3}
if [ $gzip = ".gz" ]
then
	echo "start gzip of '${output%.gz}'"
	gzip ${output%.gz}
fi

exit
