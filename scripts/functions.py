
# coding: utf-8

# In[ ]:

import fileinput
import re
from IPython.display import display, Image
import os
import subprocess

param = ['SCATTER_X_VARNAME','SCATTER_X_STAT','SCATTER_X_ABS','SCATTER_X_SEASON','SCATTER_X_PCT_CHANGES','SCATTER_X_EXPT',\
         'SCATTER_Y_VARNAME','SCATTER_Y_STAT','SCATTER_Y_ABS','SCATTER_Y_SEASON','SCATTER_Y_PCT_CHANGES','SCATTER_Y_EXPT',\
         'VERBOSE','FIND_FILES_QUIET']

# -----------------------------------------------------------------------------------------------------------------------
def params2(val):
    shfile = 'scripts/mk_scatter.sh'
    for p in param:
        for line in fileinput.input(files=(shfile),inplace=1, backup='.bak'):
            line = re.sub('%s='%p,'%s="%s"'%(p,val[p]),line.rstrip())
            print(line)



# -----------------------------------------------------------------------------------------------------------------------          
def clear2(val):
    shfile = 'scripts/mk_scatter.sh'
    for p in param:
        for line in fileinput.input(files=(shfile),inplace=1, backup='.bak'):
            line = re.sub('%s="%s"'%(p,val[p]),'%s='%p,line.rstrip())
            print(line)

            
# -----------------------------------------------------------------------------------------------------------------------
def ncl_comp2(val):
    shfile = 'scripts/mk_scatter.sh'
    params2(val)
    #bash = os.popen("sh %s"%shfile).read()
    os.system("sh %s"%shfile)
    clear2(val)
    print('Bash and NCL have run successfully')
    
    # Derive the name of the output scatter plot from the inputs
    
    figure = "output/SCATTER_%s-expt_%s_%s_vs_%s-expt_%s_%s.png"%(val['SCATTER_X_EXPT'],val['SCATTER_X_STAT'],val['SCATTER_X_VARNAME'],val['SCATTER_Y_EXPT'],val['SCATTER_Y_STAT'],val['SCATTER_Y_VARNAME'])  
    display(Image(filename=figure))
    
    
            

# -----------------------------------------------------------------------------------------------------------------------
def params(val,shfile):
    for v,p in zip(val,param):
        for line in fileinput.input(files=(shfile),inplace=1, backup='.bak'):
            line = re.sub('%s='%p,'%s="%s"'%(p,v),line.rstrip())
            print(line)

            
# -----------------------------------------------------------------------------------------------------------------------          
def clear(val,shfile):
    for v,p in zip(val,param):
        for line in fileinput.input(files=(shfile),inplace=1, backup='.bak'):
            line = re.sub('%s="%s"'%(p,v),'%s='%p,line.rstrip())
            print(line)

            
# -----------------------------------------------------------------------------------------------------------------------
def ncl_comp(val,shfile):
    params(val,shfile)
    #bash = os.popen("sh %s"%shfile).read()
    #print bash
    os.system("sh %s"%shfile)
    clear(val,shfile)
    print('Bash and NCL have run successfully')
    
    
# -----------------------------------------------------------------------------------------------------------------------
def read_plot(val,shfile):
    params(val,shfile)
    os.system("sh %s"%shfile)
    clear(val,shfile)
    f = "SCATTER_%s-expt_%s_%s_vs_%s-expt_%s_%s.png"%(SCATTER_X_EXPT,SCATTER_X_STAT,SCATTER_X_VARNAME,\
                                                      SCATTER_Y_EXPT,SCATTER_Y_STAT,SCATTER_Y_VARNAME)  
    display(Image(filename=f))
       
        
# -----------------------------------------------------------------------------------------------------------------------          
def read_plot2(val,shfile):
    params(val,shfile)
    
    bashCommand = "sh %s"%shfile
    process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
    subprocess.check_output(['ls', '-l'])
    output, error = process.communicate()  
    
    clear(val,shfile)
    f = "SCATTER_%s-expt_%s_%s_vs_%s-expt_%s_%s.png"%(SCATTER_X_EXPT,SCATTER_X_STAT,SCATTER_X_VARNAME,\
                                                      SCATTER_Y_EXPT,SCATTER_Y_STAT,SCATTER_Y_VARNAME)  
    display(Image(filename=f))    

    
# -----------------------------------------------------------------------------------------------------------------------
def plot(val):
    f = "output/SCATTER_%s-expt_%s_%s_vs_%s-expt_%s_%s.png"%(val['SCATTER_X_EXPT'],val['SCATTER_X_STAT'],val['SCATTER_X_VARNAME'],val['SCATTER_Y_EXPT'],val['SCATTER_Y_STAT'],val['SCATTER_Y_VARNAME']) 
    display(Image(filename=f))

    
# -----------------------------------------------------------------------------------------------------------------------    
def mappable_variables(keyword):
    mv = os.popen("ncdump -h /data/aod/cvdp_cmip5/local_output/data_PVar_kira/MPI-ESM-P-p2_piControl.cvdp_data.2400-3000.nc | grep float | grep lat | cut -d\( -f1 | cut -d\  -f2").read()
    
    if keyword != 'all':
        selection = []
        sub = mv.split('\n')
        for i in sub:
            if keyword in i:
                selection.append(i)
    
        for i in selection:
            print(i)       
        if len(selection) == 0:
            print('no variables matching keyword')
    else:
        print(mv)
# -----------------------------------------------------------------------------------------------------------------------
def timeseries_variables(keyword):
    ts = os.popen("ncdump -h /data/aod/cvdp_cmip5/local_output/data_PVar_kira/MPI-ESM-P-p2_piControl.cvdp_data.2400-3000.nc | grep float | grep time | cut -d\( -f1 | cut -d\  -f2").read()  
    
    if keyword != 'all':
        selection = []
        sub = ts.split('\n')
        for i in sub:
            if keyword in i:
                selection.append(i)
    
        for i in selection:
            print(i) 
        if len(selection) == 0:
            print('no variables matching keyword')
    else:
        print(ts)    
    
    
# -----------------------------------------------------------------------------------------------------------------------
def variable_longname(var):
    var_d = os.popen("ncdump -h /data/aod/cvdp_cmip5/local_output/data_PVar_kira/MPI-ESM-P-p2_piControl.cvdp_data.2400-3000.nc | grep long_name").read()
    mp = os.popen("ncdump -h /data/aod/cvdp_cmip5/local_output/data_PVar_kira/MPI-ESM-P-p2_piControl.cvdp_data.2400-3000.nc | grep float | grep lat | cut -d\( -f1 | cut -d\  -f2").read()
    ts = os.popen("ncdump -h /data/aod/cvdp_cmip5/local_output/data_PVar_kira/MPI-ESM-P-p2_piControl.cvdp_data.2400-3000.nc | grep float | grep time | cut -d\( -f1 | cut -d\  -f2").read()
    
    # dictionary storing longnames 
    var_longname = {}
    descriptions = var_d.split(';')
    for i in range(len(descriptions[1:])):
        root = descriptions[i].split(':')
        var_longname['%s'%root[0][3:]] = '%s'%root[1][13:-2]
    
    # printing type and variable longname from dictionary                
    if var in var_longname.keys() and var in mp:
        print('mappable variable - ' + var_longname['%s'%var])
    elif var in var_longname.keys() and var in ts:
        print('timeseries variable - ' + var_longname['%s'%var])                                                                 
    else:
        print('not valid variable')   
           


print('functions successfully imported') 

      