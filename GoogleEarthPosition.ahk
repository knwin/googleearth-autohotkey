; GoogleEarthPosition.ahk  version 1.02
; by David Tryse   davidtryse@gmail.com
; http://david.tryse.net/googleearth/
; http://code.google.com/p/googleearth-autohotkey/
; License:  GPLv2+
; 
; Script for AutoHotkey   ( http://www.autohotkey.com/ )
; Creates a small GUI for reading the current coordinates from the Google Earth client
; * can also edit coordinates to make Google Earth fly to a new location
; * can copy coordinates to the clipboard, either in KML format or tab separated
;   (tab separated = for use with Google's SpreadSheet Mapper: http://earth.google.com/outreach/tutorial_mapper.html )
; 
; Needs _libGoogleEarth.ahk library:  http://david.tryse.net/googleearth/
; Needs ws4ahk.ahk library:  http://www.autohotkey.net/~easycom/
; 
; The script uses the Google Earth COM API  ( http://earth.google.com/comapi/ )

; Version history:
; 1.02   -   * read Terrain Altitude * add drop-down list for AltitudeMode * DMS coord in statusbar * keyboard shortcuts * fix edit-box text-select in auto-mode * round values option (right-click menu)

#NoEnv
#SingleInstance off
#NoTrayIcon 
#include _libGoogleEarth.ahk
version = 1.02

Speed := 1.0
RoundVal := 1

; -------- create right-click menu -------------
Menu, context, add, Always On Top, OnTop
Menu, context, Check, Always On Top
Menu, context, add, Round values, RoundVal
If RoundVal
	Menu, context, Check, Round values
Menu, context, add,
Menu, context, add, About, About

; ----------- create GUI ----------------
Gui, Add, Text, x10, FocusPointLatitude:
Gui, Add, Edit, yp x140 w150 vFocusPointLatitude,
Gui, Add, Text, x10, FocusPointLongitude:
Gui, Add, Edit, yp x140 w150 vFocusPointLongitude,
Gui, Add, Text, x10, FocusPointAltitude:
Gui, Add, Edit, yp x140 w150 vFocusPointAltitude,
Gui, Add, Text, x10, FocusPointAltitudeMode:
Gui, Add, DropDownList, yp x140 w150 AltSubmit Choose1 vFocusPointAltitudeMode, Relative To Ground|Absolute
Gui, Add, Text, x10, Range:
Gui, Add, Edit, yp x140 w150 vRange,
Gui, Add, Text, x10, Tilt:
Gui, Add, Edit, yp x140 w150 vTilt,
Gui, Add, Text, x10, Azimuth:
Gui, Add, Edit, yp x140 w150 vAzimuth,
Gui, Add, Text, x10, Terrain Altitude:
Gui, Add, Edit, yp x140 w150 vAltitude ReadOnly,

Gui, Add, Button, x10 w70, &GetPos
Gui, Add, Checkbox, yp x85 vAutoLoad Checked,(au&to)
Gui, Add, Button, yp x140 w70 default, &FlyTo
Gui, Add, Text, yp x227, speed:
Gui, Add, Edit, yp x263 w27 vSpeed, %Speed%
Gui, Add, Button, x10 w120 gButtonCopy_LatLong,&Copy LatLong
Gui, Add, Button, yp x140 w120 gButtonCopy_LookAt,Copy Look&At
Gui, Add, Button, x10 w120 gButtonCopy_LatLong_KML,Copy LatLong K&ML
Gui, Add, Button, yp x140 w120 gButtonCopy_LookAt_KML,Copy LookAt KM&L

;Gui, Add, Text, x10, DMS Coordinates:
;Gui, Add, Edit, x10 w100 ReadOnly, %A_Space%DMS Coordinates:
;Gui, Add, Edit, yp x110 w180 vDMSCoord ReadOnly,

Gui Add, StatusBar
SB_SetText("  Google Earth is not running ")


Gui, Show,, Google Earth Position %version%
Gui +LastFound
WinSet AlwaysOnTop
Gosub ButtonGetPos

Loop {
  Gui, Submit, NoHide
  If (AutoLoad = "1")
	Gosub ButtonGetPos
  If (AutoLoad != PrevAutoLoad)  {
	  If (AutoLoad = "1") 
	  {
		  GuiControl, +ReadOnly, FocusPointLatitude,
		  GuiControl, +ReadOnly, FocusPointLongitude,
		  GuiControl, +ReadOnly, FocusPointAltitude,
		  GuiControl, +Disabled, FocusPointAltitudeMode,
		  GuiControl, +ReadOnly, Range,
		  GuiControl, +ReadOnly, Tilt,
		  GuiControl, +ReadOnly, Azimuth,
		  GuiControl, +ReadOnly, Speed,
		  GuiControl, -Disabled, Altitude,
	  } else {
		  GuiControl, -ReadOnly, FocusPointLatitude,
		  GuiControl, -ReadOnly, FocusPointLongitude,
		  GuiControl, -ReadOnly, FocusPointAltitude,
		  GuiControl, -Disabled, FocusPointAltitudeMode,
		  GuiControl, -ReadOnly, Range,
		  GuiControl, -ReadOnly, Tilt,
		  GuiControl, -ReadOnly, Azimuth,
		  GuiControl, -ReadOnly, Speed,
		  GuiControl, +Disabled, Altitude,
	  }
  }
  PrevAutoLoad := AutoLoad
  Sleep 100
}

ButtonGetPos:
  If not IsGErunning()
	return
  oldFocusPointLatitude := FocusPointLatitude
  oldFocusPointLongitude := FocusPointLongitude
  oldFocusPointAltitude := FocusPointAltitude
  oldFocusPointAltitudeMode := FocusPointAltitudeMode
  oldRange := Range
  oldTilt := Tilt
  oldAzimuth := Azimuth
  oldPointAltitude := PointAltitude
  oldDMSCoord := DMSCoord
  GetGEpos(FocusPointLatitude, FocusPointLongitude, FocusPointAltitude, FocusPointAltitudeMode, Range, Tilt, Azimuth)
  GetGEpoint(PointLatitude, PointLongitude, PointAltitude)
  If (RoundVal) {
	FocusPointLatitude := Round(FocusPointLatitude,6)
	FocusPointLongitude := Round(FocusPointLongitude,6)
	;FocusPointAltitude := Round(FocusPointAltitude,2)
	Range := Round(Range,2)
	Tilt := Round(Tilt,2)
	Azimuth := Round(Azimuth,2)
	PointAltitude := Round(PointAltitude,2)
  }
  DMSCoord := Dec2Deg(FocusPointLatitude "," FocusPointLongitude)
  If (FocusPointLatitude != oldFocusPointLatitude)
	GuiControl,, FocusPointLatitude, %FocusPointLatitude%
  If (FocusPointLongitude != oldFocusPointLongitude)
	GuiControl,, FocusPointLongitude, %FocusPointLongitude%
  If (FocusPointAltitude != oldFocusPointAltitude)
	GuiControl,, FocusPointAltitude, %FocusPointAltitude%
  If (FocusPointAltitudeMode != oldFocusPointAltitudeMode)
	GuiControl, Choose, FocusPointAltitudeMode, %FocusPointAltitudeMode%
  If (Range != oldRange)
	GuiControl,, Range, %Range%
  If (Tilt != oldTilt)
	GuiControl,, Tilt, %Tilt%
  If (Azimuth != oldAzimuth)
	GuiControl,, Azimuth, %Azimuth%
  If (PointAltitude != oldPointAltitude)
	GuiControl,, Altitude, %PointAltitude%
  If (DMSCoord != oldDMSCoord)
	SB_SetText("   DMS Coordinates:   " DMSCoord)
	;GuiControl,, DMSCoord, %DMSCoord%
  GuiControl,, Speed, %Speed%
return

ButtonFlyTo:
  SetGEpos(FocusPointLatitude,FocusPointLongitude,FocusPointAltitude,FocusPointAltitudeMode,Range,Tilt,Azimuth,Speed)
return

ButtonCopy_LatLong:
  clipboard = %FocusPointLatitude%`t%FocusPointLongitude%
return

ButtonCopy_LookAt:
  clipboard = %FocusPointLatitude%`t%FocusPointLongitude%`t%FocusPointAltitude%`t%Range%`t%Tilt%`t%Azimuth%
return

ButtonCopy_LatLong_KML:
  clipboard = <coordinates>%FocusPointLongitude%,%FocusPointLatitude%,0</coordinates>
return

ButtonCopy_LookAt_KML:
  clipboard = <LookAt>`n`t<longitude>%FocusPointLongitude%</longitude>`n`t<latitude>%FocusPointLatitude%</latitude>`n`t<altitude>%FocusPointAltitude%</altitude>`n`t<range>%Range%</range>`n`t<tilt>%Tilt%</tilt>`n`t<heading>%Azimuth%</heading>`n</LookAt>
return

ButtonCopy_LatLongIni:
  clipboard = lat = %FocusPointLatitude%`nlong = %FocusPointLongitude%
return

OnTop:
  Menu, context, ToggleCheck, %A_ThisMenuItem%
  Winset, AlwaysOnTop, Toggle, A
return

RoundVal:
  Menu, context, ToggleCheck, %A_ThisMenuItem%
  RoundVal := (RoundVal - 1)**2	; toggle value 1/0
return

GuiContextMenu:
  Menu, context, Show
return

GuiClose:
  WS_Uninitialize()
ExitApp

About:
  Gui 2:Destroy
  Gui 2:+Owner
  Gui 1:+Disabled
  Gui 2:Font,Bold
  Gui 2:Add,Text,x+0 yp+10, Google Earth Position %version%
  Gui 2:Font
  Gui 2:Add,Text,xm yp+22, A tiny program for reading coordinates from the Google Earth client
  Gui 2:Add,Text,xm yp+15, (or edit coordinates to make Google Earth fly to a new location).
  Gui 2:Add,Text,xm yp+18, License: GPLv2+
  Gui 2:Add,Text,xm yp+36, The copy functions are intended to be useful when editing KML
  Gui 2:Add,Text,xm yp+15, using Google's SpreadSheet Mapper:
  Gui 2:Font,CBlue Underline
  Gui 2:Add,Text,xm gMapperlink yp+15, http://earth.google.com/outreach/tutorial_mapper.html
  Gui 2:Font
  Gui 2:Add,Text,xm yp+36, Check for updates here:
  Gui 2:Font,CBlue Underline
  Gui 2:Add,Text,xm gWeblink yp+15, http://david.tryse.net/googleearth/
  Gui 2:Font
  Gui 2:Add,Text,xm yp+20, For bug reports or suggestions email:
  Gui 2:Font,CBlue Underline
  Gui 2:Add,Text,xm gEmaillink yp+15, davidtryse@gmail.com
  Gui 2:Font
  Gui 2:Add,Button,gAboutOk Default w80 h80 yp-60 x230,&OK
  Gui 2:Show,,About: Google Earth Position
  Gui 2:+LastFound
  WinSet AlwaysOnTop
Return

Weblink:
  Run, http://david.tryse.net/googleearth/,,UseErrorLevel
Return

Mapperlink:
  Run, http://earth.google.com/outreach/tutorial_mapper.html,,UseErrorLevel
Return

Emaillink:
  Run, mailto:davidtryse@gmail.com,,UseErrorLevel
Return

AboutOk:
2GuiClose:
  Gui 1:-Disabled
  Gui 2:Destroy
return
