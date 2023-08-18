; This Plots Figure 2 - Spatial maps, 
; This plots Figure 3 - Vegetation plots


; =====================================================================
load "/home/bridge/swsvalde/ummodel/scripts/new_plots_scripts/ncl_files/my_ncl_code.ncl"
load "/home/bridge/swsvalde/ummodel/scripts/new_plots_scripts/ncl_files/initialise_myncl_variables.ncl"
load "/home/bridge/ea13310/Finland/Scripts/sub_scripts/quaternary_timeseries_functions.ncl"
; =====================================================================
;  begin;
;  xwks=new(1,graphic)
;  res1=True

;======================================================================

; Variable:

var = "precip_mm_srf"   ;wind / currents
out=32000 ; file size yr

;======================================================================
; Open the Precip data & Isolate the AHPs

print("Isolating the AHPs")

endY = 800000 ; For the data files   ;!! I have to identify this to order the files properly!
stY = 0 ; For the data files
seqFils := ispan(endY,stY+out,out)

diri = "/home/bridge/ea13310/Finland/Finland_Files/Spline/"
filen = "precip_mm_srf_convec_sims_100yrAvg_ann_1degRes_noBias_Global"

open_files := systemfunc("ls " + diri + filen+"*")
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

data = new((/(dimsizes(open_files)*dimsizes(time))+1,ilat1,ilon1/),"float")
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

data = data*365

;================
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

;=======================
; Make & average our data
data_avg = wgt_areaave(mask(data,mask_af,1.),clat_t,1.0,0) 

;====
; Isolate AHPs -  where 1stddev above the mean
ahp_am = avg(data_avg)+stddev(data_avg) ; This is the thresold value to define the AHP
ahp = ind(data_avg.ge.ahp_am) ; These are the indices for yrs when we have AHP
;noAHPS = ind(data_avg.lt.100) ; These are the indices for yrs when we dont have AHP - I have put this as less than 100mm/yr

; asciiwrite("/home/bridge/ea13310/Finland/Data/ahp.txt" ,ahp)
;ahp = asciiread("/home/bridge/ea13310/Finland/Data/ahp.txt" ,-1, "integer")
;noAHPS = asciiread("/home/bridge/ea13310/Finland/Data/noAHPS.txt",-1, "integer")
PMAX = asciiread("/home/bridge/ea13310/Finland/Data/PMAX.txt",-1, "integer")
;====================================================================
   dataAHPs := new((/3,ilat1,ilon1/),"float")
   dataAHPs!1   ="lat"    ; Set metadata for first array
   dataAHPs!2   = "lon"
   dataAHPs&lat = lat
   dataAHPs&lon = lon
   dataAHPs@_FillValue = -999 


; NEED TO ROTATE THE PMAX HERE?!!!!?!?! OR DO ind_nearest_coord TO THE TIME_SEQ?

    dataAHPs(0,:,:) = dim_avg_n(data(ahp,:,:),0)
    dataAHPs(1,:,:) = dim_avg_n(data(PMAX,:,:),0)
    dataAHPs(2,:,:) =  dataAHPs(0,:,:) - dataAHPs(1,:,:)

delete(data)


;======================================================================;======================================================================
;======================================================================;======================================================================

; Now make the contour map for the laransona vegeation classification

; First mask out the ocean.
cdf_file = addfile("/home/bridge/ea13310/Finland/Finland_Files/Spline/precip_mm_srf_convec_sims_100yrAvg_ann_1degRes_CRU_Global_32000_0kyr.nc","r") ; 
contour_mask = cdf_file ->mask(0,:,:) ; This for the mask

dataAHP_mask = mask(dataAHPs,contour_mask,1.)
copy_VarMeta(dataAHPs,dataAHP_mask)

; Get rid over values above Sahara and Arabia

dataAHP_mask(:,{36:90},{-180:180}) = 0
dataAHP_mask(:,{30:90},{35:180}) = 0
dataAHP_mask(:,{20:90},{50:180}) = 0

;=== Now convert Meditterean values back to 0

;dataAHP_maskmed = dataAHP_mask
;dataAHP_maskmed(:,{-90:28},{-180:180}) = 0
;====

;x1D2      = ndtooned (dataAHP_maskmed)
;imed    := ind(x1D2.ge.250) 

x1D      = ndtooned (dataAHP_mask)
i50    := ind(x1D.lt.100) 
i5100    := ind(x1D.ge.100.and.x1D.lt.250) 
i5250    := ind(x1D.ge.250.and.x1D.lt.1250) 
i51250   := ind(x1D.ge.1250.and.x1D.lt.1750) 
i51750   := ind(x1D.ge.1750)

x1D(i50) = 0.5   
x1D(i5100) = 1.5  
x1D(i5250) = 2.5  
x1D(i51250) = 3.5
x1D(i51750) = 4.5
;x1D(imed) = 5.5

dataAHP_mask_vals = onedtond(x1D, dimsizes(dataAHP_mask))
copy_VarMeta(dataAHP_mask,dataAHP_mask_vals)

;======================================================================;======================================================================

print("Opening the wind data") ; To caluclate posiion of ITCZ

 filen = "u_mm_10m_convec_sims_100yrAvg_jja_1degRes_noBias_Global"
 filen2 = "v_mm_10m_convec_sims_100yrAvg_jja_1degRes_noBias_Global"

   dataW := new((/3,(dimsizes(open_files)*dimsizes(time))+1,ilat1,ilon1/),"float") ; u then v
   dataW!2   ="lat"    ; Set metadata for first array
   dataW!3   = "lon"
   dataW&lat = lat
   dataW&lon = lon
   dataW!1   ="time"
   dataW@_FillValue = -999 

;=========
do i=0, dimsizes(open_files)-1
  
   fname1 = diri+filen+"_"+seqFils(i)+"_"
   fname2 = systemfunc("ls " + fname1+ "*")
   cdf_file1 = addfile(fname2,"r")
 
   fname12 = diri+filen2+"_"+seqFils(i)+"_"
   fname22 = systemfunc("ls " + fname12+ "*")
   cdf_file2 = addfile(fname22,"r")

  ;print(fname2)

   if (i.eq.dimsizes(open_files)-1)
     dataW(0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:) = cdf_file1->u_mm_10m    ;!!! CHANGE VARIABLE NAME HERE
     dataW(1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:) = cdf_file2->v_mm_10m    ;!!! CHANGE VARIABLE NAME HERE
    else 
     dataW(0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:) = cdf_file1->u_mm_10m    ;!!! CHANGE VARIABLE NAME HERE
     dataW(1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:) = cdf_file2->v_mm_10m    ;!!! CHANGE VARIABLE NAME HERE
   end if

end do 

dataW(2,:,:,:) = wind_speed(dataW(0,:,:,:),dataW(1,:,:,:))

   dataAHPW := new((/3,3,ilat1,ilon1/),"float")  ; time, u/v/speed , lat, lon
   dataAHPW!2   ="lat"    ; Set metadata for first array
   dataAHPW!3   = "lon"
   dataAHPW&lat = lat
   dataAHPW&lon = lon
   dataAHPW@_FillValue = -999 

    dataAHPW(0,:,:,:) = dim_avg_n(dataW(:,ahp,:,:),1)
    dataAHPW(1,:,:,:) = dim_avg_n(dataW(:,PMAX,:,:),1)
    dataAHPW(2,:,:,:) = dataAHPW(0,:,:,:) - dataAHPW(1,:,:,:)

delete(dataW)
;========================================================================================================================================================

; NOW OPen the PFTs data - dont need to do this, open saved NetCDF

;out=8000 ; file size yr
;endY = 800000 ; For the data files   ;!! I have to identify this to order the files properly!
;stY = 0 ; For the data files
;seqFils := ispan(endY,stY+out,out)
;diri = "/home/bridge/ea13310/Finland/Finland_Files/Spline/"
;    filen = "fracPFTs_mm_srf_convec_sims_100yrAvg_ann_1degRes_noBias_Global"
;    open_files := systemfunc("ls " + diri + filen+"*")
;   cdf_file1 = addfile(open_files(0),"r")
;   lon = cdf_file1 ->lon
;  lat = cdf_file1 ->lat
;time:= cdf_file1 ->time
;ilon1=dimsizes(lon)
;ilat1=dimsizes(lat) 

; Extract just Africa - get the lat/lons
; latsE = ind_nearest_coord((/-40,50/), lat,0)
; lonsE = ind_nearest_coord((/-30,70/), lon,0)

;    dataP := new((/(dimsizes(open_files)*dimsizes(time))+1,6,dimsizes(lat(latsE(0):latsE(1))),dimsizes(lon(lonsE(0):lonsE(1)))/),"float")
;    dataP!2   ="lat"    ; Set metadata for first array
;    dataP!3   = "lon"
;    dataP&lat = lat(latsE(0):latsE(1))
;    dataP&lon = lon(lonsE(0):lonsE(1))
;    dataP!0   ="time"
;    dataP!1   ="depth"
;    dataP@_FillValue = -999 

;=========
;do i=0, dimsizes(open_files)-1
  
;   fname1 = diri+filen+"_"+seqFils(i)+"_"
;   fname2 = systemfunc("ls " + fname1+ "*")
;   cdf_file1 = addfile(fname2,"r")

;  print(seqFils(i))

;   if (i.eq.dimsizes(open_files)-1)
;     dataP(i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:,:) = cdf_file1->fracPFTs_mm_srf(:,(/0,1,2,3,4,7/),latsE(0):latsE(1),lonsE(0):lonsE(1))  ;!!! CHANGE VARIABLE NAME HERE
;     else 
;      dataP(i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:,:) = cdf_file1->fracPFTs_mm_srf(:,(/0,1,2,3,4,7/),latsE(0):latsE(1),lonsE(0):lonsE(1))   ;!!! CHANGE VARIABLE NAME HERE
 ;   end if
;end do

; Now identify the most prominant vegetation in each grid square
; Make a new array to put indices in
;    indPFT := new((/(dimsizes(open_files)*dimsizes(time))+1,dimsizes(lat(latsE(0):latsE(1))),dimsizes(lon(lonsE(0):lonsE(1)))/),"float")
;    indPFT!1   ="lat"    ; Set metadata for first array
;    indPFT!2   = "lon"
;    indPFT&lat = lat(latsE(0):latsE(1))
;    indPFT&lon = lon(lonsE(0):lonsE(1))
;    indPFT!0   ="time"
;    indPFT@_FillValue = -999 
;maxind(indPFT(0,{15},{0}))

;=====
;do i=0,8001-1
; print(i+0)
; do h=0,91-1
;  do l=0,101-1
;   indPFT(i,h,l) = maxind(dataP(i,:,h,l))
;  end do
; end do
;end do

; Save this array =====
;  begin
;  system("/bin/rm -f /home/bridge/ea13310/Finland/Finland_Files/PFTs.nc")   ; remove any pre-existing file
;  ncdf = addfile("/home/bridge/ea13310/Finland/Finland_Files/PFTs.nc" ,"c")  ; open output netCDF file
;  ncdf->indPFT =indPFT
;  end 

;=== OPEN the PFTs index

 cdf_file1 = addfile("/home/bridge/ea13310/Finland/Finland_Files/PFTs.nc","r")
 indPFT = cdf_file1->indPFT

  latsE = ind_nearest_coord((/-40,50/), lat,0)
  lonsE = ind_nearest_coord((/-30,70/), lon,0)

   dataAHPP := new((/2,dimsizes(lat(latsE(0):latsE(1))),dimsizes(lon(lonsE(0):lonsE(1)))/),"float")
   dataAHPP!1   ="lat"    ; Set metadata for first array
   dataAHPP!2   = "lon"
   dataAHPP&lat = lat(latsE(0):latsE(1))
   dataAHPP&lon = lon(lonsE(0):lonsE(1))
   dataAHPP@_FillValue = -999 

    dataAHPP(0,:,:) = round(dim_avg_n(indPFT(ahp,:,:),0),0)
    dataAHPP(1,:,:) = round(dim_avg_n(indPFT(PMAX,:,:),0),0)

dataAHPP = dataAHPP+0.5

;delete(dataW)

;==============================;==============================;==============================;==============================
;==============================;==============================;==============================;==============================
; NOW DO THE PLOTTING

begin

wks = gsn_open_wks("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/precip_ANN_AHPs_anomalies_maps_t.pdf")  
plot = new (3, graphic)   

res1=True

 contour_list0000:=(/0,50,100,150,200,250,300,350,400,500,600,800,1000,1500,2000,2500/)
 contour_list00001:=(/-800,-700,-600,-500,-400,-300,-250,-200,-150,-100,-75,-50,-25,0,25,50,75,100,150,200,250,300,400,500,600,700,800/)
 my_fix_contours(dataAHPs(0,:,:),contour_list0000)
 colormap_orig0000=(/"(/0.56,0.17,0.93/)","(/0,0,0.93/)","(/0.52,0.80,0.92/)","(/1,1,1/)"/)
 colormap_orig0000=colormap_orig0000(::-1)
  ;colormap_orig0000=colormap_orig0000(::-1)
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
 res1@mpMaxLatF = 50
 res1@mpMinLonF = -30
 res1@mpMaxLonF = 70

 res1@mpGeophysicalLineColor="Black"
 ;res1@mpFillOn = False
 res1@mpPerimOn         = True

res1@gsnScalarContour = True

 res1@mpGeophysicalLineColor="Black"
 res1@mpFillOn = False
 res1@mpPerimOn         = True
 res1@mpOutlineDrawOrder    = "PostDraw"

 res1@gsnLeftString = "Composite PMax Precip (mm/yr)"
 plot(0) = gsn_csm_contour_map(wks,dataAHPs(1,:,:),res1)

 res1@gsnLeftString = "Composite Humid Periods (mm/yr)"
 plot(1) = gsn_csm_contour_map(wks,dataAHPs(0,:,:),res1)

;====
my_fix_contours(dataAHPs(2,:,:),contour_list00001)
colormap_orig0000=(/"(/0.56,0.17,0.93/)","(/0,0,0.93/)","(/0.52,0.80,0.92/)","(/1,1,1/)","(/1,0.64,0/)","(/0.93,0,0/)","(/1,0.08,0.58/)"/)
colormap_orig0000=colormap_orig0000(::-1)
colormap_revised0000=my_StretchColorMap(colormap_orig0000,contour_list00001)
delete(colormap_orig0000)
my_updateColors1a(colormap_revised0000,contour_list00001,"zero","Gray91","-1","Gray91")
res1@gsnSpreadColors = False
ColorMap0000:=colormap_revised0000
delete(colormap_revised0000)
res1@cnLevels:=contour_list00001
res1@cnFillPalette:=ColorMap0000

;===

res1@gsnLeftString = "Anomaly (NAHP-PMax; mm/yr)"
plot(2) = gsn_csm_contour_map(wks,dataAHPs(2,:,:),res1)

gsn_panel(wks,plot,(/1,3/),False)

delete(res1)
end

;=========================

begin

wks = gsn_open_wks("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/PFT_larrasoana_AHPS2_t.pdf")  
plot = new (3, graphic)   

gsn_define_colormap(wks,"testcmap")

res=True
res1=True

res1@gsnDraw                = False              ; dont draw
res1@gsnFrame               = False 
res@gsnDraw                = False              ; dont draw
res@gsnFrame               = False              ; dont advance frame

  res             = True
  ;res@gsnMaximize = True                        ; maximize plot in frame
  res@mpFillOn    = False                       ; turn map fill off
  res@mpOutlineOn = True                        ; turn the map outline on
  res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res@cnLevels    = (/ 0,1,2,3,4,5/)   ; set levels
  res@cnFillOn    = True                        ; turn on color fill
  res@cnLinesOn   = False                       ; turn off the contour lines
  res@cnFillColors = (/ -1,-1,115,170,180,64,50/)  ; set the colors to be used
  res@cnLineLabelsOn = False                    ; turn the line labels off

 res@mpMinLatF =  0
 res@mpMaxLatF = 40
 res@mpMinLonF = -30
 res@mpMaxLonF = 70
 
  res1@cnLineColor  = "black"  
  res1@cnLevelSelectionMode = "ManualLevels"  ; manually set the contour levels with the following 3 resources
  res1@cnMinLevelValF  = 100;250        ; set the minimum contour level
  res1@cnMaxLevelValF  = 2000;500         ; set the maximum contour level
  res1@cnLevelSpacingF = 400;250       
  res1@cnLineLabelsOn       = True

 ;res1@mpMinLatF =  0
 ;res1@mpMaxLatF = 50
 ;res1@mpMinLonF = -30
 ;res1@mpMaxLonF = 70

 res@gsnLeftString = "Composite PMax Vegetation"
  plot(0) = gsn_csm_contour_map_overlay(wks,dataAHP_mask_vals(1,:,:),dataAHP_mask(1,:,:),res,res1)
  res@gsnLeftString = "Composite Humid Period Vegetation"
  plot(1) = gsn_csm_contour_map_overlay(wks,dataAHP_mask_vals(0,:,:),dataAHP_mask(0,:,:),res,res1)


gsn_panel(wks,plot,(/1,3/),False)
  delete(res) 
delete(res1) 
end    



;=========================



begin

wks = gsn_open_wks("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/PFT_TRIFFID_AHPS2.pdf")  
plot = new (3, graphic)   

gsn_define_colormap(wks,"testcmap")

res2=True

res2@gsnDraw                = False              ; dont draw
res2@gsnFrame               = False              ; dont advance frame

  ;res2@gsnMaximize = True                        ; maximize plot in frame
  res2@mpFillOn    = False                       ; turn map fill off
  res2@mpOutlineOn = True                        ; turn the map outline on
  res2@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res2@cnLevels    = (/ 0,1,2,3,4,5,6/)   ; set levels
  res2@cnFillOn    = True                        ; turn on color fill
  res2@cnLinesOn   = False                       ; turn off the contour lines
  
 ; Broadleaf, needle, C3, c4, Shrub, Soil
  res2@cnFillColors = (/-1,64,56,171,148,87,107/) 
  res2@cnLineLabelsOn = False                    ; turn the line labels off
  res2@gsnAddCyclic = False

 res2@mpMinLatF =  -40
 res2@mpMaxLatF = 50
 res2@mpMinLonF = -30
 res2@mpMaxLonF = 70

   res2@gsnLeftString = "Composite PMax TRIFFID Vegetation"
   plot(0) = gsn_csm_contour_map(wks,dataAHPP(1,:,:),res2)
       res2@gsnLeftString = "Composite Humid Period TRIFFID Vegetation"
   plot(1) = gsn_csm_contour_map(wks,dataAHPP(0,:,:),res2)
  


gsn_panel(wks,plot,(/1,3/),False)
delete(res2) 
end    


































;==============================;==============================;==============================;==============================
;==============================;==============================;==============================;==============================
; NOW plot the lat/ht omega/wind plots

vars = (/"omega_mm_p","u_mm_p"/)

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

end do 
end do

;==============================;==============================;
; Calculate the anomlaies - THIS IS AHPS VS NOAHPS METHODS

ahp = asciiread("/home/bridge/ea13310/Finland/Data/ahp.txt" ,-1, "integer")
PMAX = asciiread("/home/bridge/ea13310/Finland/Data/noAHPS.txt",-1, "integer")

; Define yrs when we have precession maxima

;PMAX = ispan(0,20,1)
;PMAX := array_append_record(PMAX,ispan(210,230,1),0) 
;PMAX := array_append_record(PMAX, ispan(460,480,1),0)
;PMAX := array_append_record(PMAX, ispan(710,730,1),0)
;PMAX := array_append_record(PMAX, ispan(930,950,1),0)
;PMAX := array_append_record(PMAX, ispan(1150,1170,1),0)
;PMAX := array_append_record(PMAX, ispan(1380,1400,1),0)
;PMAX := array_append_record(PMAX, ispan(1620,1640,1),0)
;PMAX := array_append_record(PMAX, ispan(1860,1880,1),0)
;PMAX := array_append_record(PMAX, ispan(2080,2100,1),0)
;PMAX := array_append_record(PMAX, ispan(2300,2320,1),0)
;PMAX := array_append_record(PMAX, ispan(2520,2540,1),0)
;PMAX := array_append_record(PMAX, ispan(2790,2810,1),0)
;PMAX := array_append_record(PMAX, ispan(3010,3030,1),0)
;PMAX := array_append_record(PMAX, ispan(3230,3250,1),0)
;PMAX := array_append_record(PMAX, ispan(3440,3460,1),0)
;PMAX := array_append_record(PMAX, ispan(4540,4550,1),0)
;PMAX := array_append_record(PMAX, ispan(4740,4760,1),0)
;PMAX := array_append_record(PMAX, ispan(4950,4970,1),0)
;PMAX := array_append_record(PMAX, ispan(5160,5180,1),0)
;PMAX := array_append_record(PMAX, ispan(5450,5470,1),0)
;PMAX := array_append_record(PMAX, ispan(5670,5680,1),0)
;PMAX := array_append_record(PMAX, ispan(5880,5900,1),0)
;PMAX := array_append_record(PMAX, ispan(6100,6120,1),0)
;PMAX := array_append_record(PMAX, ispan(6320,6340,1),0)
;PMAX := array_append_record(PMAX, ispan(6600,6620,1),0)
;PMAX := array_append_record(PMAX, ispan(6820,6840,1),0)
;PMAX := array_append_record(PMAX, ispan(7030,7050,1),0)
;PMAX := array_append_record(PMAX, ispan(7240,7250,1),0)
;PMAX := array_append_record(PMAX, ispan(7430,7440,1),0)
;PMAX := array_append_record(PMAX, ispan(7580,7600,1),0)
;PMAX := array_append_record(PMAX, ispan(7770,7790,1),0)
;PMAX := array_append_record(PMAX, ispan(7970,7990,1),0)
;PMAX = PMAX(::-1)


PMIN = ispan(100,130,1)
PMIN := array_append_record(PMIN,ispan(330,350,1),0) 
PMIN := array_append_record(PMIN,ispan(590,610,1),0) 
PMIN := array_append_record(PMIN,ispan(820,840,1),0) 
PMIN := array_append_record(PMIN,ispan(1050,1070,1),0) 
PMIN := array_append_record(PMIN,ispan(1260,1280,1),0) 
PMIN := array_append_record(PMIN,ispan(1490,1520,1),0) 
PMIN := array_append_record(PMIN,ispan(1750,1770,1),0) 
PMIN := array_append_record(PMIN,ispan(1970,1990,1),0) 
PMIN := array_append_record(PMIN,ispan(2190,2210,1),0) 
PMIN := array_append_record(PMIN,ispan(2410,2430,1),0) 
PMIN := array_append_record(PMIN,ispan(2660,2680,1),0) 
PMIN := array_append_record(PMIN,ispan(2900,2920,1),0) 
PMIN := array_append_record(PMIN,ispan(3120,3140,1),0) 
PMIN := array_append_record(PMIN,ispan(3340,3360,1),0) 
PMIN := array_append_record(PMIN,ispan(3540,3560,1),0) 
PMIN := array_append_record(PMIN,ispan(3720,3730,1),0) 
PMIN := array_append_record(PMIN,ispan(3890,3900,1),0) 
PMIN := array_append_record(PMIN,ispan(4080,4090,1),0) 
PMIN := array_append_record(PMIN,ispan(4270,4280,1),0) 
PMIN := array_append_record(PMIN,ispan(4440,4460,1),0) 
PMIN := array_append_record(PMIN,ispan(4640,4650,1),0) 
PMIN := array_append_record(PMIN,ispan(4850,4860,1),0) 
PMIN := array_append_record(PMIN,ispan(5060,5070,1),0) 
PMIN := array_append_record(PMIN,ispan(5270,5290,1),0) 
PMIN := array_append_record(PMIN,ispan(5560,5580,1),0) 
PMIN := array_append_record(PMIN,ispan(5770,5790,1),0) 
PMIN := array_append_record(PMIN,ispan(5990,6010,1),0) 
PMIN := array_append_record(PMIN,ispan(6210,6230,1),0) 
PMIN := array_append_record(PMIN,ispan(6480,6500,1),0) 
PMIN := array_append_record(PMIN,ispan(6710,6730,1),0) 
PMIN := array_append_record(PMIN,ispan(6920,6940,1),0) 
PMIN := array_append_record(PMIN,ispan(7130,7150,1),0)
PMIN := array_append_record(PMIN,ispan(7340,7350,1),0)
PMIN := array_append_record(PMIN,ispan(7510,7520,1),0)
PMIN := array_append_record(PMIN,ispan(7680,7690,1),0)
PMIN := array_append_record(PMIN,ispan(7870,7890,1),0)
PMIN = PMIN(::-1)



PMAX_i = ind_nearest_coord(PMAX*100,time_seq,0)
PMIN_i = ind_nearest_coord(PMIN*100,time_seq,0)

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
anom_convec10 := dim_avg_n_Wrap(anom_convec(:,0:11,{-10:40},{-10:20}),3)

;==============================;==============================;==============================;==============================
;==============================;==============================;==============================;==============================
; Plotting

begin

wks = gsn_open_wks("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/precip_JJAwind_ann_AHPs_anomalies_maps.pdf")  
plot = new (3, graphic)   

res1=True

 else if (var.eq."precip_mm_srf")
 contour_list0000:=(/0,50,100,150,200,250,300,350,400,500,600,800,1000,1500,2000,2500/)
 contour_list00001:=(/-800,-700,-600,-500,-400,-300,-250,-200,-150,-100,-75,-50,-25,0,25,50,75,100,150,200,250,300,400,500,600,700,800/)
 my_fix_contours(dataAHPs(0,:,:),contour_list0000)
 colormap_orig0000=(/"(/0.56,0.17,0.93/)","(/0,0,0.93/)","(/0.52,0.80,0.92/)","(/1,1,1/)"/)
 colormap_orig0000=colormap_orig0000(::-1)
  ;colormap_orig0000=colormap_orig0000(::-1)
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
 res1@mpMaxLatF = 50
 res1@mpMinLonF = -30
 res1@mpMaxLonF = 70

 res1@mpGeophysicalLineColor="Black"
 ;res1@mpFillOn = False
 res1@mpPerimOn         = True

res1@gsnScalarContour = True
res1@vcRefAnnoOrthogonalPosF  = -0.97; -1.01            ; move ref vector up
res1@vcRefAnnoParallelPosF    = 0.10 ;1.01
res1@vcRefMagnitudeF          = 1.0            ; define vector ref mag
res1@vcRefLengthF             = 0.04            ; define length of vec ref
res1@vcRefAnnoFontHeightF     = 0.02
res1@vcGlyphStyle             = "CurlyVector"   ; "LineArrow","FillArrow","WindBarb","CurlyVector"

res1@vcFillArrowEdgeColor     = "black" ;"gray15" ;"gray35"
res1@vcFillArrowFillColor     = "black" ;"gray15" ;"gray35"
res1@vcLineArrowThicknessF    = 1.
res1@vcLineArrowHeadMinSizeF  = 0.012
res1@vcLineArrowHeadMaxSizeF  = 0.015
res1@vcLineArrowColor         = "black" ;"gray15" ;"gray35"

res1@vcMinDistanceF           = 0.025 ;0.018 ;0.0175 or 0.025
res1@vcRefAnnoString2On       = False

 res1@mpGeophysicalLineColor="Black"
 res1@mpFillOn = False
 res1@mpPerimOn         = True
 res1@mpOutlineDrawOrder    = "PostDraw"

 res1@gsnLeftString = "Composite PMax Precip (mm/yr)"
 plot(0) = gsn_csm_vector_scalar_map(wks,dataAHPW(1,0,:,:),dataAHPW(1,1,:,:),dataAHPs(1,:,:),res1)

 res1@gsnLeftString = "Composite Humid Periods (mm/yr)"
 plot(1) = gsn_csm_vector_scalar_map(wks,dataAHPW(0,0,:,:),dataAHPW(0,1,:,:),dataAHPs(0,:,:),res1)

;====
my_fix_contours(dataAHPs(2,:,:),contour_list00001)
colormap_orig0000=(/"(/0.56,0.17,0.93/)","(/0,0,0.93/)","(/0.52,0.80,0.92/)","(/1,1,1/)","(/1,0.64,0/)","(/0.93,0,0/)","(/1,0.08,0.58/)"/)
colormap_orig0000=colormap_orig0000(::-1)
colormap_revised0000=my_StretchColorMap(colormap_orig0000,contour_list00001)
delete(colormap_orig0000)
my_updateColors1a(colormap_revised0000,contour_list00001,"zero","Gray91","-1","Gray91")
res1@gsnSpreadColors = False
ColorMap0000:=colormap_revised0000
delete(colormap_revised0000)
res1@cnLevels:=contour_list00001
res1@cnFillPalette:=ColorMap0000

;===

res1@gsnLeftString = "Anomaly (humid-standard; mm/yr)"
plot(2) = gsn_csm_contour_map(wks,dataAHPs(2,:,:),res1)

gsn_panel(wks,plot,(/1,3/),False)

delete(res1)
end


;=================================================================================

begin

wks = gsn_open_wks("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/precip_ANN_AHPs_anomalies_maps.pdf")  
plot = new (3, graphic)   

res1=True

 contour_list0000:=(/0,50,100,150,200,250,300,350,400,500,600,800,1000,1500,2000,2500/)
 contour_list00001:=(/-800,-700,-600,-500,-400,-300,-250,-200,-150,-100,-75,-50,-25,0,25,50,75,100,150,200,250,300,400,500,600,700,800/)
 my_fix_contours(dataAHPs(0,:,:),contour_list0000)
 colormap_orig0000=(/"(/0.56,0.17,0.93/)","(/0,0,0.93/)","(/0.52,0.80,0.92/)","(/1,1,1/)"/)
 colormap_orig0000=colormap_orig0000(::-1)
  ;colormap_orig0000=colormap_orig0000(::-1)
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
 res1@mpMaxLatF = 50
 res1@mpMinLonF = -30
 res1@mpMaxLonF = 70

 res1@mpGeophysicalLineColor="Black"
 ;res1@mpFillOn = False
 res1@mpPerimOn         = True

res1@gsnScalarContour = True
res1@vcRefAnnoOrthogonalPosF  = -0.97; -1.01            ; move ref vector up
res1@vcRefAnnoParallelPosF    = 0.10 ;1.01
res1@vcRefMagnitudeF          = 1.0            ; define vector ref mag
res1@vcRefLengthF             = 0.04            ; define length of vec ref
res1@vcRefAnnoFontHeightF     = 0.02
res1@vcGlyphStyle             = "CurlyVector"   ; "LineArrow","FillArrow","WindBarb","CurlyVector"

res1@vcFillArrowEdgeColor     = "black" ;"gray15" ;"gray35"
res1@vcFillArrowFillColor     = "black" ;"gray15" ;"gray35"
res1@vcLineArrowThicknessF    = 1.
res1@vcLineArrowHeadMinSizeF  = 0.012
res1@vcLineArrowHeadMaxSizeF  = 0.015
res1@vcLineArrowColor         = "black" ;"gray15" ;"gray35"

res1@vcMinDistanceF           = 0.025 ;0.018 ;0.0175 or 0.025
res1@vcRefAnnoString2On       = False

 res1@mpGeophysicalLineColor="Black"
 res1@mpFillOn = False
 res1@mpPerimOn         = True
 res1@mpOutlineDrawOrder    = "PostDraw"

 res1@gsnLeftString = "Composite PMax Precip (mm/yr)"
 plot(0) = gsn_csm_contour_map(wks,dataAHPs(1,:,:),res1)

 res1@gsnLeftString = "Composite Humid Periods (mm/yr)"
 plot(1) = gsn_csm_contour_map(wks,dataAHPs(0,:,:),res1)

;====
my_fix_contours(dataAHPs(2,:,:),contour_list00001)
colormap_orig0000=(/"(/0.56,0.17,0.93/)","(/0,0,0.93/)","(/0.52,0.80,0.92/)","(/1,1,1/)","(/1,0.64,0/)","(/0.93,0,0/)","(/1,0.08,0.58/)"/)
colormap_orig0000=colormap_orig0000(::-1)
colormap_revised0000=my_StretchColorMap(colormap_orig0000,contour_list00001)
delete(colormap_orig0000)
my_updateColors1a(colormap_revised0000,contour_list00001,"zero","Gray91","-1","Gray91")
res1@gsnSpreadColors = False
ColorMap0000:=colormap_revised0000
delete(colormap_revised0000)
res1@cnLevels:=contour_list00001
res1@cnFillPalette:=ColorMap0000

;===

res1@gsnLeftString = "Anomaly (humid-standard; mm/yr)"
plot(2) = gsn_csm_contour_map(wks,dataAHPs(2,:,:),res1)

gsn_panel(wks,plot,(/1,3/),False)

delete(res1)
end


;=================================================================================

begin

wks = gsn_open_wks("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/wind_jja_AHPs_anomalies_maps.pdf")  
plot = new (3, graphic)   

res1=True

  contour_list0000:=(/0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,6,8,10,12/)
  contour_list00001:=(/-3,-2.5,-2,-1.5,-1,-0.5,-0.25,0,0.25,0.5,1,1.5,2,2.5,3/)
 my_fix_contours(dataAHPs(0,:,:),contour_list0000)
 colormap_orig0000=(/"(/0.56,0.17,0.93/)","(/0,0,0.93/)","(/0.52,0.80,0.92/)","(/1,1,1/)"/)
 colormap_orig0000=colormap_orig0000(::-1)
  ;colormap_orig0000=colormap_orig0000(::-1)
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
 res1@mpMaxLatF = 50
 res1@mpMinLonF = -30
 res1@mpMaxLonF = 70

 res1@mpGeophysicalLineColor="Black"
 ;res1@mpFillOn = False
 res1@mpPerimOn         = True

res1@gsnScalarContour = True
res1@vcRefAnnoOrthogonalPosF  = -0.97; -1.01            ; move ref vector up
res1@vcRefAnnoParallelPosF    = 0.10 ;1.01
res1@vcRefMagnitudeF          = 1.0            ; define vector ref mag
res1@vcRefLengthF             = 0.04            ; define length of vec ref
res1@vcRefAnnoFontHeightF     = 0.02
res1@vcGlyphStyle             = "CurlyVector"   ; "LineArrow","FillArrow","WindBarb","CurlyVector"

res1@vcFillArrowEdgeColor     = "black" ;"gray15" ;"gray35"
res1@vcFillArrowFillColor     = "black" ;"gray15" ;"gray35"
res1@vcLineArrowThicknessF    = 1.
res1@vcLineArrowHeadMinSizeF  = 0.012
res1@vcLineArrowHeadMaxSizeF  = 0.015
res1@vcLineArrowColor         = "black" ;"gray15" ;"gray35"

res1@vcMinDistanceF           = 0.025 ;0.018 ;0.0175 or 0.025
res1@vcRefAnnoString2On       = False

 res1@mpGeophysicalLineColor="Black"
 res1@mpFillOn = False
 res1@mpPerimOn         = True
 res1@mpOutlineDrawOrder    = "PostDraw"

 res1@gsnLeftString = "Average Wind. Max. Precip (m/s)"
 plot(0) = gsn_csm_vector_scalar_map(wks,dataAHPW(1,0,:,:),dataAHPW(1,1,:,:),dataAHPW(1,2,:,:),res1)

 res1@gsnLeftString = "Composite Humid Periods (m/s)"
 plot(1) = gsn_csm_vector_scalar_map(wks,dataAHPW(0,0,:,:),dataAHPW(0,1,:,:),dataAHPW(0,2,:,:),res1)

;====
my_fix_contours(dataAHPs(2,:,:),contour_list00001)
colormap_orig0000=(/"(/0.56,0.17,0.93/)","(/0,0,0.93/)","(/0.52,0.80,0.92/)","(/1,1,1/)","(/1,0.64,0/)","(/0.93,0,0/)","(/1,0.08,0.58/)"/)
colormap_orig0000=colormap_orig0000(::-1)
colormap_revised0000=my_StretchColorMap(colormap_orig0000,contour_list00001)
delete(colormap_orig0000)
my_updateColors1a(colormap_revised0000,contour_list00001,"zero","Gray91","-1","Gray91")
res1@gsnSpreadColors = False
ColorMap0000:=colormap_revised0000
delete(colormap_revised0000)
res1@cnLevels:=contour_list00001
res1@cnFillPalette:=ColorMap0000

;===

res1@gsnLeftString = "Anomaly (humid-standard; m/s)"
plot(2) = gsn_csm_contour_map(wks,dataAHPW(2,2,:,:),res1)

gsn_panel(wks,plot,(/1,3/),False)

delete(res1)
end


;=================================================================================









begin
wks   = gsn_open_wks ("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/vert_velo_lat_ht_ALL_Vars_PMAX.pdf")          ; send graphics to PNG file

plot = new (12, graphic)   

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

res1@gsnLeftString = "Vert Velo & Zonal (-10W:10E; m/s) Average"
 plotA = gsn_csm_pres_hgt(wks,dataNoAHPs_convec10(0,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,dataNoAHPs_convec10(1,:,:),res)
 overlay(plotA,plotB)                      
 plot(0) = plotA                           

res1@gsnLeftString = "Vert Velo & Zonal (-10W:10E; m/s) AHPs"
 plotC = gsn_csm_pres_hgt(wks,dataAHPs_convec10(0,:,:),res1)
 plotD = gsn_csm_pres_hgt(wks,dataAHPs_convec10(1,:,:),res)
 overlay(plotC,plotD)                      
 plot(1) = plotC        


  res@cnLevelSelectionMode = "ManualLevels"  ; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -80.        ; set the minimum contour level
  res@cnMaxLevelValF  = 40.         ; set the maximum contour level
  res@cnLevelSpacingF = 10.         
res1@gsnLeftString = "JJA Vert. Velo. & Temp. PMAX (-10W:20E)"
 plotA = gsn_csm_pres_hgt(wks,dataNoAHPs_convec10(0,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,dataNoAHPs_convec10T(1,:,:),res)
 overlay(plotA,plotB)                      
 plot(3) = plotA                           

res1@gsnLeftString = "JJA Vert. Velo. & Temp. AHPs (-10W:20E)"
 plotC = gsn_csm_pres_hgt(wks,dataAHPs_convec10(0,:,:),res1)
 plotD = gsn_csm_pres_hgt(wks,dataAHPs_convec10T(1,:,:),res)
 overlay(plotC,plotD)                      
 plot(4) = plotC      

  res@cnMinLevelValF  = 0.        ; set the minimum contour level
  res@cnMaxLevelValF  = 100.         ; set the maximum contour level
  res@cnLevelSpacingF = 5         
res1@gsnLeftString = "JJA Vert. Velo. & Rel. Humid. PMAX (-10W:20E)"
 plotA = gsn_csm_pres_hgt(wks,dataNoAHPs_convec10(0,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,dataNoAHPs_convec10T(0,:,:),res)
 overlay(plotA,plotB)                      
 plot(9) = plotA                           

res1@gsnLeftString = "JJA Vert. Velo. & Rel. Humid. AHPs (-10W:20E)"
 plotC = gsn_csm_pres_hgt(wks,dataAHPs_convec10(0,:,:),res1)
 plotD = gsn_csm_pres_hgt(wks,dataAHPs_convec10T(0,:,:),res)
 overlay(plotC,plotD)                      
 plot(10) = plotC       


  res@cnMinLevelValF  = 0        ; set the minimum contour level
  res@cnMaxLevelValF  = 16600         ; set the maximum contour level
  res@cnLevelSpacingF = 1000       
res1@gsnLeftString = "JJA Vert. Velo. & Geo.Pot.Ht PMAX (-10W:20E)"
 plotA = gsn_csm_pres_hgt(wks,dataNoAHPs_convec10(0,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,dataNoAHPs_convec10T(2,:,:),res)
 overlay(plotA,plotB)                      
 plot(6) = plotA                           

res1@gsnLeftString = "JJA Vert. Velo. & Geo.Pot.Ht AHPs (-10W:20E)"
 plotC = gsn_csm_pres_hgt(wks,dataAHPs_convec10(0,:,:),res1)
 plotD = gsn_csm_pres_hgt(wks,dataAHPs_convec10T(2,:,:),res)
 overlay(plotC,plotD)                      
 plot(7) = plotC      



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

  res@cnMinLevelValF  = -14.        ; set the minimum contour level
  res@cnMaxLevelValF  = 14.         ; set the maximum contour level
  res@cnLevelSpacingF = 2.    
res1@gsnLeftString = "Vert Velo & Zonal Anomaly (humid-standard)"
plotI = gsn_csm_pres_hgt(wks,anom_convec10(0,:,:),res1)
;plotJ = gsn_csm_pres_hgt(wks,anom_convec10(1,:,:),res)
; overlay(plotI,plotJ)                      
 plot(2) = plotI  


  res@cnMinLevelValF  = -15.         ; set the minimum contour level
  res@cnMaxLevelValF  = 40.       ; set the maximum contour level
  res@cnLevelSpacingF = 5  
res1@gsnLeftString = "JJA Vert. Velo. & Rel. Humid. Anom (AHP-PMAX)"
plotI = gsn_csm_pres_hgt(wks,anom_convec10(0,:,:),res1)
plotJ = gsn_csm_pres_hgt(wks,anom_convec10T(0,:,:),res)
 overlay(plotI,plotJ)                      
 plot(11) = plotI  


  res@cnMinLevelValF  = -4.         ; set the minimum contour level
  res@cnMaxLevelValF  = 9       ; set the maximum contour level
  res@cnLevelSpacingF = 0.5   
res1@gsnLeftString = "JJA Vert. Velo. & Temp. Anom (AHP-PMAX)"
plotI = gsn_csm_pres_hgt(wks,anom_convec10(0,:,:),res1)
plotJ = gsn_csm_pres_hgt(wks,anom_convec10T(1,:,:),res)
 overlay(plotI,plotJ)                      
 plot(5) = plotI  


res@cnMinLevelValF  = -60         ; set the minimum contour level
  res@cnMaxLevelValF  = 300       ; set the maximum contour level
  res@cnLevelSpacingF = 20   
res1@gsnLeftString = "JJA Vert. Velo. & Geo.Pot.Ht Anom (AHP-PMAX)"
plotI = gsn_csm_pres_hgt(wks,anom_convec10(0,:,:),res1)
plotJ = gsn_csm_pres_hgt(wks,anom_convec10T(2,:,:),res)
 overlay(plotI,plotJ)                      
 plot(8) = plotI  


;====
gsn_panel(wks,plot,(/4,3/),False)

delete(res1)
delete(res)
end
















  contour_list0000:=(/0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,6,8,10,12/)
  contour_list00001:=(/-3,-2.5,-2,-1.5,-1,-0.5,-0.25,0,0.25,0.5,1,1.5,2,2.5,3/)
 my_fix_contours(dataAHPs(0,:,:),contour_list0000)
 colormap_orig0000=(/"(/0.56,0.17,0.93/)","(/0,0,0.93/)","(/0.52,0.80,0.92/)","(/1,1,1/)"/)
 colormap_orig0000=colormap_orig0000(::-1)
  ;colormap_orig0000=colormap_orig0000(::-1)
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
 res1@mpMaxLatF = 50
 res1@mpMinLonF = -30
 res1@mpMaxLonF = 70

 res1@mpGeophysicalLineColor="Black"
 ;res1@mpFillOn = False
 res1@mpPerimOn         = True

res1@gsnScalarContour = True
res1@vcRefAnnoOrthogonalPosF  = -0.97; -1.01            ; move ref vector up
res1@vcRefAnnoParallelPosF    = 0.10 ;1.01
res1@vcRefMagnitudeF          = 1.0            ; define vector ref mag
res1@vcRefLengthF             = 0.04            ; define length of vec ref
res1@vcRefAnnoFontHeightF     = 0.02
res1@vcGlyphStyle             = "CurlyVector"   ; "LineArrow","FillArrow","WindBarb","CurlyVector"

res1@vcFillArrowEdgeColor     = "black" ;"gray15" ;"gray35"
res1@vcFillArrowFillColor     = "black" ;"gray15" ;"gray35"
res1@vcLineArrowThicknessF    = 1.
res1@vcLineArrowHeadMinSizeF  = 0.012
res1@vcLineArrowHeadMaxSizeF  = 0.015
res1@vcLineArrowColor         = "black" ;"gray15" ;"gray35"

res1@vcMinDistanceF           = 0.025 ;0.018 ;0.0175 or 0.025
res1@vcRefAnnoString2On       = False

 res1@mpGeophysicalLineColor="Black"
 res1@mpFillOn = False
 res1@mpPerimOn         = True
 res1@mpOutlineDrawOrder    = "PostDraw"

 res1@gsnLeftString = "Average Wind. Max. Precip (m/s)"
 plot(0) = gsn_csm_vector_scalar_map(wks,dataAHPW(1,0,:,:),dataAHPW(1,1,:,:),dataAHPW(1,2,:,:),res1)

 res1@gsnLeftString = "Composite Humid Periods (m/s)"
 plot(1) = gsn_csm_vector_scalar_map(wks,dataAHPW(0,0,:,:),dataAHPW(0,1,:,:),dataAHPW(0,2,:,:),res1)

;====
my_fix_contours(dataAHPs(2,:,:),contour_list00001)
colormap_orig0000=(/"(/0.56,0.17,0.93/)","(/0,0,0.93/)","(/0.52,0.80,0.92/)","(/1,1,1/)","(/1,0.64,0/)","(/0.93,0,0/)","(/1,0.08,0.58/)"/)
colormap_orig0000=colormap_orig0000(::-1)
colormap_revised0000=my_StretchColorMap(colormap_orig0000,contour_list00001)
delete(colormap_orig0000)
my_updateColors1a(colormap_revised0000,contour_list00001,"zero","Gray91","-1","Gray91")
res1@gsnSpreadColors = False
ColorMap0000:=colormap_revised0000
delete(colormap_revised0000)
res1@cnLevels:=contour_list00001
res1@cnFillPalette:=ColorMap0000

;===

res1@gsnLeftString = "Anomaly (humid-standard; m/s)"
plot(2) = gsn_csm_contour_map(wks,dataAHPW(2,2,:,:),res1)

gsn_panel(wks,plot,(/1,3/),False)

delete(res1)
end














;=================================================================================

begin

wks = gsn_open_wks("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/PFTs_ann_AHPs_anomalies_maps.pdf")  
plot = new (9, graphic)   

res1=True
contour_list0000:=(/0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1/)
contour_list00001:=(/-0.8,-0.7,-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8/)
my_fix_contours(dataAHPP(1,:,:,:),contour_list0000)
colormap_orig0000=(/"(/0.56,0.17,0.93/)","(/0,0,0.93/)","(/0.52,0.80,0.92/)","(/1,1,1/)"/)
colormap_orig0000=colormap_orig0000(::-1)
;colormap_orig0000=colormap_orig0000(::-1)
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
 res1@mpMaxLatF = 50
 res1@mpMinLonF = -30
 res1@mpMaxLonF = 70

 res1@mpGeophysicalLineColor="Black"
 ;res1@mpFillOn = False
 res1@mpPerimOn         = True

if(var.eq."wind".or.var.eq."currents") 
res1@gsnScalarContour = True
res1@vcRefAnnoOrthogonalPosF  = -0.97; -1.01            ; move ref vector up
res1@vcRefAnnoParallelPosF    = 0.10 ;1.01
res1@vcRefMagnitudeF          = 1.0            ; define vector ref mag
res1@vcRefLengthF             = 0.04            ; define length of vec ref
res1@vcRefAnnoFontHeightF     = 0.02
res1@vcGlyphStyle             = "CurlyVector"   ; "LineArrow","FillArrow","WindBarb","CurlyVector"

res1@vcFillArrowEdgeColor     = "black" ;"gray15" ;"gray35"
res1@vcFillArrowFillColor     = "black" ;"gray15" ;"gray35"
res1@vcLineArrowThicknessF    = 1.
res1@vcLineArrowHeadMinSizeF  = 0.012
res1@vcLineArrowHeadMaxSizeF  = 0.015
res1@vcLineArrowColor         = "black" ;"gray15" ;"gray35"

res1@vcMinDistanceF           = 0.025 ;0.018 ;0.0175 or 0.025
res1@vcRefAnnoString2On       = False
end if
;===

 res1@gsnLeftString = "Average 800kyr - Broadleaf"
 plot(0) = gsn_csm_contour_map(wks,dataAHPP(1,0,:,:),res1)

 res1@gsnLeftString = "Composite Humid Periods - Broadleaf"
 plot(1) = gsn_csm_contour_map(wks,dataAHPP(0,0,:,:),res1)

 res1@gsnLeftString = "Average 800kyr - C4"
 plot(3) = gsn_csm_contour_map(wks,dataAHPP(1,1,:,:),res1)

 res1@gsnLeftString = "Composite Humid Periods - C4"
 plot(4) = gsn_csm_contour_map(wks,dataAHPP(0,1,:,:),res1)

 res1@gsnLeftString = "Average 800kyr- Soil"
 plot(6) = gsn_csm_contour_map(wks,dataAHPP(1,2,:,:),res1)

 res1@gsnLeftString = "Composite Humid Periods - Soil"
 plot(7) = gsn_csm_contour_map(wks,dataAHPP(0,2,:,:),res1)


;====
my_fix_contours(dataAHPP(2,:,:,:),contour_list00001)
colormap_orig0000=(/"(/0.56,0.17,0.93/)","(/0,0,0.93/)","(/0.52,0.80,0.92/)","(/1,1,1/)","(/1,0.64,0/)","(/0.93,0,0/)","(/1,0.08,0.58/)"/)
 colormap_orig0000=colormap_orig0000(::-1)
colormap_revised0000=my_StretchColorMap(colormap_orig0000,contour_list00001)
delete(colormap_orig0000)
my_updateColors1a(colormap_revised0000,contour_list00001,"zero","Gray91","-1","Gray91")
res1@gsnSpreadColors = False
ColorMap0000:=colormap_revised0000
delete(colormap_revised0000)
res1@cnLevels:=contour_list00001
res1@cnFillPalette:=ColorMap0000


res1@gsnLeftString = "Broadleaf Anomaly (humid-standard)"
plot(2) = gsn_csm_contour_map(wks,dataAHPP(2,0,:,:),res1)

res1@gsnLeftString = "C4 Anomaly (humid-standard)"
plot(5) = gsn_csm_contour_map(wks,dataAHPP(2,1,:,:),res1)

res1@gsnLeftString = " Soil Anomaly (humid-standard; mm/yr) "
plot(8) = gsn_csm_contour_map(wks,dataAHPP(2,2,:,:),res1)

gsn_panel(wks,plot,(/3,3/),False)

delete(res1)
end

;=================================================================================;=================================================================================
;=================================================================================;=================================================================================


begin
wks   = gsn_open_wks ("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/vert_zonal_velo_lat_ht_PMAX_Fig2.pdf")          ; send graphics to PNG file

plot = new (3, graphic)   

res=True
res1=True

contour_list0000:=(/-0.1,-0.08,-0.06,-0.05,-0.04,-0.03,-0.025,-0.02,-0.015,-0.01,-0.005,0,0.005,0.01,0.015,0.02,0.025,0.03,0.04,0.05,0.06,0.08,0.1/)
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

res1@gsnLeftString = "JJA Vert. Velo. & Zonal Wind PMAX (-10W:20E; m/s)"
 plotA = gsn_csm_pres_hgt(wks,dataNoAHPs_convec10(0,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,dataNoAHPs_convec10(1,:,:),res)
 overlay(plotA,plotB)                      
 plot(0) = plotA                           

res1@gsnLeftString = "JJA Vert. Velo. & Zonal Wind AHPs (-10W:20E; m/s)"
 plotC = gsn_csm_pres_hgt(wks,dataAHPs_convec10(0,:,:),res1)
 plotD = gsn_csm_pres_hgt(wks,dataAHPs_convec10(1,:,:),res)
 overlay(plotC,plotD)                      
 plot(1) = plotC        


;====
contour_list0000:=(/-0.05,-0.04,-0.03,-0.025,-0.02,-0.0175,-0.015,-0.0125,-0.01,-0.0075,-0.005,-0.0025,0,0.0025,0.005,0.0075,0.01,0.0125,0.015,0.0175,0.02,0.025,0.03,0.04,0.05/)
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

  res@cnMinLevelValF  = -14.        ; set the minimum contour level
  res@cnMaxLevelValF  = 14.         ; set the maximum contour level
  res@cnLevelSpacingF = 2.    

;===

res1@gsnLeftString = "JJA Vert. Velo. Anomaly (humid-standard)"
plotI = gsn_csm_pres_hgt(wks,anom_convec10(0,:,:),res1)
;plotJ = gsn_csm_pres_hgt(wks,anom_convec10(1,:,:),res)
 ;overlay(plotI,plotJ)                      
 plot(2) = plotI  


;====
gsn_panel(wks,plot,(/1,3/),False)

delete(res1)
end



