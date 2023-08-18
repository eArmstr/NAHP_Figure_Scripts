;README : Final Figure 1 plot with all timeseeries
  Add monsoon forcing index, moon index, MIS positions (With lines) /  Lisiecki and Raymo (2005) dataset

; Extended Data Figure 2 : ALSO PLOTS WEST/EAST TIMESERIES PLOT 

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


mask_wf=contour_mask
mask_wf(:,:)=0.

do i=0,dimsizes(lat_t)-1
  do j=0,dimsizes(lon_t)-1
    if(lat_t(i).ge.15.and.lat_t(i).lt.30)then
      if(lon_t(j).gt.-15.and.lon_t(j).lt.15.)then
       mask_wf(i,j)=contour_mask(i,j)
      end if   
    end if
  end do
end do


mask_ef=contour_mask
mask_ef(:,:)=0.

do i=0,dimsizes(lat_t)-1
  do j=0,dimsizes(lon_t)-1
    if(lat_t(i).ge.15.and.lat_t(i).lt.30)then
      if(lon_t(j).gt.15.and.lon_t(j).lt.50.)then
       mask_ef(i,j)=contour_mask(i,j)
      end if   
    end if
  end do
end do

mask_bar=contour_mask
mask_bar(:,:)=0.

do i=0,dimsizes(lat_t)-1
  do j=0,dimsizes(lon_t)-1
    if(lat_t(i).ge.15.and.lat_t(i).lt.30)then
      if(lon_t(j).gt.-10.and.lon_t(j).lt.30.)then
       mask_bar(i,j)=contour_mask(i,j)
      end if   
    end if
  end do
end do

mask_tier=contour_mask
mask_tier(:,:)=0.

do i=0,dimsizes(lat_t)-1
  do j=0,dimsizes(lon_t)-1
    if(lat_t(i).ge.15.and.lat_t(i).lt.33)then
      if(lon_t(j).gt.-15.and.lon_t(j).lt.0.)then
       mask_tier(i,j)=contour_mask(i,j)
      end if   
    end if
  end do
end do

;system("/bin/rm -f /home/bridge/ea13310/Finland/Plots/Convec_Manuscript/test_mask.nc")   ; remove any pre-existing file
;ncdf = addfile("/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/test_mask.nc" ,"c")  ; open output netCDF file
;ncdf->tester =mask_af

;====================================================================
; Make & average our data

data_avg := wgt_areaave(mask(data,mask_af,1.),clat_t,1.0,0) 

data_avgE := wgt_areaave(mask(data,mask_ef,1.),clat_t,1.0,0) 
data_avgW := wgt_areaave(mask(data,mask_wf,1.),clat_t,1.0,0) 


;=========================
; Multiply by 360 here to get mm/yr

data_avg = data_avg*365

data_avgE = data_avgE*365 ;365
data_avgW = data_avgW*365 ;365

;====
; Isolate AHPs -  where 1stddev above the mean

ahp_am = avg(data_avg(0,:))+stddev(data_avg(0,:));-15 ; This is the thresold value to define the AHP
ahp0 := ind(data_avg(0,:).ge.ahp_am) ; These are the indices for yrs when we have AHP
;ahp1 = ind(data_avg(1,:).ge.ahp_am) ; These are the indices for yrs when we have AHP

;ahpE = ind(data_avgE.ge.ahp_am) ; These are the indices for yrs when we have AHP
ahpW1 = ind(data_avgW(0,:).ge.ahp_am)
ahpW2 = ind(data_avgW(1,:).ge.ahp_am)


;===== Clculate some averages for the paper

print(avg(data_avg(0,ahp0)))
print(avg(data_avgW(0,ahp0)))
print(max(data_avgW(0,ahp0)))

data_avgbar := wgt_areaave(mask(data,mask_bar,1.),clat_t,1.0,0) 
data_avgbar = data_avgbar*365
print(avg(data_avgbar(0,7890:7940)))

data_avgtier := wgt_areaave(mask(data,mask_tier,1.),clat_t,1.0,0) 
data_avgtier = data_avgtier*365
print(avg(data_avgtier(0,7890:7940)))


print(wgt_areaave(dataAHPs(0,{13:17},{43:46}),clat_t({13:17}),1.0,0))  ; South Arabia

print(wgt_areaave(dataAHPs(0,{18:22},{16:19}),clat_t({18:22}),1.0,0))      ; Tibesti

;========================================================================
;========================================================================
; For finding the latitude of maximum JJA precip

dataMax := new((/(dimsizes(open_files)*dimsizes(time))+1,ilat1,ilon1/),"float")
dataMax!1   ="lat"    ; Set metadata for first array
dataMax!2   = "lon"
dataMax&lat = lat
dataMax&lon = lon
dataMax!0  ="time"
dataMax@_FillValue = -999  

filen = "precip_mm_srf_convec_sims_100yrAvg_jja_1degRes_noBias_Global"
do i=0, dimsizes(open_files)-1
  fname1 = diri+filen+"_"+seqFils(i)+"_"
  fname2 = systemfunc("ls " + fname1+ "*")

 ; print(fname2)

  cdf_file1 = addfile(fname2,"r")

   if (i.eq.dimsizes(open_files)-1)
    dataMax(i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:) = cdf_file1->precip_mm_srf    ;!!! CHANGE VARIABLE NAME HERE
       else 
     dataMax(i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:) = cdf_file1->precip_mm_srf    ;!!! CHANGE VARIABLE NAME HERE
      end if
end do 


mask_WAf=contour_mask
mask_WAf(:,:)=0.

do i=0,dimsizes(lat_t)-1
  do j=0,dimsizes(lon_t)-1
    if(lat_t(i).ge.-10.and.lat_t(i).lt.30)then
      if(lon_t(j).gt.-15.and.lon_t(j).lt.35.)then
       mask_WAf(i,j)=contour_mask(i,j)
      end if   
    end if
  end do
end do

data_Af := mask(dataMax,mask_WAf,1.)
data_Af := dim_avg_n(data_Af,2)

;data_precip_lat := new((/3,8000+1/),"float")
data_precip_lat := new((/8000+1/),"float")

;do f=0,2
; do i=0, 8001-1
;   fn = maxind(data_Af(f,i,:))
;   data_precip_lat(f,i) = lat(fn)
; end do
;end do

 do i=0, 8001-1
   fn = maxind(data_Af(i,:))
   data_precip_lat(i) = lat(fn)
 end do


;========================================================================
;========================================================================

; Caulcate the Monsoon Index

diri = "/home/bridge/ea13310/Finland/Finland_Files/Spline/"

fileS = "downSol_mm_TOA_convec_sims_100yrAvg_monthly_nativedegRes_noBias_Global"
;fileS2 = "downSol_mm_TOA_convec_sims_noIce_100yrAvg_jja_nativedegRes_noBias_Global"
fileS2 = "downSol_mm_TOA_convec_sims_noIce_100yrAvg_monthly_nativedegRes_noBias_Global"

out=32000 ; file size yr
seqFils := ispan(800000,0+out,out)
open_files := systemfunc("ls " + diri + fileS+"*")
cdf_file1 = addfile(open_files(0),"r")
time := cdf_file1 ->time
latS := cdf_file1 ->lat
lonS := cdf_file1 ->lon

;======
print("Opening SW data")
dataSW = new((/2,(dimsizes(open_files)*dimsizes(time))+1,12,dimsizes(latS),dimsizes(lonS)/),"float")

dataSW!3   ="lat"    ; Set metadata for first array
dataSW!4   = "lon"
dataSW&lat = latS
dataSW&lon = lonS
dataSW!1   ="time"
dataSW!2   ="month"
dataSW@_FillValue = -999  

do i=0, dimsizes(open_files)-1
 fname1 = diri+fileS+"_"+seqFils(i)+"_"
 fname2 = systemfunc("ls " + fname1+ "*")

 fname12 = diri+fileS2+"_"+seqFils(i)+"_"
 fname22 = systemfunc("ls " + fname12+ "*")

 ;print(fname2)

 cdf_file1 = addfile(fname2,"r")
  cdf_file2 = addfile(fname22,"r")

  if (i.eq.dimsizes(open_files)-1)
   dataSW(0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:,:) = cdf_file1->downSol_mm_TOA;downSol_Seaice_mm_s3_srf
   dataSW(1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:,:) = cdf_file2->downSol_mm_TOA       
   else 
    dataSW(0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:,:) = cdf_file1->downSol_mm_TOA
    dataSW(1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:,:) = cdf_file2->downSol_mm_TOA   
  end if

   if (i.eq.0)
   time_seqS = cdf_file1 ->time
    else
     time_seqS2 := cdf_file1 ->time
     time_seqS := array_append_record(time_seqS,time_seqS2,0)
    end if
end do 

dataSW&time = time_seqS

clat_t2=cos(lat*rad)
clat_t2!0   ="lat"
clat_t2&lat = lat

;=======
; Calculate for Northern Hemisphere and 65N (this was same as Menviel paper)

;dataSW_NH = wgt_areaave(dataSW(:,:,{0:90},{-180:180}),clat_t2({0:90}),1.0,0) 
;dataSW_65 = dim_avg_n(dataSW(:,:,{65},{-180:180}),2)
;dataSW_23 = dim_avg_n(dataSW(0,:,{23},{-180:180}),1)
;dataSW_23S := dim_avg_n(dataSW(1,:,{-23},{-180:180}),1)
;dataSW_grad = dataSW_23 - dataSW_23S

;======= WAM INDEX
; https://rdrr.io/cran/palinsol/man/calins.html
;file:///Users/edwardarmstrong/Downloads/304046a0.pdf
; https://cp.copernicus.org/articles/18/1897/2022/#bib1.bibx69 ; SEE APPENDIX A

; Cauclate cumulative insolatiuon for the 6 month period - currently in w/m2 = j/s/m2
;  Extract the 6 summer months - or shall i extrat the 6 highest months?
;  Extarct the lats we are interested in - tropics and equator
;  Isolate zero longitude as they are all the same anyway so doesnt matter
;  Sum the months

dataSW_tr := dim_sum_n(dataSW(:,:,3:8,{18:30},{0}),2)  ; For tropics
dataSW_eq := dim_sum_n(dataSW(:,:,3:8,{0},{0}),2)      ; For equator

; Isolate lat of highest insolatiuon

dataSW_tr2 = new((/2,8001/),"float")

do bn=0,1
 do gn=0,8001-1
   dataSW_tr2(bn,gn) = max(dataSW_tr(bn,gn,:))
 end do
end do

;===== Do the sum

m_ind = (2*dataSW_tr2) - dataSW_eq
m_ind(0,:) = m_ind(0,:)  - m_ind(0,8001-1) 
m_ind(1,:) = m_ind(1,:)  - m_ind(1,8001-1) ; make realtive to begiinning

;begin
; wks   = gsn_open_wks ("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/test_index")               ; send graphics to PNG file
; res                  = True                     ; plot mods desired
; plot  = gsn_csm_xy (wks,time_seqS,m_ind(:,:),res) ; create plot
;end


;========================================================================
;========================================================================
; Calculate WAM index from winds ; OPEN AT LINE 389!!

diri = "/home/bridge/ea13310/Finland/Finland_Files/Spline/"
var_wind_ht = (/"u_mm_p","v_mm_p"/)

file_aW = var_wind_ht(0)+"_convec_sims_100yrAvg_jja_nativedegRes_noBias_Global" 
open_files = systemfunc("ls " + diri + file_aW+"*")
cdf_file1 = addfile(open_files(0),"r")
latW = cdf_file1 ->lat
ilatW=dimsizes(latW) 
lonW = cdf_file1 ->lon
ilon1=dimsizes(lonW)
depth = cdf_file1 ->depth
idepth=dimsizes(depth) 
time = cdf_file1 ->time

depg = ind_nearest_coord((/850,700,150/),depth,0)

out=32000 ; file size yr
endY = 800000 ; For the data files   ;!! I have to identify this to order the files properly!
stY = 0 ; For the data files
seqFils = ispan(endY,stY+out,out)

data_wind_Ht := new((/2,3,(dimsizes(open_files)*dimsizes(time))+1,dimsizes(depg),ilatW,ilon1/),"float")
data_wind_Ht!4   ="lat"    ; Set metadata for first array
data_wind_Ht!5   = "lon"
data_wind_Ht!3   = "depth"
data_wind_Ht&lat = latW
data_wind_Ht&lon = lonW
data_wind_Ht&depth = depth(depg)
data_wind_Ht!2  ="time"
data_wind_Ht@_FillValue = -999 

do f=0, dimsizes(var_wind_ht)-1
 do i=0, dimsizes(open_files)-1

  filen = var_wind_ht(f)+"_convec_sims_100yrAvg_jja_nativedegRes_noBias_Global"
  fileo = var_wind_ht(f)+"_convec_sims_noIce_100yrAvg_jja_nativedegRes_noBias_Global"
  filec = var_wind_ht(f)+"_convec_sims_noIce_noCO2_100yrAvg_jja_nativedegRes_noBias_Global"

  fname1 = diri+filen+"_"+seqFils(i)+"_"
  fname2 = systemfunc("ls " + fname1+ "*")

  fname12 = diri+fileo+"_"+seqFils(i)+"_"
  fname22 = systemfunc("ls " + fname12+ "*")

  fname13 = diri+filec+"_"+seqFils(i)+"_"
  fname23 = systemfunc("ls " + fname13+ "*")

  cdf_file1 = addfile(fname2,"r")
  cdf_file2 = addfile(fname22,"r")
  cdf_file3 = addfile(fname23,"r")

  print(fname1)

if (f.eq.0)
   if (i.eq.dimsizes(open_files)-1)
    data_wind_Ht(f,0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:,:) = cdf_file1->u_mm_p(:,depg,:,:)     ;!!! CHANGE VARIABLE NAME HERE
    data_wind_Ht(f,1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:,:) = cdf_file2->u_mm_p(:,depg,:,:)     ;!!! CHANGE VARIABLE NAME HERE
    data_wind_Ht(f,2,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:,:) = cdf_file3->u_mm_p(:,depg,:,:)
    else 
     data_wind_Ht(f,0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:,:) = cdf_file1->u_mm_p(:,depg,:,:)     ;!!! CHANGE VARIABLE NAME HERE
     data_wind_Ht(f,1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:,:) = cdf_file2->u_mm_p(:,depg,:,:)     ;!!! CHANGE VARIABLE NAME HERE
     data_wind_Ht(f,2,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:,:) = cdf_file3->u_mm_p(:,depg,:,:)   
   end if
end if

if (f.eq.1)
   if (i.eq.dimsizes(open_files)-1)
    data_wind_Ht(f,0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:,:) = cdf_file1->v_mm_p(:,depg,:,:)     ;!!! CHANGE VARIABLE NAME HERE
    data_wind_Ht(f,1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:,:) = cdf_file2->v_mm_p(:,depg,:,:)     ;!!! CHANGE VARIABLE NAME HERE
    data_wind_Ht(f,2,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:,:) = cdf_file3->v_mm_p(:,depg,:,:)
    else 
     data_wind_Ht(f,0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:,:) = cdf_file1->v_mm_p(:,depg,:,:)     ;!!! CHANGE VARIABLE NAME HERE
     data_wind_Ht(f,1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:,:) = cdf_file2->v_mm_p(:,depg,:,:)     ;!!! CHANGE VARIABLE NAME HERE
     data_wind_Ht(f,2,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:,:) = cdf_file3->v_mm_p(:,depg,:,:)   
   end if
end if

 end do
end do

;data_wind_Ht(2,:,:,:,:,:) = wind_speed(data_wind_Ht(0,:,:,:,:,:),data_wind_Ht(1,:,:,:,:,:))

;============ Calculate the Index from wind 
; Difference between the 850 hPa wind modulus (MOD850) and the 200 hPa zonal wind component (U200), averaged from 20W to 20E and from 3N to 13N 
; Isolate 20W to 20E and from 3N to 13N and average over those periods

rad    = 4.0*atan(1.0)/180.0
clat_W=cos(latW*rad)
clat_W!0   ="lat"
clat_W&lat = latW

data_wind_Ht_re = wgt_areaave(data_wind_Ht(:,:,:,:,{3:13},{-20:20}),clat_W({3:13}),1.0,0)
Wind_index = data_wind_Ht_re(2,:,:,0) - data_wind_Ht_re(0,:,:,1)

;==== WAM Index 2 - https://www.mdpi.com/2073-4433/11/3/309/htm
; U850 is the zonal wind at the 850 hPa level, U700 is the zonal wind at 700 hPa, and U150 is the zonal wind at 150 hPa averaged between latitude 4° N and 10° N and longitude 20° W and 20° E.

rad    = 4.0*atan(1.0)/180.0
clat_W=cos(latW*rad)
clat_W!0   ="lat"
clat_W&lat = latW

data_wind_Ht_re = wgt_areaave(data_wind_Ht(:,:,:,{3:10},{-20:20}),clat_W({3:10}),1.0,0)
Wind_index = (0.08 * data_wind_Ht_re(:,:,0)) + (0.1*data_wind_Ht_re(:,:,1)) - (0.04* data_wind_Ht_re(:,:,2)) + 6.2

;========================================
asciiwrite("/home/bridge/ea13310/Finland/Data/Wind_index_2_standard.txt", Wind_index(0,:))
asciiwrite("/home/bridge/ea13310/Finland/Data/Wind_index_2_noIce.txt", Wind_index(1,:))

Wind_index = new((/2,8001/),"float")

Wind_index(0,:) = asciiread("/home/bridge/ea13310/Finland/Data/Wind_index_2_standard.txt", -1,"float")
Wind_index(1,:) = asciiread("/home/bridge/ea13310/Finland/Data/Wind_index_2_noIce.txt", -1,"float")


;========================================================================
;========================================================================
; Lisiecki and Raymo, 2005 Benthic stack ; Please cite: Lisiecki, L. E., and M. E. Raymo (2005), A Pliocene-Pleistocene stack of 57 globally distributed benthic d18O records, Paleoceanography,20, PA1003, doi:10.1029/2004PA001071.    


benthic := asciiread("/home/bridge/ea13310/Finland/Data/lisiecki_raymo.txt",(/2115,3/),"float")
benthic(:,0) = benthic(:,0) * 1000

l_800 = ind_nearest_coord(800000,benthic(:,0) ,0)

benthic := benthic(0:l_800,:)

; Plot - benthic(:,0), benthic(:,1) - with ice sheet

;========================================================================
;========================================================================
; EPICA Dome C

epica := asciiread("/home/bridge/ea13310/Finland/Data/EPICA_800_C02_data.txt",(/1096,2/),"float")

; Plot - benthic(:,0), benthic(:,1) - with ice sheet

;========================================================================
;========================================================================

; Open the Ice sheet data and calculate the extent of ice

;fileI = "field1391_convec_sims_100yrAvg_ann_nativedegRes_noBias_Global"
;fileI2 = "field1391_convec_sims_noIce_100yrAvg_ann_nativedegRes_noBias_Global"

;out=8000 ; file size yr
;seqFils := ispan(endY,stY+out,out)
;open_files := systemfunc("ls " + diri + fileI+"*")
;cdf_file1 = addfile(open_files(0),"r")
;time := cdf_file1 ->time
;lat := cdf_file1 ->lat
;lon := cdf_file1 ->lon

;======
;print("Opening ice data")
;dataPFTs= new((/2,(dimsizes(open_files)*dimsizes(time))+1,dimsizes(lat),dimsizes(lon)/),"float")

;dataPFTs!2   ="lat"    ; Set metadata for first array
;dataPFTs!3   = "lon"
;dataPFTs&lat = lat
;dataPFTs&lon = lon
;dataPFTs!1   ="time"
;dataPFTs@_FillValue = -999  

;do i=0, dimsizes(open_files)-1
; fname1 = diri+fileI+"_"+seqFils(i)+"_"
; fname2 = systemfunc("ls " + fname1+ "*")

; fname12 = diri+fileI2+"_"+seqFils(i)+"_"
; fname22 = systemfunc("ls " + fname12+ "*")

 ;print(fname2)

; cdf_file1 = addfile(fname2,"r")
; cdf_file2 = addfile(fname22,"r")

;  if (i.eq.dimsizes(open_files)-1)
;   dataPFTs(0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:) = cdf_file1->field1391
;   dataPFTs(1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:) = cdf_file2->field1391   
;   else 
;    dataPFTs(0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:) = cdf_file1->field1391   
;    dataPFTs(1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:) = cdf_file2->field1391  
;  end if

;   if (i.eq.0)
;   time_seqI = cdf_file1 ->time
;    else
;    time_seqI2 := cdf_file1 ->time
;     time_seqI := array_append_record(time_seqI,time_seqI2,0)
;    end if
;end do 

;dataPFTs&time = time_seqI

;dataPFTs_NH = dataPFTs(:,:,{40:90},{-180:180})

; Need to set the max of these to 1 and min to 0
;dataPFTs_NH = where(dataPFTs_NH.gt.1,1,dataPFTs_NH)
;dataPFTs_NH = where(dataPFTs_NH.lt.0,0,dataPFTs_NH)

;;====== Now open height

;fileH = "ht_convec_sims_100yrAvg_ann_nativedegRes_noBias_Global"
;fileH2 = "ht_convec_sims_noIce_100yrAvg_ann_nativedegRes_noBias_Global"

;dataHT= new((/2,(dimsizes(open_files)*dimsizes(time))+1,dimsizes(lat),dimsizes(lon)/),"float")

;dataHT!2   ="lat"    ; Set metadata for first array
;dataHT!3   = "lon"
;dataHT&lat = lat
;dataHT&lon = lon
;dataHT!1   ="time"
;dataHT@_FillValue = -999  

;do i=0, dimsizes(open_files)-1
; fname1 = diri+fileH+"_"+seqFils(i)+"_"
; fname2 = systemfunc("ls " + fname1+ "*")

; fname12 = diri+fileH2+"_"+seqFils(i)+"_"
; fname22 = systemfunc("ls " + fname12+ "*")

 ;print(fname2)

; cdf_file1 = addfile(fname2,"r")
; cdf_file2 = addfile(fname22,"r")

;  if (i.eq.dimsizes(open_files)-1)
;   dataHT(0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:) = cdf_file1->ht
;   dataHT(1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:) = cdf_file2->ht      
;   else 
;    dataHT(0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:) = cdf_file1->ht
;    dataHT(1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:) = cdf_file2->ht
;  end if

;   if (i.eq.0)
;   time_seqH = cdf_file1 ->time
;    else
;    time_seqH2 := cdf_file1 ->time
;     time_seqH := array_append_record(time_seqH,time_seqH2,0)
;    end if
;end do 

;dataHT&time = time_seqH

;dataHT_NH = dataHT(:,:,{40:90},{-180:180})

;=============== Now calculate area of each grid

;latdis = (111.1983 * 1000) *2.5 ; Distance for 1 degree. This is equal everwhere. Output in meters 
;londis = (111.3210 * 1000) *3.75 ; Distance for 1 degree. This is only at equator
;rad    = 4.0*atan(1.0)/180.0

;pi=new(1,double)
;rad=new(1,double)
;radius_earth=new(1,double)
;pi=2.*asin(1.0)
;rad=pi/180.0
;radius_earth=6371000.0

;allareas := new((/73,96/),"float")
;do i=0,96-1
; allareas(:,i) = (cos(rad*lat)*londis) * latdis   ; Area of gridsqare at each lat/lon output as m2
;end do

;   allareas!0   ="lat"
;   allareas!1   = "lon"
;   allareas&lat = lat
;   allareas&lon = lon  

;  allareas_NH =  allareas({40:90},{-180:180})

;=============== Now caulcate volume in each grid
; Multiply area by fractional coverage, then multiply by height

;data_IceVol = new(dimsizes(dataPFTs_NH), "float")

;do o=0,1
; do f=0,8001-1
;  data_IceVol(o,f,:,:) = (dataPFTs_NH(o,f,:,:) * allareas_NH) * dataHT_NH(o,f,:,:)
;  end do
;end do

;data_IceVol!2   ="lat"    ; Set metadata for first array
;data_IceVol!3   = "lon"
;data_IceVol&lat = lat({40:90})
;data_IceVol&lon = lon
;data_IceVol!1   ="time"
;data_IceVol@_FillValue = -999 
;data_IceVol&time = time_seqH

;system("/bin/rm -f /home/bridge/ea13310/Finland/Finland_Files/test_iceVol.nc")   ; remove any pre-existing file
;setfileoption("nc","Format","NetCDF4Classic") 
;ncdf = addfile("/home/bridge/ea13310/Finland/Finland_Files/test_iceVol.nc" ,"c")  ; open output netCDF file
;ncdf->data_IceVol = data_IceVol
;printVarSummary(hosing_anom_var)


;============================================================
; Open file
 cdf_file1 = addfile("/home/bridge/ea13310/Finland/Finland_Files/test_iceVol.nc","r")
 data_IceVol = cdf_file1->data_IceVol

data_IceVol = data_IceVol  / 1000000000   ; 10^9 ; THis converts to km3
data_IceVol = data_IceVol/1000000  ; 10^6 km3

;Sum the ice volume in Northern Hemisphere

data_IceSum = dim_sum_n(data_IceVol, (/2,3/))

;========================================================================
;========================================================================
; OPen Orbits

orbits := asciiread("/home/bridge/ea13310/Finland/Data/orbital_params_1kyr.txt",(/5001,4/),"float")
orbits(:,0) = abs(orbits(:,0))

; Get the period were interested in

orbits := orbits(ind_nearest_coord(stY/1000,orbits(:,0),0):ind_nearest_coord(endY/1000,orbits(:,0),0),:)
orbits = orbits(::-1,:)
orbits(:,0) = orbits(:,0)*1000

;===========
; Extract same time period from our data

new_tim2 := ind_nearest_coord(orbits(:,0) ,time_seqS,0)

;east := east(new_tim2) 
;west := west(new_tim2) 
;grad := grad(new_tim2)  

;========================================================================
;========================================================================
; Sapropel Data

yr := fspan(0,800,8001)
ls := ispan(0,8000,1)

; This is from https://www.sciencedirect.com/science/article/pii/S0277379117307436

mukalla = ind_nearest_coord((/5,10,102,106,117,135,183,192,202,215,220,225,227,242,244,249,252,258,311,343,356,360/),yr,0)
Hoti = ind_nearest_coord((/5,10,79,83,98,102.5,107.5,130,131,135,177.5,181,185,188,191,198,297,300,305,309,312.5,316.5,322.5,327/),yr,0)
WSannur = ind_nearest_coord((/125,131,212,221,225,228.5,325,331,332.5,343/),yr,0)
Negev = ind_nearest_coord((/108,117.5,118,134,135,142,192,200,200.5,207.5,211,215,215.5,223.5,317,321,331,335,338,342.5,349,353/),yr,0)

; This is from  https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0076514#pone-0076514-g005
;Sapropels=ind_nearest_coord((/4,10,73,78,98,102,115,111,138,143,168,173,186,191,211,216,234,239,284,289,325,330,405,410,420,425,333,338,459,464,480,485,497,503,550,555,568,574,595,600,664,669,689,694/),yr,0)

; ===New saproepls taken from core 964, 966, 969; raw data here : https://www.sciencedirect.com/science/article/pii/S0031018200000596
Sapropels:=ind_nearest_coord((/7,9,80,82,101,103,123,125,171,173,194,196,216,218,239,241,330,332,406,409,460,462,482,484,574,576,596,598,667,669,689,691/),yr,0)


; From EGU screenshots CRAAG - this isnt published and looks a bit rubbish anyway
;craag  = ind_nearest_coord((/3,12.5,12.5,17,56,66,67,71,72,80,82.5,87.5,100,114,142,158,223,231,241,248.5,266,279,281.5,289,295,322.5,375,389,392.5,405,432,439,461,468/),yr,0)

;========
; From larrasoana 2021 - core 967
larraoana = asciiread("/home/bridge/ea13310/Finland/Data/green_sahara_timing_larrasoana.txt",(/88,2/),"float")

larraV = new(dimsizes(larraoana(:,0))*2,"float")

stl = larraoana(:,0) - larraoana(:,1)/2
enl = larraoana(:,0) + larraoana(:,1)/2

do l=0,dimsizes(larraV)-2,2
 larraV(l:l+1) = ((/larraoana(l/2,0) - larraoana(l/2,1)/2, larraoana(l/2,0) + larraoana(l/2,1)/2/))
end do

larraV2 = ind_nearest_coord(larraV(0:41),yr,0)


;======
; All data - Sapropels, then E-W speleothems (Hoti, mukalla, Negev, WSannur, craag)

allData := new((/2,8001/),"float",-999.)

do o=0,dimsizes(larraV2)-2,2
 allData(0,ls(larraV2(o):larraV2(o+1))) = 0.1
end do

do o=0,dimsizes(Sapropels)-2,2
 allData(1,ls(Sapropels(o):Sapropels(o+1))) = 0
end do

;do o=0,dimsizes(Hoti)-2,2
; allData(0,ls(Hoti(o):Hoti(o+1))) = 0.3
;end do

;do o=0,dimsizes(mukalla)-2,2
; allData(1,ls(mukalla(o):mukalla(o+1))) = 0.2
;end do

;do o=0,dimsizes(Negev)-2,2
; allData(2,ls(Negev(o):Negev(o+1))) = 0.1
;end do

;do o=0,dimsizes(WSannur)-2,2
; allData(3,ls(WSannur(o):WSannur(o+1))) = 0
;end do

;do o=0,dimsizes(craag)-2,2
; allData(4,ls(craag(o):craag(o+1))) = -0.1
;end do

;======
; Now open the timeseries plots

; Grant humidity index, Tierney data, Anya Crocker data, ANYTHING FOR WEST SAHARA ? 

grant = asciiread("/home/bridge/ea13310/Finland/Data/Grant_full_3myr.txt",(/6001,2/),"float")
grant(:,0) = grant(:,0)*1000

Tierney_wax = asciiread("/home/bridge/ea13310/Finland/Data/smoothed_tierney.dat",(/431,2/),"float") 

anya_dust = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/hopcroft_dust.txt",(/580,3/),"float")
anya_dust(:,0) = anya_dust(:,0)*1000000

anya_ZrRb = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/ZrRb_Anya_Crocker.txt",(/574,2/),"float")
anya_ZrRb(:,0) = anya_ZrRb(:,0)*1000000

;t36s=ind_nearest_coord(anya_dust(0,0),vp5,0)
;t36e=ind_nearest_coord(anya_dust(dimsizes(anya_dust(:,0))-1,0),vp5,0)
;t37s=ind_nearest_coord(anya_ZrRb(0,0),vp5,0)
;t37e=ind_nearest_coord(anya_ZrRb(dimsizes(anya_ZrRb(:,0))-1,0),vp5,0)


;=== Open some new obs data 

; Lk Bosomtwi data
val38 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m30.txt",(/122,2/),"float")
;Lk BOS pollen data
val43 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m31.txt",(/215,3/),"float") 

; Lk Ohrid Quercus data
val41 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/ohrid_pollen.txt",(/687,3/),"float") 
val41(:,0) = val41(:,0)*1000

; Grant 2022 data
val42 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/grant22.txt",(/2715,2/),"float") 
val42(:,0) = val42(:,0)*1000




;===============================================;===============================================;=============================================== 
; Individual plotting

;===============================================
;==== Plot the model paramaters
delete(attachid1)
delete(plot)
delete(res1)
delete(res2)
delete(res3)
delete(attachres1)

begin

wtype   = "pdf"
 wks =  gsn_open_wks(wtype, "/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/Figure_1_Boundary_CO2")

plot=new(2,graphic)

res1=True
res2=True
res3=True

res1@gsnDraw = False
res1@gsnFrame = False
res2@gsnDraw  = False
res2@gsnFrame = False
res3@gsnDraw  = False
res3@gsnFrame = False

res1@vpHeightF = 0.12 
res1@vpWidthF = 0.70
res2@vpHeightF = res1@vpHeightF
res2@vpWidthF = res1@vpWidthF
res3@vpHeightF = res1@vpHeightF
res3@vpWidthF = res1@vpWidthF

 res1@trXMaxF = 800000
 res1@trXMinF = 0 
 res2@trXMaxF = res1@trXMaxF 
 res2@trXMinF = res1@trXMinF 
  res3@trXMaxF = res1@trXMaxF 
 res3@trXMinF = res1@trXMinF 

 ;res1@tmXMajorGrid= True
 ;res2@tmXMajorGrid= True
 ;res1@tmXMajorGridLineColor = "grey30"
 ;res2@tmXMajorGridLineColor = "grey30"
 ;res1@tmXMajorGridLineDashPattern =1 
 ;res2@tmXMajorGridLineDashPattern =1 
 ;res1@tmXMajorGridThicknessF = 1
 ;res2@tmXMajorGridThicknessF = 1

 ;res1@tmXMinorGrid= True
 ;res3@tmXMinorGrid= True
 ;res1@tmXMinorGridLineColor = "grey30"
 ;res3@tmXMinorGridLineColor = "grey30"
 ;res1@tmXMinorGridLineDashPattern =1.2 
 ;res3@tmXMinorGridLineDashPattern =1.2 
 ;res1@tmXMinorGridThicknessF = 0.7
 ;res3@tmXMinorGridThicknessF = 0.7

  res1@tmXBBorderOn      = False
  res1@tmXBMinorPerMajor = 1
  res1@tmXBOn            = False
  res1@tmXTBorderOn      = False
  ;res1@tmXTOn            = False
  res1@tmYLBorderOn      = False
  ;res1@tmYLMinorPerMajor = 1
  ;res1@tmYLOn            = False
  res1@tmYRBorderOn      = False
  ;res1@tmYROn            = False

  res3@tmXBBorderOn      = False
  res3@tmXBMinorPerMajor = 1
  res3@tmXBOn            = False
  res3@tmXTBorderOn      = False
  ;res3@tmXTOn            = False
  res3@tmYLBorderOn      = False
  ;res3@tmYLMinorPerMajor = 1
  ;res3@tmYLOn            = False
  res3@tmYRBorderOn      = False
  ;res3@tmYROn            = False


;===

 res1@tiYAxisString = "Eccentrictiy"
 res3@tiYAxisString = "Precession"

 res1@tmXTOn  = True
 res1@tmXBOn  = False
 res3@tmXTOn  = False
 res3@tmXBOn  = False

 ;res1@gsnLeftString      = "Orbital Parameters"
 
 res1@trYMinF = -0.05
 res1@trYMaxF = 0.050
; res3@trYMinF = -0.060
; res3@trYMaxF = 0.150

 res1@xyLineColor      = "orange"
 res3@xyLineColor      = "red"

 res1@tiYAxisFontColor     = res1@xyLineColor
 res1@tmYLLabelFontColor   = res1@xyLineColor

 res3@tiYAxisFontColor     = res3@xyLineColor
 res3@tmYRLabelFontColor   = res3@xyLineColor

 ;res2@trXReverse = True
 ;res3@trXReverse = True
 ;res4@trXReverse = True
 res3@trYReverse = True
  
  
 plot(0)  = gsn_csm_xy2(wks,orbits(:,0),orbits(:,1),orbits(:,3),res1,res3) ; create plot

;delete(res3)

;====
delete(res1@trYMinF)
delete(res1@trYMaxF)

res1@tmXTBorderOn      = False
res1@tmXTOn            = False
res3@tmXTBorderOn      = False
res3@tmXTOn            = False

 res1@tiYAxisString = "Ice Vol (10^6 Km3)"
 res1@tmXTOn  = False
 res1@tmXBOn  = True
 res1@xyLineColors := (/"blue","orange"/)
 res1@tiYAxisSide          = "Left"
 res1@tiYAxisFontColor     = "black"
 res1@tmYLLabelFontColor   = "black"
 res1@tmYLLabelsOn         = True
 res1@tmYRLabelsOn         = False
  res1@trYReverse = False

 res3@tiYAxisString = "CO2"
 res3@tmXTOn  = False
 res3@tmXBOn  = True
 ;res3@trYMinF := 3
 ;res3@trYMaxF := 5.1
 ;res3@trYMinF := 22
 ;res3@trYMaxF := 25
 res3@xyLineColor      = "seagreen"
 res3@tiYAxisFontColor     = res3@xyLineColor
 res3@tmYRLabelFontColor   = res3@xyLineColor
 res3@trYReverse = False
  
; plot(1)  = gsn_csm_xy(wks,time_seq,data_IceSum,res1) ; create plot

; plot(1)  = gsn_csm_x2y2(wks,time_seq,benthic(:,0),data_IceSum(:,:),benthic(:,1),res1,res3) ; create plot

plot(1)  = gsn_csm_x2y2(wks,time_seq,epica(:,0),data_IceSum(0,:),epica(:,1),res1,res3) ; create plot

;== Attach plots along the X axes
  attachres1                     = True
  attachres1@gsnAttachPlotsXAxis = True  ;; attaches along x-axis
  attachres1@gsnAttachBorderOn   = False ;; No border please
  attachres2                     = True
  attachres2@gsnAttachPlotsXAxis = True  ;; attaches along x-axis
  attachres2@gsnAttachBorderOn   = False ;; No border please
  attachid1  = gsn_attach_plots(plot(0),plot(1),attachres1,attachres2)

;;;;;; Maximize output on the page and draw everything
  pres = False               ; No resources needed
  maximize_output(wks,pres)  ; Maximize plot on page

end


;===============================================
;==== Plot the Observations
delete(attachid1)
delete(plot)
delete(res1)
delete(res2)
delete(res3)
delete(attachres1)

begin

wtype   = "pdf"
 wks =  gsn_open_wks(wtype, "/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/Figure_1_Observations_t")

plot=new(4,graphic)

res1=True
res2=True
res3=True

res1@gsnDraw = False
res1@gsnFrame = False
res2@gsnDraw  = False
res2@gsnFrame = False
res3@gsnDraw  = False
res3@gsnFrame = False

res1@vpHeightF = 0.15 
res1@vpWidthF = 0.70
res2@vpHeightF = res1@vpHeightF
res2@vpWidthF = res1@vpWidthF
res3@vpHeightF = res1@vpHeightF
res3@vpWidthF = res1@vpWidthF

 res1@trXMaxF = 800000
 res1@trXMinF = 0 
 res2@trXMaxF = res1@trXMaxF 
 res2@trXMinF = res1@trXMinF 
  res3@trXMaxF = res1@trXMaxF 
 res3@trXMinF = res1@trXMinF 

 ;res1@tmXMajorGrid= True
 ;res2@tmXMajorGrid= True
 ;res1@tmXMajorGridLineColor = "grey30"
 ;res2@tmXMajorGridLineColor = "grey30"
 ;res1@tmXMajorGridLineDashPattern =1 
 ;res2@tmXMajorGridLineDashPattern =1 
 ;res1@tmXMajorGridThicknessF = 1
 ;res2@tmXMajorGridThicknessF = 1

 ;res1@tmXMinorGrid= True
 ;res2@tmXMinorGrid= True
 ;res1@tmXMinorGridLineColor = "grey30"
 ;res2@tmXMinorGridLineColor = "grey30"
 ;res1@tmXMinorGridLineDashPattern =1.2 
 ;res2@tmXMinorGridLineDashPattern =1.2 
 ;res1@tmXMinorGridThicknessF = 0.7
 ;res2@tmXMinorGridThicknessF = 0.7


  res1@tmXBBorderOn      = False
  res1@tmXBMinorPerMajor = 1
  ;res1@tmXBOn            = False
  res1@tmXTBorderOn      = False
  ;res1@tmXTOn            = False
  res1@tmYLBorderOn      = False
  ;res1@tmYLMinorPerMajor = 1
  res1@tmYLOn            = False
  res1@tmYRBorderOn      = False
  ;res1@tmYROn            = False

  res2@tmXBBorderOn      = False
  ;res2@tmXBMinorPerMajor = 1
  ;res2@tmXBOn            = False
  res2@tmXTBorderOn      = False
  ;res2@tmXTOn            = False
  res2@tmYLBorderOn      = False
  ;res2@tmYLMinorPerMajor = 1
  ;res2@tmYLOn            = False
  res2@tmYRBorderOn      = False
  ;res2@tmYROn            = False


;=======
res1@tmXBOn    = False
res1@tiYAxisSide          = "Right"
res1@tmYLLabelsOn         = False
res1@tmYRLabelsOn         = True
res2@trXMaxF = 800000
res2@trXMinF = 0

;res1@trYMaxF = 0.7
;res1@trYMinF = -1.2
res1@tiYAxisString     =  "Humidity Index"
res1@xyLineColor           = "brown3"
res1@tiYAxisFontColor      = res1@xyLineColor
res1@tmYLLabelFontColor    = res1@xyLineColor

;res1@gsnYRefLine = 0

 plot(0)=gsn_csm_xy(wks,grant(:,0),grant(:,1),res1)

;===

 res2@xyLineColor = (/"Orange"/)
 res2@tmXBOn               = False
 res2@tmXTOn               = False
 ;res2@tmXBMajorLineColor = "deeppink4"

 res2@tiYAxisSide          = "Right"
 res2@tmYLLabelsOn         = False
 res2@tmYRLabelsOn         = True

 res2@trYReverse = True    ; reverse the Y-axis
 ;res2@trYMaxF = 1.5
 ;res2@trYMinF = -1.5
 res2@tiYAxisFontColor     = res2@xyLineColor
 res2@tmYLLabelFontColor   = res2@xyLineColor
 res2@tiYAxisString     = "Sahara Dust Zr/Rb"

 plot(1)=gsn_csm_xy(wks,anya_ZrRb(:,0),anya_ZrRb(:,1),res2)  

;=======
res1@tmXBOn    = False
res1@tmXTOn               = False
res1@tiYAxisSide          = "Right"
res1@tmYLLabelsOn         = False
res1@tmYRLabelsOn         = True
res2@trXMaxF = 800000
res2@trXMinF = 0

;res1@trYMaxF = 0.7
;res1@trYMinF = -1.2
res1@tiYAxisString     =  "Delt.D Leaf Wax"
res1@trYReverse = True    ; reverse the Y-axis
res1@xyLineColor           = "brown3"
res1@tiYAxisFontColor      = res1@xyLineColor
res1@tmYLLabelFontColor    = res1@xyLineColor

 plot(2)=gsn_csm_xy(wks,Tierney_wax(:,0),Tierney_wax(:,1),res1)

;======
 res2@tmXBOn               = True
res2@vpHeightF = 0.075 
res2@vpWidthF = 0.70

 ;res1@gsnRightString= "4:8N,-13:4E"
 ;res2@gsnLeftString= "Sapropel (top) & Speleothems (E-W Africa - Hoti, Mukalla, Negev, W. Sannur, Craag)" 
 ;res1@tiYAxisString     = "Phytoliths"
 ;res2@xyLineColors = (/"deepskyblue3","deepskyblue3","deepskyblue3","deepskyblue3","deepskyblue3","Green4"/)
 ;res2@tiYAxisFontColor     = res2@xyLineColor
 ;res2@tmYLLabelFontColor   = res2@xyLineColor
 
 res2@xyLineColor = "seagreen"
 res2@tmXTOn  = False
 res2@tmYLOn  = False
res2@tmYROn  = False
 res2@xyLineThicknessF = 13                    ; line thicknesses 
 res2@xyDashPattern   = 0
 ;res2@tiYAxisString     = "Speleothems E-W Africa (top-bot) & Med. Sapropels (bot)"
 res2@tiYAxisString     = "Speleo & Sapropels(bot)"
 res2@trYReverse = False    ; reverse the Y-axis

 res2@trYMaxF =0.1
 res2@trYMinF =-0.1
 
plot(3) = gsn_csm_xy(wks,yr*1000,allData,res2)   

;== Attach plots along the X axes
  attachres1                     = True
  attachres1@gsnAttachPlotsXAxis = True  ;; attaches along x-axis
  attachres1@gsnAttachBorderOn   = False ;; No border please
  attachres2                     = True
  attachres2@gsnAttachPlotsXAxis = True  ;; attaches along x-axis
  attachres2@gsnAttachBorderOn   = False ;; No border please
  attachid1  = gsn_attach_plots(plot(0),plot(1:3),attachres1,attachres2)

;;;;;; Maximize output on the page and draw everything
  pres = False               ; No resources needed
  maximize_output(wks,pres)  ; Maximize plot on page

end



;===============================================
;==== Plot the Model data

; STANDARDISE MONSSON INDEX


delete(attachid1)
delete(plot)
delete(res1)
delete(res2)
delete(res3)
delete(attachres1)

begin

wtype   = "pdf"
wks =  gsn_open_wks(wtype, "/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/Figure_1_Model_noBias")

plot=new(3,graphic)

res1=True
res2=True
res3=True

res1@gsnDraw = False
res1@gsnFrame = False
res2@gsnDraw  = False
res2@gsnFrame = False
res3@gsnDraw  = False
res3@gsnFrame = False

res1@vpHeightF = 0.12 
res1@vpWidthF = 0.70
res2@vpHeightF = res1@vpHeightF
res2@vpWidthF = res1@vpWidthF
res3@vpHeightF = res1@vpHeightF
res3@vpWidthF = res1@vpWidthF

 res1@trXMaxF = 800000
 res1@trXMinF = 0 
 res2@trXMaxF = res1@trXMaxF 
 res2@trXMinF = res1@trXMinF 
 res3@trXMaxF = res1@trXMaxF 
 res3@trXMinF = res1@trXMinF 

 ;res1@tmXMajorGrid= True
 ;res2@tmXMajorGrid= True
 ;res1@tmXMajorGridLineColor = "grey30"
 ;res2@tmXMajorGridLineColor = "grey30"
 ;res1@tmXMajorGridLineDashPattern =1 
 ;res2@tmXMajorGridLineDashPattern =1 
 ;res1@tmXMajorGridThicknessF = 1
 ;res2@tmXMajorGridThicknessF = 1

 ;res1@tmXMinorGrid= True
 ;res2@tmXMinorGrid= True
 ;res1@tmXMinorGridLineColor = "grey30"
 ;res2@tmXMinorGridLineColor = "grey30"
 ;res1@tmXMinorGridLineDashPattern =1.2 
 ;res2@tmXMinorGridLineDashPattern =1.2 
 ;res1@tmXMinorGridThicknessF = 0.7
 ;res2@tmXMinorGridThicknessF = 0.7


  res1@tmXBBorderOn      = False
  res1@tmXBMinorPerMajor = 1
  ;res1@tmXBOn            = False
  res1@tmXTBorderOn      = False
  ;res1@tmXTOn            = False
  res1@tmYLBorderOn      = False
  ;res1@tmYLMinorPerMajor = 1
  res1@tmYLOn            = False
  res1@tmYRBorderOn      = False
  ;res1@tmYROn            = False

  res2@tmXBBorderOn      = False
  ;res2@tmXBMinorPerMajor = 1
  ;res2@tmXBOn            = False
  res2@tmXTBorderOn      = False
  ;res2@tmXTOn            = False
  res2@tmYLBorderOn      = False
  ;res2@tmYLMinorPerMajor = 1
  ;res2@tmYLOn            = False
  res2@tmYRBorderOn      = False
  ;res2@tmYROn            = False


;=======

 ;res1@gsnLeftString= "Sahara/Sahel Precipitation" 
 
 ;res1@xyLineColors = (/"blue","orange","blue","orange"/)
 ;res1@xyLineColors = (/"blue","orange","palegreen4"/)
 ;res1@xyDashPatterns   = (/0,0,5,5/)
 ;res1@xyLineColors = (/"orange","palegreen4","blue"/)
 res1@xyLineColors = (/"dodgerblue3"/)
 res1@xyDashPatterns   = (/0,0,0/)
 res1@xyLineThicknessF = 1.4
 res1@tmXBOn               = False
 res1@tmXTOn               = False

 res1@tiYAxisSide          = "left"
 res1@trYMaxF = 580;380  ;450
 res1@trYMinF = 0
 res1@tiYAxisFontColor     = "black"
 res1@tmYLLabelFontColor   = "black"
 res1@tiYAxisString     = "Annual Precip (mm/yr)"

 res1@tmYLLabelsOn         = True
 res1@tmYRLabelsOn         = False

 res1@gsnYRefLineColor      = "transparent"
 res1@gsnAboveYRefLineColor = "dodgerblue3"
 res1@gsnYRefLine           = ahp_am
 res1@tmYLOn            = True
 
 plot(0)  = gsn_csm_xy(wks,time_seq,data_avg(0,:),res1) ; create plot
 ;plot(0)  = gsn_csm_xy(wks,time_seq,((/data_avg(1,:),data_avg(2,:),data_avg(0,:)/)),res1) ; create plot
 ;plot(0)  = gsn_csm_xy(wks,time_seq,((/data_avgW(0,:),data_avgW(1,:),data_avgE(0,:),data_avgE(1,:)/)),res1) ; create plot


;=====

; res2@xyLineColors := (/"blue","orange"/)
; res2@tmXBOn               = False
; res2@tmXTOn               = False
; res2@tiYAxisSide          = "Right"
; res2@tiYAxisFontColor     = "black"
; res2@tmYLLabelFontColor   = "black"
; res2@tiYAxisString     = "WAM Index (Insolation)"
; res2@tmYLLabelsOn         = False
; res2@tmYRLabelsOn         = True
; res2@xyLineThicknessF = 1 

;plot(1)  = gsn_csm_xy(wks,time_seq,m_ind(0,:),res2) ; create plot


;=====

 ;res2@xyLineColors := (/"blue","orange"/)
 res2@xyLineColors := (/"orange"/)
 res2@tmXBOn               = False
 res2@tmXTOn               = False
 res2@tiYAxisSide          = "Right"
 res2@tiYAxisFontColor     = "black"
 res2@tmYLLabelFontColor   = "black"
 res2@tiYAxisString     = "WAM Index"
 res2@tmYLLabelsOn         = True
 res2@tmYRLabelsOn         = False
 res2@xyLineThicknessF = 1 
  res2@xyDashPatterns   = (/0,0/)

plot(1)  = gsn_csm_xy(wks,time_seq,dim_standardize(Wind_index(0,:),0),res2) ; create plot

;=====

res1@vpHeightF = 0.08 
res1@vpWidthF = 0.70

res1@tmXBBorderOn      = True
res1@tmYLOn            = True

 res1@xyLineColors      := (/"orange","palegreen4","blue"/)
 res1@xyLineColors      := "dodgerblue3"
 res1@tiYAxisString     = ""
 res1@tmXBOn               = True
 res1@tmXTOn               = False
 res1@tiYAxisSide          = "left"
 res1@tiYAxisFontColor     = "black"
 res1@tmYLLabelFontColor   = "black"
 res1@tmYLLabelsOn         = True
 res1@tmYRLabelsOn         = False
 res1@xyLineThicknessF = 1.4 
  res1@tiYAxisString     = "Lat."

 ;res1@xyYStyle = "Irregular"
 ;res1@xyYIrregularPoints = (/  0,8,9,10 /)

 res1@trYMaxF =12
 res1@trYMinF =3
  res1@tiXAxisString     = "Year BP"

;plot(2) = gsn_csm_xy(wks,time_seq,((/data_precip_lat(1,:),data_precip_lat(2,:),data_precip_lat(0,:)/)),res1)   
plot(2) = gsn_csm_xy(wks,time_seq,data_precip_lat,res1) 

;=======  Attach plots along the X axes
  attachres1                     = True
  attachres1@gsnAttachPlotsXAxis = True  ;; attaches along x-axis
  attachres1@gsnAttachBorderOn   = False ;; No border please
  attachres2                     = True
  attachres2@gsnAttachPlotsXAxis = True  ;; attaches along x-axis
  attachres2@gsnAttachBorderOn   = False ;; No border please
  attachid1  = gsn_attach_plots(plot(0),plot(1:2),attachres1,attachres2)

;;;;;; Maximize output on the page and draw everything
  pres = False               ; No resources needed
  maximize_output(wks,pres)  ; Maximize plot on page

end



;=============================================== =============================================== =============================================== 
;=============================================== =============================================== =============================================== 

;===============================================
;==== Plot East/West Precipiation timeseries

delete(attachid1)
delete(plot)
delete(res1)
delete(res2)
delete(res3)
delete(attachres1)

begin

wtype   = "pdf"
wks =  gsn_open_wks(wtype, "/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/Sahara_E_W_precip_noBias")

plot=new(1,graphic)

res1=True
res2=True
res3=True

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

 res1@gsnLeftString= "West (blue) & East (orange) Saharan Precipitation" 
 
 res1@xyLineColors = (/"dodgerblue","orange"/)
 res1@xyDashPatterns   = (/0,0/)
 res1@xyLineThicknessF = 1.4
 ;res1@tmXBOn               = False
 ;res1@tmXTOn               = False

 res1@tiYAxisSide          = "left"
 res1@trYMaxF = 780;380  ;450
 res1@trYMinF = 0
 res1@tiYAxisFontColor     = "black"
 res1@tmYLLabelFontColor   = "black"
 res1@tiYAxisString     = "Annual Precip (mm/yr)"

 res1@tmYLLabelsOn         = True
 res1@tmYRLabelsOn         = False

 res1@tmYLOn            = True
 
plot  = gsn_csm_xy(wks,time_seq,((/data_avgW(0,:),data_avgE(0,:)/)),res1) ; create plot

end




















































delete(attachid1)
delete(plot)
delete(res1)
delete(res2)
delete(res3)
delete(attachres1)

begin

wtype   = "pdf"
 wks =  gsn_open_wks(wtype, "/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/Figure_1_Observations_Test")

plot=new(9,graphic)

res1=True
res2=True
res3=True

res1@gsnDraw = False
res1@gsnFrame = False
res2@gsnDraw  = False
res2@gsnFrame = False
res3@gsnDraw  = False
res3@gsnFrame = False

res1@vpHeightF = 0.1 
res1@vpWidthF = 0.70
res2@vpHeightF = res1@vpHeightF
res2@vpWidthF = res1@vpWidthF
res3@vpHeightF = res1@vpHeightF
res3@vpWidthF = res1@vpWidthF

 res1@trXMaxF = 800000
 res1@trXMinF = 0 
 res2@trXMaxF = res1@trXMaxF 
 res2@trXMinF = res1@trXMinF 
  res3@trXMaxF = res1@trXMaxF 
 res3@trXMinF = res1@trXMinF 

 ;res1@tmXMajorGrid= True
 ;res2@tmXMajorGrid= True
 ;res1@tmXMajorGridLineColor = "grey30"
 ;res2@tmXMajorGridLineColor = "grey30"
 ;res1@tmXMajorGridLineDashPattern =1 
 ;res2@tmXMajorGridLineDashPattern =1 
 ;res1@tmXMajorGridThicknessF = 1
 ;res2@tmXMajorGridThicknessF = 1

 ;res1@tmXMinorGrid= True
 ;res2@tmXMinorGrid= True
 ;res1@tmXMinorGridLineColor = "grey30"
 ;res2@tmXMinorGridLineColor = "grey30"
 ;res1@tmXMinorGridLineDashPattern =1.2 
 ;res2@tmXMinorGridLineDashPattern =1.2 
 ;res1@tmXMinorGridThicknessF = 0.7
 ;res2@tmXMinorGridThicknessF = 0.7


  res1@tmXBBorderOn      = False
  res1@tmXBMinorPerMajor = 1
  ;res1@tmXBOn            = False
  res1@tmXTBorderOn      = False
  ;res1@tmXTOn            = False
  res1@tmYLBorderOn      = False
  ;res1@tmYLMinorPerMajor = 1
  res1@tmYLOn            = False
  res1@tmYRBorderOn      = False
  ;res1@tmYROn            = False

  res2@tmXBBorderOn      = False
  ;res2@tmXBMinorPerMajor = 1
  ;res2@tmXBOn            = False
  res2@tmXTBorderOn      = False
  ;res2@tmXTOn            = False
  res2@tmYLBorderOn      = False
  ;res2@tmYLMinorPerMajor = 1
  ;res2@tmYLOn            = False
  res2@tmYRBorderOn      = False
  ;res2@tmYROn            = False



  res1@tmYLLabelFontHeightF  = 0.008
  res1@tmYRLabelFontHeightF = 0.008
    res2@tmYLLabelFontHeightF  = 0.008
  res2@tmYRLabelFontHeightF = 0.008




;=======
res1@tmXBOn    = False
res1@tiYAxisSide          = "Right"
res1@tmYLLabelsOn         = False
res1@tmYRLabelsOn         = True
res2@trXMaxF = 800000
res2@trXMinF = 0

;res1@trYMaxF = 0.7
;res1@trYMinF = -1.2
res1@tiYAxisString     =  "Humidity"
res1@xyLineColor           = "brown3"
res1@tiYAxisFontColor      = res1@xyLineColor
res1@tmYLLabelFontColor    = res1@xyLineColor

 plot(0)=gsn_csm_xy(wks,grant(:,0),grant(:,1),res1)

;======
res1@tiYAxisString     =  "Grant Ba/Al"
res1@xyLineColor           = "pink"
res1@tiYAxisFontColor      = res1@xyLineColor
res1@tmYLLabelFontColor    = res1@xyLineColor

 plot(1)=gsn_csm_xy(wks,val42(:,0),val42(:,1),res1)



;======
res1@tiYAxisString     =  "BOS d15N"
res1@xyLineColor           = "purple"
res1@tiYAxisFontColor      = res1@xyLineColor
res1@tmYLLabelFontColor    = res1@xyLineColor
res1@trYReverse = True    ; reverse the Y-axis

 plot(2)=gsn_csm_xy(wks,val38(:,0),val38(:,1),res1)



;======
res1@tiYAxisString     =  "BOS Pol_Dca"
res1@xyLineColor           = "violet"
res1@tiYAxisFontColor      = res1@xyLineColor
res1@tmYLLabelFontColor    = res1@xyLineColor
res1@trYReverse = False    ; reverse the Y-axis

 plot(3)=gsn_csm_xy(wks,val43(:,0),val43(:,2),res1)


;======
res1@tiYAxisString     =  "Ohrid Quercus"
res1@xyLineColor           = "orangered"
res1@tiYAxisFontColor      = res1@xyLineColor
res1@tmYLLabelFontColor    = res1@xyLineColor
res1@trYReverse = False    ; reverse the Y-axis

 plot(4)=gsn_csm_xy(wks,val41(:,0),val41(:,2),res1)



;===

 res2@xyLineColor = (/"Orange"/)
 res2@tmXBOn               = False
 res2@tmXTOn               = False
 ;res2@tmXBMajorLineColor = "deeppink4"

 res2@tiYAxisSide          = "Right"
 res2@tmYLLabelsOn         = False
 res2@tmYRLabelsOn         = True

 res2@trYReverse = True    ; reverse the Y-axis
 ;res2@trYMaxF = 1.5
 ;res2@trYMinF = -1.5
 res2@tiYAxisFontColor     = res2@xyLineColor
 res2@tmYLLabelFontColor   = res2@xyLineColor
 res2@tiYAxisString     = "Dust Zr/Rb"

 plot(5)=gsn_csm_xy(wks,anya_ZrRb(:,0),anya_ZrRb(:,1),res2)  

;=======
res1@tmXBOn    = False
res1@tmXTOn               = False
res1@tiYAxisSide          = "Right"
res1@tmYLLabelsOn         = False
res1@tmYRLabelsOn         = True
res2@trXMaxF = 800000
res2@trXMinF = 0

;res1@trYMaxF = 0.7
;res1@trYMinF = -1.2
res1@tiYAxisString     =  "Lf Wax"
res1@trYReverse = True    ; reverse the Y-axis
res1@xyLineColor           = "brown3"
res1@tiYAxisFontColor      = res1@xyLineColor
res1@tmYLLabelFontColor    = res1@xyLineColor

 plot(6)=gsn_csm_xy(wks,Tierney_wax(:,0),Tierney_wax(:,1),res1)

;======
 res2@tmXBOn               = True
res2@vpHeightF = 0.075 
res2@vpWidthF = 0.70

 ;res1@gsnRightString= "4:8N,-13:4E"
 ;res2@gsnLeftString= "Sapropel (top) & Speleothems (E-W Africa - Hoti, Mukalla, Negev, W. Sannur, Craag)" 
 ;res1@tiYAxisString     = "Phytoliths"
 ;res2@xyLineColors = (/"deepskyblue3","deepskyblue3","deepskyblue3","deepskyblue3","deepskyblue3","Green4"/)
 ;res2@tiYAxisFontColor     = res2@xyLineColor
 ;res2@tmYLLabelFontColor   = res2@xyLineColor
 
 res2@xyLineColor = "seagreen"
 res2@tmXTOn  = False
 res2@tmYLOn  = False
res2@tmYROn  = False
 res2@xyLineThicknessF = 13                    ; line thicknesses 
 res2@xyDashPattern   = 0
 ;res2@tiYAxisString     = "Speleothems E-W Africa (top-bot) & Med. Sapropels (bot)"
 ;res2@tiYAxisString     = "Speleo & Sapropels(bot)"
 res2@tiYAxisString     = ""
 res2@trYReverse = False    ; reverse the Y-axis

 res2@trYMaxF =0.1
 res2@trYMinF =-0.1
 
plot(7) = gsn_csm_xy(wks,yr*1000,allData,res2)   

;======
res1@vpHeightF = 0.15 
res1@vpWidthF = 0.70

 ;res1@gsnLeftString= "Sahara/Sahel Precipitation" 
 
 ;res1@xyLineColors = (/"blue","orange","blue","orange"/)
 ;res1@xyLineColors = (/"blue","orange","palegreen4"/)
 ;res1@xyDashPatterns   = (/0,0,5,5/)
 ;res1@xyLineColors = (/"orange","palegreen4","blue"/)
 res1@xyLineColors = (/"dodgerblue3"/)
 res1@xyDashPatterns   = (/0,0,0/)
 res1@xyLineThicknessF = 1.4
 res1@tmXBOn               = True
 res1@tmXTOn               = False

 res1@tiYAxisSide          = "left"
 res1@trYMaxF = 580;380  ;450
 res1@trYMinF = 0
 res1@tiYAxisFontColor     = "black"
 res1@tmYLLabelFontColor   = "black"
 res1@tiYAxisString     = "Ann Precip(mm/yr)"

 res1@tmYLLabelsOn         = True
 res1@tmYRLabelsOn         = False

 res1@gsnYRefLineColor      = "transparent"
 res1@gsnAboveYRefLineColor = "dodgerblue3"
 res1@gsnYRefLine           = ahp_am
 res1@tmYLOn            = True
 res1@trYReverse = False    ; reverse the Y-axis
 
 plot(8)  = gsn_csm_xy(wks,time_seq,data_avg(0,:),res1) ; create plot





;== Attach plots along the X axes
  attachres1                     = True
  attachres1@gsnAttachPlotsXAxis = True  ;; attaches along x-axis
  attachres1@gsnAttachBorderOn   = False ;; No border please
  attachres2                     = True
  attachres2@gsnAttachPlotsXAxis = True  ;; attaches along x-axis
  attachres2@gsnAttachBorderOn   = False ;; No border please
  attachid1  = gsn_attach_plots(plot(0),plot(1:8),attachres1,attachres2)

;;;;;; Maximize output on the page and draw everything
  pres = False               ; No resources needed
  maximize_output(wks,pres)  ; Maximize plot on page

end







; Lk Ohrid Quercus data
val41 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/ohrid_pollen.txt",(/687,3/),"float") 
val41(:,0) = val41(:,0)*1000





