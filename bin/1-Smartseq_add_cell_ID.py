#!/usr/bin/env python3
# Reads R1.fastq and R2.fastq files;
# selects reads with proper cell barcode;
# produces a new _cbc.fastq.gz file.
import sys, os
import itertools as it
import argparse as argp
import numpy as np
import gzip
import pandas as pd
import matplotlib.pyplot as plt
from pandas.io.parsers import read_csv
from collections import Counter
import glob


#### check input variables ####
parser = argp.ArgumentParser(description = 'Add cellIDs to the sample name (Smart-seq).')
parser.add_argument('--fq1', help = 'single column txt file with Fastq file names for read 1. Please provide full name')
parser.add_argument('--cellid', '-cid', help = 'cell ID txt file. Please, provide full name')
parser.add_argument('--outdir', help = 'output directory for cbc.fastq.gz and log files', type = str, default = './')
parser.add_argument('--outprefix', help = 'prefix for prefix_cbc.fastq.gz and prefix.log files', type = str, default = 'none')
parser.add_argument('--idx', help = 'index sequence', type = str, default = '')
args = parser.parse_args()

fq1s = args.fq1
cellIDtxt = args.cellid
outdir = args.outdir
indexSample = args.idx
fqr = args.outprefix

#### Open cell ID file ####
if not os.path.isfile(cellIDtxt):
        sys.exit('cell ID file not found')
cellid_df = read_csv(cellIDtxt, sep = ',', names = ['SRR', 'cellID'], index_col = 0)


### Create output directory if it does not exist ####
if not os.path.isdir(outdir):
    os.system('mkdir '+outdir)

fq1_list = open(fq1s, 'r').readlines()

for ff in range(len(fq1_list)):
    fq1 = fq1_list[ff].rsplit()[0]

    #### Find input fastq files ####
    
    
    if not os.path.isfile(fq1):
        sys.exit('fastq files not found')

    fqr = fq1.rsplit('_')[0]
    print('--- Start renaming {' + fqr + '} ---\n')
    
    
    

    #### Read fastq files and assign cell barcode and UMI ####    
    
    fout = open(outdir + '/' + fqr + '_cbc.fastq', 'w')
    ns = 0
    with gzip.open(fq1) as f1: 
       	for idx, l1 in enumerate(f1):
            try:
                l1 = str(l1.rstrip().rsplit()[0], 'utf-8')
            except:
                continue

            l = np.mod(idx,4)
            if l == 0:
                n1 = l1
                cellID = cellid_df.loc[str(n1.rsplit('.')[0].rsplit('@')[1]), 'cellID']

            if l == 1:
                s1 = l1
            if l == 2:
                p1 = l1[0]
            if l == 3:
                q1 = l1

                try:
                    ns += 1
                    if len(indexSample) != 0:
                        name = str(n1 + ';SM:' + cellID)
                    else:
                        name = str(n1 + ';SM:' + cellID)
                    s, q = (s1, q1)
                    if s != 'N'*len(s):
                        fout.write( '\n'.join([name, s, '+', q, '']))
                except: 
                   	continue

 
    nt = (idx+1)/4
    fout.close()
    
        
    #### LOG ####
    fout = open(outdir + '/' + fqr + '.log', 'w')
    fout.write('=> to generate cbc file <=\n')
    fout.write(', '.join(['--------------------------','\n']))
    fout.write(', '.join(['fastq file:', str(fqr),'\n']))
    fout.write(', '.join(['total sequenced reads:', str(nt), '\n']))
    fout.close()

    print('---Added all cell IDs for fastq file {' + fqr + '} DONE ---\n-------------------------------------\n')

    ### zip fastq file ####
    os.system('gzip '+ outdir + '/' + fqr + '_cbc.fastq')
