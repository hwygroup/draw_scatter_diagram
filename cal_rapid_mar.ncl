load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin
    
    model_names =   systemfunc("ls ../..")

do mm   =   0, dimsizes(model_names)-1
    model_name  =   model_names(mm)
    dir =   "/Users/hwy_pro/Rapid_Winter_Month_changes/data/"+model_name+"/rapid.nc"

    fi   =   addfile(dir,"r")
    t1   =   fi->feb_ts
    t2   =   fi->diff3

    printMinMax(t1,0) ;min=-3.69744   max=3.4984
    printMinMax(t2,0)  ;min=-3.52891   max=2.24576
    rc   = regline (t1,t2)
    print(rc)

    t1_13   =   t1
    t1_13   =   where(t1*t2 .lt. 0.0, t1, t1@_FillValue)
    t2_13   =   t2
    t2_13   =   where(t1*t2 .lt. 0.0, t2, t2@_FillValue)
    
    rc_13   = regline (t1_13,t2_13)
    print(rc_13)


    count1  =   0
    count2  =   0
    count3  =   0
    count4  =   0
    do k = 0, dimsizes(t1)-1
        if (t1(k) .gt. 0.0 .and. t2(k) .gt. 0.0) then
            count1  =   count1+1
        end if
        if (t1(k) .lt. 0.0 .and. t2(k) .gt. 0.0) then
            count2  =   count2+1
        end if
        if (t1(k) .lt. 0.0 .and. t2(k) .lt. 0.0) then
            count3  =   count3+1
        end if
        if (t1(k) .gt. 0.0 .and. t2(k) .lt. 0.0) then
            count4  =   count4+1
        end if
    end do

    ratio1  =   tofloat(count1*1.0/dimsizes(t1))
    ratio2  =   tofloat(count2*1.0/dimsizes(t1))
    ratio3  =   tofloat(count3*1.0/dimsizes(t1))
    ratio4  =   tofloat(count4*1.0/dimsizes(t1))
    tot     =   ratio1+ratio2+ratio3+ratio4
    print("count1:"+count1+" ratio1:"+ratio1)
    print("count2:"+count2+" ratio2:"+ratio2)
    print("count3:"+count3+" ratio3:"+ratio3)
    print("count4:"+count4+" ratio4:"+ratio4)
    print("tot: "+tot)
    ratio13 =   ratio1+ratio3
    ratio24 =   ratio2+ratio4
    print("contine runs: "+ratio13)
    print("rapid runs: "+ratio24)
    
    
    x   =   t1
    y   =   rc*x + rc@yintercept

    x_13   =   t1_13
    y_13   =   rc_13*x_13 + rc_13@yintercept


    wks   =   gsn_open_wks("pdf" , model_name+"_line_mar_feb")

    res             = True              
    res@gsnDraw              = False
    res@gsnFrame             = False

    res@vpHeightF   =  0.5                   ; change aspect ratio of plot
    res@vpWidthF    =  0.5

    res@trYMinF              =  -5
    res@trYMaxF              =  5
    res@trXMinF              =  -5
    res@trXMaxF              =  5

    res@tiXAxisString = "Feb Temp (~F34~0~F~C)"
    res@tiYAxisString = "Temp Diff (Mar-Feb) (~F34~0~F~C)"          ; y-axis label 
    res@tiMainString  = "" 
    res@gsnLeftString  = sprintf("%5.2f",100*ratio24)+"%" 
    res@gsnRightString = ""
    res@gsnCenterString = model_name
    res@xyLineThicknessF    =   3.0
    res@xyLineColor =   "Green"

    res@tiMainFontHeightF   =   0.025
    res@tiXAxisFontHeightF  =   0.022
    res@tiYAxisFontHeightF  =   0.02
    res@gsnLeftStringFontHeightF    =   0.02
    res@gsnRightStringFontHeightF   =   0.02
    res@gsnCenterStringFontHeightF  =   0.02
    res@tmYLLabelFontHeightF    =   0.02
    res@tmXBLabelFontHeightF    =   0.02


    marker1  =   new(dimsizes(t1),graphic)
    plot  =   gsn_csm_xy(wks,x,y,res)
    res@xyLineColor =   "Red"
    plot_13 =   gsn_csm_xy(wks,x_13,y_13,res)
    overlay(plot,plot_13)

    pmres   =   True
    pmres@gsMarkerIndex    = 1
    pmres@gsMarkerSizeF    = 0.02
    pmres@gsMarkerColor    = "blue"
    pmres@gsMarkerThicknessF    =   2.0

    do k = 0, dimsizes(t1)-1 
            marker1(k)    = gsn_add_polymarker(wks, plot, t1(k), t2(k), pmres)
    end do

    plres   =   True
    plres@gsLineColor      = "black"
    plres@gsLineThicknessF = 1.0
    dum1 = gsn_add_polyline  (wks, plot, (/-5,5/), (/0.0,0.0/), plres)

    plres@gsLineColor      = "black"
    plres@gsLineThicknessF = 1.0
    dum2 = gsn_add_polyline  (wks, plot, (/0.0,0.0/), (/-5,5/), plres)

    draw(plot) 
    frame(wks)

    delete(t1)
    delete(t2)
    delete(rc)
    delete(x)
    delete(y)
    delete(t1_13)
    delete(t2_13)
    delete(rc_13)
    delete(x_13)
    delete(y_13)
    delete(dum1)
    delete(dum2)
    delete(marker1)
end do
end
