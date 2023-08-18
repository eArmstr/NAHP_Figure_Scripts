; This plots the Supplementary Figure that shows lat/ht climatologies and anomalies for the topo/thermo sensitivty experiments 

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

; Open SSTs

;sims = ((/"tevTa1","tevUa","tevza1","tevzb1","tevzc1","tevzd1","tevze1","tevzf1","tevzg1"/))

sims = ((/"tevTa1","tevUa"/))

cdf_file1 = addfile("/home/bridge/ea13310/ummodel/data/"+sims(0)+"/climate/"+sims(0)+"o.pfcljja.nc","r")
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
 cdf_file1 = addfile("/home/bridge/ea13310/ummodel/data/"+sims(i)+"/climate/"+sims(i)+"o.pfcljja.nc","r")
 data(i,:,:) = cdf_file1->temp_mm_uo(0,0,:,:)
end do

;=============
; Calculate the SST anomaly

anomSST = data(1,:,:) - data(0,:,:)

anomSST!0   ="lat"    ; Set metadata for first array
anomSST!1   = "lon"
anomSST&lat = lat
anomSST&lon = lon

;==================================================================================== 
; Plots the maps

begin

wks = gsn_open_wks("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/SST_anom.pdf")  
plot = new (3, graphic)   

res1=True

 ;contour_list0000:=(/0,50,100,150,200,250,300,350,400,500,600,800,1000,1500,2000,2500/)
 ;contour_list00001:=(/-800,-700,-600,-500,-400,-300,-250,-200,-150,-100,-75,-50,-25,0,25,50,75,100,150,200,250,300,400,500,600,700,800/)
 contour_list0000:=(/-30,-25,-20,-18,-16,-14,-12,-10,-8,-6,-4,-2,0,2,4,6,8,10,12,14,16,18,20,25,30/)
 contour_list00001:=(/-8,-7,-6,-5,-4,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,4,5,6,7,8/)
 my_fix_contours(data,contour_list0000)
 colormap_orig0000=(/"(/0.56,0.17,0.93/)","(/0,0,0.93/)","(/0.52,0.80,0.92/)","(/1,1,1/)","(/1,0.64,0/)","(/0.93,0,0/)","(/1,0.08,0.58/)"/)
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

; res1@mpMinLatF =  -40
; res1@mpMaxLatF = 50
; res1@mpMinLonF = -30
; res1@mpMaxLonF = 70

 res1@mpGeophysicalLineColor="Black"
 ;res1@mpFillOn = False
 res1@mpPerimOn         = True

 res1@mpGeophysicalLineColor="Black"
 res1@mpFillOn = False
 res1@mpPerimOn         = True
 res1@mpOutlineDrawOrder    = "PostDraw"

 res1@gsnRightString = ""

 res1@gsnLeftString = "HadCM3B-C Glacial SSTs (mm/yr)"
 plot(0) = gsn_csm_contour_map(wks,data(0,:,:),res1)

 res1@gsnLeftString = "HadCM3B-C no-Ice SSTs (mm/yr)"
 plot(1) = gsn_csm_contour_map(wks,data(1,:,:),res1)


;====
my_fix_contours(anomSST,contour_list00001)
colormap_orig0000=(/"(/0.56,0.17,0.93/)","(/0,0,0.93/)","(/0.52,0.80,0.92/)","(/1,1,1/)","(/1,0.64,0/)","(/0.93,0,0/)","(/1,0.08,0.58/)"/)
;colormap_orig0000=colormap_orig0000(::-1)
colormap_revised0000=my_StretchColorMap(colormap_orig0000,contour_list00001)
delete(colormap_orig0000)
my_updateColors1a(colormap_revised0000,contour_list00001,"zero","Gray91","-1","Gray91")
res1@gsnSpreadColors = False
ColorMap0000:=colormap_revised0000
delete(colormap_revised0000)
res1@cnLevels:=contour_list00001
res1@cnFillPalette:=ColorMap0000

;===

res1@gsnLeftString = "HadCM3B-C remove ice Anom. (noIce-Ice; mm/yr)"
plot(2) = gsn_csm_contour_map(wks,anomSST,res1)


gsn_panel(wks,plot,(/1,3/),False)

delete(res1)
delete(plot)
end


;=========================================================;======================================================================
;=========================================================;======================================================================
;=========================================================;======================================================================

; THIS IS FOR THE 3D PLOTS

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

vars = (/"omega_mm_p","u_mm_p"/)  ; vq_mm_p. uq_mm_p.  ; "u_mm_p","v_mm_p"
varT = (/"rh_mm_p","temp_mm_p","ht_mm_p"/)

sims = ((/"tevTa1","tevUa","tevza1","tevzb1","tevzc1","tevzd1","tevze1","tevzf1","tevzg1"/))

cdf_file1 = addfile("/home/bridge/ea13310/ummodel/data/"+sims(0)+"/climate/"+sims(0)+"a.pccljja.nc","r")
lon = cdf_file1 ->longitude_1
lat = cdf_file1 ->latitude_1
ilat1 = dimsizes(lat)
ilon1 = dimsizes(lon)
depth = cdf_file1 ->p
idepth=dimsizes(depth)

lonW = cdf_file1 ->longitude
latW = cdf_file1 ->latitude
ilatW = dimsizes(latW)
ilonW = dimsizes(lonW)

dataW = new((/dimsizes(vars),dimsizes(sims),idepth,ilatW,ilonW/),"float")
dataW!3   ="lat"    ; Set metadata for first array
dataW!4   = "lon"
dataW!2   = "depth"
dataW&lat = latW
dataW&lon = lonW
dataW&depth = depth

data := new((/dimsizes(varT),dimsizes(sims),idepth,ilat1,ilon1/),"float")
data!3   ="lat"    ; Set metadata for first array
data!4   = "lon"
data!2   = "depth"
data&lat = lat
data&lon = lon
data&depth = depth

;=====
do i=0, dimsizes(sims)-1
 print(sims(i)+0)
 cdf_file1 = addfile("/home/bridge/ea13310/ummodel/data/"+sims(i)+"/climate/"+sims(i)+"a.pccljja.nc","r")
 dataW(0,i,:,:,:) = cdf_file1->omega_mm_p(0,:,:,:)
 dataW(1,i,:,:,:) = cdf_file1->u_mm_p(0,:,:,:)

 data(0,i,:,:,:) = cdf_file1->rh_mm_p(0,:,:,:)
 data(1,i,:,:,:) = cdf_file1->temp_mm_p(0,:,:,:)
 data(2,i,:,:,:) = cdf_file1->ht_mm_p(0,:,:,:)
end do


;data=data*365

data(1,:,:,:,:) = data(1,:,:,:,:) - 273.15

;==

dataW_10 := dim_avg_n_Wrap(dataW(:,:,0:11,{-10:40},{-10:15}),4)
data_10 := dim_avg_n_Wrap(data(:,:,0:11,{-10:40},{-10:15}),4)

dataW_10!3  ="lat"    ; Set metadata for first array
dataW_10!2   = "depth"
dataW_10&depth@units="millibars"
data_10!3  ="lat"    ; Set metadata for first array
data_10!2   = "depth"
data_10&depth@units="millibars"
;==

;ice_sheet_anom_hadam3_W := dataW(:,1,:,:,:) - dataW(:,2,:,:,:) 
;ice_sheet_anom_hadam3 := data(:,1,:,:,:) - data(:,2,:,:,:) 

;sst_anom_W := dataW(:,3,:,:,:) - dataW(:,2,:,:,:) 
;sst_anom := data(:,3,:,:,:) - data(:,2,:,:,:) 

;atm_anom_W := dataW(:,5,:,:,:) - dataW(:,2,:,:,:) 
;atm_anom := data(:,5,:,:,:) - data(:,2,:,:,:) 

;topo_anom_W :=dataW(:,8,:,:,:) - dataW(:,2,:,:,:) 
;topo_anom :=data(:,8,:,:,:) - data(:,2,:,:,:) 


ice_sheet_anom_hadam3_W := dataW(:,2,:,:,:) - dataW(:,1,:,:,:) 
ice_sheet_anom_hadam3 := data(:,2,:,:,:) - data(:,1,:,:,:) 
sst_anom_W := dataW(:,2,:,:,:) - dataW(:,3,:,:,:) 
sst_anom := data(:,2,:,:,:) - data(:,3,:,:,:) 
atm_anom_W := dataW(:,2,:,:,:) - dataW(:,5,:,:,:) 
atm_anom := data(:,2,:,:,:) - data(:,5,:,:,:) 
topo_anom_W :=dataW(:,2,:,:,:) - dataW(:,8,:,:,:) 
topo_anom :=data(:,2,:,:,:) - data(:,8,:,:,:) 


sst_anom_W!2   ="lat"    ; Set metadata for first array
sst_anom_W!3   = "lon"
sst_anom_W!1   = "depth"
sst_anom_W&lat = latW
sst_anom_W&lon = lonW
sst_anom_W&depth = depth
 sst_anom_W&depth@units="millibars"

sst_anom!2   ="lat"    ; Set metadata for first array
sst_anom!3   = "lon"
sst_anom!1   = "depth"
sst_anom&lat = lat
sst_anom&lon = lon
sst_anom&depth = depth
 sst_anom&depth@units="millibars"

copy_VarMeta(sst_anom_W,atm_anom_W)
copy_VarMeta(sst_anom_W,topo_anom_W)
copy_VarMeta(sst_anom_W,ice_sheet_anom_hadam3_W)
copy_VarMeta(sst_anom,atm_anom)
copy_VarMeta(sst_anom,topo_anom)
copy_VarMeta(sst_anom,ice_sheet_anom_hadam3)

ice_sheet_anom_hadam3_W :=dim_avg_n_Wrap(ice_sheet_anom_hadam3_W(:,0:11,{-10:40},{-10:15}),3)
ice_sheet_anom_hadam3 := dim_avg_n_Wrap(ice_sheet_anom_hadam3(:,0:11,{-10:40},{-10:15}),3)

sst_anom_W:=dim_avg_n_Wrap(sst_anom_W(:,0:11,{-10:40},{-10:15}),3)
sst_anom := dim_avg_n_Wrap(sst_anom(:,0:11,{-10:40},{-10:15}),3)
atm_anom_W := dim_avg_n_Wrap(atm_anom_W(:,0:11,{-10:40},{-10:15}),3)
atm_anom := dim_avg_n_Wrap(atm_anom(:,0:11,{-10:40},{-10:15}),3)
topo_anom_W :=dim_avg_n_Wrap(topo_anom_W(:,0:11,{-10:40},{-10:15}),3)
topo_anom :=dim_avg_n_Wrap(topo_anom(:,0:11,{-10:40},{-10:15}),3)




;====================================================================;====================================================================
;====================================================================;====================================================================


begin
wks   = gsn_open_wks ("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/lat_ht_HadAM3_ALL_Vars.pdf")          ; send graphics to PNG file

plot = new (6, graphic)   

res=True
res1=True

contour_list0000:=(/-0.08,-0.06,-0.05,-0.04,-0.03,-0.025,-0.02,-0.015,-0.01,-0.005,0,0.005,0.01,0.015,0.02,0.025,0.03,0.04,0.05,0.06,0.08/)
my_fix_contours(dataW_10(0,2,:,:),contour_list0000)
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
 
 res1@gsnRightString   = ""   
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

res1@gsnLeftString = "Control: JJA Vert Velo & Zonal (-10W:20E; m/s)"
 plotA = gsn_csm_pres_hgt(wks,dataW_10(0,2,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,dataW_10(1,2,:,:),res)
 overlay(plotA,plotB)                      
 plot(0) = plotA                           

res1@gsnLeftString = "Orb_GHG 176kyr: JJA Vert Velo & Zonal (-10W:20E; m/s)"
 plotC = gsn_csm_pres_hgt(wks,dataW_10(0,1,:,:),res1)
 plotD = gsn_csm_pres_hgt(wks,dataW_10(1,1,:,:),res)
 overlay(plotC,plotD)                      
 plot(1) = plotC        


;====
contour_list0000:=(/-80,-70,-60,-50,-40,-30,-20,-10,-5,0,5,10,20,30,40,50,60,70,80/)
my_fix_contours(data_10(1,2,:,:),contour_list0000)
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
  res1@gsnLeftString = "Control:JJA Temp(C), Geo.Pot.Ht(m), Rel.Hum.(%)(-10W:20E)"
 plotA = gsn_csm_pres_hgt(wks,data_10(1,2,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,data_10(2,2,:,:),res)
 overlay(plotA,plotB)                      
 res@cnLineColor  = "seagreen"  
  res@cnMinLevelValF  = 0.        ; set the minimum contour level
  res@cnMaxLevelValF  = 100.         ; set the maximum contour level
  res@cnLevelSpacingF = 10               
 plotC = gsn_csm_pres_hgt(wks,data_10(0,2,:,:),res)
 overlay(plotA,plotC)  
 plot(3) = plotA                           


  res@cnLineColor  = "black" 
  res@cnMinLevelValF  = 0        ; set the minimum contour level
  res@cnMaxLevelValF  = 16600         ; set the maximum contour level
  res@cnLevelSpacingF = 2000   
res1@gsnLeftString = "Orb_GHG:JJA Temp(C), Geo.Pot.Ht(m), Rel.Hum.(%)(-10W:20E)"
 plotD = gsn_csm_pres_hgt(wks,data_10(1,1,:,:),res1)
 plotE = gsn_csm_pres_hgt(wks,data_10(2,1,:,:),res)
 overlay(plotD,plotE)                      
 res@cnLineColor  = "seagreen"  
  res@cnMinLevelValF  = 0.        ; set the minimum contour level
  res@cnMaxLevelValF  = 100.         ; set the maximum contour level
  res@cnLevelSpacingF = 10               
 plotF = gsn_csm_pres_hgt(wks,data_10(0,1,:,:),res)
 overlay(plotD,plotF)  
 plot(4) = plotD                           


;====================================================================
contour_list0000:=(/-0.03,-0.025,-0.02,-0.0175,-0.015,-0.0125,-0.01,-0.0075,-0.005,-0.0025,0,0.0025,0.005,0.0075,0.01,0.0125,0.015,0.0175,0.02,0.025,0.03/)
my_fix_contours(ice_sheet_anom_hadam3_W(0,:,:),contour_list0000)
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
res1@gsnLeftString = "JJA Vert Velo & Zonal Anomaly (Control-Orb_GHG)"
plotI = gsn_csm_pres_hgt(wks,ice_sheet_anom_hadam3_W(0,:,:),res1)
;plotJ = gsn_csm_pres_hgt(wks,ice_sheet_anom_hadam3_W(1,:,:),res)
; overlay(plotI,plotJ)                      
 plot(2) = plotI  

contour_list0000:=(/-7,-6,-5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,-0.25,0,0.25,0.5,1,1.5,2,2.5,3,3.5,4,5,6,7/)
my_fix_contours(ice_sheet_anom_hadam3(1,:,:),contour_list0000)
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
res@cnMinLevelValF  = -130         ; set the minimum contour level
  res@cnMaxLevelValF  = 60       ; set the maximum contour level
  res@cnLevelSpacingF = 10    
res1@gsnLeftString = "JJA Temp(C), Geo.Pot.Ht(m), Rel.Hum.(%) Anom"
plotI = gsn_csm_pres_hgt(wks,ice_sheet_anom_hadam3(1,:,:),res1)
plotJ = gsn_csm_pres_hgt(wks,ice_sheet_anom_hadam3(2,:,:),res)
 overlay(plotI,plotJ)                      
  res@cnLineColor  = "seagreen"   
  res@cnMinLevelValF  = -40.         ; set the minimum contour level
  res@cnMaxLevelValF  = 10.       ; set the maximum contour level
  res@cnLevelSpacingF = 5  
plotK = gsn_csm_pres_hgt(wks,ice_sheet_anom_hadam3(0,:,:),res)
overlay(plotI,plotK)
 plot(5) = plotI  



;====
gsn_panel(wks,plot,(/2,3/),False)

delete(res1)
delete(res)
end





;====================================================================
;====================================================================



begin
wks   = gsn_open_wks ("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/lat_ht_SST_ALL_Vars2.pdf")          ; send graphics to PNG file

plot = new (6, graphic)   
res=True
res1=True

contour_list0000:=(/-0.08,-0.06,-0.05,-0.04,-0.03,-0.025,-0.02,-0.015,-0.01,-0.005,0,0.005,0.01,0.015,0.02,0.025,0.03,0.04,0.05,0.06,0.08/)
my_fix_contours(dataW_10(0,2,:,:),contour_list0000)
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
 
 res1@gsnRightString   = ""    
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

res1@gsnLeftString = "Control: JJA Vert Velo & Zonal(-10W:20E; m/s)"
 plotA = gsn_csm_pres_hgt(wks,dataW_10(0,2,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,dataW_10(1,2,:,:),res)
 overlay(plotA,plotB)                      
 plot(0) = plotA                           

res1@gsnLeftString = "glacial_noSST: JJA Vert Velo & Zonal(-10W:20E; m/s)"
 plotC = gsn_csm_pres_hgt(wks,dataW_10(0,3,:,:),res1)
 plotD = gsn_csm_pres_hgt(wks,dataW_10(1,3,:,:),res)
 overlay(plotC,plotD)                      
 plot(1) = plotC        


;====
contour_list0000:=(/-80,-70,-60,-50,-40,-30,-20,-10,-5,0,5,10,20,30,40,50,60,70,80/)
my_fix_contours(data_10(1,2,:,:),contour_list0000)
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
  res1@gsnLeftString = "Control:JJA Temp(C), Geo.Pot.Ht(m), Rel.Hum.(%)(-10W:20E)"
 plotA = gsn_csm_pres_hgt(wks,data_10(1,2,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,data_10(2,2,:,:),res)
 overlay(plotA,plotB)                      
 res@cnLineColor  = "seagreen"  
  res@cnMinLevelValF  = 0.        ; set the minimum contour level
  res@cnMaxLevelValF  = 100.         ; set the maximum contour level
  res@cnLevelSpacingF = 10               
 plotC = gsn_csm_pres_hgt(wks,data_10(0,2,:,:),res)
 overlay(plotA,plotC)  
 plot(3) = plotA                           


  res@cnLineColor  = "black" 
  res@cnMinLevelValF  = 0        ; set the minimum contour level
  res@cnMaxLevelValF  = 16600         ; set the maximum contour level
  res@cnLevelSpacingF = 2000   
res1@gsnLeftString = "glacial_noSST:JJA Temp(C), Geo.Pot.Ht(m), Rel.Hum.(%)(-10W:20E)"
 plotD = gsn_csm_pres_hgt(wks,data_10(1,3,:,:),res1)
 plotE = gsn_csm_pres_hgt(wks,data_10(2,3,:,:),res)
 overlay(plotD,plotE)                      
 res@cnLineColor  = "seagreen"  
  res@cnMinLevelValF  = 0.        ; set the minimum contour level
  res@cnMaxLevelValF  = 100.         ; set the maximum contour level
  res@cnLevelSpacingF = 10               
 plotF = gsn_csm_pres_hgt(wks,data_10(0,3,:,:),res)
 overlay(plotD,plotF)  
 plot(4) = plotD                           


;====================================================================
contour_list0000:=(/-0.03,-0.025,-0.02,-0.0175,-0.015,-0.0125,-0.01,-0.0075,-0.005,-0.0025,0,0.0025,0.005,0.0075,0.01,0.0125,0.015,0.0175,0.02,0.025,0.03/)
my_fix_contours(sst_anom_W(0,:,:),contour_list0000)
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
res1@gsnLeftString = "JJA Vert Velo & Zonal Anomaly (Control-glacial_noSST)"
plotI = gsn_csm_pres_hgt(wks,sst_anom_W(0,:,:),res1)
; overlay(plotI,plotJ)                      
 plot(2) = plotI  

contour_list0000:=(/-7,-6,-5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,-0.25,0,0.25,0.5,1,1.5,2,2.5,3,3.5,4,5,6,7/)
my_fix_contours(sst_anom(1,:,:),contour_list0000)
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
res@cnMinLevelValF  = -130         ; set the minimum contour level
  res@cnMaxLevelValF  = 60       ; set the maximum contour level
  res@cnLevelSpacingF = 10    
res1@gsnLeftString = "JJA Temp(C), Geo.Pot.Ht(m), Rel.Hum.(%) Anom"
plotI = gsn_csm_pres_hgt(wks,sst_anom(1,:,:),res1)
plotJ = gsn_csm_pres_hgt(wks,sst_anom(2,:,:),res)
 overlay(plotI,plotJ)                      
  res@cnLineColor  = "seagreen"   
  res@cnMinLevelValF  = -40.         ; set the minimum contour level
  res@cnMaxLevelValF  = 10.       ; set the maximum contour level
  res@cnLevelSpacingF = 5   
plotK = gsn_csm_pres_hgt(wks,sst_anom(0,:,:),res)
overlay(plotI,plotK)
 plot(5) = plotI  



;====
gsn_panel(wks,plot,(/2,3/),False)

delete(res1)
delete(res)
end



;====================================================================

begin
wks   = gsn_open_wks ("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/lat_ht_ATM_ALL_Vars2.pdf")          ; send graphics to PNG file

plot = new (6, graphic)   
res=True
res1=True

contour_list0000:=(/-0.08,-0.06,-0.05,-0.04,-0.03,-0.025,-0.02,-0.015,-0.01,-0.005,0,0.005,0.01,0.015,0.02,0.025,0.03,0.04,0.05,0.06,0.08/)
my_fix_contours(dataW_10(0,2,:,:),contour_list0000)
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
 
   res1@gsnRightString   = ""    
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

res1@gsnLeftString = "Control: JJA Vert Velo & Zonal (-10W:20E; m/s)"
 plotA = gsn_csm_pres_hgt(wks,dataW_10(0,2,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,dataW_10(1,2,:,:),res)
 overlay(plotA,plotB)                      
 plot(0) = plotA                           

res1@gsnLeftString = "glacial_noAlb: JJA Vert Velo & Zonal (-10W:20E; m/s)"
 plotC = gsn_csm_pres_hgt(wks,dataW_10(0,5,:,:),res1)
 plotD = gsn_csm_pres_hgt(wks,dataW_10(1,5,:,:),res)
 overlay(plotC,plotD)                      
 plot(1) = plotC        


;====
contour_list0000:=(/-80,-70,-60,-50,-40,-30,-20,-10,-5,0,5,10,20,30,40,50,60,70,80/)
my_fix_contours(data_10(1,2,:,:),contour_list0000)
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
  res1@gsnLeftString = "Control:JJA Temp(C), Geo.Pot.Ht(m), Rel.Hum.(%)(-10W:20E)"
 plotA = gsn_csm_pres_hgt(wks,data_10(1,2,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,data_10(2,2,:,:),res)
 overlay(plotA,plotB)                      
 res@cnLineColor  = "seagreen"  
  res@cnMinLevelValF  = 0.        ; set the minimum contour level
  res@cnMaxLevelValF  = 100.         ; set the maximum contour level
  res@cnLevelSpacingF = 10               
 plotC = gsn_csm_pres_hgt(wks,data_10(0,2,:,:),res)
 overlay(plotA,plotC)  
 plot(3) = plotA                           


  res@cnLineColor  = "black" 
  res@cnMinLevelValF  = 0        ; set the minimum contour level
  res@cnMaxLevelValF  = 16600         ; set the maximum contour level
  res@cnLevelSpacingF = 2000   
res1@gsnLeftString = "glacial_noAlb:JJA Temp(C), Geo.Pot.Ht(m), Rel.Hum.(%)(-10W:20E)"
 plotD = gsn_csm_pres_hgt(wks,data_10(1,5,:,:),res1)
 plotE = gsn_csm_pres_hgt(wks,data_10(2,5,:,:),res)
 overlay(plotD,plotE)                      
 res@cnLineColor  = "seagreen"  
  res@cnMinLevelValF  = 0.        ; set the minimum contour level
  res@cnMaxLevelValF  = 100.         ; set the maximum contour level
  res@cnLevelSpacingF = 10               
 plotF = gsn_csm_pres_hgt(wks,data_10(0,5,:,:),res)
 overlay(plotD,plotF)  
 plot(4) = plotD                           


;====================================================================
contour_list0000:=(/-0.03,-0.025,-0.02,-0.0175,-0.015,-0.0125,-0.01,-0.0075,-0.005,-0.0025,0,0.0025,0.005,0.0075,0.01,0.0125,0.015,0.0175,0.02,0.025,0.03/)
my_fix_contours(atm_anom_W(0,:,:),contour_list0000)
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
res1@gsnLeftString = "JJA Vert Velo & Zonal Anomaly (Control-glacial_noAlb)"
plotI = gsn_csm_pres_hgt(wks,atm_anom_W(0,:,:),res1)
; overlay(plotI,plotJ)                      
 plot(2) = plotI  

contour_list0000:=(/-7,-6,-5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,-0.25,0,0.25,0.5,1,1.5,2,2.5,3,3.5,4,5,6,7/)
my_fix_contours(atm_anom(1,:,:),contour_list0000)
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
res@cnMinLevelValF  = -130         ; set the minimum contour level
  res@cnMaxLevelValF  = 60       ; set the maximum contour level
  res@cnLevelSpacingF = 10    
res1@gsnLeftString = "JJA Temp(C), Geo.Pot.Ht(m), Rel.Hum.(%) Anom"
plotI = gsn_csm_pres_hgt(wks,atm_anom(1,:,:),res1)
plotJ = gsn_csm_pres_hgt(wks,atm_anom(2,:,:),res)
 overlay(plotI,plotJ)                      
  res@cnLineColor  = "seagreen"   
  res@cnMinLevelValF  = -40.         ; set the minimum contour level
  res@cnMaxLevelValF  = 10.       ; set the maximum contour level
  res@cnLevelSpacingF = 5  
plotK = gsn_csm_pres_hgt(wks,atm_anom(0,:,:),res)
overlay(plotI,plotK)
 plot(5) = plotI  



;====
gsn_panel(wks,plot,(/2,3/),False)

delete(res1)
delete(res)
end


;==========================================================================================================================================================
begin
wks   = gsn_open_wks ("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/lat_ht_TOPO_ALL_Vars2.pdf")          ; send graphics to PNG file

plot = new (6, graphic)   
res=True
res1=True

contour_list0000:=(/-0.08,-0.06,-0.05,-0.04,-0.03,-0.025,-0.02,-0.015,-0.01,-0.005,0,0.005,0.01,0.015,0.02,0.025,0.03,0.04,0.05,0.06,0.08/)
my_fix_contours(dataW_10(0,2,:,:),contour_list0000)
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
 
   res1@gsnRightString   = ""    
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

res1@gsnLeftString = "Control: JJA Vert Velo & Zonal (-10W:20E; m/s)"
 plotA = gsn_csm_pres_hgt(wks,dataW_10(0,2,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,dataW_10(1,2,:,:),res)
 overlay(plotA,plotB)                      
 plot(0) = plotA                           

res1@gsnLeftString = "glacial_noTopo: JJA Vert Velo & Zonal (-10W:20E; m/s)"
 plotC = gsn_csm_pres_hgt(wks,dataW_10(0,8,:,:),res1)
 plotD = gsn_csm_pres_hgt(wks,dataW_10(1,8,:,:),res)
 overlay(plotC,plotD)                      
 plot(1) = plotC        


;====
contour_list0000:=(/-80,-70,-60,-50,-40,-30,-20,-10,-5,0,5,10,20,30,40,50,60,70,80/)
my_fix_contours(data_10(1,2,:,:),contour_list0000)
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
  res1@gsnLeftString = "Control:JJA Temp(C), Geo.Pot.Ht(m), Rel.Hum.(%)(-10W:20E)"
 plotA = gsn_csm_pres_hgt(wks,data_10(1,2,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,data_10(2,2,:,:),res)
 overlay(plotA,plotB)                      
 res@cnLineColor  = "seagreen"  
  res@cnMinLevelValF  = 0.        ; set the minimum contour level
  res@cnMaxLevelValF  = 100.         ; set the maximum contour level
  res@cnLevelSpacingF = 10               
 plotC = gsn_csm_pres_hgt(wks,data_10(0,2,:,:),res)
 overlay(plotA,plotC)  
 plot(3) = plotA                           


  res@cnLineColor  = "black" 
  res@cnMinLevelValF  = 0        ; set the minimum contour level
  res@cnMaxLevelValF  = 16600         ; set the maximum contour level
  res@cnLevelSpacingF = 2000   
res1@gsnLeftString = "glacial_noTopo:JJA Temp(C), Geo.Pot.Ht(m), Rel.Hum.(%)(-10W:20E)"
 plotD = gsn_csm_pres_hgt(wks,data_10(1,8,:,:),res1)
 plotE = gsn_csm_pres_hgt(wks,data_10(2,8,:,:),res)
 overlay(plotD,plotE)                      
 res@cnLineColor  = "seagreen"  
  res@cnMinLevelValF  = 0.        ; set the minimum contour level
  res@cnMaxLevelValF  = 100.         ; set the maximum contour level
  res@cnLevelSpacingF = 10               
 plotF = gsn_csm_pres_hgt(wks,data_10(0,8,:,:),res)
 overlay(plotD,plotF)  
 plot(4) = plotD                           


;====================================================================
contour_list0000:=(/-0.03,-0.025,-0.02,-0.0175,-0.015,-0.0125,-0.01,-0.0075,-0.005,-0.0025,0,0.0025,0.005,0.0075,0.01,0.0125,0.015,0.0175,0.02,0.025,0.03/)
my_fix_contours(topo_anom_W(0,:,:),contour_list0000)
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
res1@gsnLeftString = "JJA Vert Velo & Zonal Anomaly (Control-glacial_noTopo)"
plotI = gsn_csm_pres_hgt(wks,topo_anom_W(0,:,:),res1)
; overlay(plotI,plotJ)                      
 plot(2) = plotI  

contour_list0000:=(/-7,-6,-5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,-0.25,0,0.25,0.5,1,1.5,2,2.5,3,3.5,4,5,6,7/)
my_fix_contours(topo_anom(1,:,:),contour_list0000)
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
res@cnMinLevelValF  = -130         ; set the minimum contour level
  res@cnMaxLevelValF  = 60       ; set the maximum contour level
  res@cnLevelSpacingF = 10    
res1@gsnLeftString = "JJA Temp(C), Geo.Pot.Ht(m), Rel.Hum.(%) Anom"
plotI = gsn_csm_pres_hgt(wks,topo_anom(1,:,:),res1)
plotJ = gsn_csm_pres_hgt(wks,topo_anom(2,:,:),res)
 overlay(plotI,plotJ)                      
  res@cnLineColor  = "seagreen"   
  res@cnMinLevelValF  = -40.         ; set the minimum contour level
  res@cnMaxLevelValF  = 10.       ; set the maximum contour level
  res@cnLevelSpacingF = 5  
plotK = gsn_csm_pres_hgt(wks,topo_anom(0,:,:),res)
overlay(plotI,plotK)
 plot(5) = plotI  



;====
gsn_panel(wks,plot,(/2,3/),False)

delete(res1)
delete(res)
end





















plot = new (12, graphic)   

res=True
res1=True

contour_list0000:=(/-0.08,-0.06,-0.05,-0.04,-0.03,-0.025,-0.02,-0.015,-0.01,-0.005,0,0.005,0.01,0.015,0.02,0.025,0.03,0.04,0.05,0.06,0.08/)
my_fix_contours(dataW_10(0,2,:,:),contour_list0000)
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

res1@gsnLeftString = "Glacial: JJA Vert Velo & Zonal (-10W:10E; m/s)"
 plotA = gsn_csm_pres_hgt(wks,dataW_10(0,2,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,dataW_10(1,2,:,:),res)
 overlay(plotA,plotB)                      
 plot(0) = plotA                           

res1@gsnLeftString = "No Ice SST: JJA Vert Velo & Zonal (-10W:10E; m/s)"
 plotC = gsn_csm_pres_hgt(wks,dataW_10(0,3,:,:),res1)
 plotD = gsn_csm_pres_hgt(wks,dataW_10(1,3,:,:),res)
 overlay(plotC,plotD)                      
 plot(1) = plotC        


  res@cnLevelSelectionMode = "ManualLevels"  ; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -80.        ; set the minimum contour level
  res@cnMaxLevelValF  = 40.         ; set the maximum contour level
  res@cnLevelSpacingF = 10.         
res1@gsnLeftString = "Glacial: JJA Vert. Velo. & Temp. (-10W:20E)"
 plotA = gsn_csm_pres_hgt(wks,dataW_10(0,2,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,data_10(1,2,:,:),res)
 overlay(plotA,plotB)                      
 plot(3) = plotA                           

res1@gsnLeftString = "No Ice SST:JJA Vert. Velo. & Temp. (-10W:20E)"
 plotC = gsn_csm_pres_hgt(wks,dataW_10(0,3,:,:),res1)
 plotD = gsn_csm_pres_hgt(wks,data_10(1,3,:,:),res)
 overlay(plotC,plotD)                      
 plot(4) = plotC      

  res@cnMinLevelValF  = 0.        ; set the minimum contour level
  res@cnMaxLevelValF  = 100.         ; set the maximum contour level
  res@cnLevelSpacingF = 5         
res1@gsnLeftString = "Glacial: JJA Vert. Velo. & Rel. Humid.(-10W:20E)"
 plotA = gsn_csm_pres_hgt(wks,dataW_10(0,2,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,data_10(0,2,:,:),res)
 overlay(plotA,plotB)                      
 plot(9) = plotA                           

res1@gsnLeftString = "No Ice SST: JJA Vert. Velo. & Rel. Humid. (-10W:20E)"
 plotC = gsn_csm_pres_hgt(wks,dataW_10(0,3,:,:),res1)
 plotD = gsn_csm_pres_hgt(wks,data_10(0,3,:,:),res)
 overlay(plotC,plotD)                      
 plot(10) = plotC       


  res@cnMinLevelValF  = 0        ; set the minimum contour level
  res@cnMaxLevelValF  = 16600         ; set the maximum contour level
  res@cnLevelSpacingF = 1000       
res1@gsnLeftString = "Glacial: JJA Vert. Velo. & Geo.Pot.Ht (-10W:20E)"
 plotA = gsn_csm_pres_hgt(wks,dataW_10(0,2,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,data_10(2,2,:,:),res)
 overlay(plotA,plotB)                      
 plot(6) = plotA                           

res1@gsnLeftString = "No Ice SST: JJA Vert. Velo. & Geo.Pot.Ht (-10W:20E)"
 plotC = gsn_csm_pres_hgt(wks,dataW_10(0,3,:,:),res1)
 plotD = gsn_csm_pres_hgt(wks,data_10(2,3,:,:),res)
 overlay(plotC,plotD)                      
 plot(7) = plotC      



;====================================================================
contour_list0000:=(/-0.03,-0.025,-0.02,-0.0175,-0.015,-0.0125,-0.01,-0.0075,-0.005,-0.0025,0,0.0025,0.005,0.0075,0.01,0.0125,0.015,0.0175,0.02,0.025,0.03/)
my_fix_contours(ice_sheet_anom_hadam3_W(0,:,:),contour_list0000)
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
res1@gsnLeftString = "JJA Vert Velo & Zonal Anomaly (noIceSST-Ice)"
plotI = gsn_csm_pres_hgt(wks,sst_anom_W(0,:,:),res1)
;plotJ = gsn_csm_pres_hgt(wks,sst_anom_W(1,:,:),res)
; overlay(plotI,plotJ)                      
 plot(2) = plotI  


  res@cnMinLevelValF  = -15.         ; set the minimum contour level
  res@cnMaxLevelValF  = 40.       ; set the maximum contour level
  res@cnLevelSpacingF = 5  
res1@gsnLeftString = "JJA Vert. Velo. & Rel. Humid. Anom (noIceSST-Ice)"
plotI = gsn_csm_pres_hgt(wks,sst_anom_W(0,:,:),res1)
plotJ = gsn_csm_pres_hgt(wks,sst_anom(0,:,:),res)
 overlay(plotI,plotJ)                      
 plot(11) = plotI  


  res@cnMinLevelValF  = -7.         ; set the minimum contour level
  res@cnMaxLevelValF  = 5       ; set the maximum contour level
  res@cnLevelSpacingF = 0.25   
res1@gsnLeftString = "JJA Vert. Velo. & Temp. Anom (noIceSST-Ice)"
plotI = gsn_csm_pres_hgt(wks,sst_anom_W(0,:,:),res1)
plotJ = gsn_csm_pres_hgt(wks,sst_anom(1,:,:),res)
 overlay(plotI,plotJ)                      
 plot(5) = plotI  


res@cnMinLevelValF  = -70         ; set the minimum contour level
  res@cnMaxLevelValF  = 130       ; set the maximum contour level
  res@cnLevelSpacingF = 10   
res1@gsnLeftString = "JJA Vert. Velo. & Geo.Pot.Ht Anom (noIceSST-Ice)"
plotI = gsn_csm_pres_hgt(wks,sst_anom_W(0,:,:),res1)
plotJ = gsn_csm_pres_hgt(wks,sst_anom(2,:,:),res)
 overlay(plotI,plotJ)                      
 plot(8) = plotI  


;====
gsn_panel(wks,plot,(/4,3/),False)

delete(res1)
delete(res)
end


;====================================================================

begin
wks   = gsn_open_wks ("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/lat_ht_ATM_ALL_Vars.pdf")          ; send graphics to PNG file

plot = new (12, graphic)   

res=True
res1=True

contour_list0000:=(/-0.08,-0.06,-0.05,-0.04,-0.03,-0.025,-0.02,-0.015,-0.01,-0.005,0,0.005,0.01,0.015,0.02,0.025,0.03,0.04,0.05,0.06,0.08/)
my_fix_contours(dataW_10(0,2,:,:),contour_list0000)
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

res1@gsnLeftString = "Glacial: JJA Vert Velo & Zonal (-10W:10E; m/s)"
 plotA = gsn_csm_pres_hgt(wks,dataW_10(0,2,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,dataW_10(1,2,:,:),res)
 overlay(plotA,plotB)                      
 plot(0) = plotA                           

res1@gsnLeftString = "No Ice ATM: JJA Vert Velo & Zonal (-10W:10E; m/s)"
 plotC = gsn_csm_pres_hgt(wks,dataW_10(0,5,:,:),res1)
 plotD = gsn_csm_pres_hgt(wks,dataW_10(1,5,:,:),res)
 overlay(plotC,plotD)                      
 plot(1) = plotC        


  res@cnLevelSelectionMode = "ManualLevels"  ; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -80.        ; set the minimum contour level
  res@cnMaxLevelValF  = 40.         ; set the maximum contour level
  res@cnLevelSpacingF = 10.         
res1@gsnLeftString = "Glacial: JJA Vert. Velo. & Temp. (-10W:20E)"
 plotA = gsn_csm_pres_hgt(wks,dataW_10(0,2,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,data_10(1,2,:,:),res)
 overlay(plotA,plotB)                      
 plot(3) = plotA                           

res1@gsnLeftString = "No Ice ATM:JJA Vert. Velo. & Temp. (-10W:20E)"
 plotC = gsn_csm_pres_hgt(wks,dataW_10(0,5,:,:),res1)
 plotD = gsn_csm_pres_hgt(wks,data_10(1,5,:,:),res)
 overlay(plotC,plotD)                      
 plot(4) = plotC      

  res@cnMinLevelValF  = 0.        ; set the minimum contour level
  res@cnMaxLevelValF  = 100.         ; set the maximum contour level
  res@cnLevelSpacingF = 5         
res1@gsnLeftString = "Glacial: JJA Vert. Velo. & Rel. Humid.(-10W:20E)"
 plotA = gsn_csm_pres_hgt(wks,dataW_10(0,2,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,data_10(0,2,:,:),res)
 overlay(plotA,plotB)                      
 plot(9) = plotA                           

res1@gsnLeftString = "No Ice ATM: JJA Vert. Velo. & Rel. Humid. (-10W:20E)"
 plotC = gsn_csm_pres_hgt(wks,dataW_10(0,5,:,:),res1)
 plotD = gsn_csm_pres_hgt(wks,data_10(0,5,:,:),res)
 overlay(plotC,plotD)                      
 plot(10) = plotC       


  res@cnMinLevelValF  = 0        ; set the minimum contour level
  res@cnMaxLevelValF  = 16600         ; set the maximum contour level
  res@cnLevelSpacingF = 1000       
res1@gsnLeftString = "Glacial: JJA Vert. Velo. & Geo.Pot.Ht (-10W:20E)"
 plotA = gsn_csm_pres_hgt(wks,dataW_10(0,2,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,data_10(2,2,:,:),res)
 overlay(plotA,plotB)                      
 plot(6) = plotA                           

res1@gsnLeftString = "No Ice ATM: JJA Vert. Velo. & Geo.Pot.Ht (-10W:20E)"
 plotC = gsn_csm_pres_hgt(wks,dataW_10(0,5,:,:),res1)
 plotD = gsn_csm_pres_hgt(wks,data_10(2,5,:,:),res)
 overlay(plotC,plotD)                      
 plot(7) = plotC      



;====================================================================
contour_list0000:=(/-0.03,-0.025,-0.02,-0.0175,-0.015,-0.0125,-0.01,-0.0075,-0.005,-0.0025,0,0.0025,0.005,0.0075,0.01,0.0125,0.015,0.0175,0.02,0.025,0.03/)
my_fix_contours(ice_sheet_anom_hadam3_W(0,:,:),contour_list0000)
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
res1@gsnLeftString = "JJA Vert Velo & Zonal Anomaly (noIceSST-Ice)"
plotI = gsn_csm_pres_hgt(wks,atm_anom_W(0,:,:),res1)
;plotJ = gsn_csm_pres_hgt(wks,atm_anom_W(1,:,:),res)
; overlay(plotI,plotJ)                      
 plot(2) = plotI  


  res@cnMinLevelValF  = -15.         ; set the minimum contour level
  res@cnMaxLevelValF  = 40.       ; set the maximum contour level
  res@cnLevelSpacingF = 5  
res1@gsnLeftString = "JJA Vert. Velo. & Rel. Humid. Anom (noIceSST-Ice)"
plotI = gsn_csm_pres_hgt(wks,atm_anom_W(0,:,:),res1)
plotJ = gsn_csm_pres_hgt(wks,atm_anom(0,:,:),res)
 overlay(plotI,plotJ)                      
 plot(11) = plotI  


  res@cnMinLevelValF  = -7.         ; set the minimum contour level
  res@cnMaxLevelValF  = 5       ; set the maximum contour level
  res@cnLevelSpacingF = 0.25     
res1@gsnLeftString = "JJA Vert. Velo. & Temp. Anom (noIceSST-Ice)"
plotI = gsn_csm_pres_hgt(wks,atm_anom_W(0,:,:),res1)
plotJ = gsn_csm_pres_hgt(wks,atm_anom(1,:,:),res)
 overlay(plotI,plotJ)                      
 plot(5) = plotI  


res@cnMinLevelValF  = -70         ; set the minimum contour level
  res@cnMaxLevelValF  = 130       ; set the maximum contour level
  res@cnLevelSpacingF = 10  
res1@gsnLeftString = "JJA Vert. Velo. & Geo.Pot.Ht Anom (noIceSST-Ice)"
plotI = gsn_csm_pres_hgt(wks,atm_anom_W(0,:,:),res1)
plotJ = gsn_csm_pres_hgt(wks,atm_anom(2,:,:),res)
 overlay(plotI,plotJ)                      
 plot(8) = plotI  

;====
gsn_panel(wks,plot,(/4,3/),False)

delete(res1)
delete(res)
end


;====================================================================

begin
wks   = gsn_open_wks ("pdf","/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/lat_ht_TOPO_ALL_Vars.pdf")          ; send graphics to PNG file

plot = new (12, graphic)   

res=True
res1=True

contour_list0000:=(/-0.08,-0.06,-0.05,-0.04,-0.03,-0.025,-0.02,-0.015,-0.01,-0.005,0,0.005,0.01,0.015,0.02,0.025,0.03,0.04,0.05,0.06,0.08/)
my_fix_contours(dataW_10(0,2,:,:),contour_list0000)
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

res1@gsnLeftString = "Glacial: JJA Vert Velo & Zonal (-10W:10E; m/s)"
 plotA = gsn_csm_pres_hgt(wks,dataW_10(0,2,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,dataW_10(1,2,:,:),res)
 overlay(plotA,plotB)                      
 plot(0) = plotA                           

res1@gsnLeftString = "No Ice Topo: JJA Vert Velo & Zonal (-10W:10E; m/s)"
 plotC = gsn_csm_pres_hgt(wks,dataW_10(0,8,:,:),res1)
 plotD = gsn_csm_pres_hgt(wks,dataW_10(1,8,:,:),res)
 overlay(plotC,plotD)                      
 plot(1) = plotC        


  res@cnLevelSelectionMode = "ManualLevels"  ; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -80.        ; set the minimum contour level
  res@cnMaxLevelValF  = 40.         ; set the maximum contour level
  res@cnLevelSpacingF = 10.         
res1@gsnLeftString = "Glacial: JJA Vert. Velo. & Temp. (-10W:20E)"
 plotA = gsn_csm_pres_hgt(wks,dataW_10(0,2,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,data_10(1,2,:,:),res)
 overlay(plotA,plotB)                      
 plot(3) = plotA                           

res1@gsnLeftString = "No Ice Topo:JJA Vert. Velo. & Temp. (-10W:20E)"
 plotC = gsn_csm_pres_hgt(wks,dataW_10(0,8,:,:),res1)
 plotD = gsn_csm_pres_hgt(wks,data_10(1,8,:,:),res)
 overlay(plotC,plotD)                      
 plot(4) = plotC      

  res@cnMinLevelValF  = 0.        ; set the minimum contour level
  res@cnMaxLevelValF  = 100.         ; set the maximum contour level
  res@cnLevelSpacingF = 5         
res1@gsnLeftString = "Glacial: JJA Vert. Velo. & Rel. Humid.(-10W:20E)"
 plotA = gsn_csm_pres_hgt(wks,dataW_10(0,2,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,data_10(0,2,:,:),res)
 overlay(plotA,plotB)                      
 plot(9) = plotA                           

res1@gsnLeftString = "No Ice Topo: JJA Vert. Velo. & Rel. Humid. (-10W:20E)"
 plotC = gsn_csm_pres_hgt(wks,dataW_10(0,8,:,:),res1)
 plotD = gsn_csm_pres_hgt(wks,data_10(0,8,:,:),res)
 overlay(plotC,plotD)                      
 plot(10) = plotC       


  res@cnMinLevelValF  = 0        ; set the minimum contour level
  res@cnMaxLevelValF  = 16600         ; set the maximum contour level
  res@cnLevelSpacingF = 1000       
res1@gsnLeftString = "Glacial: JJA Vert. Velo. & Geo.Pot.Ht (-10W:20E)"
 plotA = gsn_csm_pres_hgt(wks,dataW_10(0,2,:,:),res1)
 plotB = gsn_csm_pres_hgt(wks,data_10(2,2,:,:),res)
 overlay(plotA,plotB)                      
 plot(6) = plotA                           

res1@gsnLeftString = "No Ice Topo: JJA Vert. Velo. & Geo.Pot.Ht (-10W:20E)"
 plotC = gsn_csm_pres_hgt(wks,dataW_10(0,8,:,:),res1)
 plotD = gsn_csm_pres_hgt(wks,data_10(2,8,:,:),res)
 overlay(plotC,plotD)                      
 plot(7) = plotC      



;====================================================================
contour_list0000:=(/-0.03,-0.025,-0.02,-0.0175,-0.015,-0.0125,-0.01,-0.0075,-0.005,-0.0025,0,0.0025,0.005,0.0075,0.01,0.0125,0.015,0.0175,0.02,0.025,0.03/)
my_fix_contours(ice_sheet_anom_hadam3_W(0,:,:),contour_list0000)
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
res1@gsnLeftString = "JJA Vert Velo & Zonal Anomaly (noIceSST-Ice)"
plotI = gsn_csm_pres_hgt(wks,topo_anom_W(0,:,:),res1)
;plotJ = gsn_csm_pres_hgt(wks,topo_anom_W(1,:,:),res)
; overlay(plotI,plotJ)                      
 plot(2) = plotI  


  res@cnMinLevelValF  = -15.         ; set the minimum contour level
  res@cnMaxLevelValF  = 40.       ; set the maximum contour level
  res@cnLevelSpacingF = 5  
res1@gsnLeftString = "JJA Vert. Velo. & Rel. Humid. Anom (noIceSST-Ice)"
plotI = gsn_csm_pres_hgt(wks,topo_anom_W(0,:,:),res1)
plotJ = gsn_csm_pres_hgt(wks,topo_anom(0,:,:),res)
 overlay(plotI,plotJ)                      
 plot(11) = plotI  


  res@cnMinLevelValF  = -7.         ; set the minimum contour level
  res@cnMaxLevelValF  = 5       ; set the maximum contour level
  res@cnLevelSpacingF = 0.25   
res1@gsnLeftString = "JJA Vert. Velo. & Temp. Anom (noIceSST-Ice)"
plotI = gsn_csm_pres_hgt(wks,topo_anom_W(0,:,:),res1)
plotJ = gsn_csm_pres_hgt(wks,topo_anom(1,:,:),res)
 overlay(plotI,plotJ)                      
 plot(5) = plotI  


res@cnMinLevelValF  = -70         ; set the minimum contour level
  res@cnMaxLevelValF  = 130       ; set the maximum contour level
  res@cnLevelSpacingF = 10   
res1@gsnLeftString = "JJA Vert. Velo. & Geo.Pot.Ht Anom (noIceSST-Ice)"
plotI = gsn_csm_pres_hgt(wks,topo_anom_W(0,:,:),res1)
plotJ = gsn_csm_pres_hgt(wks,topo_anom(2,:,:),res)
 overlay(plotI,plotJ)                      
 plot(8) = plotI  


;====
gsn_panel(wks,plot,(/4,3/),False)

delete(res1)
delete(res)
end





































