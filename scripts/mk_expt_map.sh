#!/bin/bash

#define the dependent variable
export SCATTER_X_VARNAME=
export SCATTER_X_STAT= #(/"mean","stddev","skew","kurtosis","pcvar"/)
export SCATTER_X_ABS= # determines whether to set ts_opt@make_absolute=True
export SCATTER_X_SEASON= # determines which season to compute (for monthly timeseries)
export SCATTER_X_PCT_CHANGES= #if True, the scatterplots present the changes as percentages.
export SCATTER_X_EXPT= #select a particular experiment. Setting "all" or "missing" selects all experiments

#define the independent variable
export SCATTER_Y_VARNAME=
export SCATTER_Y_STAT= # (/"mean","stddev","skew","kurtosis","pcvar"/)
export SCATTER_Y_ABS= # determines whether to set ts_opt@make_absolute=True
export SCATTER_Y_SEASON= #determines which season to compute (for monthly timeseries)
export SCATTER_Y_PCT_CHANGES= #if True, the scatterplots present the changes as percentages.
export SCATTER_Y_EXPT= #select a particular experiment. Setting "all" or "missing" selects all experiments

#Some error help
export VERBOSE=
export FIND_FILES_QUIET=

ncl -n PMIP4/plot_scatter.ncl
