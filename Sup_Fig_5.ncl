load "/home/bridge/swsvalde/ummodel/scripts/new_plots_scripts/ncl_files/my_ncl_code.ncl"
load "/home/bridge/swsvalde/ummodel/scripts/new_plots_scripts/ncl_files/initialise_myncl_variables.ncl"
load "/home/bridge/ea13310/Finland/Scripts/sub_scripts/quaternary_timeseries_functions.ncl"

;======================================================================
; Open the Precip data & Isolate the AHPs

var = "precip_mm_srf"   ;wind / currents
out=32000 ; file size yr

print("Isolating the AHprecip_mm_srf_Ps")

endY = 800000 ; For the data files   ;!! I have to identify this to order the files properly!
stY = 0 ; For the data files
seqFils = ispan(endY,stY+out,out)

diri = "/home/bridge/ea13310/Finland/Finland_Files/Spline/"
filen = "precip_mm_srf_convec_sims_100yrAvg_ann_1degRes_noBias_Global"
fileo = "precip_mm_srf_convec_sims_noIce_100yrAvg_ann_1degRes_noBias_Global"
filec = "precip_mm_srf_convec_sims_noIce_noCO2_100yrAvg_ann_1degRes_noBias_Global"

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

data := new((/3,(dimsizes(open_files)*dimsizes(time))+1,ilat1,ilon1/),"float")
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

  fname13 = diri+filec+"_"+seqFils(i)+"_"
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

data_avg := wgt_areaave(mask(data,mask_af,1.),clat_t,1.0,0) 
data_avg = data_avg*365

;======================================================================
; Open the SATs

var = "temp_mm_1_5m"   ;wind / currents
out=32000 ; file size yr

endY = 800000 ; For the data files   ;!! I have to identify this to order the files properly!
stY = 0 ; For the data files
seqFils = ispan(endY,stY+out,out)

diri = "/home/bridge/ea13310/Finland/Finland_Files/Spline/"
fileTn = "temp_mm_1_5m_convec_sims_100yrAvg_ann_1degRes_noBias_Global"
fileTo = "temp_mm_1_5m_convec_sims_noIce_100yrAvg_ann_1degRes_noBias_Global"
fileTc = "temp_mm_1_5m_convec_sims_noIce_noCO2_100yrAvg_ann_1degRes_noBias_Global"

open_files = systemfunc("ls " + diri + fileTn+"*")
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

dataT := new((/3,(dimsizes(open_files)*dimsizes(time))+1,ilat1,ilon1/),"float")
dataT!2   ="lat"    ; Set metadata for first array
dataT!3   = "lon"
dataT&lat = lat
dataT&lon = lon
dataT!1  ="time"
dataT@_FillValue = -999  

do i=0, dimsizes(open_files)-1
  fname1 = diri+fileTn+"_"+seqFils(i)+"_"
  fname2 = systemfunc("ls " + fname1+ "*")

  fname12 = diri+fileTo+"_"+seqFils(i)+"_"
  fname22 = systemfunc("ls " + fname12+ "*")

  fname13 = diri+fileTc+"_"+seqFils(i)+"_"
  fname23 = systemfunc("ls " + fname13+ "*")


 ; print(fname2)

  cdf_file1 = addfile(fname2,"r")
  cdf_file2 = addfile(fname22,"r")
    cdf_file3 = addfile(fname23,"r")

   if (i.eq.dimsizes(open_files)-1)
    dataT(0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:) = cdf_file1->temp_mm_1_5m    ;!!! CHANGE VARIABLE NAME HERE
    dataT(1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:) = cdf_file2->temp_mm_1_5m    ;!!! CHANGE VARIABLE NAME HERE
    dataT(2,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:) = cdf_file3->temp_mm_1_5m    ;!!! CHANGE VARIABLE NAME HERE
    else 
     dataT(0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:) = cdf_file1->temp_mm_1_5m    ;!!! CHANGE VARIABLE NAME HERE
     dataT(1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:) = cdf_file2->temp_mm_1_5m    ;!!! CHANGE VARIABLE NAME HERE
     dataT(2,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:) = cdf_file3->temp_mm_1_5m    ;!!! CHANGE VARIABLE NAME HERE
   end if


end do 


data_avg_N := wgt_areaave(dataT(:,:,{24:90},:),clat_t({24:90}),1.0,0) 
data_avg_S := wgt_areaave(dataT(:,:,{-90:-24},:),clat_t({-90:-24}),1.0,0) 

diff = data_avg_N - data_avg_S




;============================================================================================================================
;============================================================================================================================

begin

wtype   = "pdf"
wks =  gsn_open_wks(wtype, "/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/merid_temp_grad")

plot=new(1,graphic)

res1=True
res2=True

res1@vpHeightF = 0.16 
res1@vpWidthF = 0.70
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

 res1@gsnLeftString= "Saharan precip. (blue) & N-S meridional temp. grad. (orange)" 
 
 res1@xyLineColors = (/"dodgerblue","orange"/)
 res1@xyDashPatterns   = (/0,0/)
 res1@xyLineThicknessF = 1.4

 ;res1@tiYAxisSide          = "left"
 res1@trYMaxF = 600
 res1@trYMinF = 0
 ;res1@tiYAxisFontColor     = "black"
 ;res1@tmYLLabelFontColor   = "black"
 res1@tiYAxisString     = "Annual Precip (mm/yr)"

 ;res1@tmYLLabelsOn         = True
 ;res1@tmYRLabelsOn         = False

 ;res1@tmYLOn            = True

 res2@xyLineColors = (/"orange"/)
 res2@xyDashPatterns   = (/0,0/)
 res2@xyLineThicknessF = 1.4

 ;res1@trYMaxF = 780;380  ;450
 ;res2@trYMinF = 0
 res2@tiYAxisFontColor     = "black"
 res2@tmYLLabelFontColor   = "black"
 res2@tiYAxisString     = "N-S Temp (C)"


 
plot  = gsn_csm_xy2(wks,time_seq,data_avg(0,:),diff(0,:),res1,res2) ; create plot

end



















