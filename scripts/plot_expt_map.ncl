;presumes inputs of filename,exptname and varname

;First load the ncl scripts
load "~/Desktop/scripts/cvdp_data.functions.ncl"
data_dir="/data/p2f/cvdp_data" ;Point the directory containing the output from the CVDP
output_string="output/"+exptname+"_"+varname
output_string@filetype="png"
;Use the routines in cvdp_data.functions.ncl to create the plot
plot_output_CVDPmap(data_dir,exptname,varname,output_string,False)