
load "/home/bridge/swsvalde/ummodel/scripts/new_plots_scripts/ncl_files/my_ncl_code.ncl"
load "/home/bridge/swsvalde/ummodel/scripts/new_plots_scripts/ncl_files/initialise_myncl_variables.ncl"
load "/home/bridge/ea13310/Finland/Scripts/sub_scripts/quaternary_timeseries_functions.ncl"

;======================================================================

vars = (/"omega_mm_p","u_mm_p"/)  ; vq_mm_p. uq_mm_p.  ; "u_mm_p","v_mm_p"
varT = (/"rh_mm_p","temp_mm_p","ht_mm_p"/)
;varT = "ht_mm_p"

out=32000 ; file size yr
endY = 800000 ; For the data files   ;!! I have to identify this to order the files properly!
stY = 0 ; For the data files
seqFils = ispan(endY,stY+out,out)

diri = "/home/bridge/ea13310/Finland/Finland_Files/Spline/"
file_aHt = vars(0)+"_convec_sims_100yrAvg_jja_nativedegRes_noBias_Global" 

open_files = systemfunc("ls " + diri + file_aHt+"*")
cdf_file1 = addfile(open_files(0),"r")
lon = cdf_file1 ->lon
lat = cdf_file1 ->lat
time = cdf_file1 ->time
depth = cdf_file1 ->depth
ilon1=dimsizes(lon)
ilat1=dimsizes(lat)
idepth1= dimsizes(depth) 

data_Ht = new((/dimsizes(vars),2,(dimsizes(open_files)*dimsizes(time))+1,idepth1,ilat1,ilon1/),"float")
data_Ht!4   ="lat"    ; Set metadata for first array
data_Ht!5   = "lon"
data_Ht!3   = "depth"
data_Ht&lat = lat
data_Ht&lon = lon
data_Ht&depth = depth
data_Ht!2  ="time"
data_Ht@_FillValue = -999 

;==========
file_t = varT(0)+"_convec_sims_100yrAvg_jja_nativedegRes_noBias_Global" 

open_files = systemfunc("ls " + diri + file_t+"*")
cdf_file1 = addfile(open_files(0),"r")
lonT = cdf_file1 ->lon
latT = cdf_file1 ->lat
ilonT=dimsizes(lonT)
ilatT=dimsizes(latT)

data_T = new((/dimsizes(varT),2,(dimsizes(open_files)*dimsizes(time))+1,idepth1,ilatT,ilonT/),"float")
data_T!4   ="lat"    ; Set metadata for first array
data_T!5   = "lon"
data_T!3   = "depth"
data_T&lat = latT
data_T&lon = lonT
data_T&depth = depth
data_T!2  ="time"
data_T@_FillValue = -999 

;========================================================================
; Open the Ht atm variables

do f=0, dimsizes(vars)-1
 do i=0, dimsizes(open_files)-1

 print(seqFils(i)+0)

  filen = vars(f)+"_convec_sims_100yrAvg_jja_nativedegRes_noBias_Global"
  fileo = vars(f)+"_convec_sims_noIce_100yrAvg_jja_nativedegRes_noBias_Global"

  fname1 = diri+filen+"_"+seqFils(i)+"_"
  fname2 = systemfunc("ls " + fname1+ "*")

  fname12 = diri+fileo+"_"+seqFils(i)+"_"
  fname22 = systemfunc("ls " + fname12+ "*")

  cdf_file1 = addfile(fname2,"r")
  cdf_file2 = addfile(fname22,"r")
 
if (f.eq.0)
   if (i.eq.dimsizes(open_files)-1)
    data_Ht(f,0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:,:) = cdf_file1->omega_mm_p    ;!!! CHANGE VARIABLE NAME HERE
    data_Ht(f,1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:,:) = cdf_file2->omega_mm_p    ;!!! CHANGE VARIABLE NAME HERE
    else 
     data_Ht(f,0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:,:) = cdf_file1->omega_mm_p    ;!!! CHANGE VARIABLE NAME HERE
     data_Ht(f,1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:,:) = cdf_file2->omega_mm_p   ;!!! CHANGE VARIABLE NAME HERE
   end if

  if (i.eq.0)
   time_seq = cdf_file1 ->time
    else
     time_seq2 := cdf_file1 ->time
     time_seq := array_append_record(time_seq,time_seq2,0)
  end if
end if

if (f.eq.1)
   if (i.eq.dimsizes(open_files)-1)
    data_Ht(f,0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:,:) = cdf_file1->u_mm_p  ;!!! CHANGE VARIABLE NAME HERE
    data_Ht(f,1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:,:) = cdf_file2->u_mm_p  ;!!! CHANGE VARIABLE NAME HERE
    else 
     data_Ht(f,0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:,:) = cdf_file1->u_mm_p    ;!!! CHANGE VARIABLE NAME HERE
     data_Ht(f,1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:,:) = cdf_file2->u_mm_p    ;!!! CHANGE VARIABLE NAME HERE
   end if
end if

;if (f.eq.2)
;   if (i.eq.dimsizes(open_files)-1)
;    data_Ht(f,0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:,:) = cdf_file1->v_mm_p  ;!!! CHANGE VARIABLE NAME HERE
;    data_Ht(f,1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:,:) = cdf_file2->v_mm_p  ;!!! CHANGE VARIABLE NAME HERE
;    else 
;     data_Ht(f,0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:,:) = cdf_file1->v_mm_p    ;!!! CHANGE VARIABLE NAME HERE
;     data_Ht(f,1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:,:) = cdf_file2->v_mm_p    ;!!! CHANGE VARIABLE NAME HERE
;   end if
;end if

end do 
end do

;========

do f=0, dimsizes(varT)-1
 do i=0, dimsizes(open_files)-1

 print(seqFils(i)+0)

  filen = varT(f)+"_convec_sims_100yrAvg_jja_nativedegRes_noBias_Global"
  fileo = varT(f)+"_convec_sims_noIce_100yrAvg_jja_nativedegRes_noBias_Global"

  fname1 = diri+filen+"_"+seqFils(i)+"_"
  fname2 = systemfunc("ls " + fname1+ "*")

  fname12 = diri+fileo+"_"+seqFils(i)+"_"
  fname22 = systemfunc("ls " + fname12+ "*")

  cdf_file1 = addfile(fname2,"r")
  cdf_file2 = addfile(fname22,"r")

if (f.eq.0)
   if (i.eq.dimsizes(open_files)-1)
    data_T(f,0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:,:) = cdf_file1->rh_mm_p  ;!!! CHANGE VARIABLE NAME HERE
    data_T(f,1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:,:) = cdf_file2->rh_mm_p  ;!!! CHANGE VARIABLE NAME HERE
    else 
     data_T(f,0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:,:) = cdf_file1->rh_mm_p    ;!!! CHANGE VARIABLE NAME HERE
     data_T(f,1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:,:) = cdf_file2->rh_mm_p    ;!!! CHANGE VARIABLE NAME HERE
   end if
end if

if (f.eq.1)
   if (i.eq.dimsizes(open_files)-1)
    data_T(f,0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:,:) = cdf_file1->temp_mm_p  ;!!! CHANGE VARIABLE NAME HERE
    data_T(f,1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:,:) = cdf_file2->temp_mm_p  ;!!! CHANGE VARIABLE NAME HERE
    else 
     data_T(f,0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:,:) = cdf_file1->temp_mm_p    ;!!! CHANGE VARIABLE NAME HERE
     data_T(f,1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:,:) = cdf_file2->temp_mm_p    ;!!! CHANGE VARIABLE NAME HERE
   end if
end if

if (f.eq.2)
   if (i.eq.dimsizes(open_files)-1)
    data_T(f,0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:,:) = cdf_file1->ht_mm_p  ;!!! CHANGE VARIABLE NAME HERE
    data_T(f,1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:,:) = cdf_file2->ht_mm_p  ;!!! CHANGE VARIABLE NAME HERE
    else 
     data_T(f,0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:,:) = cdf_file1->ht_mm_p    ;!!! CHANGE VARIABLE NAME HERE
     data_T(f,1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:,:) = cdf_file2->ht_mm_p    ;!!! CHANGE VARIABLE NAME HERE
   end if
end if


end do 
end do

;==============================
; CHANGE UNITS!
; If Specific Humidity

;data_T(0,:,:,:,:,:) = data_T(0,:,:,:,:,:) * 1000 ; Convert kg/kg to g/kg




;==========================================================================================
; Calculate the anomlaies - 

PMINall := ispan(330,350,1)
PMINall := array_append_record(PMINall,ispan(590,610,1),0)
PMINall := array_append_record(PMINall,ispan(1500,1510,1),0)
PMINall := array_append_record(PMINall,ispan(1750,1770,1),0)
PMINall := array_append_record(PMINall,ispan(2650,2680,1),0)
PMINall := array_append_record(PMINall,ispan(3540,3560,1),0)
PMINall := array_append_record(PMINall,ispan(4640,4660,1),0)
PMINall := array_append_record(PMINall,ispan(5560,5580,1),0)
PMINall := array_append_record(PMINall,ispan(6480,6500,1),0)
PMINall := array_append_record(PMINall,ispan(6710,6730,1),0)
PMINall := array_append_record(PMINall,ispan(7130,7150,1),0)
PMINall := array_append_record(PMINall,ispan(7680,7700,1),0)
PMINall = PMINall(::-1)
Glac_PMIN_ind = ind_nearest_coord(PMINall*100,time_seq,0)
alls = Glac_PMIN_ind


data_Ht2 := dim_avg_n(data_Ht(:,:,alls,:,:,:),2)
data_T2 := dim_avg_n(data_T(:,:,alls,:,:,:),2)

; Do the anomlaies now ; (ice - noIce) ; 
data_Ht_anom := data_Ht2(:,0,:,:,:) - data_Ht2(:,1,:,:,:)
data_T_anom := data_T2(:,0,:,:,:) - data_T2(:,1,:,:,:)

data_Ht2!2   ="depth"
data_Ht2!3   ="lat"    ; Set metadata for first array
data_Ht2!4   = "lon"
data_Ht2&lat = lat
data_Ht2&lon = lon
data_Ht2&depth = depth
data_Ht2&depth@units="millibars"
data_Ht2@_FillValue = -999  

data_Ht_anom!1   ="depth"
data_Ht_anom!2   ="lat"    ; Set metadata for first array
data_Ht_anom!3   = "lon"
data_Ht_anom&lat = lat
data_Ht_anom&lon = lon
data_Ht_anom&depth = depth
data_Ht_anom&depth@units="millibars"
data_Ht_anom@_FillValue = -999 

;==
data_T2!2   ="depth"
data_T2!3   ="lat"    ; Set metadata for first array
data_T2!4   = "lon"
data_T2&lat = latT
data_T2&lon = lonT
data_T2&depth = depth
data_T2&depth@units="millibars"
data_T2@_FillValue = -999  

data_T_anom!1   ="depth"
data_T_anom!2   ="lat"    ; Set metadata for first array
data_T_anom!3   = "lon"
data_T_anom&lat = latT
data_T_anom&lon = lonT
data_T_anom&depth = depth
data_T_anom&depth@units="millibars"
data_T_anom@_FillValue = -999 

;============= Isolate the region of interest

data_Ht_10W := dim_avg_n(data_Ht2(:,:,0:11,{-10:40},{-10:15}),4)
data_Ht_anom_10W := dim_avg_n(data_Ht_anom(:,0:11,{-10:40},{-10:15}),3)

data_T_10W := dim_avg_n(data_T2(:,:,0:11,{-10:40},{-10:15}),4)
data_T_anom_10W := dim_avg_n(data_T_anom(:,0:11,{-10:40},{-10:15}),3)

;==============

data_Ht_10W!2   ="depth"
data_Ht_10W!3   ="lat"    ; Set metadata for first array
data_Ht_10W&lat = lat({-10:40})
data_Ht_10W&depth = depth(0:11)
data_Ht_10W&depth@units="millibars"
data_Ht_10W@_FillValue = -999 

data_Ht_anom_10W!1   ="depth"
data_Ht_anom_10W!2   ="lat"    ; Set metadata for first array
data_Ht_anom_10W&lat = lat({-10:40})
data_Ht_anom_10W&depth = depth(0:11)
data_Ht_anom_10W&depth@units="millibars"
data_Ht_anom_10W@_FillValue = -999 


data_T_10W!2   ="depth"
data_T_10W!3   ="lat"    ; Set metadata for first array
data_T_10W&lat = latT({-10:40})
data_T_10W&depth = depth(0:11)
data_T_10W&depth@units="millibars"
data_T_10W@_FillValue = -999 

data_T_anom_10W!1   ="depth"
data_T_anom_10W!2   ="lat"    ; Set metadata for first array
data_T_anom_10W&lat = latT({-10:40})
data_T_anom_10W&depth = depth(0:11)
data_T_anom_10W&depth@units="millibars"
data_T_anom_10W@_FillValue = -999 





;=========================================================================================================;=========================================================================================================
; FOR PLOTTING ALL THE VARIABLES TOGETHER


begin ;
wks   = gsn_open_wks ("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/vert_velo_lat_ht_ALL_Vars_GlacialPMIN_new.pdf")          ; send graphics to PNG file

plot = new (6, graphic)   

res=True
res1=True

contour_list0000:=(/-0.08,-0.06,-0.05,-0.04,-0.03,-0.025,-0.02,-0.015,-0.01,-0.005,0,0.005,0.01,0.015,0.02,0.025,0.03,0.04,0.05,0.06,0.08/)
my_fix_contours(dataNoAHPs_convec10(0,:,:),contour_list0000)
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

   res1@gsnLeftStringFontHeightF   = 0.022
 
  res@gsnRightString   = ""    
  res@gsnLeftString    = ""
  res@gsnCenterString  = ""
  res@gsnContourZeroLineThicknessF = 2.     ; doubles thickness of zero contour
  res@gsnContourNegLineDashPattern = 1         ; sets negative contours to dash pattern 1
  res@cnLineColor  = "black"  
  res@cnLevelSelectionMode = "ManualLevels"  ; manually set the contour levels with the following 3 resources
 
  res@cnMinLevelValF  = -24.        ; set the minimum contour level
  res@cnMaxLevelValF  = 24.         ; set the maximum contour level
  res@cnLevelSpacingF = 2.       

res1@gsnLeftString = "JJA AHP_All Vert. Velo. & Zonal Wind(-10W:20E; m/s)"
 plotA = gsn_csm_pres_hgt(wks,data_Ht_10W(0,0,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,data_Ht_10W(1,0,:,:),res)
 overlay(plotA,plotB)                      
 plot(0) = plotA         


res1@gsnLeftString = "JJA Orb_GHG Vert. Velo. & Zonal Wind(-10W:20E; m/s)"
 plotC = gsn_csm_pres_hgt(wks,data_Ht_10W(0,1,:,:),res1)
 plotD = gsn_csm_pres_hgt(wks,data_Ht_10W(1,1,:,:),res)
 overlay(plotC,plotD)                      
 plot(1) = plotC        

;====
contour_list0000:=(/-80,-70,-60,-50,-40,-30,-20,-10,-5,0,5,10,20,30,40,50,60,70,80/)
my_fix_contours(dataNoAHPs_convec10T(1,:,:),contour_list0000)
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

  res@cnLevelSelectionMode = "ManualLevels"  ; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = 0        ; set the minimum contour level
  res@cnMaxLevelValF  = 16600         ; set the maximum contour level
  res@cnLevelSpacingF = 2000        
res1@gsnLeftString = "JJA AHP_All Temp(C), Geo.Pot.Ht(m) & Rel. Humid(%)(-10W:20E)"
 plotA = gsn_csm_pres_hgt(wks,data_T_10W(1,0,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,data_T_10W(2,0,:,:),res)
 overlay(plotA,plotB)  
 res@cnLineColor  = "seagreen"  
  res@cnMinLevelValF  = 0.        ; set the minimum contour level
  res@cnMaxLevelValF  = 100.         ; set the maximum contour level
  res@cnLevelSpacingF = 10               
 plotC = gsn_csm_pres_hgt(wks,data_T_10W(0,0,:,:),res)
 overlay(plotA,plotC)  
 plot(3) = plotA                           

 res@cnLineColor  = "black" 
  res@cnMinLevelValF  = 0        ; set the minimum contour level
  res@cnMaxLevelValF  = 16600         ; set the maximum contour level
  res@cnLevelSpacingF = 2000   

res1@gsnLeftString = "JJA Orb_GHG Temp(C), Geo.Pot.Ht(m) & Rel. Humid(%)(-10W:20E)"
 plotD = gsn_csm_pres_hgt(wks,data_T_10W(1,1,:,:),res1)
 plotE = gsn_csm_pres_hgt(wks,data_T_10W(2,1,:,:),res)
 overlay(plotD,plotE)  
  res@cnLineColor  = "seagreen"                      
   res@cnMinLevelValF  = 0.        ; set the minimum contour level
  res@cnMaxLevelValF  = 100.         ; set the maximum contour level
  res@cnLevelSpacingF = 10
  plotF = gsn_csm_pres_hgt(wks,data_T_10W(0,1,:,:),res)
overlay(plotD,plotF)       

 plot(4) = plotD      




;====================================================================
contour_list0000:=(/-0.03,-0.025,-0.02,-0.0175,-0.015,-0.0125,-0.01,-0.0075,-0.005,-0.0025,0,0.0025,0.005,0.0075,0.01,0.0125,0.015,0.0175,0.02,0.025,0.03/)
my_fix_contours(anom_convec10(0,:,:),contour_list0000)
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

 res@cnLineColor  = "black" 
  res@cnMinLevelValF  = -14.        ; set the minimum contour level
  res@cnMaxLevelValF  = 14.         ; set the maximum contour level
  res@cnLevelSpacingF = 2.    
res1@gsnLeftString = "JJA Vert. Velo. Anomaly (m/s, AHP_All-Orb_GHG)"
plotI = gsn_csm_pres_hgt(wks,data_Ht_anom_10W(0,:,:),res1)
;plotJ = gsn_csm_pres_hgt(wks,anom_convec10(1,:,:),res)
; overlay(plotI,plotJ)                      
 plot(2) = plotI  



contour_list0000:=(/-5,-4,-3,-2.5,-2,-1.5,-1,-0.5,-0.25,0,0.25,0.5,1,1.5,2,2.5,3,4,5/)
my_fix_contours(anom_convec10T(1,:,:),contour_list0000)
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


res@cnMinLevelValF  = -60         ; set the minimum contour level
  res@cnMaxLevelValF  = 60       ; set the maximum contour level
  res@cnLevelSpacingF = 10 
res1@gsnLeftString = "JJA Temp(C), Geo.Pot.Ht(m) & Rel. Humid(%) Anom"
plotI = gsn_csm_pres_hgt(wks,data_T_anom_10W(1,:,:),res1)
plotJ = gsn_csm_pres_hgt(wks,data_T_anom_10W(2,:,:),res)
 overlay(plotI,plotJ)    

  res@cnLineColor  = "seagreen"   
  res@cnMinLevelValF  = -24.         ; set the minimum contour level
  res@cnMaxLevelValF  = 4.       ; set the maximum contour level
  res@cnLevelSpacingF = 2  
plotK = gsn_csm_pres_hgt(wks,data_T_anom_10W(0,:,:),res)
 overlay(plotI,plotK)   

 plot(5) = plotI  



;====
gsn_panel(wks,plot,(/2,3/),False)

delete(res1)
delete(res)
end



