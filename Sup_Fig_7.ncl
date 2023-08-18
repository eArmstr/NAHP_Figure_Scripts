
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

data := new((/(dimsizes(open_files)*dimsizes(time))+1,ilat1,ilon1/),"float")
data!1   ="lat"    ; Set metadata for first array
data!2   = "lon"
data&lat = lat
data&lon = lon
data!0  ="time"
data@_FillValue = -999  

do i=0, dimsizes(open_files)-1
  fname1 = diri+filen+"_"+seqFils(i)+"_"
  fname2 = systemfunc("ls " + fname1+ "*")

 ; print(fname2)

  cdf_file1 = addfile(fname2,"r")

   if (i.eq.dimsizes(open_files)-1)
    data(i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:) = cdf_file1->precip_mm_srf    ;!!! CHANGE VARIABLE NAME HERE
      else 
     data(i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:) = cdf_file1->precip_mm_srf    ;!!! CHANGE VARIABLE NAME HERE
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


;====================================================================
; Make & average our data

data_avg := wgt_areaave(mask(data,mask_af,1.),clat_t,1.0,0) 
data_avg = data_avg*365


;========================================================================
; Open AMOC index

fileA = "Merid_Atlantic_convec_sims_100yrAvg_ann_nativedegRes_noBias_Global"

;======
print("Opening AMOC data")

diri = "/home/bridge/ea13310/Finland/Finland_Files/Spline/"

open_files = systemfunc("ls " + diri + fileA+"*")
cdf_file1 = addfile(open_files(0),"r")
lonA = cdf_file1 ->lon
latA = cdf_file1 ->lat
timeA = cdf_file1 ->time
depth = cdf_file1 ->depth
ilonA=dimsizes(lonA)
ilatA=dimsizes(latA) 
idepthA = dimsizes(depth) 

dataAM = new((/(dimsizes(open_files)*dimsizes(timeA))+1,idepthA,ilatA/),"float")

dataAM!1   ="depth"    ; Set metadata for first array
dataAM!2   = "lat"
dataAM&lat = latA
dataAM&depth = depth
dataAM!0   ="time"
dataAM@_FillValue = -999  

do i=0, dimsizes(open_files)-1
 fname1 = diri+fileA+"_"+seqFils(i)+"_"
 fname2 = systemfunc("ls " + fname1+ "*")
 ;print(fname2)

 cdf_file1 = addfile(fname2,"r")

  if (i.eq.dimsizes(open_files)-1)
   dataAM(i*dimsizes(timeA):i*dimsizes(timeA)+(dimsizes(timeA)),:,:) = cdf_file1->Merid_Atlantic(:,:,:,0)   
   else 
    dataAM(i*dimsizes(timeA):i*dimsizes(timeA)+(dimsizes(timeA)-1),:,:) = cdf_file1->Merid_Atlantic(:,:,:,0)    
  end if

   if (i.eq.0)
   time_seqA = cdf_file1 ->time
    else
     time_seqA2 := cdf_file1 ->time
     time_seqA := array_append_record(time_seqA,time_seqA2,0)
    end if
end do 

;== Calculate AMOC index :  Avg between 40:50N @ 800m

   low = ind_nearest_coord (40, latA, 0)
   high = ind_nearest_coord (50, latA, 0)

   AMOCInd = dim_avg_n(dataAM(:,12,low:high),1)






delete(attachid1)
delete(plot)
delete(res1)
delete(res2)
delete(res3)
delete(attachres1)

begin

wtype   = "pdf"
wks =  gsn_open_wks(wtype, "/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/NAHPs_AMOCInd")

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

 res1@gsnLeftString= "Saharan precip (blue) & AMOC Index (orange)" 
 
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
 res2@tiYAxisString     = "AMOC Ind (Sv)"


 
plot  = gsn_csm_xy2(wks,time_seq,data_avg,AMOCInd,res1,res2) ; create plot

end






















