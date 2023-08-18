; THIS makes the latitude/Ht part of Figure 2


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


;==============================;==============================;==============================
; Calculate the anomlaies - THIS IS AHPS VS NOAHPS METHODS

ahp = asciiread("/home/bridge/ea13310/Finland/Data/ahp.txt" ,-1, "integer")
noAHPS = asciiread("/home/bridge/ea13310/Finland/Data/noAHPS.txt",-1, "integer")
PMAX = asciiread("/home/bridge/ea13310/Finland/Data/PMAX.txt",-1, "integer")

   dataAHPs_convec := dim_avg_n(data_Ht(:,0,ahp,:,:,:),1)    
   dataAHPs_convec!1   ="depth"
   dataAHPs_convec!2   ="lat"    ; Set metadata for first array
   dataAHPs_convec!3   = "lon"
   dataAHPs_convec&lat = lat
   dataAHPs_convec&lon = lon
   dataAHPs_convec&depth = depth
   dataAHPs_convec@_FillValue = -999 
   dataAHPs_convec&depth@units="millibars"

   dataNoAHPs_convec := dim_avg_n(data_Ht(:,0,PMAX,:,:,:),1)     ; Average for AHPs for convec sim
   dataNoAHPs_convec!1   ="depth"
   dataNoAHPs_convec!2   ="lat"    ; Set metadata for first array
   dataNoAHPs_convec!3   = "lon"
   dataNoAHPs_convec&lat = lat
   dataNoAHPs_convec&lon = lon
   dataNoAHPs_convec&depth = depth
   dataNoAHPs_convec@_FillValue = -999 
   dataNoAHPs_convec&depth@units="millibars"

   anom_convec := dataAHPs_convec - dataNoAHPs_convec
   anom_convec!1   ="depth"
   anom_convec!2   ="lat"    ; Set metadata for first array
   anom_convec!3   = "lon"
   anom_convec&lat = lat
   anom_convec&lon = lon
   anom_convec&depth = depth
   anom_convec@_FillValue = -999 
   anom_convec&depth@units="millibars"

dataAHPs_convec10 := dim_avg_n_Wrap(dataAHPs_convec(:,0:11,{-10:40},{-10:15}),3)
dataNoAHPs_convec10 := dim_avg_n_Wrap(dataNoAHPs_convec(:,0:11,{-10:40},{-10:15}),3)
anom_convec10 := dim_avg_n_Wrap(anom_convec(:,0:11,{-10:40},{-10:15}),3)



   dataAHPs_convecT := dim_avg_n(data_T(:,0,ahp,:,:,:),1)    
   dataAHPs_convecT!1   ="depth"
   dataAHPs_convecT!2   ="lat"    ; Set metadata for first array
   dataAHPs_convecT!3   = "lon"
   dataAHPs_convecT&lat = latT
   dataAHPs_convecT&lon = lon
   dataAHPs_convecT&depth = depth
   dataAHPs_convecT@_FillValue = -999 
   dataAHPs_convecT&depth@units="millibars"

   dataNoAHPs_convecT := dim_avg_n(data_T(:,0,PMAX,:,:,:),1)     ; Average for AHPs for convec sim
   dataNoAHPs_convecT!1   ="depth"
   dataNoAHPs_convecT!2   ="lat"    ; Set metadata for first array
   dataNoAHPs_convecT!3   = "lon"
   dataNoAHPs_convecT&lat = latT
   dataNoAHPs_convecT&lon = lon
   dataNoAHPs_convecT&depth = depth
   dataNoAHPs_convecT@_FillValue = -999 
   dataNoAHPs_convecT&depth@units="millibars"

   anom_convecT := dataAHPs_convecT - dataNoAHPs_convecT
   anom_convecT!1   ="depth"
   anom_convecT!2   ="lat"    ; Set metadata for first array
   anom_convecT!3   = "lon"
   anom_convecT&lat = latT
   anom_convecT&lon = lon
   anom_convecT&depth = depth
   anom_convecT@_FillValue = -999 
   anom_convecT&depth@units="millibars"

dataAHPs_convec10T := dim_avg_n_Wrap(dataAHPs_convecT(:,0:11,{-10:40},{-10:15}),3)
dataNoAHPs_convec10T := dim_avg_n_Wrap(dataNoAHPs_convecT(:,0:11,{-10:40},{-10:15}),3)
anom_convec10T := dim_avg_n_Wrap(anom_convecT(:,0:11,{-10:40},{-10:15}),3)



;=========================================================================================================;=========================================================================================================
; FOR PLOTTING ALL THE VARIABLES TOGETHER


begin
wks   = gsn_open_wks ("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/vert_velo_lat_ht_ALL_Vars_PMAX_new.pdf")          ; send graphics to PNG file

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

res1@gsnLeftString = "JJA PMax Vert. Velo. & Zonal Wind (-10W:20E; m/s)"
 plotA = gsn_csm_pres_hgt(wks,dataNoAHPs_convec10(0,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,dataNoAHPs_convec10(1,:,:),res)
 overlay(plotA,plotB)                      
 plot(0) = plotA                           

res1@gsnLeftString = "JJA NAHP Vert. Velo. & Zonal Wind (-10W:20E; m/s)"
 plotC = gsn_csm_pres_hgt(wks,dataAHPs_convec10(0,:,:),res1)
 plotD = gsn_csm_pres_hgt(wks,dataAHPs_convec10(1,:,:),res)
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
res1@gsnLeftString = "JJA PMax Temp(C), Geo.Pot.Ht(m) & Rel. Humid(%)(-10W:20E)"
 plotA = gsn_csm_pres_hgt(wks,dataNoAHPs_convec10T(1,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,dataNoAHPs_convec10T(2,:,:),res)
 overlay(plotA,plotB)  
 res@cnLineColor  = "seagreen"  
  res@cnMinLevelValF  = 0.        ; set the minimum contour level
  res@cnMaxLevelValF  = 100.         ; set the maximum contour level
  res@cnLevelSpacingF = 10               
 plotC = gsn_csm_pres_hgt(wks,dataNoAHPs_convec10T(0,:,:),res)
 overlay(plotA,plotC)  
 plot(3) = plotA                           

 res@cnLineColor  = "black" 
  res@cnMinLevelValF  = 0        ; set the minimum contour level
  res@cnMaxLevelValF  = 16600         ; set the maximum contour level
  res@cnLevelSpacingF = 2000   

res1@gsnLeftString = "JJA NAHP Temp(C), Geo.Pot.Ht(m) & Rel. Humid(%)(-10W:20E)"
 plotD = gsn_csm_pres_hgt(wks,dataAHPs_convec10T(1,:,:),res1)
 plotE = gsn_csm_pres_hgt(wks,dataAHPs_convec10T(2,:,:),res)
 overlay(plotD,plotE)  
  res@cnLineColor  = "seagreen"                      
   res@cnMinLevelValF  = 0.        ; set the minimum contour level
  res@cnMaxLevelValF  = 100.         ; set the maximum contour level
  res@cnLevelSpacingF = 10
  plotF = gsn_csm_pres_hgt(wks,dataAHPs_convec10T(0,:,:),res)
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
res1@gsnLeftString = "JJA Vert. Velo. Anomaly (m/s, NAHP-PMax)"
plotI = gsn_csm_pres_hgt(wks,anom_convec10(0,:,:),res1)
;plotJ = gsn_csm_pres_hgt(wks,anom_convec10(1,:,:),res)
; overlay(plotI,plotJ)                      
 plot(2) = plotI  



contour_list0000:=(/-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,-0.5,0,0.5,1,2,3,4,5,6,7,8,9,10/)
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
  res@cnMaxLevelValF  = 300       ; set the maximum contour level
  res@cnLevelSpacingF = 30 
res1@gsnLeftString = "JJA Temp(C), Geo.Pot.Ht(m) & Rel. Humid(%) Anom)"
plotI = gsn_csm_pres_hgt(wks,anom_convec10T(1,:,:),res1)
plotJ = gsn_csm_pres_hgt(wks,anom_convec10T(2,:,:),res)
 overlay(plotI,plotJ)    

  res@cnLineColor  = "seagreen"   
  res@cnMinLevelValF  = -16.         ; set the minimum contour level
  res@cnMaxLevelValF  = 40.       ; set the maximum contour level
  res@cnLevelSpacingF = 8  
plotK = gsn_csm_pres_hgt(wks,anom_convec10T(0,:,:),res)
 overlay(plotI,plotK)   

 plot(5) = plotI  



;====
gsn_panel(wks,plot,(/2,3/),False)

delete(res1)
delete(res)
end



