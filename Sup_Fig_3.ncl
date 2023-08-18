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
filen = "precip_mm_srf_convec_sims_100yrAvg_jja_1degRes_noBias_Global"
fileo = "precip_mm_srf_convec_sims_100yrAvg_djf_1degRes_noBias_Global"

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

data = new((/2,(dimsizes(open_files)*dimsizes(time))+1,ilat1,ilon1/),"float")
data!2   ="lat"    ; Set metadata for first array
data!3   = "lon"
data&lat = lat
data&lon = lon
data!1  ="time"
data@_FillValue = -999  

do i=0, dimsizes(open_files)-1
  fname1 = diri+filen+"_"+seqFils(i)+"_"
  fname2 = systemfunc("ls " + fname1+ "*")
 ; print(fname2)
  cdf_file1 = addfile(fname2,"r")

  fname12 = diri+fileo+"_"+seqFils(i)+"_"
  fname22 = systemfunc("ls " + fname12+ "*")
  cdf_file12 = addfile(fname22,"r")


   if (i.eq.dimsizes(open_files)-1)
    data(0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:) = cdf_file1->precip_mm_srf    ;!!! CHANGE VARIABLE NAME HERE
    data(1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:) = cdf_file12->precip_mm_srf    ;!!! CHANGE VARIABLE NAME HERE
    else 
     data(0,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:) = cdf_file1->precip_mm_srf    ;!!! CHANGE VARIABLE NAME HERE
     data(1,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:) = cdf_file12->precip_mm_srf    ;!!! CHANGE VARIABLE NAME HERE
   end if

  if (i.eq.0)
   time_seq = cdf_file1 ->time
    else
     time_seq2 := cdf_file1 ->time
     time_seq := array_append_record(time_seq,time_seq2,0)
    end if
end do 

data = data*91

;====================================================================

ahp = asciiread("/home/bridge/ea13310/Finland/Data/ahp.txt" ,-1, "integer")
noAHPS = asciiread("/home/bridge/ea13310/Finland/Data/noAHPS.txt",-1, "integer")
PMAX = asciiread("/home/bridge/ea13310/Finland/Data/PMAX.txt",-1, "integer")
;====================================================================
   dataAHPs := new((/2,3,ilat1,ilon1/),"float")
   dataAHPs!2   ="lat"    ; Set metadata for first array
   dataAHPs!3   = "lon"
   dataAHPs&lat = lat
   dataAHPs&lon = lon
   dataAHPs@_FillValue = -999 

    dataAHPs(:,0,:,:) = dim_avg_n(data(:,ahp,:,:),1)
    dataAHPs(:,1,:,:) = dim_avg_n(data(:,PMAX,:,:),1)
    dataAHPs(:,2,:,:) =  dataAHPs(:,0,:,:) - dataAHPs(:,1,:,:)

delete(data)



;====================================================================


begin

wks = gsn_open_wks("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/precip_JJA_DJF_AHPs_anomalies_maps_noBIAS.pdf")  
plot = new (6, graphic)   

res1=True

 contour_list0000:=(/0,50,100,150,200,250,300,350,400,500,600,800,1000,1500,2000,2500/)
 contour_list00001:=(/-800,-700,-600,-500,-400,-300,-250,-200,-150,-100,-75,-50,-25,0,25,50,75,100,150,200,250,300,400,500,600,700,800/)
 my_fix_contours(dataAHPs(:,0,:,:),contour_list0000)
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

 res1@gsnLeftString = "Composite JJA PMax Precip (mm/JJA)"
 plot(0) = gsn_csm_contour_map(wks,dataAHPs(0,1,:,:),res1)

 res1@gsnLeftString = "Composite JJA Humid Periods (mm/JJA)"
 plot(1) = gsn_csm_contour_map(wks,dataAHPs(0,0,:,:),res1)



 res1@gsnLeftString = "Composite DJF PMax Precip (mm/DJF)"
 plot(3) = gsn_csm_contour_map(wks,dataAHPs(1,1,:,:),res1)

 res1@gsnLeftString = "Composite DJF Humid Periods (mm/DJF)"
 plot(4) = gsn_csm_contour_map(wks,dataAHPs(1,0,:,:),res1)



;====
my_fix_contours(dataAHPs(:,2,:,:),contour_list00001)
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

res1@gsnLeftString = "JJA Anomaly (NAHP-PMax; mm/JJA)"
plot(2) = gsn_csm_contour_map(wks,dataAHPs(0,2,:,:),res1)

res1@gsnLeftString = "DJF Anomaly (NAHP-PMax; mm/DJF)"
plot(5) = gsn_csm_contour_map(wks,dataAHPs(1,2,:,:),res1)

gsn_panel(wks,plot,(/2,3/),False)

delete(res1)
end






