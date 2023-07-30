#!/usr/bin/python

import sys, os
import pandas as pd
import numpy as np
from pandas.io.parsers import read_csv
import matplotlib.pyplot as plt
import glob
#from pyPDF2 import PdfFileMerger

f = sys.argv[1]
donor = sys.argv[2]
path = sys.argv[3]
path= str(path)
if os.path.exists(path) == False:
	os.makedirs(path)

print(donor)

matrix = read_csv(f, sep='\t', index_col=0)
mito = [idx for idx in matrix.index if 'MT-' in idx]
matrix_mito = matrix.loc[mito]
meta_matrix = pd.DataFrame({'reads': matrix.sum(), 'genes': (matrix>0).sum()})
meta_matrix['mito'] = matrix.loc[mito].sum()
meta_matrix['GAPDH'] = matrix.loc['GAPDH>12']
meta_matrix['GAPDH_frac'] = meta_matrix['GAPDH'] /meta_matrix['reads']
meta_matrix['mito_frac'] = meta_matrix['mito']/meta_matrix['reads']
#filtr = meta_matrix[(meta_matrix['reads']> 1e5) & (meta_matrix['mito_frac']<= 0.2) & (meta_matrix['genes']> 3)]


plt.subplots(figsize=(10,10))
plt.hist(np.log10(matrix.sum()+1), bins = 50)
plt.xlabel('log10(reads)')
plt.ylabel('frequency')
plt.title(str("Quality control plots for "+ donor + "\n\n\nNumber of reads"))
fig1 = str(path + "/" + donor + "_nreads.pdf")
plt.savefig(fig1)

plt.subplots(figsize=(10,10))
plt.hist(np.log10(matrix.sum(axis=1)+1), bins = 50)
plt.xlabel('log10(genes)')
plt.ylabel('frequency')
plt.title(str("Quality control plots for "+ donor + "\n\n\nFrequency of genes"))
fig2 = str(path + "/" + donor + "_freqgenes.pdf")
plt.savefig(fig2)

plt.subplots(figsize=(10,10))
plt.scatter(range(len(meta_matrix)), meta_matrix['reads'], label = 'reads')
plt.scatter(range(len(meta_matrix)), meta_matrix['mito'], label = 'mito')
plt.legend()
plt.xlabel('Number of reads')
plt.ylabel('Cell')
plt.title(str("Quality control plots for "+ donor + "\n\n\nType of reads per cell"))
plt.yscale('log')
fig3 = str(path + "/" + donor + "_rpcell.pdf")
plt.savefig(fig3)

plt.subplots(figsize=(10,10))
plt.hist(meta_matrix['mito_frac'], bins = 50)
plt.title(str("Quality control plots for "+ donor + "\n\n\nMitochondrial read fraction"))
plt.xlabel('Fraction')
plt.ylabel('Frequency')
plt.xlim([0,1])
fig4 = str(path + "/" + donor + "_mitofrac.pdf")
plt.savefig(fig4)

plt.subplots(figsize=(10,10))
plt.hist(meta_matrix['GAPDH_frac'], bins = 50)
plt.title(str("Quality control plots for "+ donor + "\n\n\nGAPDH read fraction"))
plt.xlabel('Fraction')
plt.ylabel('Frequency')
#plt.xlim([1e-20,1e-2])
plt.xscale('log')
fig4 = str(path + "/" + donor + "_GAPDHfrac.pdf")
plt.savefig(fig4)


plt.subplots(figsize=(10,10))
plt.scatter(meta_matrix['reads'], meta_matrix['genes'])
plt.xlabel('reads')
plt.ylabel('genes')
plt.title(str("Quality control plots for "+ donor + "\n\n\nReads per gene"))
fig5 = str(path + "/" + donor + "_rpgene.pdf")
plt.savefig(fig5)

sys.exit()
