;This file creates a generic scatter plot

;First load the ncl scripts
load "scripts/cvdp_data.functions.ncl"
data_dir="/data/p2f/cvdp_data/" ;Point the directory containing the output from the CVDP
expts=(/"piControl","midHolocene","lgm","lig127k","1pctCO2","abrupt4xCO2"/)
expts_color=(/"grey24","darkgreen","dodgerblue4","yellowgreen","firebrick","orangered2"/)
gcms=(/"AWI-ESM","bcc-csm1-1","BCC-CSM2-MR","BCC-ESM1","CCSM4","CCSM4-r2","CESM2","CNRM-CM5","CNRM-CM6-1","CNRM-ESM2-1","COSMOS-ASO","CSIRO-Mk3-6-0","CSIRO-Mk3L-1-2","EC-EARTH-2-2","FGOALS-g2","FGOALS-s2","GFDL-CM4","GISS-E2-1-G","GISS-E2-R-p2","GISS-E2-R","HadCM3","HadGEM2-CC","HadGEM2-ES","HadGEM3-GC31","IPSL-CM5A-LR","IPSL-CM6A-LR","KCM1-2-2","MIROC6","MIROC-ESM","MPI-ESM-P-p2","MPI-ESM-P","MRI-CGCM3","MRI-ESM2-0"/)
ECS=(/ -999.    ,2.8         ,3.1          ,-999.     , 2.9   , 2.9      , 5.2   , 3.3      , 5.0        , 4.4         , -999.      , 4.1           , -999.          , 4.2          , -999.     , -999.     , 5.0      , 2.7         , 2.1          , 2.1       , -999.  , -999.      , 4.6        , -999.        ,4.1          , 4.5          , -999.    , 2.5    , 4.7       , 3.5          , 3.5       , 2.6        , -999.      /)
ECS@_FillValue=-999.
isCMIP6=(/True  ,False       ,True         ,True      ,False  ,False     ,True   ,False     ,True        ,True         ,False       ,False          ,False           ,False         ,False      ,False      ,True      ,True         ,False         ,False      ,False   ,False       ,False       ,True          ,False         ,True         ,False     ,True    ,False      ,False         ,False      ,False       ,True/)
alphabet=(/"a","b","c","d","e","f","g","h","i","j","k","l"/)

;OPTIONS
input=getenv("VERBOSE")
if ismissing(input) then
  VERBOSE=False
else
  if input.eq."True" then
    VERBOSE=True
  else
    VERBOSE=False
  end if
end if
input=getenv("FIND_FILES_QUIET")
if ismissing(input) then
  data_dir@quiet=True
else
  if input.eq."True" then
    data_dir@quiet=True
  else
    data_dir@quiet=False
  end if
end if
OUTPUT_TYPE="png"

print("VERBOSE is set to "+VERBOSE)

;define the dependent variable
input=getenv("SCATTER_X_VARNAME")
if ismissing(input) then
  print("SCATTER_X_VARNAME is not set. Exiting now")
else
  SCATTER_X_VARNAME=input
end if
input=getenv("SCATTER_X_STAT")
if ismissing(input) then
  SCATTER_X_STAT="mean"
else
  SCATTER_X_STAT=input
end if
input=getenv("SCATTER_X_ABS")
if ismissing(input) then
  SCATTER_X_ABS=False
else
  if input.eq."True" then
    SCATTER_X_ABS=True
  else
    SCATTER_X_ABS=False
  end if
end if
input=getenv("SCATTER_X_SEASON")
if ismissing(input) then
  SCATTER_X_SEASON="ANN"
else
  SCATTER_X_SEASON=input
end if
input=getenv("SCATTER_X_PCT_CHANGES")
if ismissing(input) then
  SCATTER_X_PCT_CHANGES=False
else
  if input.eq."True" then
    SCATTER_X_PCT_CHANGES=True
  else
    SCATTER_X_PCT_CHANGES=False
  end if
end if
input=getenv("SCATTER_X_EXPT")
if ismissing(input) then
  SCATTER_X_EXPT="all"
else
  SCATTER_X_EXPT=input
end if

;define the dependent variable
input=getenv("SCATTER_Y_VARNAME")
if ismissing(input) then
  print("SCATTER_Y_VARNAME is not set. Exiting now")
else
  SCATTER_Y_VARNAME=input
end if
input=getenv("SCATTER_Y_STAT")
if ismissing(input) then
  SCATTER_Y_STAT="mean"
else
  SCATTER_Y_STAT=input
end if
input=getenv("SCATTER_Y_ABS")
if ismissing(input) then
  SCATTER_Y_ABS=False
else
  if input.eq."True" then
    SCATTER_Y_ABS=True
  else
    SCATTER_Y_ABS=False
  end if
end if
input=getenv("SCATTER_Y_SEASON")
if ismissing(input) then
  SCATTER_Y_SEASON="ANN"
else
  SCATTER_Y_SEASON=input
end if
input=getenv("SCATTER_Y_PCT_CHANGES")
if ismissing(input) then
  SCATTER_Y_PCT_CHANGES=False
else
  if input.eq."True" then
    SCATTER_Y_PCT_CHANGES=True
  else
    SCATTER_Y_PCT_CHANGES=False
  end if
end if
input=getenv("SCATTER_Y_EXPT")
if ismissing(input) then
  SCATTER_Y_EXPT="all"
else
  SCATTER_Y_EXPT=input
end if

dY=new((/dimsizes(gcms),dimsizes(expts)-1/),float);array to hold variability change
dY=(/dY@_FillValue/)
dX=new((/dimsizes(gcms),dimsizes(expts)-1/),float);array to hold mean state change
dX=(/dX@_FillValue/)
ts_opt=True
ts_opt@NO_EXIT_ON_ERROR=True
ts_transient=ts_opt
ts_transient@subset=True
ts_transient@subset_syear=-30
ts_transient@subset_eyear=0
ts_transient@DETREND=True

;do some quick checks...
possible_expt_settings=array_append_record(expts,(/"all","missing"/),0)
if .not.any(SCATTER_Y_EXPT.eq.possible_expt_settings).or..not.any(SCATTER_Y_EXPT.ne.possible_expt_settings) then
  print("You've set SCATTER_X_EXPT as "+SCATTER_X_EXPT+" and SCATTER_Y_EXPT as "+SCATTER_Y_EXPT)
  print("The only possible values for these are: "+str_join(possible_expt_settings,","))
  exit
end if

if any(SCATTER_X_EXPT.eq.(/"all","missing"/)) then
  if any(SCATTER_Y_EXPT.eq.(/"all","missing"/)) then
    if VERBOSE then
      print("Selecting all experiments and plotting on a single graph")
    end if
    ALL_EXPTS=True
  else
    print("You've set SCATTER_X_EXPT as "+SCATTER_X_EXPT+" (so selecting all experiments), but SCATTER_Y_EXPT as "+SCATTER_Y_EXPT)
    print("I don't see how that can be plotted, so am exiting now")
    exit
  end if
else
  if any(SCATTER_Y_EXPT.eq.(/"all","missing"/)) then
    print("You've set SCATTER_X_EXPT as "+SCATTER_X_EXPT+" (so selecting all experiments), but SCATTER_Y_EXPT as "+SCATTER_Y_EXPT)
    print("I don't see how that can be plotted, so am exiting now")
    exit
  else
    if VERBOSE then
      print("Selecting X axis as "+SCATTER_X_EXPT+" and Y axis as "+SCATTER_Y_EXPT)
    end if
      ALL_EXPTS=False
      X_expt_i=ind(expts.eq.SCATTER_X_EXPT)
      Y_expt_i=ind(expts.eq.SCATTER_Y_EXPT)
    end if
  end if

;collect all the data
do expt_i=1,dimsizes(expts)-1
  if VERBOSE then
    print("Working on data for scatter plot for expt "+expt_i+": "+expts(expt_i))
  end if
  if any(expts(expt_i).eq.(/"1pctCO2","abrupt4xCO2","rcp85"/)) then
    ts_a=ts_transient
    ts_b=ts_opt
  else  
    ts_a=ts_opt
    ts_b=ts_opt
  end if
  ;collect the X_Variable changes
  if SCATTER_X_ABS then 
    ts_a@make_absolute=True
    ts_b@make_absolute=True
  end if
  if .not.any((/isStrSubset(SCATTER_X_VARNAME,"ann"),isStrSubset(SCATTER_X_VARNAME,"djf"),\
    isStrSubset(SCATTER_X_VARNAME,"mam"),isStrSubset(SCATTER_X_VARNAME,"jja"),\
    isStrSubset(SCATTER_X_VARNAME,"son"),isStrSubset(SCATTER_X_VARNAME,"monsoon")/)) then 
    ts_a@SEASON=SCATTER_X_SEASON
    ts_b@SEASON=SCATTER_X_SEASON
  end if
  if ALL_EXPTS.or.(expt_i.eq.X_expt_i) then
    do gcm_i=0,dimsizes(gcms)-1
      if SCATTER_X_VARNAME.eq."climate_sensitivity" then
        dX(gcm_i,expt_i-1)=ECS(gcm_i)
      else
        piC_file=find_files_wVar(data_dir,gcms(gcm_i)+"_piControl",SCATTER_X_VARNAME)
        piC_file@_FillValue=default_fillvalue(typeof(piC_file))
        expt_file=find_files_wVar(data_dir,gcms(gcm_i)+"_"+expts(expt_i),SCATTER_X_VARNAME)
        expt_file@_FillValue=default_fillvalue(typeof(expt_file))
        if VERBOSE then
          print(SCATTER_X_VARNAME+": "+expt_file+" and "+piC_file)
        end if
        if .not.any((/ismissing(piC_file),ismissing(expt_file)/)) then
          X_a=stat_ts_var(expt_file,SCATTER_X_VARNAME,SCATTER_X_STAT,ts_a)
          X_b=stat_ts_var(piC_file,SCATTER_X_VARNAME,SCATTER_X_STAT,ts_b)
          if .not.ALL_EXPTS then
            if SCATTER_X_PCT_CHANGES then
              dX(gcm_i,1)=100.*(X_a-X_b)/X_b
            else
              dX(gcm_i,1)=X_a-X_b
            end if
          else
            if SCATTER_X_PCT_CHANGES then
              dX(gcm_i,expt_i-1)=100.*(X_a-X_b)/X_b
            else
              dX(gcm_i,expt_i-1)=X_a-X_b
            end if
          end if
          delete([/X_a,X_b/])
        end if
        delete([/piC_file,expt_file/])
      end if
    end do
  end if

  ;Now collect the Y_Variable changes
  delete([/ts_a,ts_b/])
  if any(expts(expt_i).eq.(/"1pctCO2","abrupt4xCO2","rcp85"/)) then
    ts_a=ts_transient
    ts_b=ts_opt
  else  
    ts_a=ts_opt
    ts_b=ts_opt
  end if
  if SCATTER_Y_ABS then 
    ts_a@make_absolute=True
    ts_b@make_absolute=True
  end if
  if .not.any((/isStrSubset(SCATTER_Y_VARNAME,"ann"),isStrSubset(SCATTER_Y_VARNAME,"djf"),\
    isStrSubset(SCATTER_Y_VARNAME,"mam"),isStrSubset(SCATTER_Y_VARNAME,"jja"),\
    isStrSubset(SCATTER_Y_VARNAME,"son"),isStrSubset(SCATTER_Y_VARNAME,"monsoon")/)) then 
    ts_a@SEASON=SCATTER_Y_SEASON  
    ts_b@SEASON=SCATTER_Y_SEASON
  end if
  if ALL_EXPTS.or.(expt_i.eq.Y_expt_i) then
    do gcm_i=0,dimsizes(gcms)-1
      if SCATTER_Y_VARNAME.eq."climate_sensitivity" then
        dY(gcm_i,expt_i-1)=ECS(gcm_i)
      else
        piC_file=find_files_wVar(data_dir,gcms(gcm_i)+"_piControl",SCATTER_Y_VARNAME)
        piC_file@_FillValue=default_fillvalue(typeof(piC_file))
        expt_file=find_files_wVar(data_dir,gcms(gcm_i)+"_"+expts(expt_i),SCATTER_Y_VARNAME)
        expt_file@_FillValue=default_fillvalue(typeof(expt_file))
        if VERBOSE then
          print(SCATTER_Y_VARNAME+": "+expt_file+" and "+piC_file)
        end if
        if .not.any((/ismissing(piC_file),ismissing(expt_file)/)) then
          Y_a=stat_ts_var(expt_file,SCATTER_Y_VARNAME,SCATTER_Y_STAT,ts_a)
          Y_b=stat_ts_var(piC_file,SCATTER_Y_VARNAME,SCATTER_Y_STAT,ts_b)
          if VERBOSE then
            print("Y_a="+Y_a+", Y_b="+Y_b)
          end if
          if .not.ALL_EXPTS then
            if SCATTER_Y_PCT_CHANGES then
              dY(gcm_i,1)=100.*(Y_a-Y_b)/Y_b
            else
              dY(gcm_i,1)=Y_a-Y_b
            end if
          else
            if SCATTER_Y_PCT_CHANGES then
              dY(gcm_i,expt_i-1)=100.*(Y_a-Y_b)/Y_b
            else
              dY(gcm_i,expt_i-1)=Y_a-Y_b
            end if
          end if
          delete([/Y_a,Y_b/])
        end if
        delete([/piC_file,expt_file/])
      end if
    end do
  end if
end do

;do a final error check
dY=where(dY.eq.default_fillvalue("float"),dY@_FillValue,dY)
dX=where(dX.eq.default_fillvalue("float"),dX@_FillValue,dX)


;Write out the values to csv files
if ALL_EXPTS then
  hlist=[/"MODEL,"+str_join(expts(1:),",")/]
  fname="output/SCATTER_"+SCATTER_X_EXPT+"-expt_"+SCATTER_X_STAT+"_"+SCATTER_X_VARNAME+".csv"
  write_table(fname, "w", hlist, "%s ")
  alist=NewList("lifo")
  ListAppend(alist,gcms)
  format_string="%s"
  printVarSummary(dX)
  do expt_i=0,dimsizes(expts)-2
    values=dX(:,expt_i)
    values@_FillValue=-999.
    str = unique_string("polymarker")
    values@$str$=values
    ListAppend(alist,values@$str$)
    format_string=format_string+",%5.2f"
  end do
  write_table(fname, "a", alist,format_string)
  delete([/alist,values,format_string,fname/])
  hlist=[/"MODEL,"+str_join(expts(1:),",")/]
  fname="output/SCATTER_"+SCATTER_Y_EXPT+"-expt_"+SCATTER_Y_STAT+"_"+SCATTER_Y_VARNAME+".csv"
  write_table(fname, "w", hlist, "%s ")
  alist=NewList("lifo")
  ListAppend(alist,gcms)
  format_string="%s"
  do expt_i=0,dimsizes(expts)-2
    values=dY(:,expt_i)
    values@_FillValue=-999.
    str = unique_string("polymarker")
    values@$str$=values
    ListAppend(alist,values@$str$)
    format_string=format_string+",%5.2f"
  end do
  write_table(fname, "a", alist,format_string)
  delete([/alist,values,format_string,fname/])
else
  hlist=[/"MODEL",SCATTER_X_EXPT/]
  fname="output/SCATTER_"+SCATTER_X_EXPT+"-expt_"+SCATTER_X_STAT+"_"+SCATTER_X_VARNAME+".csv"
  write_table(fname, "w", hlist, "%s ")
  alist=NewList("lifo")
  ListAppend(alist,models)
  format_string="%s,%5.2f"
  values=dX(:,X_expt_i)
  values@_FillValue=-999.
  ListAppend(alist,values)
  write_table(fname, "a", alist,format_string)
  delete([/alist,values,format_string,fname/])
  hlist=[/"MODEL",SCATTER_Y_EXPT/]
  fname="output/SCATTER_"+SCATTER_Y_EXPT+"-expt_"+SCATTER_Y_STAT+"_"+SCATTER_Y_VARNAME+".csv"
  write_table(fname, "w", hlist, "%s ")
  alist=NewList("lifo")
  ListAppend(alist,models)
  format_string="%s,%5.2f"
  values=dY(:,Y_expt_i)
  values@_FillValue=-999.
  ListAppend(alist,values)
  write_table(fname, "a", alist,format_string)
  delete([/alist,values,format_string,fname/])
end if

;create the scatter plot
plotname="output/SCATTER_"+SCATTER_X_EXPT+"-expt_"+SCATTER_X_STAT+"_"+SCATTER_X_VARNAME+"_vs_"+SCATTER_Y_EXPT+"-expt_"+SCATTER_Y_STAT+"_"+SCATTER_Y_VARNAME+"."+OUTPUT_TYPE
wks = gsn_open_wks(OUTPUT_TYPE,"output/SCATTER_"+SCATTER_X_EXPT+"-expt_"+SCATTER_X_STAT+"_"+SCATTER_X_VARNAME+"_vs_"+SCATTER_Y_EXPT+"-expt_"+SCATTER_Y_STAT+"_"+SCATTER_Y_VARNAME)
res = True ; plot mods desired
res@gsnDraw = False
res@gsnFrame = False ; plot mods desired
res@tiMainString= " " ; add title
res@xyMarkLineModes = "Markers"; choose which have markers
res@xyMonoMarkerColor = True
res@xyMarkerSizeF = 0.01 ; Marker size (default 0.01)
res@gsnYRefLine=0.0
res@gsnXRefLine=0.0
res@tmLabelAutoStride = True ; nice tick mark labels
if SCATTER_X_PCT_CHANGES then
  res@tiXAxisString = "Change in "+SCATTER_X_STAT+" "+SCATTER_X_VARNAME+" (%)"
else
  res@tiXAxisString = "Change in "+SCATTER_X_STAT+" "+SCATTER_X_VARNAME
end if
if SCATTER_Y_PCT_CHANGES then
  res@tiYAxisString = "Change in "+SCATTER_Y_STAT+" "+SCATTER_Y_VARNAME+" (%)"
else
  res@tiYAxisString = "Change in "+SCATTER_Y_STAT+" "+SCATTER_Y_VARNAME
end if
res@trYMaxF=max(dY)
res@trYMinF=min(dY)
res@trXMaxF=max(dX)
res@trXMinF=min(dX)

expt_i=0
res@xyMarker=3 
res@xyMonoMarker = True
res@xyMarkerColor = expts_color(expt_i+1)
if VERBOSE then 
  print(res)
end if
if ALL_EXPTS then
  plot= gsn_csm_xy(wks,dX(ind(.not.isCMIP6),expt_i),dY(ind(.not.isCMIP6),expt_i),res) ; create plot
  do expt_i=1,dimsizes(expts)-2
    res@xyMarkerColor =expts_color(expt_i+1) 
    str=unique_string("oplot")
    plot@$str$= gsn_csm_xy (wks,dX(ind(.not.isCMIP6),expt_i),dY(ind(.not.isCMIP6),expt_i),res)
    overlay(plot,plot@$str$)
  end do
  res@xyMarker=16; choose type of marker
  do expt_i=0,dimsizes(expts)-2
    res@xyMarkerColor =expts_color(expt_i+1) 
    str=unique_string("oplot")
    plot@$str$= gsn_csm_xy (wks,dX(ind(isCMIP6),expt_i),dY(ind(isCMIP6),expt_i),res)
    overlay(plot,plot@$str$)
  end do
else
  plot= gsn_csm_xy(wks,dX(ind(.not.isCMIP6),X_expt_i-1),dY(ind(.not.isCMIP6),Y_expt_i-1),res) ; create plot
  oplot = gsn_csm_xy(wks,dX(ind(isCMIP6),X_expt_i-1),dY(ind(isCMIP6),Y_expt_i-1),res) ; create plot
  overlay(plot,oplot)
end if
draw(plot)
frame(wks)
delete(wks)
system("convert -trim -append "+plotname+" scripts/scatter_key.png "+plotname)
