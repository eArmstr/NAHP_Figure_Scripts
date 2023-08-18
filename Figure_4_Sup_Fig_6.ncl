;README : This plots the two components of Figure 4 - The timeseries plot and the wavelet plots. 
; This also has the code for producing the IceSheet wavelet, but not the plotting function (this might be in wavelet_plots.ncl)

load "/home/bridge/swsvalde/ummodel/scripts/new_plots_scripts/ncl_files/my_ncl_code.ncl"
load "/home/bridge/swsvalde/ummodel/scripts/new_plots_scripts/ncl_files/initialise_myncl_variables.ncl"
load "/home/bridge/ea13310/Finland/Scripts/sub_scripts/quaternary_timeseries_functions.ncl"

;======================================================================
; Open the Precip data & Isolate the AHPs

var = "precip_mm_srf"   ;wind / currents
out=32000 ; file size yr

endY = 800000 ; For the data files   ;!! I have to identify this to order the files properly!
stY = 0 ; For the data files
seqFils = ispan(endY,stY+out,out)

diri = "/home/bridge/ea13310/Finland/Finland_Files/Spline/"
filen = "precip_mm_srf_convec_sims_100yrAvg_jja_1degRes_noBias_Global"
fileo = "precip_mm_srf_convec_sims_noIce_100yrAvg_jja_1degRes_noBias_Global"
filep = "precip_mm_srf_convec_sims_noIce_noCO2_100yrAvg_jja_1degRes_noBias_Global"

open_files = systemfunc("ls " + diri + filen+"*")
cdf_file1 = addfile(open_files(0),"r")
lon = cdf_file1 ->lon
lat = cdf_file1 ->lat
time = cdf_file1 ->time
ilon1=dimsizes(lon)
ilat1=dimsizes(lat) 

rad    = 4.0*atan(1.0)/180.0
clat_t=cos(lat*rad)
clat_t!0   ="lat"
clat_t&lat = lat

data = new((/3,(dimsizes(open_files)*dimsizes(time))+1,ilat1,ilon1/),"float")
data!2   ="lat"    ; Set metadata for first array
data!3   = "lon"
data&lat = lat
data&lon = lon
data!1  ="time"
data@_FillValue = -999  

do i=0, dimsizes(open_files)-1
  fname1 = diri+filen+"_"+seqFils(i)+"_"
  fname2 = systemfunc("ls " + fname1+ "*")

  fname12 = diri+fileo+"_"+seqFils(i)+"_"
  fname22 = systemfunc("ls " + fname12+ "*")

  fname13 = diri+filep+"_"+seqFils(i)+"_"
  fname23 = systemfunc("ls " + fname13+ "*")

 ; print(fname2)

  cdf_file1 = addfile(fname2,"r")
  cdf_file2 = addfile(fname22,"r")
  cdf_file3 = addfile(fname23,"r")

   if (i.eq.dimsizes(open_files)-1)
    data(0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:) = cdf_file1->precip_mm_srf    ;!!! CHANGE VARIABLE NAME HERE
    data(1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:) = cdf_file2->precip_mm_srf    ;!!! CHANGE VARIABLE NAME HERE
    data(2,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:) = cdf_file3->precip_mm_srf    ;!!! CHANGE VARIABLE NAME HERE
    else 
     data(0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:) = cdf_file1->precip_mm_srf    ;!!! CHANGE VARIABLE NAME HERE
     data(1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:) = cdf_file2->precip_mm_srf    ;!!! CHANGE VARIABLE NAME HERE
     data(2,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:) = cdf_file3->precip_mm_srf    ;!!! CHANGE VARIABLE NAME HERE
   end if

  if (i.eq.0)
   time_seq = cdf_file1 ->time
    else
     time_seq2 := cdf_file1 ->time
     time_seq := array_append_record(time_seq,time_seq2,0)
    end if
end do 

;====================================================================
; Make a Mask for region to define the AHPs. Take this as wide band across Africa

cdf_file = addfile("/home/bridge/ea13310/Finland/Finland_Files/Spline/precip_mm_srf_convec_sims_100yrAvg_ann_1degRes_CRU_Global_32000_0kyr.nc","r") ; 
contour_mask = cdf_file ->mask(0,:,:) ; This for the mask
lat_t := cdf_file ->lat
lon_t := cdf_file ->lon

mask_af=contour_mask
mask_af(:,:)=0.

do i=0,dimsizes(lat_t)-1
  do j=0,dimsizes(lon_t)-1
    if(lat_t(i).ge.15.and.lat_t(i).lt.30)then
      if(lon_t(j).gt.-15.and.lon_t(j).lt.35.)then
       mask_af(i,j)=contour_mask(i,j)
      end if   
    end if
  end do
end do

;system("/bin/rm -f /home/bridge/ea13310/Finland/Plots/Convec_Manuscript/test_mask.nc")   ; remove any pre-existing file
;ncdf = addfile("/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/test_mask.nc" ,"c")  ; open output netCDF file
;ncdf->tester =mask_af

;====================================================================
; Make & average our data

data_avg = wgt_areaave(mask(data,mask_af,1.),clat_t,1.0,0) 
;data_avg=  data_avg*365

;========================================================================
; Calculate the wavelets

  N     = dimsizes(time_seq)
  mother  = 0
  param   = 6.0
  dt      = 100    ;timesteps in units of years
  s0      = dt
  dj      = 0.25
  jtot    = 1+floattointeger(((log10(N*dt/s0))/dj)/log10(2.))
  npad    = N
  nadof   = 0
  noise   = 1
  siglvl  = .01
  isigtest= 0

; For convec_sims precip
 ahp_wave0 = wavelet(data_avg(0,:),mother,dt,param,s0,dj,jtot,npad,noise,isigtest,siglvl,nadof)
; For convec_sims_noIce precip 
 ahp_wave1 = wavelet(data_avg(1,:),mother,dt,param,s0,dj,jtot,npad,noise,isigtest,siglvl,nadof)
; For convec_sims_noIceNoCO2 precip 
 ahp_wave2 = wavelet(data_avg(2,:),mother,dt,param,s0,dj,jtot,npad,noise,isigtest,siglvl,nadof)


;========================================================================
;========================================================================

; Open the Ice sheet data and calculate the extent of ice

system("/bin/rm -f /home/bridge/ea13310/Finland/Finland_Files/test_iceVol.nc")   ; remove any pre-existing file
setfileoption("nc","Format","NetCDF4Classic") 
ncdf = addfile("/home/bridge/ea13310/Finland/Finland_Files/test_iceVol.nc" ,"c")  ; open output netCDF file
ncdf->data_IceVol = data_IceVol
printVarSummary(hosing_anom_var)

data_IceVol = data_IceVol  / 1000000000   ; 10^9 ; THis converts to km3
data_IceVol = data_IceVol/1000000  ; 10^6 km3

;Sum the ice volume in Northern Hemisphere

data_IceSum = dim_sum_n(data_IceVol, (/2,3/))

;==================================
; For convec_sims_noIce precip 
 data_IceSum0 = wavelet(data_IceSum(0,:),mother,dt,param,s0,dj,jtot,npad,noise,isigtest,siglvl,nadof)
 data_IceSum1 = wavelet(data_IceSum(1,:),mother,dt,param,s0,dj,jtot,npad,noise,isigtest,siglvl,nadof)
;========================================================================

; Now plot

; Choose variable to plot here:
; ahp_wave0, ahp_wave1 , ahpWA_wave0 
; sahara_dust_anya / sahara_ZrRb_anya / sahara_dust
;filen = "precip_convec_sims.pdf"  ;  "precip_convec_sims.pdf" "precip_convec_noIce_sims.pdf"  "precip_convec_noIce_noCO2_sims.pdf" 
;filep = "Saharan Precip. AHP_All Wavelet"   ; "Saharan Precip. AHP_All Wavelet"  "Saharan Precip. Orb_GHG Wavelet" "Saharan Precip. Orb_Only Wavelet"

;===
varT := ahp_wave0
  power            := onedtond(varT@power,(/jtot,N/))
  power!0          = "period"                        ; Y axis
  power&period     = varT@period
  power!1          = "time"                          ; X axis
  power&time       = time_seq  ; !!!! xo or time_seq
  power@long_name  = "Power Spectrum"
  power@units      = "unit^2"

; compute significance ( >= 1 is significant)
  SIG              := power                            ; transfer meta data
  SIG              := power/conform(power,varT@signif,0)
  SIG@long_name    = "Significance"
  SIG@units        = " "

  SIG!0          = "period"                        ; Y axis
  SIG&period     = varT@period
  SIG!1          = "time"                          ; X axis
  SIG&time       = time_seq  ; !!!! xo or time_seq

 power :=power({5000:500000},:)    ; Extract yrs for plot
 SIG :=SIG({5000:500000},:)

;===

varT1 := ahp_wave1
  power1            := onedtond(varT1@power,(/jtot,N/))
  power1!0          = "period"                        ; Y axis
  power1&period     = varT1@period
  power1!1          = "time"                          ; X axis
  power1&time       = time_seq  ; !!!! xo or time_seq
  power1@long_name  = "Power Spectrum"
  power1@units      = "unit^2"

; compute significance ( >= 1 is significant)
  SIG1              := power1                            ; transfer meta data
  SIG1              := power1/conform(power1,varT1@signif,0)
  SIG1@long_name    = "Significance"
  SIG1@units        = " "
  SIG1!0          = "period"                        ; Y axis
  SIG1&period     = varT1@period
  SIG1!1          = "time"                          ; X axis
  SIG1&time       = time_seq  ; !!!! xo or time_seq

 power1 :=power1({5000:500000},:)    ; Extract yrs for plot
 SIG1 :=SIG1({5000:500000},:)


;===

varT2 := ahp_wave2
  power2            := onedtond(varT2@power,(/jtot,N/))
  power2!0          = "period"                        ; Y axis
  power2&period     = varT2@period
  power2!1          = "time"                          ; X axis
  power2&time       = time_seq  ; !!!! xo or time_seq
  power2@long_name  = "Power Spectrum"
  power2@units      = "unit^2"

; compute significance ( >= 1 is significant)
  SIG2              := power2                            ; transfer meta data
  SIG2              := power2/conform(power2,varT2@signif,0)
  SIG2@long_name    = "Significance"
  SIG2@units        = " "

  SIG2!0          = "period"                        ; Y axis
  SIG2&period     = varT2@period
  SIG2!1          = "time"                          ; X axis
  SIG2&time       = time_seq  ; !!!! xo or time_seq

 power2 :=power2({5000:500000},:)    ; Extract yrs for plot
 SIG2 :=SIG2({5000:500000},:)



;==========================
begin
 wks = gsn_open_wks("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/wavelet3_all_model.pdf")             ; send graphics to PNG file"
 plot = new (3, graphic)   

  res                     = True                  ; plot mods desired
  res@gsnDraw             = False                 ; Do not draw plot
  res@gsnFrame            = False                 ; Do not advance frome
  res@cnFillOn            = True                  ; turn on color
  res@cnFillPalette       = "MPL_terrain"   ; set color map
  res@cnFillMode          = "RasterFill"          ; turn on raster mode
  res@cnRasterSmoothingOn = True                  ; turn on raster smoothing
  res@cnLinesOn           = False                 ; turn off contour lines
  res@cnLineLabelsOn      = False
  res@cnInfoLabelOn       = False
  res@trYReverse          = True                  ; reverse y-axis
  res@tmYLMode = "Explicit"
  res@tmYLValues = (/10000,21000,41000,100000,400000/)
  res@tmYLLabels = (/"10000","21000","41000","100000","400000"/)
  res@tmLabelAutoStride   = True
  ;res@vpHeightF           = .4                    ;
  ;res@vpWidthF            = .14

  res@vpHeightF = 0.28 
  res@vpWidthF = 0.80

  res@cnLevelSelectionMode = "ExplicitLevels"       ; set manual contour levels
  
  ;res@cnLevels = (/10,15,20,25,30,35,40,45,50,55,60,70,80,90,100,120,140,160/)
  ;  res@cnLevels = (/1,2,3,4,5,6,7,8,12,16,20,24,28,32,40/)
  
  ;res@cnLevels = (/0,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,180,300,450/)
  ;res@cnLevels = (/0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,20,22,24,26,30,34,40,/)
  ;res@cnLevels = (/0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,20,22,24,26,30,34,40,60,80,100,150/)

  ;res@cnLevels = (/0,5,10,15,20,25,30,35,40,50,60,80,100,120,140,160,180,200,220,240/)
  res@cnLevels = (/0,10,20,30,40,50,60,70,80,90,100,120,140,160,180,200,220,240,260,300,400/)


  res@gsnRightString       = ""
  res@tiYAxisString       = "Period"
  res@tiXAxisString       = "Year (BP)"

  ;res@trYMinF = 0
  ;res@trYMaxF = 200000

   res@trXMaxF = 800000
   res@trXMinF = 0

  res2 = True                            ; res2 probability plots
  res2@gsnDraw             = False                 ; Do not draw plot
  res2@gsnFrame            = False        

  ; res2@trXMaxF = 800000
  ; res2@trXMinF = 0
  res2@trYReverse          = True
  res2@tmYLMode = "Explicit"
  res2@tmYLValues = (/10000,21000,41000,100000,400000/)
  res2@tmYLLabels = (/"10000","21000","41000","100000","400000"/)

  ;res2@cnFillOn            = True                  ; turn on color
  ;res2@cnFillPalette       = "MPL_terrain"   ; set color map
  ;res2@cnFillMode          = "RasterFill"          ; turn on raster mode

  res2@cnLevelSelectionMode = "ManualLevels" ; set manual contour levels
  res2@cnMinLevelValF      = 0.00        ; set min contour level
  res2@cnMaxLevelValF      = 2.00        ; set max contour level
  res2@cnLevelSpacingF     = 1.00        ; set contour spacing
  res2@cnInfoLabelOn       = False
  res2@cnLinesOn           = False       ; do not draw contour lines
  res2@cnLineLabelsOn      = False       ; do not draw contour labels
  res2@cnFillScaleF        = 0.5         ; add extra density
  res2@gsnLeftString = ""
  res2@gsnRightString = ""

 ; plot := new(1,graphic)

  res@gsnLeftString       = "Saharan Precip. AHP_All Wavelet"
  plot(2) = gsn_csm_contour(wks,power,res)
  
  iplot = gsn_csm_contour(wks,SIG,res2)
  opt   = True
  opt@gsnShadeFillType = "pattern"
  opt@gsnShadeHigh         = 17          ; stipple
  opt@gsnShadeFillScaleF   = 0.4         ; add extra density
  opt@gsnShadeFillDotSizeF = 0.0015      ; make dots larger
  ;opt@gsnShadeHigh     = 17
  iplot = gsn_contour_shade(iplot,0, 0.8, opt)
  overlay(plot(2),iplot)        ; overlay probability plot onto power plot

   res@gsnLeftString       = "Saharan Precip. Orb_GHG Wavelet"
  plot(1) = gsn_csm_contour(wks,power1,res)

  iplot2 = gsn_csm_contour(wks,SIG1,res2)
  iplot2 = gsn_contour_shade(iplot2,0, 0.8, opt)
  overlay(plot(1),iplot2)        ; overlay probability plot onto power plot


    res@gsnLeftString       = "Saharan Precip. Orb_Only Wavelet"
  plot(0) = gsn_csm_contour(wks,power2,res)
  iplot3 = gsn_csm_contour(wks,SIG2,res2)
  iplot3 = gsn_contour_shade(iplot3,0, 0.8, opt)
  overlay(plot(0),iplot3)        ; overlay probability plot onto power plot


  pres = True
  pres@gsnMaximize = True
  ;pres@gsnPaperOrientation = "portrait"
  gsn_panel(wks,plot,(/3,1/),pres)
  delete([/res,res2,pres,plot/])
end










;==========================
begin
 wks = gsn_open_wks("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/wavelet3_all_model.pdf")             ; send graphics to PNG file"
 plot = new (3, graphic)   

  res                     = True                  ; plot mods desired
  res@gsnDraw             = False                 ; Do not draw plot
  res@gsnFrame            = False                 ; Do not advance frome
  res@cnFillOn            = True                  ; turn on color
  res@cnFillPalette       = "MPL_terrain"   ; set color map
  res@cnFillMode          = "RasterFill"          ; turn on raster mode
  res@cnRasterSmoothingOn = True                  ; turn on raster smoothing
  res@cnLinesOn           = False                 ; turn off contour lines
  res@cnLineLabelsOn      = False
  res@cnInfoLabelOn       = False
  res@trYReverse          = True                  ; reverse y-axis
  res@tmYLMode = "Explicit"
  res@tmYLValues = (/10000,21000,41000,100000,400000/)
  res@tmYLLabels = (/"10000","21000","41000","100000","400000"/)
  res@tmLabelAutoStride   = True
  ;res@vpHeightF           = .4                    ;
  ;res@vpWidthF            = .14

  res@vpHeightF = 0.28 
  res@vpWidthF = 0.80

  res@cnLevelSelectionMode = "ExplicitLevels"       ; set manual contour levels
  
  ;res@cnLevels = (/10,15,20,25,30,35,40,45,50,55,60,70,80,90,100,120,140,160/)
  ;  res@cnLevels = (/1,2,3,4,5,6,7,8,12,16,20,24,28,32,40/)
  
  ;res@cnLevels = (/0,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,180,300,450/)
  ;res@cnLevels = (/0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,20,22,24,26,30,34,40,/)
  ;res@cnLevels = (/0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,20,22,24,26,30,34,40,60,80,100,150/)

  ;res@cnLevels = (/0,5,10,15,20,25,30,35,40,50,60,80,100,120,140,160,180,200,220,240/)
  res@cnLevels = (/0,10,20,30,40,50,60,70,80,90,100,120,140,160,180,200,220,240,260,300,400/)


  res@gsnRightString       = ""
  res@tiYAxisString       = "Period"
  res@tiXAxisString       = "Year (BP)"

  ;res@trYMinF = 0
  ;res@trYMaxF = 200000

   res@trXMaxF = 800000
   res@trXMinF = 0

  res2 = True                            ; res2 probability plots
  res2@gsnDraw             = False                 ; Do not draw plot
  res2@gsnFrame            = False        

  ; res2@trXMaxF = 800000
  ; res2@trXMinF = 0
  res2@trYReverse          = True
  res2@tmYLMode = "Explicit"
  res2@tmYLValues = (/10000,21000,41000,100000,400000/)
  res2@tmYLLabels = (/"10000","21000","41000","100000","400000"/)

  ;res2@cnFillOn            = True                  ; turn on color
  ;res2@cnFillPalette       = "MPL_terrain"   ; set color map
  ;res2@cnFillMode          = "RasterFill"          ; turn on raster mode

  res2@cnLevelSelectionMode = "ManualLevels" ; set manual contour levels
  res2@cnMinLevelValF      = 0        ; set min contour level
  res2@cnMaxLevelValF      = 0.95        ; set max contour level
  res2@cnLevelSpacingF     = 0.95        ; set contour spacing
  res2@cnInfoLabelOn       = False
  res2@cnLinesOn           = True       ; do not draw contour lines
  res2@cnLineLabelsOn      = False       ; do not draw contour labels
  ;res2@cnFillScaleF        = 0.5         ; add extra density
  res2@gsnLeftString = ""
  res2@gsnRightString = ""
  res2@gsnContourZeroLineThicknessF = 2.

 ; plot := new(1,graphic)

  res@gsnLeftString       = "Saharan Precip. AHP_All Wavelet"
  plot(2) = gsn_csm_contour(wks,power,res)
  iplot = gsn_csm_contour(wks,SIG,res2)
    overlay(plot(2),iplot)        ; overlay probability plot onto power plot

   res@gsnLeftString       = "Saharan Precip. Orb_GHG Wavelet"
  plot(1) = gsn_csm_contour(wks,power1,res)
  iplot2 = gsn_csm_contour(wks,SIG1,res2)
  overlay(plot(1),iplot2)        ; overlay probability plot onto power plot


    res@gsnLeftString       = "Saharan Precip. Orb_Only Wavelet"
  plot(0) = gsn_csm_contour(wks,power2,res)
  iplot3 = gsn_csm_contour(wks,SIG2,res2)
  overlay(plot(0),iplot3)        ; overlay probability plot onto power plot


  pres = True
  pres@gsnMaximize = True
  ;pres@gsnPaperOrientation = "portrait"
  gsn_panel(wks,plot,(/3,1/),pres)
  delete([/res,res2,pres,plot/])
end









;===================;===================;===================;===================;===================;===================
;===================;===================;===================;===================;===================;===================
; NOw make the timsereis plots



var = "precip_mm_srf"   ;wind / currents
out=32000 ; file size yr

endY = 800000 ; For the data files   ;!! I have to identify this to order the files properly!
stY = 0 ; For the data files
seqFils = ispan(endY,stY+out,out)

diri = "/home/bridge/ea13310/Finland/Finland_Files/Spline/"
filen = "precip_mm_srf_convec_sims_100yrAvg_ann_1degRes_noBias_Global"
fileo = "precip_mm_srf_convec_sims_noIce_100yrAvg_ann_1degRes_noBias_Global"
filep = "precip_mm_srf_convec_sims_noIce_noCO2_100yrAvg_ann_1degRes_noBias_Global"

open_files = systemfunc("ls " + diri + filen+"*")
cdf_file1 = addfile(open_files(0),"r")
lon = cdf_file1 ->lon
lat = cdf_file1 ->lat
time = cdf_file1 ->time
ilon1=dimsizes(lon)
ilat1=dimsizes(lat) 

rad    = 4.0*atan(1.0)/180.0
clat_t=cos(lat*rad)
clat_t!0   ="lat"
clat_t&lat = lat

data = new((/3,(dimsizes(open_files)*dimsizes(time))+1,ilat1,ilon1/),"float")
data!2   ="lat"    ; Set metadata for first array
data!3   = "lon"
data&lat = lat
data&lon = lon
data!1  ="time"
data@_FillValue = -999  

do i=0, dimsizes(open_files)-1
  fname1 = diri+filen+"_"+seqFils(i)+"_"
  fname2 = systemfunc("ls " + fname1+ "*")

  fname12 = diri+fileo+"_"+seqFils(i)+"_"
  fname22 = systemfunc("ls " + fname12+ "*")

  fname13 = diri+filep+"_"+seqFils(i)+"_"
  fname23 = systemfunc("ls " + fname13+ "*")

 ; print(fname2)

  cdf_file1 = addfile(fname2,"r")
  cdf_file2 = addfile(fname22,"r")
  cdf_file3 = addfile(fname23,"r")

   if (i.eq.dimsizes(open_files)-1)
    data(0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:) = cdf_file1->precip_mm_srf    ;!!! CHANGE VARIABLE NAME HERE
    data(1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:) = cdf_file2->precip_mm_srf    ;!!! CHANGE VARIABLE NAME HERE
    data(2,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:) = cdf_file3->precip_mm_srf    ;!!! CHANGE VARIABLE NAME HERE
    else 
     data(0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:) = cdf_file1->precip_mm_srf    ;!!! CHANGE VARIABLE NAME HERE
     data(1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:) = cdf_file2->precip_mm_srf    ;!!! CHANGE VARIABLE NAME HERE
     data(2,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:) = cdf_file3->precip_mm_srf    ;!!! CHANGE VARIABLE NAME HERE
   end if

  if (i.eq.0)
   time_seq = cdf_file1 ->time
    else
     time_seq2 := cdf_file1 ->time
     time_seq := array_append_record(time_seq,time_seq2,0)
    end if
end do 

;====================================================================
; Make a Mask for region to define the AHPs. Take this as wide band across Africa

cdf_file = addfile("/home/bridge/ea13310/Finland/Finland_Files/Spline/precip_mm_srf_convec_sims_100yrAvg_ann_1degRes_CRU_Global_32000_0kyr.nc","r") ; 
contour_mask = cdf_file ->mask(0,:,:) ; This for the mask
lat_t := cdf_file ->lat
lon_t := cdf_file ->lon

mask_af=contour_mask
mask_af(:,:)=0.

do i=0,dimsizes(lat_t)-1
  do j=0,dimsizes(lon_t)-1
    if(lat_t(i).ge.15.and.lat_t(i).lt.30)then
      if(lon_t(j).gt.-15.and.lon_t(j).lt.35.)then
       mask_af(i,j)=contour_mask(i,j)
      end if   
    end if
  end do
end do

;system("/bin/rm -f /home/bridge/ea13310/Finland/Plots/Convec_Manuscript/test_mask.nc")   ; remove any pre-existing file
;ncdf = addfile("/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/test_mask.nc" ,"c")  ; open output netCDF file
;ncdf->tester =mask_af

;====================================================================
; Make & average our data

data_avg = wgt_areaave(mask(data,mask_af,1.),clat_t,1.0,0) 
data_avg = data_avg*365
;===================
begin

wtype   = "pdf"
wks =  gsn_open_wks(wtype, "/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/Figure3_allTimeseries")

plot=new(3,graphic)

res1=True
res2=True
res3=True

;res1@gsnDraw = False
;res1@gsnFrame = False
;res2@gsnDraw  = False
;res2@gsnFrame = False
;res3@gsnDraw  = False
;res3@gsnFrame = False

res1@vpHeightF = 0.15 
res1@vpWidthF = 0.60
res2@vpHeightF = res1@vpHeightF
res2@vpWidthF = res1@vpWidthF

 res1@trXMaxF = 800000
 res1@trXMinF = 0 
 res2@trXMaxF = res1@trXMaxF 
 res2@trXMinF = res1@trXMinF 

 res1@tmXMajorGrid= True
 res2@tmXMajorGrid= True
 res1@tmXMajorGridLineColor = "grey30"
 res2@tmXMajorGridLineColor = "grey30"
 res1@tmXMajorGridLineDashPattern =1 
 res2@tmXMajorGridLineDashPattern =1 
 res1@tmXMajorGridThicknessF = 1
 res2@tmXMajorGridThicknessF = 1

 res1@tiXAxisString     = "Year BP"

  res1@tiXAxisFontHeightF  = 0.015
  res1@tiYAxisFontHeightF = 0.015

;=======

 res1@gsnLeftString= "Saharan Precipitation - Orb_Only     Orb_GHG     AHP_All" 
 
 res1@xyLineColors := (/"red","goldenrod1","dodgerblue3"/)
 res1@xyDashPatterns   = (/0,0/)
 res1@xyLineThicknessF = 1.3
 ;res1@tmXBOn               = False
 ;res1@tmXTOn               = False

 res1@tiYAxisSide          = "left"
 res1@trYMaxF = 620;380  ;450
 res1@trYMinF = 0
 res1@tiYAxisFontColor     = "black"
 res1@tmYLLabelFontColor   = "black"
 res1@tiYAxisString     = "Annual Precip (mm/yr)"

 res1@tmYLLabelsOn         = True
 res1@tmYRLabelsOn         = False

 res1@tmYLOn            = True
 
plot  = gsn_csm_xy(wks,time_seq,(/data_avg(2,:),data_avg(1,:),data_avg(0,:)/),res1) ; create plot

delete(res1)
delete(res2)
delete(res3)

end








