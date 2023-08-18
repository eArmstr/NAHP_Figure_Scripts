; This makes the validation plots for the Supplementary

begin
; =====================================================================

; Open Files

var_atm = (/"temp_mm_1_5m","precip_mm_srf"/)     
var_ocn = (/"temp_mm_uo"/)    

out=32000 ; file size yr

endY = 800000 ; For the data files   ;!! I have to identify this to order the files properly!
stY = 0 ; For the data files
seqFils = ispan(endY,stY+out,out)

diri = "/home/bridge/ea13310/Finland/Finland_Files/Spline/"

filen = var_atm(0)+"_convec_sims_100yrAvg_ann_1degRes_noBias_Global"
filenj = var_atm(0)+"_convec_sims_100yrAvg_jja_1degRes_noBias_Global"
filep = var_atm(1)+"_convec_sims_100yrAvg_ann_1degRes_CRU_Global"

filenO = var_ocn(0)+"_convec_sims_100yrAvg_ann_1degRes_HadISST_Global"

open_files = systemfunc("ls " + diri + filen+"*")
cdf_file1 = addfile(open_files(0),"r")
lon = cdf_file1 ->lon
lat = cdf_file1 ->lat
time = cdf_file1 ->time
ilon1=dimsizes(lon)
ilat1=dimsizes(lat) 

open_files = systemfunc("ls " + diri + filenO+"*")
cdf_file1 = addfile(open_files(0),"r")
lonO = cdf_file1 ->lon
latO = cdf_file1 ->lat
time = cdf_file1 ->time
ilon1O=dimsizes(lonO)
ilat1O=dimsizes(latO) 

;=================

rad    = 4.0*atan(1.0)/180.0
clat_t=cos(latO*rad)
clat_t!0   ="lat"
clat_t&lat = latO

clat2=cos(lat*rad)
clat2!0   ="lat"
clat2&lat = lat

data_atm := new((/dimsizes(var_atm)+1,(dimsizes(open_files)*dimsizes(time))+1,ilat1,ilon1/),"float")
data_atm!2   ="lat"    ; Set metadata for first array
data_atm!3   = "lon"
data_atm&lat = lat
data_atm&lon = lon
data_atm!1  ="time"
data_atm@_FillValue = -999  

data_ocn := new((/dimsizes(var_ocn),(dimsizes(open_files)*dimsizes(time))+1,ilat1O,ilon1O/),"float")
data_ocn!2   ="lat"    ; Set metadata for first array
data_ocn!3   = "lon"
data_ocn&lat = latO
data_ocn&lon = lonO
data_ocn!1  ="time"
data_ocn@_FillValue = -999  

;=========

do f=0,0 ;, dimsizes(var_atm)-1
 do i=0, dimsizes(open_files)-1
 
  fname1 = diri+filen+"_"+seqFils(i)+"_"
  fname2 = systemfunc("ls " + fname1+ "*")

  print(fname2)

  cdf_file1 = addfile(fname2,"r")
 
if (f.eq.0)
   if (i.eq.dimsizes(open_files)-1)
    data_atm(f,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:) = cdf_file1->temp_mm_1_5m    ;!!! CHANGE VARIABLE NAME HERE
    else 
     data_atm(f,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:) = cdf_file1->temp_mm_1_5m    ;!!! CHANGE VARIABLE NAME HERE
   end if
  if (i.eq.0)
   time_seq = cdf_file1 ->time
    else
     time_seq2 := cdf_file1 ->time
     time_seq := array_append_record(time_seq,time_seq2,0)
    end if
end if

end do 
end do

;============
do f=1,1;  , dimsizes(var_atm)-1
 do i=0, dimsizes(open_files)-1
 
  fname1 = diri+filenj+"_"+seqFils(i)+"_"
  fname2 = systemfunc("ls " + fname1+ "*")

  print(fname2)

  cdf_file1 = addfile(fname2,"r")
 
if (f.eq.1)
   if (i.eq.dimsizes(open_files)-1)
    data_atm(f,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:) = cdf_file1->temp_mm_1_5m    ;!!! CHANGE VARIABLE NAME HERE
    else 
     data_atm(f,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:) = cdf_file1->temp_mm_1_5m    ;!!! CHANGE VARIABLE NAME HERE
   end if
end if

end do 
end do

;============

do f=2,2;  , dimsizes(var_atm)-1
 do i=0, dimsizes(open_files)-1
 
  fname1 = diri+filep+"_"+seqFils(i)+"_"
  fname2 = systemfunc("ls " + fname1+ "*")

  print(fname2)

  cdf_file1 = addfile(fname2,"r")
 
if (f.eq.2)
   if (i.eq.dimsizes(open_files)-1)
    data_atm(f,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:) = cdf_file1->precip_mm_srf    ;!!! CHANGE VARIABLE NAME HERE
    else 
     data_atm(f,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:) = cdf_file1->precip_mm_srf    ;!!! CHANGE VARIABLE NAME HERE
   end if
end if

end do 
end do

;============

do f=0, dimsizes(var_ocn)-1
 do i=0, dimsizes(open_files)-1
 
  fname1 = diri+filenO+"_"+seqFils(i)+"_"
  fname2 = systemfunc("ls " + fname1+ "*")

  print(fname2)

  cdf_file1 = addfile(fname2,"r")
 
  if (f.eq.0)
   if (i.eq.dimsizes(open_files)-1)
    data_ocn(f,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)),:,:) = cdf_file1->temp_mm_uo    ;!!! CHANGE VARIABLE NAME HERE
    else 
     data_ocn(f,i*dimsizes(time):i*dimsizes(time)+(dimsizes(time)-1),:,:) = cdf_file1->temp_mm_uo    ;!!! CHANGE VARIABLE NAME HERE
   end if
  end if

 end do 
end do


;=====================================================================
; For SSTs
;=====================================================================

 print("Extracting SST Validation data")

 ; TO ADD
 ; https://www.nature.com/articles/ngeo2813.pdf
 ; https://pubmed.ncbi.nlm.nih.gov/16223985/
 ; https://www.semanticscholar.org/paper/Surface-water-response-of-the-equatorial-Atlantic-Mcintyre-Ruddiman/58cfe6be305a0647d217f0ef9c100a9ab4efb6a6

  data_ocn := data_ocn(0,:,:,:)

 print("Extracting Annual SST Validation data")
 
   vals = new((/dimsizes(time_seq),31/),"float")
   vals@_FillValue = -999    

  vals(:,0) = wgt_areaave(data_ocn(:,{-46:-44},{-146:-144}),clat_t({-46:-44}),1.0,0)
  ;vals(:,1) = wgt_areaave(data_ocn(:,{41:43},{-11:-9}),clat_t({41:43}),1.0,0)
       vals(:,1) = wgt_areaave(data_ocn(:,{37:43},{-11:-9}),clat_t({37:43}),1.0,0) ; Tihis is an average for whole iberian margin (1,3,4,5,8)
  vals(:,2) = wgt_areaave(data_ocn(:,{40:42},{-34:-32}),clat_t({40:42}),1.0,0)
  vals(:,3) = wgt_areaave(data_ocn(:,{40:42},{-11:-9}),clat_t({40:42}),1.0,0)
  vals(:,4) = wgt_areaave(data_ocn(:,{37:39},{-11:-9}),clat_t({37:39}),1.0,0)
  vals(:,5) = wgt_areaave(data_ocn(:,{37:39},{-11:-9}),clat_t({37:39}),1.0,0)
  vals(:,6) = wgt_areaave(data_ocn(:,{40:42},{-34:-32}),clat_t({40:42}),1.0,0)
  vals(:,7) = wgt_areaave(data_ocn(:,{59:61},{-25:-21}),clat_t({59:61}),1.0,0)
  vals(:,8) = wgt_areaave(data_ocn(:,{37:39},{-11:-9}),clat_t({37:39}),1.0,0)
  vals(:,9) = wgt_areaave(data_ocn(:,{35:37},{-3:-1}),clat_t({35:37}),1.0,0)
  vals(:,10) = wgt_areaave(data_ocn(:,{-30:-28},{-88:-86}),clat_t({-30:-28}),1.0,0)
  vals(:,11) = wgt_areaave(data_ocn(:,{-20:-18},{-21:-19}),clat_t({-20:-18}),1.0,0)
  vals(:,12) = wgt_areaave(data_ocn(:,{19:21},{89:91}),clat_t({19:21}),1.0,0)
  vals(:,13) = wgt_areaave(data_ocn(:,{-7:-5},{10:12}),clat_t({-7:-5}),1.0,0)
  vals(:,14) = wgt_areaave(data_ocn(:,{-40:-38},{142:144}),clat_t({-40:-38}),1.0,0)
  vals(:,15) = wgt_areaave(data_ocn(:,{-40:-36},{136:138}),clat_t({-40:-36}),1.0,0)
  vals(:,16) = wgt_areaave(data_ocn(:,{-47:-45},{96:98}),clat_t({-47:-45}),1.0,0)

  vals(:,17) = wgt_areaave(data_ocn(:,{1:3},{140:142}),clat_t({1:3}),1.0,0)
  vals(:,18) = wgt_areaave(data_ocn(:,{-22:-20},{11:13}),clat_t({-22:-20}),1.0,0)
  vals(:,19) = wgt_areaave(data_ocn(:,{16:18},{60:62}),clat_t({16:18}),1.0,0)
  ;vals(:,20) = wgt_areaave(data_ocn(:,{-4:-2},{-92:-90}),clat_t({-4:-2}),1.0,0)
  vals(:,20) = wgt_areaave(data_ocn(:,{-4:1},{-97:-90}),clat_t({-4:1}),1.0,0) ; This is average for E. Pacific, 20, 25, 28
  vals(:,21) = wgt_areaave(data_ocn(:,{18:20},{115:117}),clat_t({18:20}),1.0,0)
  vals(:,22) = wgt_areaave(data_ocn(:,{57:59},{-17:-15}),clat_t({57:59}),1.0,0)
  vals(:,23) = wgt_areaave(data_ocn(:,{-1:1},{158:160}),clat_t({-1:1}),1.0,0)
  vals(:,24) = wgt_areaave(data_ocn(:,{8:10},{112:114}),clat_t({8:10}),1.0,0)
   vals(:,25) = wgt_areaave(data_ocn(:,{-4:-2},{-92:-90}),clat_t({-4:-2}),1.0,0)
  vals(:,26) = wgt_areaave(data_ocn(:,{40:42},{-34:-32}),clat_t({40:42}),1.0,0)
  vals(:,27) = wgt_areaave(data_ocn(:,{-24:-22},{166:168}),clat_t({-24:-22}),1.0,0)
   vals(:,28) = wgt_areaave(data_ocn(:,{-1:1},{-97:-95}),clat_t({-1:1}),1.0,0)
  vals(:,29) = wgt_areaave(data_ocn(:,{-47:-45},{174:176}),clat_t({-47:-45}),1.0,0)
  vals(:,30) = wgt_areaave(data_ocn(:,{-11:-9},{-14:-12}),clat_t({-11:-9}),1.0,0)

;=====================================================================
; Do SATs
;=====================================================================

 print("Extracting annual SAT validation data")

 ;data_atm := data_atm(0,:,:,:)
 
 valsT := new((/2,dimsizes(time_seq),32/),"float")

  valsT(:,:,0) = wgt_areaave(data_atm(0:1,:,{73:77},{-44:-40}),clat2({73:77}),1.0,0)
  valsT(:,:,1) = wgt_areaave(data_atm(0:1,:,{73:77},{-44:-40}),clat2({73:77}),1.0,0)
  valsT(:,:,2) = wgt_areaave(data_atm(0:1,:,{73:77},{-44:-40}),clat2({73:77}),1.0,0)
  valsT(:,:,3) = wgt_areaave(data_atm(0:1,:,{71:75},{-40:-36}),clat2({71:75}),1.0,0)
  valsT(:,:,4) = wgt_areaave(data_atm(0:1,:,{71:75},{-40:-36}),clat2({71:75}),1.0,0)
  valsT(:,:,5) = wgt_areaave(data_atm(0:1,:,{76:80},{-53:-49}),clat2({76:80}),1.0,0)
  valsT(:,:,6) = wgt_areaave(data_atm(0:1,:,{63:67},{-46:-42}),clat2({63:67}),1.0,0)
  valsT(:,:,7) = wgt_areaave(data_atm(0:1,:,{69:73},{-29:-25}),clat2({69:73}),1.0,0)
  valsT(:,:,8) = wgt_areaave(data_atm(0:1,:,{79:83},{-75:-71}),clat2({79:83}),1.0,0)
  valsT(:,:,9) = wgt_areaave(data_atm(0:1,:,{81:85},{-38:-34}),clat2({81:85}),1.0,0)
  valsT(:,:,10) = wgt_areaave(data_atm(0:1,:,{75:79},{-63:-59}),clat2({75:79}),1.0,0)
  valsT(:,:,11) = wgt_areaave(data_atm(0:1,:,{74:78},{-38:-34}),clat2({74:78}),1.0,0)
  valsT(:,:,12) = wgt_areaave(data_atm(0:1,:,{69:73},{-26:-22}),clat2({69:73}),1.0,0)
  valsT(:,:,13) = wgt_areaave(data_atm(0:1,:,{67:71},{-34:-30}),clat2({67:71}),1.0,0)
  valsT(:,:,14) = wgt_areaave(data_atm(0:1,:,{65:69},{-39:-35}),clat2({65:69}),1.0,0)
  valsT(:,:,15) = wgt_areaave(data_atm(0:1,:,{63:67},{-52:-48}),clat2({63:67}),1.0,0)
  valsT(:,:,16) = wgt_areaave(data_atm(0:1,:,{65:69},{-53:-49}),clat2({65:69}),1.0,0)
  valsT(:,:,17) = wgt_areaave(data_atm(0:1,:,{67:71},{-53:-49}),clat2({67:71}),1.0,0)
  valsT(:,:,18) = wgt_areaave(data_atm(0:1,:,{75:79},{-71:-67}),clat2({75:79}),1.0,0)
  valsT(:,:,19) = wgt_areaave(data_atm(0:1,:,{77:81},{-22:-18}),clat2({77:81}),1.0,0)
  valsT(:,:,20) = wgt_areaave(data_atm(0:1,:,{79:83},{-62:-58}),clat2({79:83}),1.0,0)
  valsT(:,:,21) = wgt_areaave(data_atm(0:1,:,{66:70},{-162:-158}),clat2({66:70}),1.0,0)
  valsT(:,:,22) = wgt_areaave(data_atm(0:1,:,{33:37},{111:115}),clat2({33:37}),1.0,0)
  valsT(:,:,23) = wgt_areaave(data_atm(0:1,:,{39:43},{14:18}),clat2({39:43}),1.0,0)

  valsT(:,:,24) = wgt_areaave(data_atm(0:1,:,{-8:-4},{28:32}),clat2({-8:-4}),1.0,0)
  valsT(:,:,25) = wgt_areaave(data_atm(0:1,:,{39:43},{18:22}),clat2({39:43}),1.0,0)
  valsT(:,:,26) = wgt_areaave(data_atm(0:1,:,{-13:-9},{32:36}),clat2({-13:-9}),1.0,0) 

  valsT(:,:,27) = wgt_areaave(data_atm(0:1,:,{-80:-70},{-10:180}),clat2({-80:-70}),1.0,0)  ; pan Antarctic
  valsT(:,:,28) = wgt_areaave(data_atm(0:1,:,{-77:-73},{121:125}),clat2({-77:-73}),1.0,0)  ; Dome C

  valsT(:,:,29) = wgt_areaave(data_atm(0:1,:,{-15:-9},{33:36}),clat2({-15:-9}),1.0,0)  ; Lake Malawi, m10
  valsT(:,:,30) = wgt_areaave(data_atm(0:1,:,{-27:-20},{26:34}),clat2({-27:-20}),1.0,0) ; Limpopo, m19

;JJA
  valsT(:,:,31) = wgt_areaave(data_atm(0:1,:,{66:70},{170:174}),clat2({66:70}),1.0,0)


;=====================================================================
; Do Precip
;=====================================================================

 print("Extracting annual Precip validation data")

 v1 := data_atm(2,:,:,:)
 valsP := new((/dimsizes(time_seq),45/),"float")

 valsP(:,0) = wgt_areaave(v1(:,{-7:2},{10:20}),clat_t({-7:2}),1.0,0) ; ;m1 ; val0
 valsP(:,1) = wgt_areaave(v1(:,{-7:2},{10:20}),clat_t({-7:2}),1.0,0) ; ;m2 ;val1
 valsP(:,2) = wgt_areaave(v1(:,{-7:2},{10:20}),clat_t({-7:2}),1.0,0) ; ;m3 ;val2
 valsP(:,3) = wgt_areaave(v1(:,{2:8},{35:40}),clat_t({2:8}),1.0,0) ;  ;m4 ;val3
 valsP(:,4) = wgt_areaave(v1(:,{-15:-9},{33:36}),clat_t({-15:-9}),1.0,0) ; ;m5 ;val4
 valsP(:,5) = wgt_areaave(v1(:,{-15:-9},{33:36}),clat_t({-15:-9}),1.0,0) ; ;m6  ;val5
 valsP(:,6) = wgt_areaave(v1(:,{-3:-1},{35:37}),clat_t({-3:-1}),1.0,0) ;  ;m7 ; val6_1, val6_2
 valsP(:,7) = wgt_areaave(v1(:,{-15:-9},{33:36}),clat_t({-15:-9}),1.0,0) ; ;m8  ; val7
 valsP(:,8) = wgt_areaave(v1(:,{-9:-3},{28:32}),clat_t({-9:-3}),1.0,0) ;  ;m9   ; val8 
 valsP(:,9) = wgt_areaave(v1(:,{20:30},{25:35}),clat_t({20:30}),1.0,0) ;  ;m11   ; val9
 valsP(:,10) = wgt_areaave(v1(:,{15:25},{-20:-5}),clat_t({15:25}),1.0,0) ; m12  ; val10 
 valsP(:,11) = wgt_areaave(v1(:,{15:25},{-20:-5}),clat_t({15:25}),1.0,0) ; m13  ; val11
 valsP(:,12) = wgt_areaave(v1(:,{10:18},{-17:-8}),clat_t({10:18}),1.0,0) ; m14  ; val12
 valsP(:,13) = wgt_areaave(v1(:,{8:25},{-20:-10}),clat_t({8:25}),1.0,0) ; m15  ; val13

 valsP(:,14) = wgt_areaave(v1(:,{20:30},{25:35}),clat_t({20:30}),1.0,0) ;    m16_MED
 valsP(:,15) = wgt_areaave(v1(:,{2:6},{34:38}),clat_t({2:6}),1.0,0) ;      m16_CHB.
 valsP(:,16) = wgt_areaave(v1(:,{-2:2},{34:38}),clat_t({-2:2}),1.0,0) ;     m16_MAG
 valsP(:,17) = wgt_areaave(v1(:,{-15:-9},{33:36}),clat_t({-15:-9}),1.0,0) ;   m16_MAL
 valsP(:,18) = wgt_areaave(v1(:,{-27:-20},{26:34}),clat_t({-27:-20}),1.0,0) ;  m16_LOM
 valsP(:,19) = wgt_areaave(v1(:,{15:25},{-20:-5}),clat_t({15:25}),1.0,0) ;  m16_SAH
 valsP(:,20) = wgt_areaave(v1(:,{4:8},{-3:1}),clat_t({4:8}),1.0,0) ;      m16_BOS
 valsP(:,21) = wgt_areaave(v1(:,{-5:5},{15:25}),clat_t({-5:5}),1.0,0) ;     m16_CON
 valsP(:,22) = wgt_areaave(v1(:,{-25:-15},{10:20}),clat_t({-25:-15}),1.0,0) ;  m16_NAM1
 valsP(:,23) = wgt_areaave(v1(:,{-28:-12},{10:20}),clat_t({-28:-12}),1.0,0) ;  m16_NAM2
 valsP(:,24) = wgt_areaave(v1(:,{0:10},{-15:-5}),clat_t({0:10}),1.0,0) ;    m16_LIB

 valsP(:,25) = wgt_areaave(v1(:,{-27:-20},{26:34}),clat_t({-27:-20}),1.0,0) ;  m17
 valsP(:,26) = wgt_areaave(v1(:,{-27:-20},{26:34}),clat_t({-27:-20}),1.0,0) ;  m18
 valsP(:,27) = wgt_areaave(v1(:,{5:10},{-6:4}),clat_t({5:10}),1.0,0) ;   m21      dim_avg_n(v1(:,0,0,{5:15},{-10:5}),(/1,2/))
 valsP(:,28) = wgt_areaave(v1(:,{-5:5},{8:15}),clat_t({-5:5}),1.0,0) ;    m22      dim_avg_n(v1(:,0,0,{-5:5},{5:15}),(/1,2/))
 valsP(:,29) = wgt_areaave(v1(:,{0:10},{-15:-5}),clat_t({0:10}),1.0,0) ;    m23

; NEW ONES ADDED - 22/02/2022 - m24:m29

valsP(:,30) = wgt_areaave(v1(:,{4:8},{0:5}),clat_t({4:8}),1.0,0) ;    m24
valsP(:,31) = wgt_areaave(v1(:,{-24:-22},{12:15}),clat_t({-24:-22}),1.0,0) ;    m25
valsP(:,32) = wgt_areaave(v1(:,{32:34},{-5:-3}),clat_t({32:34}),1.0,0) ;    m26
valsP(:,33) = wgt_areaave(v1(:,{30:35},{8:10}),clat_t({30:35}),1.0,0) ;    m27
valsP(:,34) = wgt_areaave(v1(:,{7:9},{38:40}),clat_t({7:9}),1.0,0) ;    m28
valsP(:,35) = wgt_areaave(v1(:,{22:32},{28:34}),clat_t({22:32}),1.0,0) ;    m29 ; I INCREASED AREA OF THIS

;==== Crocker data

valsP(:,36) = wgt_areaave(v1(:,{15:25},{-20:-5}),clat_t({15:25}),1.0,0) ;  Hopcroft  
valsP(:,37) = wgt_areaave(v1(:,{15:25},{-20:-5}),clat_t({15:25}),1.0,0) ;  Crocker

valsP(:,38) = wgt_areaave(v1(:,{4:8},{-3:1}),clat_t({4:8}),1.0,0) ;     m30 val38 

;==== New data

valsP(:,39) = wgt_areaave(v1(:,{35:40},{-7:0}),clat_t({35:40}),1.0,0) ;  Padul precip  
valsP(:,40) = wgt_areaave(v1(:,{41:48},{18:23}),clat_t({41:48}),1.0,0) ;  Ohrid TIC
valsP(:,41) = wgt_areaave(v1(:,{41:48},{18:23}),clat_t({41:48}),1.0,0) ;  Ohrid Pollen
valsP(:,42) = wgt_areaave(v1(:,{22:32},{28:34}),clat_t({22:32}),1.0,0) ;  Grant 2022 Barium-Al values
valsP(:,43) = wgt_areaave(v1(:,{4:8},{-3:1}),clat_t({4:8}),1.0,0) ;     m31 
valsP(:,44) = wgt_areaave(v1(:,{10:14},{35:40}),clat_t({10:14}),1.0,0) ;     m32 Lake Tana


; =====================================================================
; Read in the obs datasets

print("Reading in the obs datasets")

; =====================================================================
vp5 = time_seq

print("open annual ssts")

val0 = asciiread("/home/bridge/ea13310/Finland/Data/validation/SST/SST_ann_3.txt",(/694,2/),"float")
t0s=ind_nearest_coord(val0(0,0),vp5,0)
t0e=ind_nearest_coord(val0(dimsizes(val0(:,0))-1,0),vp5,0)

val1 = asciiread("/home/bridge/ea13310/Finland/Data/validation/SST/SST_ann_4.txt",(/141,5/),"float")
val1(:,0) = val1(:,0)*1000
val1(:,1) = dim_avg_n((/val1(:,1),val1(:,2),val1(:,3),val1(:,4)/),0)
t1s=ind_nearest_coord(val1(0,0),vp5,0)
t1e=ind_nearest_coord(val1(dimsizes(val1(:,0))-1,0),vp5,0)

val2 = asciiread("/home/bridge/ea13310/Finland/Data/validation/SST/SST_ann_5.txt",(/2999,2/),"float")
val2(:,0) = val2(:,0)*1000
t2s=ind_nearest_coord(val2(0,0),vp5,0)
t2e=ind_nearest_coord(val2(dimsizes(val2(:,0))-1,0),vp5,0)

val3 = asciiread("/home/bridge/ea13310/Finland/Data/validation/SST/SST_ann_6.txt",(/846,2/),"float")
val3(:,0) = val3(:,0)*1000
t3s=ind_nearest_coord(val3(0,0),vp5,0)
t3e=ind_nearest_coord(val3(dimsizes(val3(:,0))-1,0),vp5,0)

val4 = asciiread("/home/bridge/ea13310/Finland/Data/validation/SST/SST_ann_8.txt",(/1538,2/),"float")
val4(:,0) = val4(:,0)*1000
t4s=ind_nearest_coord(val4(0,0),vp5,0)
t4e=ind_nearest_coord(val4(dimsizes(val4(:,0))-1,0),vp5,0)

val5 = asciiread("/home/bridge/ea13310/Finland/Data/validation/SST/SST_ann_9.txt",(/328,5/),"float")
val5(:,0) = val5(:,0)*1000
val5@_FillValue = -999
val5(:,1) = dim_avg_n((/val5(:,1),val5(:,2),val5(:,3),val5(:,4)/),0)
t5s=ind_nearest_coord(val5(0,0),vp5,0)
t5e=ind_nearest_coord(val5(dimsizes(val5(:,0))-1,0),vp5,0)

val6 = asciiread("/home/bridge/ea13310/Finland/Data/validation/SST/SST_ann_10.txt",(/876,2/),"float")
val6(:,0) = val6(:,0)*1000
t6s=ind_nearest_coord(val6(0,0),vp5,0)
t6e=ind_nearest_coord(val6(dimsizes(val6(:,0))-1,0),vp5,0)

val7 = asciiread("/home/bridge/ea13310/Finland/Data/validation/SST/SST_ann_11.txt",(/176,2/),"float")
val7(:,0) = val7(:,0)*1000
t7s=ind_nearest_coord(val7(0,0),vp5,0)
t7e=ind_nearest_coord(val7(dimsizes(val7(:,0))-1,0),vp5,0)

val8 = asciiread("/home/bridge/ea13310/Finland/Data/validation/SST/SST_ann_12.txt",(/1532,2/),"float")
val8(:,0) = val8(:,0)*1000
t8s=ind_nearest_coord(val8(0,0),vp5,0)
t8e=ind_nearest_coord(val8(dimsizes(val8(:,0))-1,0),vp5,0)

val9 = asciiread("/home/bridge/ea13310/Finland/Data/validation/SST/SST_ann_13.txt",(/655,2/),"float")
val9(:,0) = val9(:,0)*1000
t9s=ind_nearest_coord(val9(0,0),vp5,0)
t9e=ind_nearest_coord(val9(dimsizes(val9(:,0))-1,0),vp5,0)

val10 = asciiread("/home/bridge/ea13310/Finland/Data/validation/SST/SST_ann_15.txt",(/2071,2/),"float")
;val10(:,0) = val10(:,0)*1000
val10@_FillValue = -999 

val11 = asciiread("/home/bridge/ea13310/Finland/Data/validation/SST/SST_ann_16.txt",(/124,2/),"float")
;val11(:,0) = val11(:,0)*1000
t11s=ind_nearest_coord(val11(0,0),vp5,0)
t11e=ind_nearest_coord(val11(dimsizes(val11(:,0))-1,0),vp5,0)

val12 = asciiread("/home/bridge/ea13310/Finland/Data/validation/SST/SST_ann_17.txt",(/485,2/),"float")
val12(:,0) = val12(:,0)*1000
t12s=ind_nearest_coord(val12(0,0),vp5,0)
t12e=ind_nearest_coord(val12(dimsizes(val12(:,0))-1,0),vp5,0)

val13 = asciiread("/home/bridge/ea13310/Finland/Data/validation/SST/SST_ann_18.txt",(/144,3/),"float")
val13(:,0) = val13(:,0)*1000
val13@_FillValue = -999
val13(:,1) = dim_avg_n((/val13(:,1),val13(:,2)/),0)
t13s=ind_nearest_coord(val13(0,0),vp5,0)
t13e=ind_nearest_coord(val13(dimsizes(val13(:,0))-1,0),vp5,0)

val14 = asciiread("/home/bridge/ea13310/Finland/Data/validation/SST/SST_ann_19.txt",(/310,2/),"float")
val14(:,0) = val14(:,0)*1000
t14s=ind_nearest_coord(val14(0,0),vp5,0)
t14e=ind_nearest_coord(val14(dimsizes(val14(:,0))-1,0),vp5,0)

val15 = asciiread("/home/bridge/ea13310/Finland/Data/validation/SST/SST_ann_20.txt",(/536,2/),"float")
val15(:,0) = val15(:,0)*1000
t15s=ind_nearest_coord(val15(0,0),vp5,0)
t15e=ind_nearest_coord(val15(dimsizes(val15(:,0))-1,0),vp5,0)

val16 = asciiread("/home/bridge/ea13310/Finland/Data/validation/SST/SST_ann_23.txt",(/211,2/),"float")
val16(:,0) = val16(:,0)*1000
t16s=ind_nearest_coord(val16(0,0),vp5,0)
t16e=ind_nearest_coord(val16(dimsizes(val16(:,0))-1,0),vp5,0)

val17 = asciiread("/home/bridge/ea13310/Finland/Data/validation/SST/SST_ann_24.txt",(/376,15/),"float")
val17(:,0) = val17(:,0)*1000
t17s=ind_nearest_coord(val17(0,0),vp5,0)
t17e=ind_nearest_coord(val17(dimsizes(val17(:,0))-1,0),vp5,0)

;=====================================================================
; OPen the SAT data
;=====================================================================

ngripT0 = asciiread("/home/bridge/ea13310/NHM/data/nGRIP.txt",(/2998,2/),"float")
t0ts=ind_nearest_coord(ngripT0(0,1),vp5,0)
t0te=ind_nearest_coord(ngripT0(dimsizes(ngripT0(:,1))-1,1),vp5,0)

kindler1 = asciiread("/home/bridge/ea13310/NHM/data/kindler_greenland_t.txt",(/5651,2/),"float") ; only 10k to 120k
t1ts=ind_nearest_coord(kindler1(0,0),vp5,0)
t1te=ind_nearest_coord(kindler1(dimsizes(kindler1(:,0))-1,0),vp5,0)

ngripTMass2 = asciiread("/home/bridge/ea13310/NHM/data/gicc05_Ngrip_T2.txt",(/601,2/),"float") 
t2ts=ind_nearest_coord(ngripTMass2(0,0),vp5,0)
t2te=ind_nearest_coord(ngripTMass2(dimsizes(ngripTMass2(:,0))-1,0),vp5,0)

cuffeyclow3 = asciiread("/home/bridge/ea13310/NHM/data/CuffeyClow1997.dat",(/1632,2/),"float")
cuffeyclow3(:,0) = cuffeyclow3(:,0)*1000.0
t3ts=ind_nearest_coord(cuffeyclow3(0,0),vp5,0)
t3te=ind_nearest_coord(cuffeyclow3(dimsizes(cuffeyclow3(:,0))-1,0),vp5,0)

gripT4 = asciiread("/home/bridge/ea13310/NHM/data/GRIP.txt",(/1620,2/),"float")
t4ts=ind_nearest_coord(gripT4(0,1),vp5,0)
t4te=ind_nearest_coord(gripT4(dimsizes(gripT4(:,1))-1,1),vp5,0)

buizert = asciiread("/home/bridge/ea13310/NHM/data/BuizertData.txt",(/1100,18/),"float") 
t5ts=ind_nearest_coord(buizert(0,0),vp5,0)
t5te=ind_nearest_coord(buizert(dimsizes(buizert(:,0))-1,0),vp5,0)

lake21 = asciiread("/home/bridge/ea13310/NHM/data/3.BurialLake.txt",(/86,2/),"float")
t21ts=ind_nearest_coord(lake21(0,1),vp5,0)
t21te=ind_nearest_coord(lake21(dimsizes(lake21(:,1))-1,1),vp5,0)

china22 = asciiread("/home/bridge/ea13310/NHM/data/20.ChineseLoessPlateau.txt",(/58,2/),"float")
t22ts=ind_nearest_coord(china22(0,1),vp5,0)
t22te=ind_nearest_coord(china22(dimsizes(china22(:,1))-1,1),vp5,0)

Mlakes23 = asciiread("/home/bridge/ea13310/NHM/data/LakeData.txt",(/1321,8/),"float") 
MlakeYear = Mlakes23(:,0)*1000.0 
Mlakeavg = dim_avg_n(Mlakes23(:,1:7),1)
t23ts=ind_nearest_coord(MlakeYear(0),vp5,0)
t23te=ind_nearest_coord(MlakeYear(dimsizes(MlakeYear)-1),vp5,0)

val1T = asciiread("/home/bridge/ea13310/Finland/Data/validation/SAT/SAT_ann_1.txt",(/210,2/),"float")
;val1(:,0) = val1(:,0)*1000
t24ts=ind_nearest_coord(val1T(0,0),vp5,0)
t24te=ind_nearest_coord(val1T(dimsizes(val1T(:,0))-1,0),vp5,0)

val2T = asciiread("/home/bridge/ea13310/Finland/Data/validation/SAT/SAT_ann_2.txt",(/784,2/),"float")
val2T(:,0) = val2T(:,0)*1000
t25ts=ind_nearest_coord(val2T(0,0),vp5,0)
t25te=ind_nearest_coord(val2T(dimsizes(val2T(:,0))-1,0),vp5,0)

val3T = asciiread("/home/bridge/ea13310/Finland/Data/validation/SAT/SAT_ann_3.txt",(/407,2/),"float")
;val3(:,0) = val3(:,0)*1000
t26ts=ind_nearest_coord(val3T(0,0),vp5,0)
t26te=ind_nearest_coord(val3T(dimsizes(val3T(:,0))-1,0),vp5,0)


val5T = asciiread("/home/bridge/ea13310/Finland/Data/validation/SAT/SAT_ann_5.txt",(/40000,2/),"float")
val5T(:,0) = val5T(:,0)*1000
val5T(:,1) = val5T(:,1) - 42
t27ts=ind_nearest_coord(val5T(0,0),vp5,0)
t27te=ind_nearest_coord(val5T(dimsizes(val5T(:,0))-1,0),vp5,0)

val6T = asciiread("/home/bridge/ea13310/Finland/Data/validation/SAT/SAT_ann_6.txt",(/5788,2/),"float")
val6T(:,0) = val6T(:,0)*1000
val6T(:,1) = val6T(:,1) - 52
t28ts=ind_nearest_coord(val6T(0,0),vp5,0)
t28te=ind_nearest_coord(val6T(dimsizes(val6T(:,0))-1,0),vp5,0)

val7T = asciiread("/home/bridge/ea13310/Finland/Data/validation/SAT/SAT_ann_m10.txt",(/407,2/),"float")
val7T(:,0) = val7T(:,0)*1000
t29ts=ind_nearest_coord(val7T(0,0),vp5,0)
t29te=ind_nearest_coord(val7T(dimsizes(val7T(:,0))-1,0),vp5,0)

val8T = asciiread("/home/bridge/ea13310/Finland/Data/validation/SAT/SAT_ann_m19.txt",(/181,2/),"float")
val8T(:,0) = val8T(:,0)*1000
t30ts=ind_nearest_coord(val8T(0,0),vp5,0)
t30te=ind_nearest_coord(val8T(dimsizes(val8T(:,0))-1,0),vp5,0)

;===
val0J = asciiread("/home/bridge/ea13310/Finland/Data/validation/SAT/SAT_JJA_4.txt",(/91,2/),"float")
val0J(:,0) = val0J(:,0)*1000
t0tjs=ind_nearest_coord(val0J(0,0),vp5,0)
t0tje=ind_nearest_coord(val0J(dimsizes(val0J(:,0))-1,0),vp5,0)

;=====================================================================
; Do Precip
;=====================================================================
; OPEN THESE IN SEPARATE WINDOW TO SAT AND SST OBSERVATIONS AS LABELS ARE THE SAME

vp5=time_seq

val0 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m1.txt",(/224,2/),"float")
val0(:,0) = val0(:,0)*1000
t0s=ind_nearest_coord(val0(0,0),vp5,0)
t0e=ind_nearest_coord(val0(dimsizes(val0(:,0))-1,0),vp5,0)

val1 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m2.txt",(/122,4/),"float")
val1(:,0) = val1(:,0)*1000
t1s=ind_nearest_coord(val1(0,0),vp5,0)
t1e=ind_nearest_coord(val1(dimsizes(val1(:,0))-1,0),vp5,0)

val2 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m3.txt",(/94,2/),"float")
val2(:,0) = val2(:,0)*1000
t2s=ind_nearest_coord(val2(0,0),vp5,0)
t2e=ind_nearest_coord(val2(dimsizes(val2(:,0))-1,0),vp5,0)

val3 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m4.txt",(/17462,3/),"float")
val3(:,0) = val3(:,0)*1000
t3s=ind_nearest_coord(val3(0,0),vp5,0)
t3e=ind_nearest_coord(val3(dimsizes(val3(:,0))-1,0),vp5,0)

val4 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m5.txt",(/208,2/),"float")
val4(:,0) = val4(:,0)*1000
t4s=ind_nearest_coord(val4(0,0),vp5,0)
t4e=ind_nearest_coord(val4(dimsizes(val4(:,0))-1,0),vp5,0)

val5 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m6.txt",(/407,2/),"float")
val5(:,0) = val5(:,0)*1000
t5s=ind_nearest_coord(val5(0,0),vp5,0)
t5e=ind_nearest_coord(val5(dimsizes(val5(:,0))-1,0),vp5,0)

val5_2 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m6_2.txt",(/208,2/),"float")
t5_2s=ind_nearest_coord(val5_2(0,0),vp5,0)
t5_2e=ind_nearest_coord(val5_2(dimsizes(val5_2(:,0))-1,0),vp5,0)


val6_1 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m7_1.txt",(/285,2/),"float")
val6_1(:,0) = val6_1(:,0)*1000
t6_1s=ind_nearest_coord(val6_1(0,0),vp5,0)
t6_1e=ind_nearest_coord(val6_1(dimsizes(val6_1(:,0))-1,0),vp5,0)

val6_2 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m7_2.txt",(/59,2/),"float")
val6_2(:,0) = val6_2(:,0)*1000
t6_2s=ind_nearest_coord(val6_2(0,0),vp5,0)
t6_2e=ind_nearest_coord(val6_2(dimsizes(val6_2(:,0))-1,0),vp5,0)

val7 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m8.txt",(/427,2/),"float")
val7(:,0) = val7(:,0)*1000
;val7(:,1) = val7(:,1)/365
t7s=ind_nearest_coord(val7(0,0),vp5,0)
t7e=ind_nearest_coord(val7(dimsizes(val7(:,0))-1,0),vp5,0)

val8 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m9.txt",(/49,2/),"float")
val8(:,1) = val8(:,1)/365
t8s=ind_nearest_coord(val8(0,0),vp5,0)
t8e=ind_nearest_coord(val8(dimsizes(val8(:,0))-1,0),vp5,0)

val9 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m11.txt",(/653,2/),"float")
val9(:,0) = val9(:,0)*1000
t9s=ind_nearest_coord(val9(0,0),vp5,0)
t9e=ind_nearest_coord(val9(dimsizes(val9(:,0))-1,0),vp5,0)

val10 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m12.txt",(/158,2/),"float")
val10(:,0) = val10(:,0)*1000
t10s=ind_nearest_coord(val10(0,0),vp5,0)
t10e=ind_nearest_coord(val10(dimsizes(val10(:,0))-1,0),vp5,0)

val11 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m13.txt",(/313,2/),"float")
val11(:,0) = val11(:,0)*1000
t11s=ind_nearest_coord(val11(0,0),vp5,0)
t11e=ind_nearest_coord(val11(dimsizes(val11(:,0))-1,0),vp5,0)

val12 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m14.txt",(/228,3/),"float")
val12(:,0) = val12(:,0)*1000
t12s=ind_nearest_coord(val12(0,0),vp5,0)
t12e=ind_nearest_coord(val12(dimsizes(val12(:,0))-1,0),vp5,0)

val13 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m15.txt",(/1209,2/),"float")
val13(:,0) = val13(:,0)*1000
t13s=ind_nearest_coord(val13(0,0),vp5,0)
t13e=ind_nearest_coord(val13(dimsizes(val13(:,0))-1,0),vp5,0)

val14 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m16_MED.txt",(/606,2/),"float")
val14(:,0) = val14(:,0)*1000
t14s=ind_nearest_coord(val14(0,0),vp5,0)
t14e=ind_nearest_coord(val14(dimsizes(val14(:,0))-1,0),vp5,0)

val15 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m16_CHB.txt",(/606,2/),"float")
val15(:,0) = val15(:,0)*1000
t15s=ind_nearest_coord(val15(0,0),vp5,0)
t15e=ind_nearest_coord(val15(dimsizes(val15(:,0))-1,0),vp5,0)

val16 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m16_MAG.txt",(/606,2/),"float")
val16(:,0) = val16(:,0)*1000
t16s=ind_nearest_coord(val16(0,0),vp5,0)
t16e=ind_nearest_coord(val16(dimsizes(val16(:,0))-1,0),vp5,0)

val17 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m16_MAL.txt",(/606,2/),"float")
val17(:,0) = val17(:,0)*1000
t17s=ind_nearest_coord(val17(0,0),vp5,0)
t17e=ind_nearest_coord(val17(dimsizes(val17(:,0))-1,0),vp5,0)

val18 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m16_LOM.txt",(/606,2/),"float")
val18(:,0) = val18(:,0)*1000
t18s=ind_nearest_coord(val18(0,0),vp5,0)
t18e=ind_nearest_coord(val18(dimsizes(val18(:,0))-1,0),vp5,0)

val19  = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m16_SAH.txt",(/606,2/),"float")
val19(:,0) = val19(:,0)*1000
t19s=ind_nearest_coord(val19(0,0),vp5,0)
t19e=ind_nearest_coord(val19(dimsizes(val19(:,0))-1,0),vp5,0)

val20  = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m16_BOS.txt",(/542,2/),"float")
val20(:,0) = val20(:,0)*1000
t20s=ind_nearest_coord(val20(0,0),vp5,0)
t20e=ind_nearest_coord(val20(dimsizes(val20(:,0))-1,0),vp5,0)

val21 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m16_CON.txt",(/606,2/),"float")
val21(:,0) = val21(:,0)*1000
t21s=ind_nearest_coord(val21(0,0),vp5,0)
t21e=ind_nearest_coord(val21(dimsizes(val21(:,0))-1,0),vp5,0)

val22  = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m16_NAM1.txt",(/402,2/),"float")
val22(:,0) = val22(:,0)*1000
t22s=ind_nearest_coord(val22(0,0),vp5,0)
t22e=ind_nearest_coord(val22(dimsizes(val22(:,0))-1,0),vp5,0)

val23  = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m16_NAM2.txt",(/606,2/),"float")
val23(:,0) = val23(:,0)*1000
t23s=ind_nearest_coord(val23(0,0),vp5,0)
t23e=ind_nearest_coord(val23(dimsizes(val23(:,0))-1,0),vp5,0)

val24 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m16_LIB.txt",(/606,2/),"float")
val24(:,0) = val24(:,0)*1000
t24s=ind_nearest_coord(val24(0,0),vp5,0)
t24e=ind_nearest_coord(val24(dimsizes(val24(:,0))-1,0),vp5,0)

val25 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m17.txt",(/7031,2/),"float")
val25(:,0) = val25(:,0)*1000
t25s=ind_nearest_coord(val25(0,0),vp5,0)
t25e=ind_nearest_coord(val25(dimsizes(val25(:,0))-1,0),vp5,0)

val26 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m18.txt",(/218,2/),"float")
val26(:,0) = val26(:,0)*1000
val26(:,1) = val26(:,1)/365
t26s=ind_nearest_coord(val26(0,0),vp5,0)
t26e=ind_nearest_coord(val26(dimsizes(val26(:,0))-1,0),vp5,0)

val27 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m21.txt",(/542,2/),"float")
val27(:,0) = val27(:,0)*1000
t27s=ind_nearest_coord(val27(0,0),vp5,0)
t27e=ind_nearest_coord(val27(dimsizes(val27(:,0))-1,0),vp5,0)

val28 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m22.txt",(/314,2/),"float")
val28(:,1) = val28(:,1)/365
t28s=ind_nearest_coord(val28(0,0),vp5,0)
t28e=ind_nearest_coord(val28(dimsizes(val28(:,0))-1,0),vp5,0)

val29 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m23.txt",(/76,2/),"float")
val29(:,0) = val29(:,0)*1000
t29s=ind_nearest_coord(val29(0,0),vp5,0)
t29e=ind_nearest_coord(val29(dimsizes(val29(:,0))-1,0),vp5,0)

;==== New ones added 22/02/2022

val30 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m24.txt",(/90,2/),"float")
val30(:,1) = val30(:,1)/365
t30s=ind_nearest_coord(val30(0,0),vp5,0)
t30e=ind_nearest_coord(val30(dimsizes(val30(:,0))-1,0),vp5,0)

val31 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m25.txt",(/68,2/),"float")
val31(:,0) = val31(:,0)*1000
t31s=ind_nearest_coord(val31(0,0),vp5,0)
t31e=ind_nearest_coord(val31(dimsizes(val31(:,0))-1,0),vp5,0)

val32 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m26.txt",(/185,2/),"float")
val32(:,1) = val32(:,1)/365
t32s=ind_nearest_coord(val32(0,0),vp5,0)
t32e=ind_nearest_coord(val32(dimsizes(val32(:,0))-1,0),vp5,0)

val33 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m27.txt",(/106,2/),"float")
val33(:,1) = val33(:,1)/365
t33s=ind_nearest_coord(val33(0,0),vp5,0)
t33e=ind_nearest_coord(val33(dimsizes(val33(:,0))-1,0),vp5,0)

val34 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m28.txt",(/185,2/),"float")
val34(:,1) = val34(:,1)/365
t34s=ind_nearest_coord(val34(0,0),vp5,0)
t34e=ind_nearest_coord(val34(dimsizes(val34(:,0))-1,0),vp5,0)

val35 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m29.txt",(/5993,2/),"float")
val35(:,0) = val35(:,0)*1000
t35s=ind_nearest_coord(val35(0,0),vp5,0)
t35e=ind_nearest_coord(val35(dimsizes(val35(:,0))-1,0),vp5,0)

;==== Hopcroft added 23/05/2022

val36 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/hopcroft_dust.txt",(/580,3/),"float")
val36(:,0) = val36(:,0)*1000000
t36s=ind_nearest_coord(val36(0,0),vp5,0)
t36e=ind_nearest_coord(val36(dimsizes(val36(:,0))-1,0),vp5,0)

val37 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/ZrRb_Anya_Crocker.txt",(/574,2/),"float")
val37(:,0) = val37(:,0)*1000000
t37s=ind_nearest_coord(val37(0,0),vp5,0)
t37e=ind_nearest_coord(val37(dimsizes(val37(:,0))-1,0),vp5,0)

;==== New added 28/02/2023 ; Lake Bosum ( vals(:,20))

val38 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m30.txt",(/122,2/),"float")
t38s=ind_nearest_coord(val38(0,0),vp5,0)
t38e=ind_nearest_coord(val38(dimsizes(val38(:,0))-1,0),vp5,0)


;==== New added 28/02/2023 ; Padul, Ohrid, Grant22

val39 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/padul_precip.txt",(/427,4/),"float") ; Arranged with 2col=MAP, 3col=MWP, 4col=MSP
val39(:,0) = val39(:,0)*1000
val39(:,1) = val39(:,1)/365
t39s=ind_nearest_coord(val39(0,0),vp5,0)
t39e=ind_nearest_coord(val39(dimsizes(val39(:,0))-1,0),vp5,0)

val40 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/ohrid_TIC.txt",(/2794,2/),"float") 
val40(:,0) = val40(:,0)*1000
t40s=ind_nearest_coord(val40(0,0),vp5,0)
t40e=ind_nearest_coord(val40(dimsizes(val40(:,0))-1,0),vp5,0)

val41 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/ohrid_pollen.txt",(/687,3/),"float") 
val41(:,0) = val41(:,0)*1000
t41s=ind_nearest_coord(val41(0,0),vp5,0)
t41e=ind_nearest_coord(val41(dimsizes(val41(:,0))-1,0),vp5,0)

val42 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/grant22.txt",(/2715,2/),"float") 
val42(:,0) = val42(:,0)*1000
t42s=ind_nearest_coord(val42(0,0),vp5,0)
t42e=ind_nearest_coord(val42(dimsizes(val42(:,0))-1,0),vp5,0)


val43 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m31.txt",(/215,3/),"float") 
t43s=ind_nearest_coord(val43(0,0),vp5,0)
t43e=ind_nearest_coord(val43(dimsizes(val43(:,0))-1,0),vp5,0)


val44 = asciiread("/home/bridge/ea13310/Finland/Data/validation/PPT/Precip_ann_m32.txt",(/5341,2/),"float") 
t44s=ind_nearest_coord(val44(0,0),vp5,0)
t44e=ind_nearest_coord(val44(dimsizes(val44(:,0))-1,0),vp5,0)




;==============

 ;plot(10)=gsn_csm_x2y2(wks,vp5,val7(:,0),datas(7,:),val7(:,1),res1,res2)  
 ;plot(11)=gsn_csm_x2y2(wks,vp5,val8(:,0),datas(8,:),val8(:,1),res1,res2)  
 ;plot(13)=gsn_csm_x2y2(wks,vp5,val10(:,0),datas(10,:),val10(:,1),res1,res2)  
 ;plot(14)=gsn_csm_x2y2(wks,vp5,val11(:,0),datas(11,:),val11(:,1),res1,res2)  
 ;plot(17)=gsn_csm_x2y2(wks,vp5,val13(:,0),datas(13,:),val13(:,1),res1,res2)  
 ;plot(23)=gsn_csm_x2y2(wks,vp5,val19(:,0),datas(19,:),val19(:,1),res1,res2)
 ;plot(30)=gsn_csm_x2y2(wks,vp5,val26(:,0),datas(26,:),val26(:,1),res1,res2)
 ;plot(32)=gsn_csm_x2y2(wks,vp5,val28(:,0),datas(28,:),val28(:,1),res1,res2)
 ;plot(34)=gsn_csm_x2y2(wks,vp5,val30(:,0),datas(30,:),val30(:,1),res1,res2)
 ;plot(35)=gsn_csm_x2y2(wks,vp5,val31(:,0),datas(31,:),val31(:,1),res1,res2)

 ;plot(0)=gsn_csm_xy(wks,vp5,val6_1(:,0),datas(6,:),val6_1(:,1),res1)  
 ;plot(3)=gsn_csm_xy(wks,vp5,val34(:,0),datas(34,:),val34(:,1),res2)  ; East AFrica (North)
 ;plot(2)=gsn_csm_xy(wks,vp5,val35(:,0),datas(35,:),val35(:,1),res1)  ;N.E. Africa - Nile River Basin
 ;plot(0)=gsn_csm_xy(wks,vp5,val32(:,0),datas(32,:),val32(:,1),res1)  ;North Africa 
 ;plot(1)=gsn_csm_xy(wks,vp5,val33(:,0),datas(33,:),val33(:,1),res2)  ;North Africa


;========================================================================================================================
;========================================================================================================================

; NOW MAKE MARKERS FOR THE MAPS

;SATs

;To include : 1,3,4,6,10,24,25,29,30,27,28,31

lats = (/75,73,73,65,77,-6,41,-12,-24,-75,-75,68/)
lons = (/-42,-38,-38,-44,-61,30,20,25,30,90,123,172/)

;valsT(:,:,1) = wgt_areaave(data_atm(0:1,:,{73:77},{-44:-40}),clat2({73:77}),1.0,0)
;valsT(:,:,3) = wgt_areaave(data_atm(0:1,:,{71:75},{-40:-36}),clat2({71:75}),1.0,0)
;valsT(:,:,4) = wgt_areaave(data_atm(0:1,:,{71:75},{-40:-36}),clat2({71:75}),1.0,0)
;valsT(:,:,6) = wgt_areaave(data_atm(0:1,:,{63:67},{-46:-42}),clat2({63:67}),1.0,0)
;valsT(:,:,10) = wgt_areaave(data_atm(0:1,:,{75:79},{-63:-59}),clat2({75:79}),1.0,0)
;valsT(:,:,24) = wgt_areaave(data_atm(0:1,:,{-8:-4},{28:32}),clat2({-8:-4}),1.0,0)
;valsT(:,:,25) = wgt_areaave(data_atm(0:1,:,{39:43},{18:22}),clat2({39:43}),1.0,0)
;valsT(:,:,29) = wgt_areaave(data_atm(0:1,:,{-15:-9},{33:36}),clat2({-15:-9}),1.0,0)  ; Lake Malawi, m10
;valsT(:,:,30) = wgt_areaave(data_atm(0:1,:,{-27:-20},{26:34}),clat2({-27:-20}),1.0,0) ; Limpopo, m19
;valsT(:,:,27) = wgt_areaave(data_atm(0:1,:,{-80:-70},{-10:180}),clat2({-80:-70}),1.0,0)  ; pan Antarctic
;valsT(:,:,28) = wgt_areaave(data_atm(0:1,:,{-77:-73},{121:125}),clat2({-77:-73}),1.0,0)  ; Dome C
;valsT(:,:,31) = wgt_areaave(data_atm(0:1,:,{66:70},{170:174}),clat2({66:70}),1.0,0)

;SSTs

; To include : 1,9,2,7,26,13,18,30,19,12,16,24,21,15,17,23,27,29,0,20

latS = (/40,36,41,60,41,-6,-21,-10,17,20,-46,9,19,-38,2,0,-23,-46,-45,-1/)
lonS = (/-10,-2,-33,-23,-33,11,12,-13,61,90,97,113,116,137,141,159,167,175,-145,-94/)

;vals(:,1) = wgt_areaave(data_ocn(:,{37:43},{-11:-9}),clat_t({37:43}),1.0,0) 
;vals(:,9) = wgt_areaave(data_ocn(:,{35:37},{-3:-1}),clat_t({35:37}),1.0,0)
;vals(:,2) = wgt_areaave(data_ocn(:,{40:42},{-34:-32}),clat_t({40:42}),1.0,0)
;vals(:,7) = wgt_areaave(data_ocn(:,{59:61},{-25:-21}),clat_t({59:61}),1.0,0)
;vals(:,26) = wgt_areaave(data_ocn(:,{40:42},{-34:-32}),clat_t({40:42}),1.0,0)
;vals(:,13) = wgt_areaave(data_ocn(:,{-7:-5},{10:12}),clat_t({-7:-5}),1.0,0)
;vals(:,18) = wgt_areaave(data_ocn(:,{-22:-20},{11:13}),clat_t({-22:-20}),1.0,0)
;vals(:,30) = wgt_areaave(data_ocn(:,{-11:-9},{-14:-12}),clat_t({-11:-9}),1.0,0)
;vals(:,19) = wgt_areaave(data_ocn(:,{16:18},{60:62}),clat_t({16:18}),1.0,0)
;vals(:,12) = wgt_areaave(data_ocn(:,{19:21},{89:91}),clat_t({19:21}),1.0,0)
;vals(:,16) = wgt_areaave(data_ocn(:,{-47:-45},{96:98}),clat_t({-47:-45}),1.0,0)
;vals(:,24) = wgt_areaave(data_ocn(:,{8:10},{112:114}),clat_t({8:10}),1.0,0)
;vals(:,21) = wgt_areaave(data_ocn(:,{18:20},{115:117}),clat_t({18:20}),1.0,0)
;vals(:,15) = wgt_areaave(data_ocn(:,{-40:-36},{136:138}),clat_t({-40:-36}),1.0,0)
;vals(:,17) = wgt_areaave(data_ocn(:,{1:3},{140:142}),clat_t({1:3}),1.0,0)
;vals(:,23) = wgt_areaave(data_ocn(:,{-1:1},{158:160}),clat_t({-1:1}),1.0,0)
;vals(:,27) = wgt_areaave(data_ocn(:,{-24:-22},{166:168}),clat_t({-24:-22}),1.0,0)
;vals(:,29) = wgt_areaave(data_ocn(:,{-47:-45},{174:176}),clat_t({-47:-45}),1.0,0)
;vals(:,0) = wgt_areaave(data_ocn(:,{-46:-44},{-146:-144}),clat_t({-46:-44}),1.0,0)
;vals(:,20) = wgt_areaave(data_ocn(:,{-4:1},{-97:-90}),clat_t({-4:1}),1.0,0) 

;Precip

;Tp include : 7,8,11,26,28,30,31,6,33,34,35

;latP := (/20,-24,0,67,-2,32,12/)
;lonP := (/-12,30,12, 172,36,34,37/)

latP := (/-2,-12,-2,20,4,0,-23,7,5,-23,45,27,12/)
lonP := (/15,35,36,-12,36,36,30,-1,-10,14,20,31,37/)

7 valsP(:,0) = wgt_areaave(v1(:,{-7:2},{10:20}),clat_t({-7:2}),1.0,0) ; ;m1 ; val0
8 valsP(:,1) = wgt_areaave(v1(:,{-7:2},{10:20}),clat_t({-7:2}),1.0,0) ; ;m2 ;val1
9 valsP(:,2) = wgt_areaave(v1(:,{-7:2},{10:20}),clat_t({-7:2}),1.0,0) ; ;m3 ;val2
15 valsP(:,5) = wgt_areaave(v1(:,{-15:-9},{33:36}),clat_t({-15:-9}),1.0,0) ; ;m6  ;val5
12 valsP(:,6) = wgt_areaave(v1(:,{-3:-1},{35:37}),clat_t({-3:-1}),1.0,0) ;  ;m7 ; val6_1, val6_2
3 valsP(:,10) = wgt_areaave(v1(:,{15:25},{-20:-5}),clat_t({15:25}),1.0,0) ; m12  ; val10 
4 valsP(:,11) = wgt_areaave(v1(:,{15:25},{-20:-5}),clat_t({15:25}),1.0,0) ; m13  ; val11
10 valsP(:,15) = wgt_areaave(v1(:,{2:6},{34:38}),clat_t({2:6}),1.0,0) ;      m16_CHB.
11 valsP(:,16) = wgt_areaave(v1(:,{-2:2},{34:38}),clat_t({-2:2}),1.0,0) ;     m16_MAG
14 valsP(:,25) = wgt_areaave(v1(:,{-27:-20},{26:34}),clat_t({-27:-20}),1.0,0) ;  m17
6 valsP(:,27) = wgt_areaave(v1(:,{5:10},{-6:4}),clat_t({5:10}),1.0,0) ;   m21      5:15N,-10:5E"
5 valsP(:,29) = wgt_areaave(v1(:,{0:10},{-15:-5}),clat_t({0:10}),1.0,0) ;    m23
13 valsP(:,31) = wgt_areaave(v1(:,{-24:-22},{12:15}),clat_t({-24:-22}),1.0,0) ;    m25
1 valsP(:,41) = wgt_areaave(v1(:,{41:48},{18:23}),clat_t({41:48}),1.0,0) ;  Ohrid Pollen
2 valsP(:,42) = wgt_areaave(v1(:,{22:32},{28:34}),clat_t({22:32}),1.0,0) ;  Grant 2022 Barium-Al values

valsP(:,44) = wgt_areaave(v1(:,{10:14},{35:40}),clat_t({10:14}),1.0,0) ;



========================================================================================================================
;========================================================================================================================

print("Plotting Validation plot")

dataS :=transpose(vals)
dataS@_FillValue = -999

datas :=transpose(valsT)
datas@_FillValue = -999

; NEED TO RUN IN SEPARATE SCRIPT TO SAT DATA AS VARIABLE NAMES THE SAME

datas =transpose(valsP)
datas@_FillValue = -999

;========================================================================================================================
begin 

plot=new(13,graphic)

res1=True
res2=True

wtype   = "pdf"

wks =  gsn_open_wks(wtype, "/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/all_validation_SATs")

res1@gsnDraw = False
res1@gsnFrame = False

res2@gsnDraw = False
res2@gsnFrame = False

;res1@gsnLeftString      = vp2@long_name
res1@tiYAxisString     = ""
res1@tiXAxisString     = ""

res1@vpHeightF = 0.25 
res1@vpWidthF = 0.55
res2@vpHeightF = 0.25 
res2@vpWidthF = 0.55

;res1@gsnMaximize      = True 
;res1@gsnPaperOrientation      = "landscape" 

;res1@xyLineColors      = (/"black","grey","green3","blue","red3","mediumorchid4","darkorange1","hotpink1","mediumpurple3","seagreen3"/)
;res1@xyDashPatterns     = (/0,0,0,0,0,0,0,0,0,0/)   

;===
 res=True
 res@gsnDraw          = False             ; so we can add poly stuff
 res@gsnFrame         = False
res@vpHeightF = 0.27 
res@vpWidthF = 0.57

   polyres                   = True
   polyres@gsMarkerIndex     = 10          ; polymarker style
   polyres@gsMarkerSizeF     = 6.          ; polymarker size
   polyres@gsMarkerColor     = "firebrick2"


;================;================;================;================;================
; PLots the SATs
;================;================;================;================;================
  
  res@gsnLeftString= "a) SAT Timeseries Locations" 
plot(0) = gsn_csm_map(wks,res)        ; draw global map
dum1    = gsn_add_polymarker(wks,plot(0),lons,lats,polyres)


;---- 

 res1@trYMaxF = max((/max(kindler1(:,1)),max(datas(1,:,0))/))
 res1@trYMinF =  min((/min(kindler1(:,1)),min(datas(1,:,0))/))
 res1@gsnRightString= "75N, -42E," 
 
 res1@xyLineColor = "Black"
 res1@gsnLeftString= "b) NGRIP ice core"; (Kindler et al.) 
 plot(1)=gsn_csm_xy(wks,vp5(t1ts:t1te),datas(1,t1ts:t1te,0),res1)
 
 res1@xyLineColor = "firebrick2"
 plot_data = gsn_csm_xy(wks,kindler1(:,0),kindler1(:,1),res1)
 overlay(plot(1),plot_data)

;---- 

 res1@trYMaxF = max((/max(cuffeyclow3(:,1)),max(datas(3,:,0))/))  
 res1@trYMinF =  min((/min(cuffeyclow3(:,1)),min(datas(3,:,0))/))
 res1@gsnRightString= "73N, -38E," 
 
 res1@xyLineColor = "Black"
 res1@gsnLeftString= "c) GISP ice core" ;(Cuffeyclow)
 plot(2)=gsn_csm_xy(wks,vp5(t3ts:t3te),datas(3,t3ts:t3te,0),res1)
 
 res1@xyLineColor = "firebrick2"
 plot_data = gsn_csm_xy(wks,cuffeyclow3(:,0),cuffeyclow3(:,1),res1)
 overlay(plot(2),plot_data)

;----  

res1@tiYAxisString     = "degC"


 res1@trYMaxF = max((/max(gripT4(:,0)),max(datas(4,:,0))/))
 res1@trYMinF =  min((/min(gripT4(:,0)),min(datas(4,:,0))/))
 res1@gsnRightString= "73N, -38E,"

 res1@xyLineColor = "Black"
 res1@gsnLeftString= "d) GRIP ice core" 
 plot(3)=gsn_csm_xy(wks,vp5(t4ts:t4te),datas(4,t4ts:t4te,0),res1) 
 
 res1@xyLineColor = "firebrick2"
 plot_data= gsn_csm_xy(wks,gripT4(:,1),gripT4(:,0),res1)
 overlay(plot(3),plot_data)
  
;----; BUIZERT

res1@tiYAxisString     = ""

 res1@trYMaxF = max((/max(buizert(:,2)),max(datas(6,:,0))/))  
 res1@trYMinF =  min((/min(buizert(:,2)),min(datas(6,:,0))/)) 
 res1@gsnRightString= "65N, -44E,"

 res1@xyLineColor = "Black"
 res1@gsnLeftString= "e) Dye-3 ice core"
 plot(4)=gsn_csm_xy(wks,vp5(t5ts:t5te),datas(6,t5ts:t5te,0),res1)
 
 res1@xyLineColor = "firebrick2"
 plot_data = gsn_csm_xy(wks,buizert(:,0),buizert(:,2),res1)
 overlay(plot(4),plot_data)
  
 ;---- 
 res1@trYMaxF = max((/max(buizert(:,6)),max(datas(10,:,0))/))  
 res1@trYMinF =  min((/min(buizert(:,6)),min(datas(10,:,0))/)) 
 res1@gsnRightString= "77N, -61E,"

 res1@xyLineColor = "Black"
 res1@gsnLeftString= "f) Camp century ice core"
 plot(5)=gsn_csm_xy(wks,vp5(t5ts:t5te),datas(10,t5ts:t5te,0),res1)
 
 res1@xyLineColor = "firebrick2"
 plot_data = gsn_csm_xy(wks,buizert(:,0),buizert(:,6),res1)
 overlay(plot(5),plot_data)
 
 ;----  Now outside Greenland

;---- ------------

res1@tiYAxisString     = "degC"

 res1@trYMaxF = max((/max(val1T(:,1)),max(datas(24,:,1))/))  
 res1@trYMinF =  min((/min(val1T(:,1)),min(datas(24,:,1))/)) 
 res1@gsnRightString= "-6N:30E"

 res1@xyLineColor = "Black"
 res1@gsnLeftString= "g) Lake Tanganyika JJA " ;: Peterse et al. (2011)
 plot(6)=gsn_csm_xy(wks,vp5(t24ts:t24te),datas(24,t24ts:t24te,1),res1)
 
 res1@xyLineColor = "firebrick2"
 plot_data = gsn_csm_xy(wks,val1T(:,0),val1T(:,1),res1)
 overlay(plot(6),plot_data)

 ;----

 res1@tiYAxisString     = ""


 res1@trYMaxF = max((/max(val2T(:,1)),max(datas(25,:,1))/))  
 res1@trYMinF =  min((/min(val2T(:,1)),min(datas(25,:,1))/)) 
 res1@gsnRightString= "41N:20E"

 res1@xyLineColor = "Black"
 res1@gsnLeftString= "h) Lake Ohrid JJA (modelled)" ;: Peterse et al. (2011)
 plot(7)=gsn_csm_xy(wks,vp5(t25ts:t25te),datas(25,t25ts:t25te,1),res1)
 
 res1@xyLineColor = "firebrick2"
 plot_data = gsn_csm_xy(wks,val2T(:,0),val2T(:,1),res1)
 overlay(plot(7),plot_data)

 ;----

 res1@trYMaxF = max((/max(val7T(:,1)),max(datas(29,:,0))/))  
 res1@trYMinF =  min((/min(val7T(:,1)),min(datas(29,:,0))/)) 
 res1@gsnRightString= "-15:-9N,33:36E"

 res1@xyLineColor = "Black"
 res1@gsnLeftString= "i) Lake Malawi" ;
 plot(8)=gsn_csm_xy(wks,vp5(t29ts:t29te),datas(29,t29ts:t29te,0),res1)
 
 res1@xyLineColor = "firebrick2"
 plot_data = gsn_csm_xy(wks,val7T(:,0),val7T(:,1),res1)
 overlay(plot(8),plot_data)

;----

res1@tiYAxisString     = "degC"
res1@tiXAxisString     = "Year BP"

 res1@trYMaxF = max((/max(val8T(:,1)),max(datas(30,:,0))/))  
 res1@trYMinF =  min((/min(val8T(:,1)),min(datas(30,:,0))/)) 
 res1@gsnRightString= "-27:-20N,26:34E"

 res1@xyLineColor = "Black"
 res1@gsnLeftString= "j) Limpopo Basin" ;
 plot(9)=gsn_csm_xy(wks,vp5(t30ts:t30te),datas(30,t30ts:t30te,0),res1)
 
 res1@xyLineColor = "firebrick2"
 plot_data = gsn_csm_xy(wks,val8T(:,0),val8T(:,1),res1)
 overlay(plot(9),plot_data)

 ;----
res1@tiYAxisString     = ""
res1@tiXAxisString     = ""

 res1@trYMaxF = max((/max(val5T(:,1)),max(datas(27,:,0))/))  
 res1@trYMinF =  min((/min(val5T(:,1)),min(datas(27,:,0))/)) 
 res1@gsnRightString= "-80:-70N,-10:180E"

 res1@xyLineColor = "Black"
 res1@gsnLeftString= "k) Pan-Antarctica (composite 5 cores) " ;: Peterse et al. (2011)
 plot(10)=gsn_csm_xy(wks,vp5(t27ts:t27te),datas(27,t27ts:t27te,0),res1)
 
 res1@xyLineColor = "firebrick2"
 plot_data = gsn_csm_xy(wks,val5T(:,0),val5T(:,1),res1)
 overlay(plot(10),plot_data)

 ;----
res1@tiXAxisString     = "Year BP"
 res1@trYMaxF = max((/max(val6T(:,1)),max(datas(28,:,0))/))  
 res1@trYMinF =  min((/min(val6T(:,1)),min(datas(28,:,0))/)) 
 res1@gsnRightString= "-77:-73N,121:125E"

 res1@xyLineColor = "Black"
 res1@gsnLeftString= "l) EPICA Dome-C" ;: Peterse et al. (2011)
 plot(11)=gsn_csm_xy(wks,vp5(t28ts:t28te),datas(28,t28ts:t28te,0),res1)
 
 res1@xyLineColor = "firebrick2"
 plot_data = gsn_csm_xy(wks,val6T(:,0),val6T(:,1),res1)
 overlay(plot(11),plot_data)


;==== JJA

res1@tiYAxisString     = "degC"
 res1@trYMaxF = max((/max(val0J(:,1)),max(datas(31,:,1))/))  
 res1@trYMinF =  min((/min(val0J(:,1)),min(datas(31,:,1))/)) 
 res1@gsnRightString= "66:70N,170:174E"

 res1@xyLineColor = "Black"
 res1@gsnLeftString= "m) Lake Elgygytgyn JJA" ;: Peterse et al. (2011)
 plot(12)=gsn_csm_xy(wks,vp5(t0tjs:t0tje),datas(31,t0tjs:t0tje,1),res1)
 
 res1@xyLineColor = "firebrick2"
 plot_data = gsn_csm_xy(wks,val0J(:,0),val0J(:,1),res1)
 overlay(plot(12),plot_data)

;================;================;================


res_mult=True
res_mult@gsnPanelXWhiteSpacePercent=2.0
res_mult@gsnPanelYWhiteSpacePercent=3
;res_mult@gsnMaximize=True
  res_mult@gsnPanelLeft               = 0.1
  res_mult@gsnPanelRight              = 0.9
;res_mult@gsnPaperOrientation="landscape"
gsn_panel(wks,plot,(/5,3/),res_mult)

delete(plot)
delete(res1)
delete(res2)
delete(res)
delete(res_mult)
end






;================;================;================;================;================;================
begin 

plot=new(21,graphic)

res1=True
res2=True

wtype   = "pdf"

wks =  gsn_open_wks(wtype, "/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/all_validation_SSTs")

res1@gsnDraw = False
res1@gsnFrame = False

res2@gsnDraw = False
res2@gsnFrame = False

;res1@gsnLeftString      = vp2@long_name
res1@tiYAxisString     = ""
res1@tiXAxisString     = ""

res1@vpHeightF = 0.25 
res1@vpWidthF = 0.55
res2@vpHeightF = 0.25 
res2@vpWidthF = 0.55

;===
 res=True
 res@gsnDraw          = False             ; so we can add poly stuff
 res@gsnFrame         = False
res@vpHeightF = 0.27 
res@vpWidthF = 0.57

   polyres                   = True
   polyres@gsMarkerIndex     = 11          ; polymarker style
   polyres@gsMarkerSizeF     = 6.          ; polymarker size
   polyres@gsMarkerColor     = "dodgerblue2"


;================;================;================;================;================
  
 res@gsnLeftString= "a) SST Timeseries Locations" 
plot(0) = gsn_csm_map(wks,res)        ; draw global map
dum1    = gsn_add_polymarker(wks,plot(0),lonS,latS,polyres)

;======

 res1@trYMaxF = 20  
 res1@trYMinF =  5 
 res1@gsnRightString= "37N:43N:-11:-9E" 
 res1@gsnLeftString= "b) Off Portugal (Stack)"
 
 res1@xyLineColor = "Black"
 plot(1)=gsn_csm_xy(wks,vp5(ind_nearest_coord(0,vp5,0):ind_nearest_coord(500000,vp5,0)),dataS(1,ind_nearest_coord(0,vp5,0):ind_nearest_coord(500000,vp5,0)),res1)
 
 res1@xyLineColor = "dodgerblue2"
 res1@gsnRightString= "" 
 res1@gsnLeftString= ""
 plot_data = gsn_csm_xy(wks,val1(:,0),val1(:,1),res1)
 overlay(plot(1),plot_data)

 ;res1@xyLineColor = "dodgerblue2"
 ;plot_data = gsn_csm_xy(wks,val3(:,0),val3(:,1),res1)
 ;overlay(plot(12),plot_data)

 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val4(:,0),val4(:,1),res1)
 overlay(plot(1),plot_data)

 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val5(:,0),val5(:,1),res1)
 overlay(plot(1),plot_data)

 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val8(:,0),val8(:,1),res1)
 overlay(plot(1),plot_data)

  res1@xyLineColor = "Black"
 plot_data = gsn_csm_xy(wks,vp5(ind_nearest_coord(0,vp5,0):ind_nearest_coord(500000,vp5,0)),dataS(1,ind_nearest_coord(0,vp5,0):ind_nearest_coord(500000,vp5,0)),res1)
 overlay(plot(1),plot_data)

;======== 10
 res1@trYMaxF := max((/max(val9(:,1)),max(dataS(9,:))/))  
 res1@trYMinF :=  min((/min(val9(:,1)),min(dataS(9,:))/)) 
 res1@gsnRightString= "36N:-2E" 
 res1@gsnLeftString= "c) Med. off S. Spain"
 
 res1@xyLineColor = "Black"
 plot(2)=gsn_csm_xy(wks,vp5(t9s:t9e),dataS(9,t9s:t9e),res1)
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val9(:,0),val9(:,1),res1)
 overlay(plot(2),plot_data)


;======== 3,7,
res1@tiYAxisString     = "degC"

 res1@trYMaxF = max((/max(val2(:,1)),max(dataS(2,:))/))  
 res1@trYMinF =  min((/min(val2(:,1)),min(dataS(2,:))/)) 
 res1@gsnRightString= "41N:-33E" 
 res1@gsnLeftString= "d) Cent. N. Atlantic (Stack)"
 
 res1@xyLineColor = "Black"
 plot(3)=gsn_csm_xy(wks,vp5(t2s:t2e),dataS(2,t2s:t2e),res1)
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val2(:,0),val2(:,1),res1)
 overlay(plot(3),plot_data)

 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val6(:,0),val6(:,1),res1)
 overlay(plot(3),plot_data)


;======== 8
res1@tiYAxisString     = ""

res1@trYMaxF = max((/max(val7(:,1)),max(dataS(7,:))/))  
 res1@trYMinF =  min((/min(val7(:,1)),min(dataS(7,:))/)) 
 res1@gsnRightString= "60N:-24E" 
 res1@gsnLeftString= "e) N. Atlantic (S. Iceland)"
 
 res1@xyLineColor = "Black"
 plot(4)=gsn_csm_xy(wks,vp5(t7s:t7e),dataS(7,t7s:t7e),res1)
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val7(:,0),val7(:,1),res1)
 overlay(plot(4),plot_data)

 ;======== 2J
 res1@trYMaxF = max((/max(val17(:,10)),max(dataS(26,:))/))  
 res1@trYMinF =  min((/min(val17(:,10)),min(dataS(26,:))/)) 
 res1@gsnRightString= "39:43N,-35:-31E" 
 res1@gsnLeftString= "f) Northeast Atlantic"
 
 res1@xyLineColor = "Black"
 plot(5)=gsn_csm_xy(wks,vp5(t17s:t17e),dataS(26,t17s:t17e),res1)
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,10),res1)
 overlay(plot(5),plot_data)

;======== 14
res1@tiYAxisString     = "degC"

 res1@trYMaxF = max((/max(val13(:,1)),max(dataS(13,:))/))  
 res1@trYMinF =  min((/min(val13(:,1)),min(dataS(13,:))/)) 
 res1@gsnRightString= "-6N:11E" 
 res1@gsnLeftString= "g) Off Angola"
 
 res1@xyLineColor = "Black"
 plot(6)=gsn_csm_xy(wks,vp5(t13s:t13e),dataS(13,t13s:t13e),res1)
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val13(:,0),val13(:,1),res1)
 overlay(plot(6),plot_data)

 ;======== 12
 res1@tiYAxisString     = ""

 res1@trYMaxF = max((/max(val17(:,2)),max(dataS(18,:))/))  
 res1@trYMinF =  min((/min(val17(:,2)),min(dataS(18,:))/)) 
 res1@gsnRightString= "-23:-19N,10:14E" 
 res1@gsnLeftString= "h) South Atlantic"
 
 res1@xyLineColor = "Black"
 plot(7)=gsn_csm_xy(wks,vp5(t17s:t17e),dataS(18,t17s:t17e),res1)
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,2),res1)
 overlay(plot(7),plot_data)

 ;======== 31
 res1@trYMaxF = max((/max(val17(:,14)),max(dataS(30,:))/))  
 res1@trYMinF =  min((/min(val17(:,14)),min(dataS(30,:))/)) 
 res1@gsnRightString= "-12:-8N,-15:-11E" 
 res1@gsnLeftString= "i) South Atlantic"
 
 res1@xyLineColor = "Black"
 plot(8)=gsn_csm_xy(wks,vp5(t17s:t17e),dataS(30,t17s:t17e),res1)
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,14),res1)
 overlay(plot(8),plot_data)
 
 ;======== 20
 res1@tiYAxisString     = "degC"
 res1@trYMaxF = max((/max(val17(:,3)),max(dataS(19,:))/))  
 res1@trYMinF =  min((/min(val17(:,3)),min(dataS(19,:))/)) 
 res1@gsnRightString= "15:19N, 59:63E" 
 res1@gsnLeftString= "j) Arabian Sea"
 
 res1@xyLineColor = "Black"
 plot(9)=gsn_csm_xy(wks,vp5(t17s:t17e),dataS(19,t17s:t17e),res1)
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,3),res1)
 overlay(plot(9),plot_data)

 ;======== 13
 res1@tiYAxisString     = ""
 res1@trYMaxF = max((/max(val12(:,1)),max(dataS(12,:))/))  
 res1@trYMinF =  min((/min(val12(:,1)),min(dataS(12,:))/)) 
 res1@gsnRightString= "20N:90E" 
 res1@gsnLeftString= "k) Bay of Bengal"
 
 res1@xyLineColor = "Black"
 plot(10)=gsn_csm_xy(wks,vp5(t12s:t12e),dataS(12,t12s:t12e),res1)
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val12(:,0),val12(:,1),res1)
 overlay(plot(10),plot_data)

;======== 17
 res1@trYMaxF = max((/max(val16(:,1)),max(dataS(16,:))/))  
 res1@trYMinF =  min((/min(val16(:,1)),min(dataS(16,:))/)) 
 res1@gsnRightString= "-46N:97E" 
 res1@gsnLeftString= "l) Cent. S. Indian Oc"
 
 res1@xyLineColor = "Black"
 plot(11)=gsn_csm_xy(wks,vp5(t16s:t16e),dataS(16,t16s:t16e),res1)
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val16(:,0),val16(:,1),res1)
 overlay(plot(11),plot_data)

;======== 25
 res1@tiYAxisString     = "degC"
 res1@trYMaxF = max((/max(val17(:,8)),max(dataS(24,:))/))  
 res1@trYMinF =  min((/min(val17(:,8)),min(dataS(24,:))/)) 
 res1@gsnRightString= "7:11N,111:115E" 
 res1@gsnLeftString= "m) S. South China Sea"
 
 res1@xyLineColor = "Black"
 plot(12)=gsn_csm_xy(wks,vp5(t17s:t17e),dataS(24,t17s:t17e),res1)
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,8),res1)
 overlay(plot(12),plot_data)


;======== 22
 res1@tiYAxisString     = ""
 res1@trYMaxF = max((/max(val17(:,5)),max(dataS(21,:))/))  
 res1@trYMinF =  min((/min(val17(:,5)),min(dataS(21,:))/)) 
 res1@gsnRightString= "17:21N,114:118E" 
 res1@gsnLeftString= "n) N. South China Sea"
 
 res1@xyLineColor = "Black"
 plot(13)=gsn_csm_xy(wks,vp5(t17s:t17e),dataS(21,t17s:t17e),res1)
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,5),res1)
 overlay(plot(13),plot_data)

;======== 16
 res1@trYMaxF = max((/max(val15(:,1)),max(dataS(15,:))/))  
 res1@trYMinF =  min((/min(val15(:,1)),min(dataS(15,:))/)) 
 res1@gsnRightString= "-37N:137E" 
 res1@gsnLeftString= "o) Off S. Aus"
 
 res1@xyLineColor = "Black"
 plot(14)=gsn_csm_xy(wks,vp5(t15s:t15e),dataS(15,t15s:t15e),res1)
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val15(:,0),val15(:,1),res1)
 overlay(plot(14),plot_data)

;========;======== 18
 res1@tiYAxisString     = "degC"
 res1@trYMaxF = max((/max(val17(:,1)),max(dataS(17,:))/))  
 res1@trYMinF =  min((/min(val17(:,1)),min(dataS(17,:))/)) 
 res1@gsnRightString= "0:4N,139:143E" 
 res1@gsnLeftString= "p) Western Pacific Warm Pool"
 
 res1@xyLineColor = "Black"
 plot(15)=gsn_csm_xy(wks,vp5(t17s:t17e),dataS(17,t17s:t17e),res1)
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,1),res1)
 overlay(plot(15),plot_data)

;======== 24
 res1@tiYAxisString     = ""
 res1@trYMaxF = max((/max(val17(:,7)),max(dataS(23,:))/))  
 res1@trYMinF =  min((/min(val17(:,7)),min(dataS(23,:))/)) 
 res1@gsnRightString= "-2:2N,157:161E" 
 res1@gsnLeftString= "q) Western Equatorial Pacific"
 
 res1@xyLineColor = "Black"
 plot(16)=gsn_csm_xy(wks,vp5(t17s:t17e),dataS(23,t17s:t17e),res1)
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,7),res1)
 overlay(plot(16),plot_data)


 ;======== 28
 res1@trYMaxF = max((/max(val17(:,11)),max(dataS(27,:))/))  
 res1@trYMinF =  min((/min(val17(:,11)),min(dataS(27,:))/)) 
 res1@gsnRightString= "-25:-21N,165:169E" 
 res1@gsnLeftString= "r) Tropical Western Pacific"
 
 res1@xyLineColor = "Black"
 plot(17)=gsn_csm_xy(wks,vp5(t17s:t17e),dataS(27,t17s:t17e),res1)
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,11),res1)
 overlay(plot(17),plot_data)


 ;======== 30
 res1@tiYAxisString     = "degC"
 res1@tiXAxisString     = "Year BP"

 res1@trYMaxF = max((/max(val17(:,13)),max(dataS(29,:))/))  
 res1@trYMinF =  min((/min(val17(:,13)),min(dataS(29,:))/)) 
 res1@gsnRightString= "-48:-44N,173:177E" 
 res1@gsnLeftString= "s) Southwest Pacific"
 
 res1@xyLineColor = "Black"
 plot(18)=gsn_csm_xy(wks,vp5(t17s:t17e),dataS(29,t17s:t17e),res1)
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,13),res1)
 overlay(plot(18),plot_data)

 ;====== 1
 res1@tiYAxisString     = ""

 res1@trYMaxF = max((/max(val0(:,1)),max(dataS(0,:))/))  
 res1@trYMinF =  min((/min(val0(:,1)),min(dataS(0,:))/)) 
 res1@gsnRightString= "-45N:-145E" 
 res1@gsnLeftString= "t) Cent. S. Pacific"
 
 res1@xyLineColor = "Black"
 plot(19)=gsn_csm_xy(wks,vp5(t0s:t0e),dataS(0,t0s:t0e),res1)

 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val0(:,0),val0(:,1),res1)
 overlay(plot(19),plot_data)

 ;======== 29+21+26
 res1@trYMaxF = max((/max(val17(:,4)),max(dataS(20,:))/))  
 res1@trYMinF =  min((/min(val17(:,4)),min(dataS(20,:))/)) 
 res1@gsnRightString= "-5:1N,-97:-90E" 
 res1@gsnLeftString= "u) Eastern Equatorial Pacific (Stack)"
 
 res1@xyLineColor = "Black"
 plot(20)=gsn_csm_xy(wks,vp5(t17s:t17e),dataS(20,t17s:t17e),res1)
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,4),res1)
 overlay(plot(20),plot_data)

 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,9),res1)
 overlay(plot(20),plot_data)

 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,12),res1)
 overlay(plot(20),plot_data)

;=============================================================================

res_mult=True
res_mult@gsnPanelXWhiteSpacePercent=2.0
res_mult@gsnPanelYWhiteSpacePercent=3
;res_mult@gsnMaximize=True
  res_mult@gsnPanelLeft               = 0.1
  res_mult@gsnPanelRight              = 0.9
;res_mult@gsnPaperOrientation="landscape"
gsn_panel(wks,plot,(/7,3/),res_mult)

delete(plot)
delete(res1)
delete(res2)
delete(res)
delete(res_mult)
end








;================;================;================;================;================;================


begin 

plot=new(17,graphic)

res1=True
res2=True

wtype   = "pdf"

wks =  gsn_open_wks(wtype, "/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/all_validation_Precip_New2.pdf")

res1@gsnDraw = False
res1@gsnFrame = False

res2@gsnDraw = False
res2@gsnFrame = False

;res1@gsnLeftString      = vp2@long_name
res1@tiYAxisString     = ""
res1@tiXAxisString     = ""

res1@vpHeightF = 0.25 
res1@vpWidthF = 0.55
res2@vpHeightF = 0.25 
res2@vpWidthF = 0.55


 res2@tmXTOn = False
 res2@tmXTBorderOn = False

;===
 res=True
 res@gsnDraw          = False             ; so we can add poly stuff
 res@gsnFrame         = False
res@vpHeightF = 0.27 
res@vpWidthF = 0.57

   polyres                   = True
   polyres@gsMarkerIndex     = 13          ; polymarker style
   polyres@gsMarkerSizeF     = 6.          ; polymarker size
   polyres@gsMarkerColor     = "violetred3"

res1@gsnStringFontHeightF = 0.021
res@gsnStringFontHeightF = 0.021
;================;================;==
  
  res@gsnLeftString= "a) Precip Timeseries Locations" 
plot(0) = gsn_csm_map(wks,res)        ; draw global map
dum1    = gsn_add_polymarker(wks,plot(0),lonP,latP,polyres)


;======

 res1@xyLineColor = "Black"
 res2@xyLineColors = (/"violetred3","Blue","Blue"/)
 res2@xyDashPatterns     = (/0,0,0/) 

 res1@xyLineThicknessF = 0.75
 res2@xyLineThicknessF = 0.75

 res1@trXMaxF = vp5(t0e)
 res1@trXMinF = vp5(t0s)
 res2@trXMaxF = res1@trXMaxF
 res2@trXMinF = res1@trXMinF

 ;res1@trYMaxF = max(datas(0,:))*1.5
 ;res2@trYMinF = min(val0(:,1)) - (0.5*min(val0(:,1)))

 res1@gsnRightString= "-7N:2N, 10:20E"
 res1@gsnLeftString= "j) Congo | Al/K" 
 res2@tiYAxisString     = ""
 plot(9)=gsn_csm_x2y2(wks,vp5,val0(:,0),datas(0,:),val0(:,1),res1,res2) 
 
;========
 
 res1@trXMaxF = vp5(t1e)
 res1@trXMinF = vp5(t1s)
 res2@trXMaxF = res1@trXMaxF
 res2@trXMinF = res1@trXMinF
;res2@trYMinF = min(val1(:,3)) - (0.5*min(val1(:,3)))
 res1@gsnRightString= "-7N:2N, 10:20E"
 res1@gsnLeftString= "k) Congo | Smectite" 
 res2@tiYAxisString     = ""
 plot(10)=gsn_csm_x2y2(wks,vp5,val1(:,0),datas(1,:),val1(:,3),res1,res2) 


;========

; res1@trXMaxF = vp5(t2e)
; res1@trXMinF = vp5(t2s)
; res2@trXMaxF = res1@trXMaxF
; res2@trXMinF = res1@trXMinF
; ;res1@trYMaxF = max(datas(2,:))*1.5
; ;res2@trYMinF = min(val2(:,1)) - (0.5*min(val2(:,1)))

; res1@gsnRightString= "-7N:2N, 10:20E"
; res1@gsnLeftString= "e) Congo | Total Pollen" 
; res2@tiYAxisString     = ""
; plot(10)=gsn_csm_x2y2(wks,vp5,val2(:,0),datas(2,:),val2(:,1),res1,res2) 

;========

 res1@trXMaxF = vp5(t5e)
 res1@trXMinF = vp5(t5s)
 res2@trXMaxF = res1@trXMaxF
 res2@trXMinF = res1@trXMinF
 res2@trYMaxF = 50
 res2@trYMinF = -800
 res1@gsnRightString= "-15:-9N, 33:36E"
 res1@gsnLeftString= "o) Lk Malawi | Lk Level(m)" 
 res2@tiYAxisString     = ""
 plot(14)=gsn_csm_x2y2(wks,vp5,val5(:,0),datas(5,:),val5(:,1),res1,res2)
delete([/res1@trYMaxF, res1@trYMinF, res2@trYMaxF, res2@trYMinF/])
 ;========

 res1@trXMaxF = vp5(t6_1e)
 res1@trXMinF = vp5(t6_1s)
 res2@trXMaxF = res1@trXMaxF
 res2@trXMinF = res1@trXMinF
 ;res1@trYMaxF = max(datas(6,:))*1.5
 ;res2@trYMinF = min(val6_1(:,1)) - (0.5*min(val6_1(:,1)))
 res1@gsnRightString= "-3:-1N, 35:37E"
 res1@gsnLeftString= "n) Koora | d13C Leaf Wax" 
 res2@tiYAxisString     = ""
 res2@trYReverse = True    ; reverse the Y-axis

 ;val6_1(:,1) = runave(val6_1(:,1),5,0)
 plot(13)=gsn_csm_x2y2(wks,vp5,val6_1(:,0),datas(6,:),val6_1(:,1),res1,res2)  

 ;========

 res1@trXMaxF = vp5(t10e)
 res1@trXMinF = vp5(t10s)
 res2@trXMaxF = res1@trXMaxF
 res2@trXMinF = res1@trXMinF
 ;res1@trYMaxF = max(datas(10,:))*1.5
 ;res2@trYMinF = min(val10(:,1)) - (0.5*min(val10(:,1)))
 res2@trYReverse = True    ; reverse the Y-axis
 res1@gsnRightString= "15:25N, -20:-5E"
 res1@gsnLeftString= "d) W. Sahara | Dust Flux" 
 res2@tiYAxisString     = ""

 plot(3)=gsn_csm_x2y2(wks,vp5,val10(:,0),datas(10,:),val10(:,1),res1,res2)  

 ;========

 res1@trXMaxF = vp5(t11e)
 res1@trXMinF = vp5(t11s)
 res2@trXMaxF = res1@trXMaxF
 res2@trXMinF = res1@trXMinF
 res2@trYReverse = False    ; reverse the Y-axis
 ;res1@trYMaxF = max(datas(11,:))*1.5
 ;res2@trYMinF = min(val11(:,1)) - (0.5*min(val11(:,1)))
 res1@gsnRightString= "15:25N, -20:-5E"
 res1@gsnLeftString= "e) W. Sah | Humidity Indx" 
 res2@tiYAxisString     = ""

 plot(4)=gsn_csm_x2y2(wks,vp5,val11(:,0),datas(11,:),val11(:,1),res1,res2)  


 ;========

 res1@trXMaxF = vp5(t15e)
 res1@trXMinF = vp5(t15s)
 res2@trXMaxF = res1@trXMaxF
 res2@trXMinF = res1@trXMinF
 ;res1@trYMaxF = max(datas(15,:))*1.5
 ;res2@trYMinF = min(val15(:,1))*1.5
 res1@gsnRightString= "2:6N, 34:38E"
 res1@gsnLeftString= "l) Chew Bahir | log(K/Zr)" 
 res2@tiYAxisString     = ""

 plot(11)=gsn_csm_x2y2(wks,vp5,val15(:,0),datas(15,:),val15(:,1),res1,res2)

 ;========

 res1@trXMaxF = vp5(t16e)
 res1@trXMinF = vp5(t16s)
 res2@trXMaxF = res1@trXMaxF
 res2@trXMinF = res1@trXMinF
 ;res1@trYMaxF = max(datas(16,:))*1.5
 ;res2@trYMinF = min(val16(:,1))*1.5
 res1@gsnRightString= "-2:2N, 34:38E"
 res1@gsnLeftString= "m) Lk Magadi | Pollen PCA1" 
 res2@tiYAxisString     = ""

 plot(12)=gsn_csm_x2y2(wks,vp5,val16(:,0),datas(16,:),val16(:,1),res1,res2)


 ;========

 res1@trXMaxF = vp5(t25e)
 res1@trXMinF = vp5(t25s)
 res2@trXMaxF = res1@trXMaxF
 res2@trXMinF = res1@trXMinF
 ;   res1@trYMaxF = max(datas(25,:))*1.5
 ;res2@trYMinF = min(val25(:,1))*1.5
 res2@trYReverse = False    ; reverse the Y-axis
 res1@gsnRightString= "-27:-20N, 26:34E"
 res1@gsnLeftString= "q) Limpopo | Fe/Ca" 
 res2@tiYAxisString     = ""

;val25(:,1) = runave(val25(:,1),10,0)
 plot(16)=gsn_csm_x2y2(wks,vp5,val25(:,0),datas(25,:),val25(:,1),res1,res2)

;========

 res1@trXMaxF = vp5(t27e)
 res1@trXMinF = vp5(t27s)
 res2@trXMaxF = res1@trXMaxF
 res2@trXMinF = res1@trXMinF
;  res1@trYMaxF = max(datas(27,:))*1.5
; res2@trYMinF = min(val27(:,1))*1.5
 res1@gsnRightString= "5:10N,-6:4E"
 res1@gsnLeftString= "g) Lk Bosomtwe | Tree Extent" 
 res2@tiYAxisString     = ""

 plot(6)=gsn_csm_x2y2(wks,vp5,val27(:,0),datas(27,:),val27(:,1),res1,res2)

delete([/res1@trYMaxF, res1@trYMinF, res2@trYMaxF, res2@trYMinF/])
;========

 res1@trXMaxF = vp5(t29e)
 res1@trXMinF = vp5(t29s)
 res2@trXMaxF = res1@trXMaxF
 res2@trXMinF = res1@trXMinF
 res2@trYMaxF = 1.2
 res2@trYMinF = 0.4
 res1@gsnRightString= "0:10N,-15:-5E"
 res1@gsnLeftString= "f) Liberia | Pollen ppm" 
 res2@tiYAxisString     = ""

 plot(5)=gsn_csm_x2y2(wks,vp5,val29(:,0),datas(29,:),val29(:,1),res1,res2)
delete([/res1@trYMaxF, res1@trYMinF, res2@trYMaxF, res2@trYMinF/])


;================

 res1@trXMaxF = vp5(t31e)
 res1@trXMinF = vp5(t31s)
 res2@trXMaxF = res1@trXMaxF
 res2@trXMinF = res1@trXMinF
 res1@gsnRightString= "-24:-22N, 12:15E"
 res1@gsnLeftString= "p) Namibia | Deuterium" 
 res2@tiYAxisString     = ""
 res2@trYReverse = True

 plot(15)=gsn_csm_x2y2(wks,vp5,val31(:,0),datas(31,:),val31(:,1),res1,res2)


;================

 res1@trXMaxF = vp5(t38e)
 res1@trXMinF = vp5(t38s)
 res2@trXMaxF = res1@trXMaxF
 res2@trXMinF = res1@trXMinF
 res1@gsnRightString= "5:10N,-6:4E"
 res1@gsnLeftString= "h) Lk Bosomtwe | Pollen %" 
 res2@tiYAxisString     = ""

 ;res1@trYMaxF = max((/max(val37(:,1)),max(datas(37,:))/)) 
 ;res1@trYMinF = min((/min(val37(:,1)),min(datas(37,:))/)) 
 ;res2@trYMaxF = res1@trYMaxF
 ;res2@trYMinF = res1@trYMinF
 res2@trYReverse = False

 plot(7)=gsn_csm_x2y2(wks,vp5,val43(:,0),datas(27,:),val43(:,2),res1,res2)

delete([/res1@trYMaxF, res1@trYMinF, res2@trYMaxF, res2@trYMinF/])


;================

 res1@trXMaxF = vp5(t41e)
 res1@trXMinF = vp5(t41s)
 res2@trXMaxF = res1@trXMaxF
 res2@trXMinF = res1@trXMinF
 res1@gsnRightString= "41:48N,18:23E"
 res1@gsnLeftString= "b) Lk Ohrid | Quercus %" 
 res2@tiYAxisString     = ""
 res2@trYReverse = False

 plot(1)=gsn_csm_x2y2(wks,vp5,val41(:,0),datas(41,:),val41(:,2),res1,res2)

delete([/res1@trYMaxF, res1@trYMinF, res2@trYMaxF, res2@trYMinF/])

;================

 res1@trXMaxF = vp5(t42e)
 res1@trXMinF = vp5(t42s)
 res2@trXMaxF = res1@trXMaxF
 res2@trXMinF = res1@trXMinF
 res1@gsnRightString= "22:32N,28:34E"
 res1@gsnLeftString= "c) Nile Basin | Ba/Al" 
 res2@tiYAxisString     = ""
 res2@trYReverse = False

 plot(2)=gsn_csm_x2y2(wks,vp5,val42(:,0),datas(42,:),val42(:,1),res1,res2)

delete([/res1@trYMaxF, res1@trYMinF, res2@trYMaxF, res2@trYMinF/])


;================

 res1@trXMaxF = vp5(t44e)
 res1@trXMinF = vp5(t44s)
 res2@trXMaxF = res1@trXMaxF
 res2@trXMinF = res1@trXMinF
 res1@gsnRightString= "10:14N,35:40E"
 res1@gsnLeftString= "i) Lk Tana | Ca/Ti" 
 res2@tiYAxisString     = ""
 res2@trYMaxF = 15
 res2@trYMinF = -3
 res2@trYReverse = True

 plot(8)=gsn_csm_x2y2(wks,vp5,val44(:,0),datas(44,:),val44(:,1),res1,res2)

delete([/res1@trYMaxF, res1@trYMinF, res2@trYMaxF, res2@trYMinF/])




res_mult=True
res_mult@gsnPanelXWhiteSpacePercent=9.0
res_mult@gsnPanelYWhiteSpacePercent=3
;res_mult@gsnMaximize=True
  res_mult@gsnPanelLeft               = 0.1
  res_mult@gsnPanelRight              = 0.9
;res_mult@gsnPaperOrientation="landscape"
gsn_panel(wks,plot,(/6,3/),res_mult)

delete(plot)
delete(res1)
delete(res2)
delete(res)
delete(res_mult)
end





;==============




; THIS IS THE OLD VALIATIOPN PLOT

begin 

plot=new(7,graphic)

res1=True
res2=True

wtype   = "pdf"

wks =  gsn_open_wks(wtype, "/home/bridge/ea13310/Finland/Plots/Convec_Manuscript/all_validation_Precip")

res1@gsnDraw = False
res1@gsnFrame = False

res2@gsnDraw = False
res2@gsnFrame = False

;res1@gsnLeftString      = vp2@long_name
res1@tiYAxisString     = ""
res1@tiXAxisString     = ""

res1@vpHeightF = 0.25 
res1@vpWidthF = 0.55
res2@vpHeightF = 0.25 
res2@vpWidthF = 0.55


 res2@tmXTOn = False
 res2@tmXTBorderOn = False

;===
 res=True
 res@gsnDraw          = False             ; so we can add poly stuff
 res@gsnFrame         = False
res@vpHeightF = 0.27 
res@vpWidthF = 0.57

   polyres                   = True
   polyres@gsMarkerIndex     = 13          ; polymarker style
   polyres@gsMarkerSizeF     = 6.          ; polymarker size
   polyres@gsMarkerColor     = "seagreen3"

;================;================;==
  
  res@gsnLeftString= "a) Precip Timeseries Locations" 
plot(0) = gsn_csm_map(wks,res)        ; draw global map
dum1    = gsn_add_polymarker(wks,plot(0),lonP,latP,polyres)


;===


 ;========

res1@tiYAxisString     = "mm/day"
 res1@trXMaxF = vp5(tP11e)
 res1@trXMinF = vp5(tP11s)
 res2@trXMaxF = res1@trXMaxF
 res2@trXMinF = res1@trXMinF

 res1@xyLineColor = "black"
 res2@xyLineColor = "seagreen3"
 ;res1@trYMaxF = max(valsP(11,:))*1.5
 ;res2@trYMinF = min(valP11(:,1)) - (0.5*min(valP11(:,1)))
 res1@gsnRightString= "15:25N, -20:-5E"
 res1@gsnLeftString= "b) W. Sahara" 
 res2@tiYAxisString     = "Humidity Index"

 res1@trYMaxF = max((/max(valP11(:,1)),max(valsP(11,:))/)) 
 res1@trYMinF = min((/min(valP11(:,1)),min(valsP(11,:))/)) 
 res2@trYMaxF = res1@trYMaxF
 res2@trYMinF = res1@trYMinF



 plot(1)=gsn_csm_x2y2(wks,vp5,valP11(:,0),valsP(11,:),valP11(:,1),res1,res2)  

delete([/res1@trYMaxF, res1@trYMinF, res2@trYMaxF, res2@trYMinF/])
 ;========

res1@tiYAxisString     = "mm/day"
 ;delete([/res1@trYMaxF, res2@trYMinF/])
 res1@trXMaxF = vp5(tP26e)
 res1@trXMinF = vp5(tP26s)
 res2@trXMaxF = res1@trXMaxF
 res2@trXMinF = res1@trXMinF

 res1@xyLineColor = "black"
 res2@xyLineColor = "seagreen3"
 res1@gsnRightString= "-27:-20N, 26:34E"
 res1@gsnLeftString= "c) Limpopo catchment" 
 res2@tiYAxisString     = "mm/day"

 res1@trYMaxF = max((/max(valP26(:,1)),max(valsP(26,:))/)) 
 res1@trYMinF = min((/min(valP26(:,1)),min(valsP(26,:))/)) 
 res2@trYMaxF = res1@trYMaxF
 res2@trYMinF = res1@trYMinF

 plot(2)=gsn_csm_x2y2(wks,vp5,valP26(:,0),valsP(26,:),valP26(:,1),res1,res2)

delete([/res2@trYMaxF, res2@trYMinF/])
 

;========

 ;delete([/res1@trYMaxF, res2@trYMinF/])
 res1@trXMaxF = vp5(tP28e)
 res1@trXMinF = vp5(tP28s)
 res2@trXMaxF = res1@trXMaxF
 res2@trXMinF = res1@trXMinF
 res1@xyLineColor = "black"
 res2@xyLineColor = "seagreen3"
 res1@gsnRightString= "-5:5N, 5:15E"
 res1@gsnLeftString= "d) Bambii region" 
 res2@tiYAxisString     = "mm day-1"

 res1@trYMaxF = max((/max(valP28(:,1)),max(valsP(28,:))/)) 
 res1@trYMinF = min((/min(valP28(:,1)),min(valsP(28,:))/)) 
 res2@trYMaxF = res1@trYMaxF
 res2@trYMinF = res1@trYMinF

 plot(3)=gsn_csm_x2y2(wks,vp5,valP28(:,0),valsP(28,:),valP28(:,1),res1,res2)

delete([/res1@trYMaxF, res1@trYMinF, res2@trYMaxF, res2@trYMinF/])


;================
res1@tiYAxisString     = ""
 res1@trXMaxF = vp5(tP31e)
 res1@trXMinF = vp5(tP31s)
 res2@trXMaxF = res1@trXMaxF
 res2@trXMinF = res1@trXMinF
 res1@xyLineColor = "black"
 res2@xyLineColor = "seagreen3"
 res1@gsnRightString= "66:68N, 171:173E"
 res1@gsnLeftString= "e) Lake Elgygytgyn, Russia" 
 res2@tiYAxisString     = "mm day-1"

 res1@trYMaxF = max((/max(valP31(:,1)),max(valsP(31,:))/)) 
 res1@trYMinF = min((/min(valP31(:,1)),min(valsP(31,:))/)) 
 res2@trYMaxF = res1@trYMaxF
 res2@trYMinF = res1@trYMinF

 plot(4)=gsn_csm_x2y2(wks,vp5,valP31(:,0),valsP(31,:),valP31(:,1),res1,res2)

delete([/res1@trYMaxF, res1@trYMinF, res2@trYMaxF, res2@trYMinF/])


;================

 res1@trXMaxF = vp5(tP6_1e)
 res1@trXMinF = vp5(tP6_1s)
 res2@trXMaxF = res1@trXMaxF
 res2@trXMinF = res1@trXMinF
 res1@xyLineColor = "black"
 res2@xyLineColor = "seagreen3"
 res1@gsnRightString= "-3:-1N, 35:37E"
 res1@gsnLeftString= "f) Koora Basin" 
 res2@tiYAxisString     = "d13C Leaf Wax"

 res1@trYMaxF = max(valsP(6,:))
 res1@trYMinF = min(valsP(6,:))

 res2@trYMaxF = max(valP6_1(:,1))
 res2@trYMinF = min(valP6_1(:,1))

 plot(5)=gsn_csm_x2y2(wks,vp5,valP6_1(:,0),valsP(6,:),valP6_1(:,1),res1,res2)

delete([/res1@trYMaxF, res1@trYMinF, res2@trYMaxF, res2@trYMinF/])


;================
res1@tiYAxisString     = "mm/day"
 res1@trXMaxF = vp5(tP35e)
 res1@trXMinF = vp5(tP35s)
 res2@trXMaxF = res1@trXMaxF
 res2@trXMinF = res1@trXMinF
 res1@xyLineColor = "black"
 res2@xyLineColor = "seagreen3"
 res1@gsnRightString= "30:34N, 32:36E"
 res1@gsnLeftString= "g) N.E. Africa - Nile River Basin" 
 res2@tiYAxisString     = "Humidity Index"

 res1@trYMaxF = max(valsP(35,:))
 res1@trYMinF = min(valsP(35,:))
 ;res2@trYMaxF = max(valP35(:,1))
 ;res2@trYMinF = min(valP35(:,1))

; res2@trYReverse = True

 plot(6)=gsn_csm_x2y2(wks,vp5,valP35(:,0),valsP(35,:),valP35(:,1),res1,res2)

delete([/res1@trYMaxF, res1@trYMinF, res2@trYMaxF, res2@trYMinF/])




res_mult=True
res_mult@gsnPanelXWhiteSpacePercent=9.0
res_mult@gsnPanelYWhiteSpacePercent=3
;res_mult@gsnMaximize=True
  res_mult@gsnPanelLeft               = 0.1
  res_mult@gsnPanelRight              = 0.9
;res_mult@gsnPaperOrientation="landscape"
gsn_panel(wks,plot,(/3,3/),res_mult)

delete(plot)
delete(res1)
delete(res2)
delete(res)
delete(res_mult)
end












;================;================;================;================;================
; PLots the SATs
;================;================;================;================;================
  

 plot_data = gsn_csm_xy(wks,kindler1(:,0),kindler1(:,1),res1)
 overlay(plot(1),plot_data)
 Kindler P, et al. Temperature reconstruction from 10 to 120 kyr b2k from the NGRIP ice core. Clim Past. 2014;10:887–902. doi: 10.5194/cp-10-887-2014. [CrossRef] [Google Scholar]

 plot_data = gsn_csm_xy(wks,cuffeyclow3(:,0),cuffeyclow3(:,1),res1)
 overlay(plot(2),plot_data)
  Cuffey KM, Clow GD. Temperature, accumulation, and ice sheet elevation in central Greenland through the last deglacial transition. J Geophys Res-Oceans. 1997;102:26383–26396. doi: 10.1016/S0277-3791(99)00062-110.1029/96jc03981. [CrossRef] [Google Scholar]

 plot_data= gsn_csm_xy(wks,gripT4(:,1),gripT4(:,0),res1)
 overlay(plot(3),plot_data)
  Rasmussen, S. O. et al. A new Greenland ice core chronology for the last glacial termination. J Geophys Res-Atmos111, 10.1029/2005jd006079 (2006).
  
 plot_data = gsn_csm_xy(wks,buizert(:,0),buizert(:,2),res1)
 overlay(plot(4),plot_data)
 Buizert C, et al. Greenland-Wide Seasonal Temperatures During the Last Deglaciation. Geophys Res Lett. 2018;45:1905–1914. doi: 10.1016/S0277-3791(99)00062-110.1002/2017gl075601. [CrossRef] [Google Scholar]

 plot_data = gsn_csm_xy(wks,buizert(:,0),buizert(:,6),res1)
 overlay(plot(5),plot_data)
 
 plot_data = gsn_csm_xy(wks,val1T(:,0),val1T(:,1),res1)
 overlay(plot(6),plot_data)

Tierney, J.E., J.M. Russell, Y. Huang, J.S. Sinninghe Damsté, E.C. Hopmans, and A.S. Cohen. 2008.  Northern Hemisphere Controls on Tropical Southeast African  Climate During the Past 60,000 Years.
Science, Vol. 322, No. 5899, pp. 252-255, 10 October 2008.   doi: 10.1126/science.1160485

 plot_data = gsn_csm_xy(wks,val2T(:,0),val2T(:,1),res1)
 overlay(plot(7),plot_data)

 Mediterranean winter rainfall in phase with African monsoons during the past 1.36 million years
Wagner, B; Vogel, H; (...); Zhang, XS

 plot_data = gsn_csm_xy(wks,val7T(:,0),val7T(:,1),res1)
 overlay(plot(8),plot_data)

 A progressively wetter climate in southern East Africa over the past 1.3 million years

 plot_data = gsn_csm_xy(wks,val8T(:,0),val8T(:,1),res1)
 overlay(plot(9),plot_data)

 A two-million-year-long hydroclimatic context for hominin evolution in southeastern Africa

 plot_data = gsn_csm_xy(wks,val5T(:,0),val5T(:,1),res1)
 overlay(plot(10),plot_data)

 Parrenin, F et al. (2013): Synchronous change of atmospheric CO2 and Antarctic temperature during the last deglacial warming. Science, 339(6123), 1060-1063,

 plot_data = gsn_csm_xy(wks,val6T(:,0),val6T(:,1),res1)
 overlay(plot(11),plot_data)

Jouzel, Jean; Masson-Delmotte, Valerie; Cattani, Olivier; Dreyfus, Gabrielle; Falourd, Sonia; Hoffmann, G; Minster, B√©n√©dicte; Nouet, Julius; Barnola, Jean-Marc; Chappellaz, J√©r√¥me A; Fischer, Hubertus; Gallet, J C; Johnsen, Sigf√∫s J√≥hann; Leuenberger, Markus C; Loulergue, Laetitia; Luethi, D; Oerter, Hans; Parrenin, Fr√©d√©ric; Raisbeck, Grant M; Raynaud, Dominique; Schilt, Adrian; Schwander, Jakob; Selmo, Enricomaria; Souchez, Roland A; Spahni, Renato; Stauffer, Bernhard; Steffensen, J√∏rgen Peder; Stenni, Barbara; Stocker, Thomas F; Tison, Jean-Louis; Werner, Martin; Wolff, Eric W (2007): Orbital and millennial Antarctic climate variability over the past 800,000 years. Science, 317(5839), 793-797, https://doi.org/10.1126/science.1141038

 plot_data = gsn_csm_xy(wks,val0J(:,0),val0J(:,1),res1)
 overlay(plot(12),plot_data)

Melles, M et al. (2012): 2.8 Million years of Arctic climate change from Lake El'gygytgyn, NE Russia. Science, 337(6092), 315-320, https://doi.org/10.1126/science.1222135





;================;================;================;================;================;================



 plot_data = gsn_csm_xy(wks,val1(:,0),val1(:,1),res1)
 overlay(plot(1),plot_data)
 Davtian, N et al. (2021): Biomarker indices and concentrations and biomarker-based temperature estimates from Iberian Margin cores MD99-2331, MD95-2040 and MD95-2042. PANGAEA,

 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val4(:,0),val4(:,1),res1)
 overlay(plot(1),plot_data)
Hodell, DA et al. (2013): Response of Iberian Margin sediments to orbital and suborbital forcing over the past 420 ka. Paleoceanography, 28(1), 185-199, https://doi.org/10.1002/palo.20017

 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val5(:,0),val5(:,1),res1)
 overlay(plot(1),plot_data)
Davtian, N et al. (2021): Biomarker indices and concentrations and biomarker-based temperature estimates from Iberian Margin cores MD99-2331, MD95-2040 and MD95-2042. PANGAEA,

 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val8(:,0),val8(:,1),res1)
 overlay(plot(1),plot_data)
Martrat, B et al. (2007): Four climate cycles of recurring deep and surface water destabilizations on the Iberian Margin. Science, 317(5837), 502-507, https://doi.org/10.1126/science.1139994

 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val9(:,0),val9(:,1),res1)
 overlay(plot(2),plot_data)
Martrat, B et al. (2007): Four climate cycles of recurring deep and surface water destabilizations on the Iberian Margin. Science, 317(5837), 502-507, https://doi.org/10.1126/science.1139994

 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val2(:,0),val2(:,1),res1)
 overlay(plot(3),plot_data)
 Naafs, BDA et al. (2013): Millennial-scale ice rafting events and Hudson Strait Heinrich(-like) Events during the late Pliocene and Pleistocene: a review. Quaternary Science Reviews, 80, 1-28,

 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val6(:,0),val6(:,1),res1)
 overlay(plot(3),plot_data)
Bahr, A et al. (2018): Oceanic heat pulses fueling moisture transport towards continental Europe across the mid-Pleistocene transition. Quaternary Science Reviews, 179, 48-58,

 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val7(:,0),val7(:,1),res1)
 overlay(plot(4),plot_data)
Bahr, A et al. (2018): Oceanic heat pulses fueling moisture transport towards continental Europe across the mid-Pleistocene transition. Quaternary Science Reviews, 179, 48-58,
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,10),res1)
 overlay(plot(5),plot_data)
https://doi.org/10.1594/PANGAEA.701229
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val13(:,0),val13(:,1),res1)
 overlay(plot(6),plot_data)
 Rampen, SW et al. (2012): Long chain 1,13- and 1,15-diols as a potential proxy for palaeotemperature reconstruction. Geochimica et Cosmochimica Acta, 84, 204-216,

 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,2),res1)
 overlay(plot(7),plot_data)
https://doi.org/10.1594/PANGAEA.786701

 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,14),res1)
 overlay(plot(8),plot_data)
 https://doi.org/10.1594/PANGAEA.52228
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,3),res1)
 overlay(plot(9),plot_data)
https://doi.org/10.1126/science.1185435
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val12(:,0),val12(:,1),res1)
 overlay(plot(10),plot_data)
Lauterbach, Stefan; Andersen, Nils; Wang, Yiming V; Blanz, Thomas; Larsen, Thomas; Schneider, Ralph R (2020): Alkenone concentration and UK'37 SST from sediment core SO188-17286-1. PANGAEA,
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val16(:,0),val16(:,1),res1)
 overlay(plot(11),plot_data)
Rickaby, REM; Elderfield, H (1999): Planktonic foraminiferal Cd/Ca: Paleonutrients or paleotemperature? Paleoceanography, 14(3), 293-303, https://doi.org/10.1029/1999PA900007
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,8),res1)
 overlay(plot(12),plot_data)
https://doi.org/10.1594/PANGAEA.786444
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,5),res1)
 overlay(plot(13),plot_data)
https://doi.org/10.1126/science.1185435
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val15(:,0),val15(:,1),res1)
 overlay(plot(14),plot_data)
De Deckker, Patrick; Moros, Matthias; Blanz, Thomas; Schneider, Ralph R; Barrows, Timothy T; Perner, Kerstin (2020): Multidataset for sediment cores MD03-2611 and SS0206-GC15 taken offshore southern Australia.
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,1),res1)
 overlay(plot(15),plot_data)
https://www.ncdc.noaa.gov/paleo/study/6266
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,7),res1)
 overlay(plot(16),plot_data)
https://doi.org/10.1594/PANGAEA.772015
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,11),res1)
 overlay(plot(17),plot_data)
https://www.ncdc.noaa.gov/paleo/study/11188
 
 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,13),res1)
 overlay(plot(18),plot_data)
https://doi.org/10.1594/PANGAEA.691478

 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val0(:,0),val0(:,1),res1)
 overlay(plot(19),plot_data)
 Harada, N., N. Ahagon, T. Sakamoto, M. Uchida, M. Ikehara, and Y. Shibata.  2006. Rapid fluctuation of alkenone temperature in the southwestern Okhotsk Sea during the past 120 ky. Global and Planetary Change, 53, 29-46.

 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,4),res1)
 overlay(plot(20),plot_data)
 https://doi.org/10.1126/science.1185435

 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,9),res1)
 overlay(plot(20),plot_data)
 https://doi.org/10.1038/nature02338

 res1@xyLineColor = "dodgerblue2"
 plot_data = gsn_csm_xy(wks,val17(:,0),val17(:,12),res1)
 overlay(plot(20),plot_data)
 Barth, AM et al. (2018): Climate evolution across the Mid-Brunhes Transition. Climate of the Past







;================;================;================;================;================;================

 plot(1)=gsn_csm_x2y2(wks,vp5,valP11(:,0),valsP(11,:),valP11(:,1),res1,res2)  
Coherent high- and low-latitude control of the northwest African hydrological balance

 plot(2)=gsn_csm_x2y2(wks,vp5,valP26(:,0),valsP(26,:),valP26(:,1),res1,res2)    ; standardise this
A two-million-year-long hydroclimatic context for hominin evolution in southeastern Africa

 plot(3)=gsn_csm_x2y2(wks,vp5,valP28(:,0),valsP(28,:),valP28(:,1),res1,res2)
Drivers of ecosystem and climate change in tropical West Africa over the past $540 000 years

 plot(4)=gsn_csm_x2y2(wks,vp5,valP31(:,0),valsP(31,:),valP31(:,1),res1,res2)
Melles, M et al. (2012): 2.8 Million years of Arctic climate change from Lake El'gygytgyn, NE Russia. Science, 337(6092), 315-320, https://doi.org/10.1126/science.1222135


 plot(5)=gsn_csm_x2y2(wks,vp5,valP6_1(:,0),valsP(6,:),valP6_1(:,1),res1,res2)
Eastern African environmental variation and its role in the evolution and cultural change of Homo over the last 1 million years

 plot(6)=gsn_csm_x2y2(wks,vp5,valP35(:,0),valsP(35,:),valP35(:,1),res1,res2)
Grant humidity index 




