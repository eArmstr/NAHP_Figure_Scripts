# NAHP_Figure_Scripts

This repository holds the scripts that are used to produce the Figures for the Nature Communications manuscript : North African Humid Periods over the past 800000 years.

The scripts require pre-processing of the climate data so that the relevant variable from each of the snapshot simulations are splined to a 100-year timestep using the NCL 
ftcurv function. In some cases the data is then bi-linearly interpolated to 1 degree resolution. The relevant climate variables can be accessed as NetCDF files as outlined 
in the Data availability statement in the manuscript.
