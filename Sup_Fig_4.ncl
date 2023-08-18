; This produces Extended Figure 4 which plots Precip and Veg for Skipped Beat Pmin Periods


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

;cdf_file = addfile("/home/bridge/ea13310/Finland/Finland_Files/Spline/precip_mm_srf_convec_sims_100yrAvg_ann_1degRes_CRU_Global_32000_0kyr.nc","r") ; 
;contour_mask = cdf_file ->mask(0,:,:) ; This for the mask
;lat_t := cdf_file ->lat
;lon_t := cdf_file ->lon

;mask_af=contour_mask
;mask_af(:,:)=0.

;do i=0,dimsizes(lat_t)-1
;  do j=0,dimsizes(lon_t)-1
;    if(lat_t(i).ge.15.and.lat_t(i).lt.30)then
;      if(lon_t(j).gt.-15.and.lon_t(j).lt.35.)then
;       mask_af(i,j)=contour_mask(i,j)
;      end if   
;    end if
;  end do
;end do
;data_avg = wgt_areaave(mask(data,mask_af,1.),clat_t,1.0,0) 
;=======================
; Make & average our data

PMAX = asciiread("/home/bridge/ea13310/Finland/Data/PMAX.txt",-1, "integer")

; THis is for the skipped beats
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

; OLD WAY

noAHP0  := ispan(ind_nearest_coord(36000,time_seq,0),ind_nearest_coord(31000,time_seq,0),1)
noAHP1  := ispan(ind_nearest_coord(63000,time_seq,0),ind_nearest_coord(56000,time_seq,0),1)
noAHP2  := ispan(ind_nearest_coord(155000,time_seq,0),ind_nearest_coord(146000,time_seq,0),1)
noAHP3  := ispan(ind_nearest_coord(180000,time_seq,0),ind_nearest_coord(171000,time_seq,0),1)
noAHP4  := ispan(ind_nearest_coord(271000,time_seq,0),ind_nearest_coord(262000,time_seq,0),1)
noAHP5  := ispan(ind_nearest_coord(358000,time_seq,0),ind_nearest_coord(353000,time_seq,0),1)
noAHP6  := ispan(ind_nearest_coord(468000,time_seq,0),ind_nearest_coord(464000,time_seq,0),1)
noAHP7  := ispan(ind_nearest_coord(560000,time_seq,0),ind_nearest_coord(553000,time_seq,0),1)
noAHP8  := ispan(ind_nearest_coord(652000,time_seq,0),ind_nearest_coord(645000,time_seq,0),1)
noAHP9  := ispan(ind_nearest_coord(676000,time_seq,0),ind_nearest_coord(668000,time_seq,0),1)
noAHP10 := ispan(ind_nearest_coord(771000,time_seq,0),ind_nearest_coord(766000,time_seq,0),1)
;alls = array_append_record(noAHP10,noAHP9,0)
;alls := array_append_record(alls,noAHP8,0)
;alls := array_append_record(alls,noAHP7,0)
;alls := array_append_record(alls,noAHP6,0)
;alls := array_append_record(alls,noAHP5,0)
;alls := array_append_record(alls,noAHP4,0)
;alls := array_append_record(alls,noAHP3,0)
;alls := array_append_record(alls,noAHP2,0)
;alls := array_append_record(alls,noAHP1,0)
;alls := array_append_record(alls,noAHP0,0)

;====================================================================
   dataAHPs := new((/3,ilat1,ilon1/),"float")
   dataAHPs!1   ="lat"    ; Set metadata for first array
   dataAHPs!2   = "lon"
   dataAHPs&lat = lat
   dataAHPs&lon = lon
   dataAHPs@_FillValue = -999 

    dataAHPs(0,:,:) = dim_avg_n(data(alls,:,:),0)
    dataAHPs(1,:,:) = dim_avg_n(data(PMAX,:,:),0)
    dataAHPs(2,:,:) =  dataAHPs(0,:,:) - dataAHPs(1,:,:)

;delete(data)

;====================================================================

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

;=============== OPEN the PFTs index

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

    dataAHPP(0,:,:) = round(dim_avg_n(indPFT(alls,:,:),0),0)
    dataAHPP(1,:,:) = round(dim_avg_n(indPFT(PMAX,:,:),0),0)

dataAHPP = dataAHPP+0.5

;delete(dataW)

;=============== ;=============== ;=============== ;=============== ;=============== 
;=============== ;=============== ;=============== ;=============== ;=============== 
begin

wks = gsn_open_wks("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/precip_ANN_ExFig4_SkippedBeats_maps.pdf")  
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

 res1@gsnLeftString = "Composite Skipped Beat Periods (mm/yr)"
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

res1@gsnLeftString = "Anomaly (Skipped Beat-PMax; mm/yr)"
plot(2) = gsn_csm_contour_map(wks,dataAHPs(2,:,:),res1)

gsn_panel(wks,plot,(/1,3/),False)

delete(res1)
end

;=========================

begin

wks = gsn_open_wks("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/PFT_larrasoana_ExFig4_SkippedBeatsMed.pdf")  
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
  res1@cnMinLevelValF  =250;100 ;250        ; set the minimum contour level
  res1@cnMaxLevelValF  =500;2000 ;500         ; set the maximum contour level
  res1@cnLevelSpacingF =250;400 ;250       
  res1@cnLineLabelsOn       = True

 ;res1@mpMinLatF =  0
 ;res1@mpMaxLatF = 50
 ;res1@mpMinLonF = -30
 ;res1@mpMaxLonF = 70


 res@gsnLeftString = "Composite PMax Vegetation"
  plot(0) = gsn_csm_contour_map_overlay(wks,dataAHP_mask_vals(1,:,:),dataAHP_mask(1,:,:),res,res1)
 res@gsnLeftString = "Composite Skipped Beat Vegetation"
  plot(1) = gsn_csm_contour_map_overlay(wks,dataAHP_mask_vals(0,:,:),dataAHP_mask(0,:,:),res,res1)


gsn_panel(wks,plot,(/1,3/),False)
  delete(res) 
delete(res1) 
end    



;=========================



begin

wks = gsn_open_wks("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/PFT_TRIFFID_ExFig4_SkippedBeats.pdf")  
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
    res2@gsnLeftString = "Composite Skipped Beat TRIFFID Vegetation"
   plot(1) = gsn_csm_contour_map(wks,dataAHPP(0,:,:),res2)
  


gsn_panel(wks,plot,(/1,3/),False)
delete(res2) 
end    

