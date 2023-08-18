; The compares modelled African preicpiation and ERA5 reanalysis data - This does both spatial precip/wind pattern and lat/ht plots
; This makes the lat/ht comparison plots for ERA5 and model data

load "/home/bridge/swsvalde/ummodel/scripts/new_plots_scripts/ncl_files/my_ncl_code.ncl"
load "/home/bridge/swsvalde/ummodel/scripts/new_plots_scripts/ncl_files/initialise_myncl_variables.ncl"
load "/home/bridge/ea13310/Finland/Scripts/sub_scripts/quaternary_timeseries_functions.ncl"

;======================================================================

; Open DJF/JJA files for PI simulation from list, open precip and u/v compononents

cdf_file1 = addfile("/home/bridge/ea13310/ummodel/data/tevta1/climate/tevta1a.pdcldjf.nc","r")
lon = cdf_file1 ->longitude
lat = cdf_file1 ->latitude
lonW = cdf_file1 ->longitude_1
latW = cdf_file1 ->latitude_1

ilon1=dimsizes(lon)
ilat1=dimsizes(lat) 
ilonW=dimsizes(lonW)
ilatW=dimsizes(latW) 

cdf_file2 = addfile("/home/bridge/ea13310/ummodel/data/tevta1/climate/tevta1a.pdcljja.nc","r")

data := new((/2,ilat1,ilon1/),"float")
data!1   ="lat"    ; Set metadata for first array
data!2   = "lon"
data&lat = lat
data&lon = lon
data@_FillValue = -999  

dataW := new((/2,2,ilatW,ilonW/),"float")
dataW!2   ="lat"    ; Set metadata for first array
dataW!3   = "lon"
dataW&lat = latW
dataW&lon = lonW
dataW@_FillValue = -999  

 data(0,:,:) = cdf_file1->precip_mm_srf(0,0,:,:)    
 data(1,:,:) = cdf_file2->precip_mm_srf(0,0,:,:)  

 data = data*86400

 dataW(0,0,:,:) = cdf_file1->u_mm_10m  
 dataW(0,1,:,:) = cdf_file1->v_mm_10m  

 dataW(1,0,:,:) = cdf_file2->u_mm_10m  
 dataW(1,1,:,:) = cdf_file2->v_mm_10m  

;======================================================================
Now open simulated 1deg CRU data

cdf_file1 = addfile("/home/bridge/ea13310/Finland/Finland_Files/Spline/precip_mm_srf_convec_sims_100yrAvg_djf_1degRes_noBias_Global_32000_0kyr.nc","r")
lonM = cdf_file1 ->lon
latM = cdf_file1 ->lat

tim = cdf_file1 ->tim

ilonM1=dimsizes(lonM)
ilatM1=dimsizes(latM) 

cdf_file2 = addfile("/home/bridge/ea13310/Finland/Finland_Files/Spline/precip_mm_srf_convec_sims_100yrAvg_ann_1degRes_noBias_Global_32000_0kyr.nc","r")

cdf_file3 = addfile("/home/bridge/ea13310/Finland/Finland_Files/Spline/u_mm_10m_convec_sims_100yrAvg_djf_1degRes_noBias_Global_32000_0kyr.nc","r")
cdf_file4 = addfile("/home/bridge/ea13310/Finland/Finland_Files/Spline/u_mm_10m_convec_sims_100yrAvg_jja_1degRes_noBias_Global_32000_0kyr.nc","r")

cdf_file5 = addfile("/home/bridge/ea13310/Finland/Finland_Files/Spline/v_mm_10m_convec_sims_100yrAvg_djf_1degRes_noBias_Global_32000_0kyr.nc","r")
cdf_file6 = addfile("/home/bridge/ea13310/Finland/Finland_Files/Spline/v_mm_10m_convec_sims_100yrAvg_jja_1degRes_noBias_Global_32000_0kyr.nc","r")


dataM = new((/2,3,ilatM1,ilonM1/),"float")
dataM!2   ="lat"    ; Set metadata for first array
dataM!3   = "lon"
dataM&lat = latM
dataM&lon = lonM
dataM@_FillValue = -999  

 tmp = cdf_file1->precip_mm_srf
 dataM(0,0,:,:) = tmp(321-1,:,:)    
 tmp = cdf_file2->precip_mm_srf
 dataM(1,0,:,:) = tmp(321-1,:,:) 
 
 tmp = cdf_file3->u_mm_10m  
 dataM(0,1,:,:) = tmp(321-1,:,:)
 tmp = cdf_file4->u_mm_10m  
 dataM(1,1,:,:) = tmp(321-1,:,:)

 tmp = cdf_file5->v_mm_10m  
 dataM(0,2,:,:) = tmp(321-1,:,:)
 tmp = cdf_file6->v_mm_10m  
 dataM(1,2,:,:) = tmp(321-1,:,:)


;======================================================================
;Now open ERA5 reanalysis data ; Covers 1959-2020

cdf_file = addfile("/home/bridge/ea13310/Finland/Finland_Files/ERA_data.nc","r")
lonE = cdf_file ->g0_lon_2
latE = cdf_file ->g0_lat_1
ilonE=dimsizes(lonE)
ilatE=dimsizes(latE) 

dataE := new((/2,3,ilatE,ilonE/),"float")
dataE!2   ="lat"    ; Set metadata for first array
dataE!3   = "lon"
dataE&lat = latE
dataE&lon = lonE
dataE@_FillValue = -999  

precip_m = cdf_file->TP_GDS0_SFC_S130

tmpE := new((/2,60,ilatE,ilonE/),"float")
; Extract the JJA months 
do o=0,708,12 ; 
;print(o/12+0)
 tmpE(0,o/12,:,:) = dim_avg_n(precip_m(o+11:o+13,:,:),0) ; DJF
 ;tmpE(1,o/12,:,:) = dim_avg_n(precip_m(o+5:o+7,:,:),0). ; JJA
  tmpE(1,o/12,:,:) = dim_avg_n(precip_m(o+5:o+7,:,:),0). ; JJA
end do

 dataE(:,0,:,:) = dim_avg_n(tmpE,1)
 dataE(:,0,:,:) = dataE(:,0,:,:) * 1000

;===
precip_m = cdf_file->10U_GDS0_SFC_S123
do o=0,708,12 ; start at june of each yr
;print(o/12+0)
 tmpE(0,o/12,:,:) = dim_avg_n(precip_m(o+11:o+13,:,:),0) ; Extract the DJF months 
 tmpE(1,o/12,:,:) = dim_avg_n(precip_m(o+5:o+7,:,:),0) ; Extract the JJA months 
end do

 dataE(:,1,:,:) = dim_avg_n(tmpE,1)

;===
precip_m = cdf_file->10V_GDS0_SFC_S123
do o=0,708,12 ; start at june of each yr
;print(o/12+0)
 tmpE(0,o/12,:,:) = dim_avg_n(precip_m(o+11:o+13,:,:),0) ; Extract the DJF months 
 tmpE(1,o/12,:,:) = dim_avg_n(precip_m(o+5:o+7,:,:),0) ; Extract the JJA months 
end do

 dataE(:,2,:,:) = dim_avg_n(tmpE,1)

;======================================================================
; PLOTTING 

begin

wks = gsn_open_wks("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/ERA5_precip_wind_comparisonNEW.pdf")  
plot := new (4, graphic)   

res1=True
contour_list0000:=(/0,0.1,0.2,0.3,0.4,0.6,0.8,1,1.2,1.4,1.6,1.8,2,2.4,2.8,3.2,3.6,4,4.5,5,6,8,10/)
my_fix_contours(dataM,contour_list0000)
colormap_orig0000=(/"(/0.56,0.17,0.93/)","(/0,0,0.93/)","(/0.52,0.80,0.92/)","(/1,1,1/)"/)
colormap_orig0000=colormap_orig0000(::-1)
colormap_revised0000=my_StretchColorMap(colormap_orig0000,contour_list0000)
delete(colormap_orig0000)
my_updateColors1a(colormap_revised0000,contour_list0000,"zero","Gray91","-1","Gray91")
res1@gsnSpreadColors = False
ColorMap0000:=colormap_revised0000
delete(colormap_revised0000)

res1@gsnDraw                = False              ; dont draw
res1@gsnFrame               = False              ; dont advance frame

;res1@gsnMaximize       = True
 res1@cnLinesOn = False
 res1@cnMonoFillPattern     = True
 res1@cnMonoFillColor       = False
 res1@cnLineLabelsOn        = False
 res1@cnInfoLabelOn         = False
 res1@cnFillOn = True
 res1@cnFillMode="CellFill"
 res1@cnConstFLabelOn=False
 res1@cnLevelSelectionMode = "ExplicitLevels"
 res1@cnLevels:=contour_list0000
 res1@cnFillPalette:=ColorMap0000
 ;res1@cnMissingValFillPattern="SolidFill"
 ;res1@cnMissingValFillColor="Gray61"
 res1@mpOutlineOn            = True      ; 
 res1@gsnAddCyclic = True

 res1@mpMinLatF =  -40
 res1@mpMaxLatF = 60
 res1@mpMinLonF = -40
 res1@mpMaxLonF = 80

 res1@mpGeophysicalLineColor="Black"
 ;res1@mpFillOn = False
 res1@mpPerimOn         = True

 res1@mpGeophysicalLineColor="Black"
 res1@mpFillOn = False
 res1@mpPerimOn         = True
 res1@mpOutlineDrawOrder    = "PostDraw"

res1@gsnScalarContour = True
res1@vcRefAnnoOrthogonalPosF  = -0.97; -1.01            ; move ref vector up
res1@vcRefAnnoParallelPosF    = 0.10 ;1.01
res1@vcRefMagnitudeF          = 0.5            ; define vector ref mag
res1@vcRefLengthF             = 0.02            ; define length of vec ref
res1@vcRefAnnoFontHeightF     = 0.02
res1@vcGlyphStyle             = "CurlyVector"   ; "LineArrow","FillArrow","WindBarb","CurlyVector"

res1@vcFillArrowEdgeColor     = "black" ;"gray15" ;"gray35"
res1@vcFillArrowFillColor     = "black" ;"gray15" ;"gray35"
res1@vcLineArrowThicknessF    = 0.8
res1@vcLineArrowHeadMinSizeF  = 0.012
res1@vcLineArrowHeadMaxSizeF  = 0.015
res1@vcLineArrowColor         = "black" ;"gray15" ;"gray35"

res1@vcMinDistanceF           = 0.015 ;0.018 ;0.0175 or 0.025
res1@vcRefAnnoString2On       = False

;=====
; res1@gsnLeftString = "Model DJF Native Res."
; plot(0) = gsn_csm_vector_scalar_map(wks,dataW(0,0,:,:),dataW(0,1,:,:),data(0,:,:),res1)

; res1@gsnLeftString = "Model JJA Native Res."
; plot(1) = gsn_csm_vector_scalar_map(wks,dataW(1,0,:,:),dataW(1,1,:,:) ,data(1,:,:),res1)

;=====
res1@vcMinDistanceF           = 0.022
res1@vcLineArrowThicknessF    = 0.7
 res1@gsnLeftString = "Model DJF Precip (mm/day) & Wind (m/s)"
 plot(0) = gsn_csm_vector_scalar_map(wks,dataM(0,1,:,:),dataM(0,2,:,:),dataM(0,0,:,:),res1)

 res1@gsnLeftString = "Model JJA Precip (mm/day) & Wins (m/s)"
 plot(1) = gsn_csm_vector_scalar_map(wks,dataM(1,1,:,:),dataM(1,2,:,:),dataM(1,0,:,:),res1)

dataM(1,0,:,:)

;=====
res1@vcMinDistanceF           = 0.027

 res1@gsnLeftString = "ERA 5 DJF Precip (mm/day) & Wind (m/s)"
 plot(2) = gsn_csm_vector_scalar_map(wks,dataE(0,1,:,:),dataE(0,2,:,:),dataE(0,0,:,:),res1)

 res1@gsnLeftString = "ERA 5 JJA Precip (mm/day) & Wind (m/s)"
 plot(3) = gsn_csm_vector_scalar_map(wks,dataE(1,1,:,:),dataE(1,2,:,:),dataE(1,0,:,:),res1)


gsn_panel(wks,plot,(/2,2/),False)


delete(res1)
end

;======================================================================;======================================================================
;======================================================================;======================================================================

rad    = 4.0*atan(1.0)/180.0
clat_t=cos(latM*rad)
clat_t!0   ="lat"
clat_t&lat = latM

mav = wgt_areaave(dataM(1,0,{22:32},{-15:35}),clat_t({20:30}),1.0,0) 


clat_t2=cos(latE*rad)
clat_t2!0   ="lat"
clat_t2&lat = latE

gtmp = lonFlip(dataE(1,0,:,:))
oav = wgt_areaave(gtmp({22:32},{-15:35}),clat_t2({20:30}),1.0,0) 

print(mav - oav)

;======================================================================

; Open DJF/JJA files for PI simulation from list, open uplift and u/v compononents

cdf_file1 = addfile("/home/bridge/ea13310/ummodel/data/tevta1/climate/tevta1a.pccldjf.nc","r")
lon = cdf_file1 ->longitude
lat = cdf_file1 ->latitude
lonW = cdf_file1 ->longitude_1
latW = cdf_file1 ->latitude_1
depth = cdf_file1 ->p

ilon1=dimsizes(lon)
ilat1=dimsizes(lat) 
ilonW=dimsizes(lonW)
ilatW=dimsizes(latW) 
idepth=dimsizes(depth)

cdf_file2 = addfile("/home/bridge/ea13310/ummodel/data/tevta1/climate/tevta1a.pccljja.nc","r")

data := new((/2,3,idepth,ilat1,ilon1/),"float")  ; season, var(omega,u,v) ...
data!3   ="lat"    ; Set metadata for first array
data!4   = "lon"
data&lat = lat
data&lon = lon
data!2   = "depth"
data&depth = depth
data@_FillValue = -999  
data&depth@units="millibars"

 data(0,0,:,:,:) = ((/cdf_file1->omega_mm_p(0,:,:,:)/))    
 data(1,0,:,:,:) = ((/cdf_file2->omega_mm_p(0,:,:,:)/)) 

 data(0,1,:,:,:) = ((/cdf_file1->u_mm_p(0,:,:,:)/))    
 data(0,2,:,:,:) = ((/cdf_file1->v_mm_p(0,:,:,:)/))    

 data(1,1,:,:,:) = ((/cdf_file2->u_mm_p(0,:,:,:)/))    
 data(1,2,:,:,:) = ((/cdf_file2->v_mm_p(0,:,:,:)/))  

data10 = dim_avg_n_Wrap(data(:,:,0:11,{-10:40},{-10:10}),4)

data30 = dim_avg_n_Wrap(data(:,:,0:11,{-10:40},{10:30}),4)
data10&depth@units="millibars"
data30&depth@units="millibars"

;======================================================================
;Now open ERA5 reanalysis data ; Covers 1959-2020

cdf_file = addfile("/home/bridge/ea13310/Finland/Finland_Files/ERA_data_pressure_lev.nc","r")
lonE = cdf_file ->g0_lon_3
latE = cdf_file ->g0_lat_2
depthE = cdf_file ->lv_ISBL1
ilonE=dimsizes(lonE)
ilatE=dimsizes(latE) 
idepthE=dimsizes(depthE) 

dataE := new((/2,3,idepthE,ilatE,ilonE/),"float")
dataE!3   ="lat"    ; Set metadata for first array
dataE!4   = "lon"
dataE&lat = latE
dataE&lon = lonE
dataE!2   = "depth"
dataE&depth = depthE
dataE@_FillValue = -999  
dataE&depth@units="millibars"

velo_m = cdf_file->W_GDS0_ISBL_S123

tmpE := new((/2,40,idepthE,ilatE,ilonE/),"float")
; Extract the  months 
do o=0,234,6 ; 
print(o/6+0)
 tmpE(0,o/6,:,:,:) = dim_avg_n(velo_m(o+5:o+7,:,:,:),0)
 tmpE(1,o/6,:,:,:) = dim_avg_n(velo_m(o+2:o+4,:,:,:),0)
end do

 dataE(:,0,:,:,:) = dim_avg_n(tmpE,1)

;===
velo_m = cdf_file->U_GDS0_ISBL_S123
do o=0,234,6 ; 
print(o/6+0)
 tmpE(0,o/6,:,:,:) = dim_avg_n(velo_m(o+5:o+7,:,:,:),0)
 tmpE(1,o/6,:,:,:) = dim_avg_n(velo_m(o+2:o+4,:,:,:),0)
end do

 dataE(:,1,:,:,:) = dim_avg_n(tmpE,1)

;===
velo_m = cdf_file->V_GDS0_ISBL_S123
do o=0,234,6 ; 
print(o/6+0)
 tmpE(0,o/6,:,:,:) = dim_avg_n(velo_m(o+5:o+7,:,:,:),0)
 tmpE(1,o/6,:,:,:) = dim_avg_n(velo_m(o+2:o+4,:,:,:),0)
end do

 dataE(:,2,:,:,:) = dim_avg_n(tmpE,1)

 ; Flip the depth
 dataE = dataE(:,:,::-1,:,:)

dataE10 = dim_avg_n_Wrap(dataE(:,:,0:11,:,:),4)
dataE30 = dim_avg_n_Wrap(dataE(:,:,0:11,:,:),4)
dataE10&depth@units="millibars"
dataE30&depth@units="millibars"
;===================================================================================================================================
begin
wks   = gsn_open_wks ("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/vert_zonal_ERA5_model_lat_ht.pdf")          ; send graphics to PNG file

plot = new (8, graphic)   

res=True
res1=True

contour_list0000:=(/-0.08,-0.06,-0.05,-0.04,-0.03,-0.025,-0.02,-0.015,-0.01,-0.005,0,0.005,0.01,0.015,0.02,0.025,0.03,0.04,0.05,0.06,0.08/)
my_fix_contours(data10,contour_list0000)
colormap_orig0000=(/"(/0.56,0.17,0.93/)","(/0,0,0.93/)","(/0.52,0.80,0.92/)","(/1,1,1/)","(/1,0.64,0/)","(/0.93,0,0/)","(/1,0.08,0.58/)"/)
;colormap_orig0000=colormap_orig0000(::-1) 
colormap_revised0000=my_StretchColorMap(colormap_orig0000,contour_list0000)
delete(colormap_orig0000)
my_updateColors1a(colormap_revised0000,contour_list0000,"zero","Gray91","-1","Gray91")
res1@gsnSpreadColors = False
ColorMap0000:=colormap_revised0000
delete(colormap_revised0000)

res1@gsnDraw                = False              ; dont draw
res1@gsnFrame               = False 
res@gsnDraw                = False              ; dont draw
res@gsnFrame               = False              ; dont advance frame

;res1@gsnMaximize       = True
 res1@cnLinesOn = False
 res1@cnMonoFillPattern     = True
 res1@cnMonoFillColor       = False
 res1@cnLineLabelsOn        = False
 res1@cnInfoLabelOn         = False
 res1@cnFillOn = True
 res1@cnFillMode="CellFill"
 res1@cnConstFLabelOn=False
 res1@cnLevelSelectionMode = "ExplicitLevels"
 res1@cnLevels:=contour_list0000
 res1@cnFillPalette:=ColorMap0000

  res1@vpWidthF = 0.8
 res1@vpHeightF = 0.4
   res@vpWidthF = 0.8
 res@vpHeightF = 0.4
 
  res@gsnRightString   = ""    
  res@gsnLeftString    = ""
  res@gsnCenterString  = ""
  res@gsnContourZeroLineThicknessF = 2.     ; doubles thickness of zero contour
  res@gsnContourNegLineDashPattern = 1         ; sets negative contours to dash pattern 1
  res@cnLineColor  = "black"  
  res@cnLevelSelectionMode = "ManualLevels"  ; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -24.        ; set the minimum contour level
  res@cnMaxLevelValF  = 24.         ; set the maximum contour level
  res@cnLevelSpacingF = 3.       

res1@gsnLeftString = "Model DJF Vert Velo & Zonal (-10W:10E; m/s)"
 plotA = gsn_csm_pres_hgt(wks,data10(0,0,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,data10(0,1,:,:),res)
 overlay(plotA,plotB)                      
 plot(0) = plotA                           

res1@gsnLeftString = "Model JJA Vert Velo & Zonal (-10W:10E) noIce"
 plotC = gsn_csm_pres_hgt(wks,data10(1,0,:,:),res1)
 plotD = gsn_csm_pres_hgt(wks,data10(1,1,:,:),res)
 overlay(plotC,plotD)                      
 plot(1) = plotC        

res1@gsnLeftString = "Model DJF Vert Velo & Zonal (10E:30E) "
 plotE = gsn_csm_pres_hgt(wks,data30(0,0,:,:),res1)
 plotF = gsn_csm_pres_hgt(wks,data30(0,1,:,:),res)
 overlay(plotE,plotF)                      
 plot(2) = plotE    

res1@gsnLeftString = "Model JJA Vert Velo & Zonal(10E:30E)"
 plotG = gsn_csm_pres_hgt(wks,data30(1,0,:,:),res1)
 plotH = gsn_csm_pres_hgt(wks,data30(1,1,:,:),res)
 overlay(plotG,plotH)                      
 plot(3) = plotG  



res1@gsnLeftString = "ERA5 DJF Vert Velo & Zonal (-10W:10E)"
 plotI = gsn_csm_pres_hgt(wks,dataE10(0,0,:,:),res1)
 plotJ = gsn_csm_pres_hgt(wks,dataE10(0,1,:,:),res)
 overlay(plotI,plotJ)                      
 plot(4) = plotI                           

res1@gsnLeftString = "ERA5 JJA Vert Velo & Zonal (-10W:10E)"
 plotK = gsn_csm_pres_hgt(wks,dataE10(1,0,:,:),res1)
 plotL = gsn_csm_pres_hgt(wks,dataE10(1,1,:,:),res)
 overlay(plotK,plotL)                      
 plot(5) = plotK        

res1@gsnLeftString = "ERA5 DJF Vert Velo & Zonal (10E:30E)"
 plotM = gsn_csm_pres_hgt(wks,dataE30(0,0,:,:),res1)
 plotN = gsn_csm_pres_hgt(wks,dataE30(0,1,:,:),res)
 overlay(plotM,plotN)                      
 plot(6) = plotM    

res1@gsnLeftString = "ERA5 JJA Vert Velo & Zonal (10E:30E)"
 plotO = gsn_csm_pres_hgt(wks,dataE30(1,0,:,:),res1)
 plotP = gsn_csm_pres_hgt(wks,dataE30(1,1,:,:),res)
 overlay(plotO,plotP)                      
 plot(7) = plotO  


;====
gsn_panel(wks,plot,(/4,2/),False)

delete(res1)
end







;====
contour_list0000:=(/-0.03,-0.025,-0.02,-0.0175,-0.015,-0.0125,-0.01,-0.0075,-0.005,-0.0025,0,0.0025,0.005,0.0075,0.01,0.0125,0.015,0.0175,0.02,0.025,0.03/)
my_fix_contours(data_Ht_anom_10W(0,:,:),contour_list0000)
colormap_orig0000=(/"(/0.56,0.17,0.93/)","(/0,0,0.93/)","(/0.52,0.80,0.92/)","(/1,1,1/)","(/1,0.64,0/)","(/0.93,0,0/)","(/1,0.08,0.58/)"/)
;colormap_orig0000=colormap_orig0000(::-1)
colormap_revised0000=my_StretchColorMap(colormap_orig0000,contour_list0000)
delete(colormap_orig0000)
my_updateColors1a(colormap_revised0000,contour_list0000,"zero","Gray91","-1","Gray91")
res1@gsnSpreadColors = False
ColorMap0000:=colormap_revised0000
delete(colormap_revised0000)
res1@cnLevels:=contour_list0000
res1@cnFillPalette:=ColorMap0000

;===

res1@gsnLeftString = "Vert Velo Anom (Ice-noIce)"
plotI = gsn_csm_pres_hgt(wks,data_Ht_anom_10W(0,:,:),res1)
plotJ = gsn_csm_pres_hgt(wks,data_Ht_anom_10W(1,:,:),res)
 overlay(plotI,plotJ)                      
 plot(2) = plotI  

res1@gsnLeftString = "Vert Velo Anom (Ice-noIce)"
plotK = gsn_csm_pres_hgt(wks,data_Ht_anom_30E(0,:,:),res1)
plotL = gsn_csm_pres_hgt(wks,data_Ht_anom_30E(1,:,:),res)
 overlay(plotK,plotL)                      
 plot(5) = plotK  




