; This plots Extended Figure 7 - the scatter plot showing topo/thermo impact - NEW ONE IS AT THE BOTTOM OF THIS SCRIPT!!
; This plots the Supplementary Figure - spatial maps and anomalies for the topo/thermo sensitivity expimernts



load "/home/bridge/swsvalde/ummodel/scripts/new_plots_scripts/ncl_files/my_ncl_code.ncl"
load "/home/bridge/swsvalde/ummodel/scripts/new_plots_scripts/ncl_files/initialise_myncl_variables.ncl"
load "/home/bridge/ea13310/Finland/Scripts/sub_scripts/quaternary_timeseries_functions.ncl"

;======================================================================

; First open the data for 176kyr and the HadAM3B simulations

;HadCM3B
;0tevTa1: all forcing
;1tevUa: orbit + ghg

; HadAM3B
;2tevza1: All boundary conditions as tevTa1, except that it is HadAM3. SST/seaice from tevTa1: Hence I would have expected this to be very similar to tevTa1 climate
;3tevzb1: As tevza but SST/seaice from tevUa
;4tevzc1: As tevza but SST/seaice from tevVa
;5tevzd1: As tevza but ice sheet cover (but not height) set to tevUa (i.e. modern).
;6tevze1: As tevzd but CO2 etc set to modern
;7tevzf1: As tevzd but ice sheet elevation changes included as well.
;8tevzg1: changed orog (i.e preind) but no change in ice extent.

; Open precipiation For all simulations

sims = ((/"tevTa1","tevUa","tevza1","tevzb1","tevzc1","tevzd1","tevze1","tevzf1","tevzg1"/))

cdf_file1 = addfile("/home/bridge/ea13310/ummodel/data/"+sims(0)+"/climate/"+sims(0)+"a.pdcljja.nc","r")
lon = cdf_file1 ->longitude
lat = cdf_file1 ->latitude
ilat1 = dimsizes(lat)
ilon1 = dimsizes(lon)

data := new((/dimsizes(sims),ilat1,ilon1/),"float")
data!1   ="lat"    ; Set metadata for first array
data!2   = "lon"
data&lat = lat
data&lon = lon

do i=0, dimsizes(sims)-1
 print(sims(i)+0)
 cdf_file1 = addfile("/home/bridge/ea13310/ummodel/data/"+sims(i)+"/climate/"+sims(i)+"a.pdcljja.nc","r")
 data(i,:,:) = cdf_file1->precip_mm_srf(0,0,:,:)
end do

data=data*86400

;data=data*365

;==

ice_sheet_anom_hadcm3 = data(0,:,:) - data(1,:,:)
ice_sheet_anom_hadam3 = data(2,:,:) - data(1,:,:)
sst_anom = data(2,:,:) - data(3,:,:)
atm_anom =data(2,:,:) - data(5,:,:)
topo_anom =data(2,:,:) - data(8,:,:)

;all_anoms = sst_anom + atm_anom + topo_anom
;diff_anoms = ice_sheet_anom_hadam3 - all_anoms


;ice_sheet_anom_hadcm3 = data(1,:,:) - data(0,:,:) 
;ice_sheet_anom_hadam3 = data(1,:,:) - data(2,:,:)
;sst_anom = data(3,:,:) - data(2,:,:) 
;atm_anom = data(5,:,:) - data(2,:,:) 
;topo_anom =data(8,:,:) - data(2,:,:) 

;topo_anom2 =data(7,:,:) - data(2,:,:) 

;all_anoms = sst_anom + topo_anom2
;diff_anoms = ice_sheet_anom_hadam3 - all_anoms


ice_sheet_anom_hadcm3!0   ="lat"    ; Set metadata for first array
ice_sheet_anom_hadcm3!1   = "lon"
ice_sheet_anom_hadcm3&lat = lat
ice_sheet_anom_hadcm3&lon = lon
copy_VarMeta(ice_sheet_anom_hadcm3,ice_sheet_anom_hadam3)
copy_VarMeta(ice_sheet_anom_hadcm3,sst_anom)
copy_VarMeta(ice_sheet_anom_hadcm3,atm_anom)
copy_VarMeta(ice_sheet_anom_hadcm3,topo_anom)
copy_VarMeta(ice_sheet_anom_hadcm3,all_anoms)
copy_VarMeta(ice_sheet_anom_hadcm3,diff_anoms)
copy_VarMeta(ice_sheet_anom_hadcm3,topo_anom2)
;==================================================================================== 
; Plots the maps

begin

wks = gsn_open_wks("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/thermo_topo_precip_JJA.pdf")  
plot = new (15, graphic)   

res1=True

 ;contour_list0000:=(/0,50,100,150,200,250,300,350,400,500,600,800,1000,1500,2000,2500/)
 ;contour_list00001:=(/-800,-700,-600,-500,-400,-300,-250,-200,-150,-100,-75,-50,-25,0,25,50,75,100,150,200,250,300,400,500,600,700,800/)
 contour_list0000:=(/0,0.2,0.4,0.6,0.8,1,1.2,1.4,1.6,1.8,2,2.2,2.4,2.6,2.8,3,3.2,3.4,3.6,3.8,4,4.5,5,5.5,6,6.5,7,7.5,8/)
 contour_list00001:=(/-10,-9,-8,-7,-6,-5,-4,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,4,5,6,7,8,9,10/)
 my_fix_contours(data,contour_list0000)
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

 res1@mpGeophysicalLineColor="Black"
 res1@mpFillOn = False
 res1@mpPerimOn         = True
 res1@mpOutlineDrawOrder    = "PostDraw"

 res1@gsnRightString = ""

 res1@gsnLeftString = "All_AHP 176kyr BP (mm/yr)"
 plot(0) = gsn_csm_contour_map(wks,data(0,:,:),res1)

 res1@gsnLeftString = "Orb_GHG 176kyr BP (mm/yr)"
 plot(1) = gsn_csm_contour_map(wks,data(1,:,:),res1)

;==
 res1@gsnLeftString = "Control (mm/yr)"
 plot(3) = gsn_csm_contour_map(wks,data(2,:,:),res1)

 res1@gsnLeftString = "Orb_GHG 176kyr BP (mm/yr)"
 plot(4) = gsn_csm_contour_map(wks,data(1,:,:),res1)

;==
 res1@gsnLeftString = "Control (mm/yr)"
 plot(6) = gsn_csm_contour_map(wks,data(2,:,:),res1)

 res1@gsnLeftString = "glacial_noSST (mm/yr)"
 plot(7) = gsn_csm_contour_map(wks,data(3,:,:),res1)

;==
 res1@gsnLeftString = "Control (mm/yr)"
 plot(9) = gsn_csm_contour_map(wks,data(2,:,:),res1)

 res1@gsnLeftString = "glacial_noAlb (mm/yr)"
 plot(10) = gsn_csm_contour_map(wks,data(5,:,:),res1)


;==
 res1@gsnLeftString = "Control (mm/yr)"
 plot(12) = gsn_csm_contour_map(wks,data(2,:,:),res1)

 res1@gsnLeftString = "glacial_noTopo (mm/yr)"
 plot(13) = gsn_csm_contour_map(wks,data(8,:,:),res1)




;====
my_fix_contours(ice_sheet_anom_hadcm3,contour_list00001)
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

res1@gsnLeftString = "AHP_All - Orb_GHG Anom (mm/yr)"
plot(2) = gsn_csm_contour_map(wks,ice_sheet_anom_hadcm3,res1)

res1@gsnLeftString = "Control - Orb_GHG Anom (mm/yr)"
plot(5) = gsn_csm_contour_map(wks,ice_sheet_anom_hadam3,res1)

res1@gsnLeftString = "Control - glacial_noSST Anom (mm/yr)"
plot(8) = gsn_csm_contour_map(wks,sst_anom,res1)

res1@gsnLeftString = "Control - glacial_noAlb Anom (mm/yr)"
plot(11) = gsn_csm_contour_map(wks,atm_anom,res1)

res1@gsnLeftString = "Control - glacial_noTopo Anom( mm/yr)"
plot(14) = gsn_csm_contour_map(wks,topo_anom,res1)



;res1@gsnLeftString = "HadAM3B-C Ice sheet Anom (Ice-noIce; mm/yr)"
;plot(15) = gsn_csm_contour_map(wks,ice_sheet_anom_hadam3,res1)

;res1@gsnLeftString = "All anoms (mm/yr)"
;plot(16) = gsn_csm_contour_map(wks,all_anoms,res1)

;res1@gsnLeftString = "Diff in Anoms (mm/yr)"
;plot(17) = gsn_csm_contour_map(wks,diff_anoms,res1)



gsn_panel(wks,plot,(/5,3/),False)

delete(res1)
delete(plot)
end


;================================================================================================================================
;================================================================================================================================
sims = ((/"tevTa1","tevUa","tevza1","tevzb1","tevzc1","tevzd1","tevze1","tevzf1","tevzg1"/))

cdf_file1 = addfile("/home/bridge/ea13310/ummodel/data/"+sims(0)+"/climate/"+sims(0)+"a.pdclann.nc","r")
lon = cdf_file1 ->longitude
lat = cdf_file1 ->latitude
ilat1 = dimsizes(lat)
ilon1 = dimsizes(lon)

rad    = 4.0*atan(1.0)/180.0
clat_t=cos(lat*rad)
clat_t!0   ="lat"
clat_t&lat = lat

data := new((/dimsizes(sims),ilat1,ilon1/),"float")
data!1   ="lat"    ; Set metadata for first array
data!2   = "lon"
data&lat = lat
data&lon = lon

do i=0, dimsizes(sims)-1
 print(sims(i)+0)
 cdf_file1 = addfile("/home/bridge/ea13310/ummodel/data/"+sims(i)+"/climate/"+sims(i)+"a.pdclann.nc","r")
 data(i,:,:) = cdf_file1->precip_mm_srf(0,0,:,:)
end do

data=data*86400
data=data*365

data = lonFlip(data)
;======
data_avg = wgt_areaave(data(:,{30:15},{-15:35}),clat_t({30:15}),1.0,0) 
data_avgW = wgt_areaave(data(:,{30:15},{-15:15}),clat_t({30:15}),1.0,0) 

;======
; Get out ones we need

;HadCM3B
;0tevTa1: all forcing
;1tevUa: orbit + ghg

;2tevza1: All boundary conditions as tevTa1, except that it is HadAM3. SST/seaice from tevTa1: Hence I would have expected this to be very similar to tevTa1 climate
;3tevzb1: As tevza but SST/seaice from tevUa
;4tevzc1: As tevza but SST/seaice from tevVa
;5tevzd1: As tevza but ice sheet cover (but not height) set to tevUa (i.e. modern).
;6tevze1: As tevzd but CO2 etc set to modern
;7tevzf1: As tevzd but ice sheet elevation changes included as well.
;8tevzg1: changed orog (i.e preind) but no change in ice extent.

; Plot 2, 1, 3, 5, 8
; NoIce, Glacial, NoIce SST, noIce Atm, noIce Topography

tims = (/0.5,1.5,2.5,3.5,4.5/)
data_avg1 = (/data_avg(2),data_avg(1),data_avg(3),data_avg(5),data_avg(8)/)

data_avg2 = (/data_avgW(2),data_avgW(1),data_avgW(3),data_avgW(5),data_avgW(8)/)


;==========


delete(attachid1)
delete(plot)
delete(res1)
delete(res2)
delete(res3)
delete(attachres1)

begin

wtype   = "pdf"
wks =  gsn_open_wks(wtype, "/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/Topo_Thermo_scatter.pdf")

plot=new(1,graphic)

res1=True
res2=True

res1@vpHeightF = 0.25 
res1@vpWidthF = 0.55
;res2@vpHeightF = res1@vpHeightF
;res2@vpWidthF = res1@vpWidthF

 res1@trXMaxF = 5
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

; res1@tiXAxisString     = "Year BP"

  res1@tiXAxisFontHeightF  = 0.015
;  res1@tiYAxisFontHeightF = 0.015

;=======

 res1@gsnLeftString= "Annual Saharan     and West Saharan     Precip.(mm/yr)" 
 
; res1@xyLineColors = (/"dodgerblue","orange"/)
; res1@xyDashPatterns   = (/0,0/)
; res1@xyLineThicknessF = 1.4
 ;res1@tmXBOn               = False
 ;res1@tmXTOn               = False


  res1@xyMarkLineMode    = "Markers"                ; choose to use markers
  res1@xyMarkers         =  (/10,11/)                      ; choose type of marker  
  res1@xyMarkerColors     = (/"NavyBlue"  , "orange"/)             ; Marker color
  res1@xyMarkerSizeF     = 0.01   

 res1@tiYAxisSide          = "left"
 res1@trYMaxF = 650
 res1@trYMinF = 0
 res1@tiYAxisFontColor     = "black"
 res1@tmYLLabelFontColor   = "black"
 res1@tiYAxisString     = "Annual Precip (mm/yr)"

; res1@tmYLLabelsOn         = True
; res1@tmYRLabelsOn         = False

; res1@tmYLOn            = True
 
plot  = gsn_csm_xy(wks,tims,(/data_avg1,data_avg2/),res1) ; create plot

delete(res1)

end













;================================================================================================================================
; THIS IS THE NEW SCATTER PLOT 

;================================================================================================================================
sims = ((/"tevTa1","tevUa","tevza1","tevzb1","tevzc1","tevzd1","tevze1","tevzf1","tevzg1"/))

cdf_file1 = addfile("/home/bridge/ea13310/ummodel/data/"+sims(0)+"/climate/"+sims(0)+"a.pdclann.nc","r")
lon = cdf_file1 ->longitude
lat = cdf_file1 ->latitude
ilat1 = dimsizes(lat)
ilon1 = dimsizes(lon)

rad    = 4.0*atan(1.0)/180.0
clat_t=cos(lat*rad)
clat_t!0   ="lat"
clat_t&lat = lat

data := new((/2,dimsizes(sims),ilat1,ilon1/),"float")
data!2   ="lat"    ; Set metadata for first array
data!3   = "lon"
data&lat = lat
data&lon = lon

do i=0, dimsizes(sims)-1
 print(sims(i)+0)
 cdf_file1 = addfile("/home/bridge/ea13310/ummodel/data/"+sims(i)+"/climate/"+sims(i)+"a.pdclann.nc","r")
 data(0,i,:,:) = cdf_file1->precip_mm_srf(0,0,:,:)
 data(1,i,:,:) = cdf_file1->temp_mm_1_5m(0,0,:,:)
end do

data(0,:,:,:)=data(0,:,:,:)*86400
data(0,:,:,:)=data(0,:,:,:)*365

data = lonFlip(data)
;======
data_avg = wgt_areaave(data(0,:,{30:15},{-15:35}),clat_t({30:15}),1.0,0) 
data_avgW = wgt_areaave(data(0,:,{30:15},{-15:15}),clat_t({30:15}),1.0,0) 


;===== Temp gradient

data_avg_N := wgt_areaave(data(1,:,{24:90},:),clat_t({24:90}),1.0,0) 
data_avg_S := wgt_areaave(data(1,:,{-90:-24},:),clat_t({-90:-24}),1.0,0) 

diff = data_avg_N - data_avg_S

;====== Now get Altantic temp gradient 

data_avg_NA := wgt_areaave(data(1,:,{24:90},{-70:20}),clat_t({24:90}),1.0,0) 
data_avg_SA := wgt_areaave(data(1,:,{-90:-24},{-70:20}),clat_t({-90:-24}),1.0,0) 

diffN = data_avg_NA - data_avg_SA



;======
; Get out ones we need

;HadCM3B
;0tevTa1: all forcing
;1tevUa: orbit + ghg

;2tevza1: All boundary conditions as tevTa1, except that it is HadAM3. SST/seaice from tevTa1: Hence I would have expected this to be very similar to tevTa1 climate
;3tevzb1: As tevza but SST/seaice from tevUa
;4tevzc1: As tevza but SST/seaice from tevVa
;5tevzd1: As tevza but ice sheet cover (but not height) set to tevUa (i.e. modern).
;6tevze1: As tevzd but CO2 etc set to modern
;7tevzf1: As tevzd but ice sheet elevation changes included as well.
;8tevzg1: changed orog (i.e preind) but no change in ice extent.

; Plot 2, 1, 3, 5, 8
; NoIce, Glacial, NoIce SST, noIce Atm, noIce Topography

tims = (/0.5,1.5,2.5,3.5,4.5/)
data_avg1 = (/data_avg(2),data_avg(1),data_avg(3),data_avg(5),data_avg(8)/)
data_avg2 = (/data_avgW(2),data_avgW(1),data_avgW(3),data_avgW(5),data_avgW(8)/)

temp = (/diff(2),diff(1),diff(3),diff(5),diff(8)/)
tempN = (/diffN(2),diffN(1),diffN(3),diffN(5),diffN(8)/)
;==========


delete(attachid1)
delete(plot)
delete(res1)
delete(res2)
delete(res3)
delete(attachres1)

begin

wtype   = "pdf"
wks =  gsn_open_wks(wtype, "/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/Topo_Thermo_scatter_MedridTemp1.pdf")

plot=new(1,graphic)

res1=True
res2=True

res1@vpHeightF = 0.25 
res1@vpWidthF = 0.55
res2@vpHeightF = res1@vpHeightF
res2@vpWidthF = res1@vpWidthF

 res1@trXMaxF = 5
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

; res1@tiXAxisString     = "Year BP"

  res1@tiXAxisFontHeightF  = 0.015
;  res1@tiYAxisFontHeightF = 0.015

;=======

 res1@gsnLeftString= "Annual Saharan     and West Saharan     precip.(mm/yr)" 
; res1@gsnLeftString=  "Annual Global      and Atlantic     meridional temp. grad. (C)" 


; res1@xyLineColors = (/"dodgerblue","orange"/)
; res1@xyDashPatterns   = (/0,0/)
; res1@xyLineThicknessF = 1.4
 ;res1@tmXBOn               = False
 ;res1@tmXTOn               = False


  res1@xyMarkLineMode    = "Markers"                ; choose to use markers
  res1@xyMarkers         =  (/10,11/)                      ; choose type of marker  
  res1@xyMarkerColors     = (/"NavyBlue"  , "orange"/)             ; Marker color
  res1@xyMarkerSizeF     = 0.01   



 res2@xyMarkLineMode    = "Markers"                ; choose to use markers
  res2@xyMarkers         =  (/7,8/)                      ; choose type of marker  
  res2@xyMarkerColors     = (/"springgreen4","firebrick"/)             ; Marker color
  res2@xyMarkerSizeF     = 0.01   
 res2@trYMaxF = 2
 res2@trYMinF = -5.5


 res1@tiYAxisSide          = "left"
 res1@trYMaxF = 680
 res1@trYMinF = 0
 res1@tiYAxisFontColor     = "black"
 res1@tmYLLabelFontColor   = "black"
 res1@tiYAxisString     = "Annual Precip (mm/yr)"
 res2@tiYAxisString     = "Merid. temp. grad. (C)"

; res1@tmYLLabelsOn         = True
; res1@tmYRLabelsOn         = False

; res1@tmYLOn            = True
 
plot  = gsn_csm_xy2(wks,tims,(/data_avg1,data_avg2/),(/temp,tempN/),res1,res2) ; create plot

delete(res1)

end





















