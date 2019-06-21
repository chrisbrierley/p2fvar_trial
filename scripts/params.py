
# coding: utf-8

# In[ ]:

import fileinput
import re

val = ['ipcc_GLOBAL_all_tas','mean','True','ANN','False','all',\
       'nino34','stddev',True,'ANN',True,'all',\
       'True','True']

param = ['SCATTER_X_VARNAME','SCATTER_X_STAT','SCATTER_X_ABS','SCATTER_X_SEASON','SCATTER_X_PCT_CHANGES','SCATTER_X_EXPT',\
         'SCATTER_Y_VARNAME','SCATTER_Y_STAT','SCATTER_Y_ABS','SCATTER_Y_SEASON','SCATTER_Y_PCT_CHANGES','SCATTER_Y_EXPT',\
         'VERBOSE','FIND_FILES_QUIET']

for v,p in zip(val,param):
    for line in fileinput.input(inplace=1, backup='.bak'):
        line = re.sub('%s='%p,'%s="%s"'%(p,v),line.rstrip())
        print(line)

                
      