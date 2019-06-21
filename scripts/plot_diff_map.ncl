;presumes inputs of filename,exptname and varname

;First load the ncl scripts
load "scripts/cvdp_data.functions.ncl"
data_dir="/data/p2f/cvdp_data" ;Point the directory containing the output from the CVDP

;set some options
opt=True
if isvar("CONSISTENCY") then
    ;this option stipples locations where >2/3 of the model have the same sign 
    opt@CONSISTENCY=True
end if
if isvar("OVERLAY_CONTROL") then
  ;this option will add some contour lines of the Ensemble Mean of B.
  opt@OVERLAY_CONTROL=True
end if
if isvar("MASK_TRIVIAL") then
  ;this option will mask out any instances where the magnitude of both patterns is less than 10% of the global mean
  opt@MASK_TRIVIAL=True
end if
if isvar("RATIO") then
  ;this option will plot the ratio of the fields 
  opt@RATIO=True
end if
if isvar("PERCENTAGE") then
  ;this option will plot the ratio of the fields 
  opt@PERCENTAGE=True
end if

output_string="output/"+exptname_a+"-"+exptname_b+"_"+varname

output_string@filetype="png"
if isvar("VERBOSE") then
  ;Provides a modicum of more information
  output_string@VERBOSE=True
end if


;Use the routines in cvdp_data.functions.ncl to create the plot
plot_output_DiffEnsMn(data_dir,exptname_a,exptname_b,varname,output_string,opt)