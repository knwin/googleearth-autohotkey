; GoogleEarthScreenOverlay.ahk
; by David Tryse   davidtryse@gmail.com
; http://earth.tryse.net/
; http://code.google.com/p/googleearth-autohotkey/
; License:  GPLv2+
; 
; Script for AutoHotkey   ( http://www.autohotkey.com/ )
; A small program for adding screen overlay images to Google Earth.
; 
; Version history:
; 1.01   -   Add DrawOrder option, make it possible to edit several overlays at once (use unique tmp file names, add menu option to open more copies of the program)

#NoEnv
#SingleInstance off
#NoTrayIcon 
version = 1.01

RegRead OnTop, HKEY_CURRENT_USER, SOFTWARE\GoogleEarthScreenOverlay, OnTop
IfEqual, OnTop,
	OnTop := 1

Random, rnd, 0, 9999999
KMLfile := A_Temp "\GoogleEarthScreenOverlay_"  rnd "_tmp.kml"
KMLfile_nw := A_Temp "\GoogleEarthScreenOverlay_" rnd "_nw.kml"

; -------- create right-click menu -------------
Menu, context, add, Always On Top, OnTop
Menu, context, add, Open another window, AddWindow
Menu, context, add,
Menu, context, add, Check for updates, webHome
Menu, context, add, About, About
If OnTop
	Menu, context, Check, Always On Top

; ----------- create GUI ----------------
Gui, Margin, 6, 6
Gui Add, Button, xm ym+5 vOpenFileDialog gOpenFileDialog, &Open Image..
Gui Add, Edit, vImageFile ReadOnly yp xp+90 w230 r1 0x400,
ImageFile_TT := "Image file to show on the Google Earth screen."
OpenFileDialog_TT := ImageFile_TT
; ================================================================================
ScreenX=0
ScreenY=0
Gui, Font, bold
Gui, Add, GroupBox, yp+30 xm w320 h100, Screen Anchor
Gui, Font, norm
Gui, font,, Wingdings
Gui Add, Button, xm+8  yp+17 w26 vScreenXYtl gScreenXYtl, �
Gui Add, Button, xp+30 yp w26 vScreenXYtc gScreenXYtc, �
Gui Add, Button, xp+30 yp w26 vScreenXYtr gScreenXYtr, �
Gui Add, Button, xm+8  yp+26 w26 vScreenXYcl gScreenXYcl, �
Gui Add, Button, xp+30 yp w26 vScreenXYcc gScreenXYcc, �
Gui Add, Button, xp+30 yp w26 vScreenXYcr gScreenXYcr, �
Gui Add, Button, xm+8  yp+26 w26 vScreenXYbl gScreenXYbl, �
Gui Add, Button, xp+30 yp w26 vScreenXYbc gScreenXYbc, �
Gui Add, Button, xp+30 yp w26 vScreenXYbr gScreenXYbr, �
; ����l����		bold arrows
Gui, font,, Verdana
Gui, Add, Text, yp-36 xm+120, &X:
Gui, Add, Edit, yp-3 xp+20 w46 vScreenX gUpdateKML, %ScreenX%
; Gui, Add, UpDown, vMyUpDown, 0.01
Gui, Add, DropDownList, yp xp+56 w86 Choose1 gUpdateKML vScreenXunit, fraction|pixels|insetPixels
Gui, Add, Text, yp+30 xm+120, &Y:
Gui, Add, Edit, yp-3 xp+20 w46 vScreenY gUpdateKML, %ScreenY%
; Gui, Add, UpDown, vMyUpDown2 Horz 16, 0.01
Gui, Add, DropDownList, yp xp+56 w86 Choose1 gUpdateKML vScreenYunit, fraction|pixels|insetPixels
ScreenXYtl_TT := "Position image in the top-left corner of the screen."
ScreenXYtc_TT := "Position image centered at the top of the screen."
ScreenXYtr_TT := "Position image in the top-right corner of the screen."
ScreenXYcl_TT := "Position image centered at the left screen edge."
ScreenXYcc_TT := "Position image at the center of the screen."
ScreenXYcr_TT := "Position image centered at the right screen edge."
ScreenXYbl_TT := "Position image in the bottom-left corner of the screen."
ScreenXYbc_TT := "Position image centered at the bottom of the screen."
ScreenXYbr_TT := "Position image in the bottom-right corner of the screen."
ScreenX_TT := "Position along the X (horizontal) axis of the screen."
ScreenY_TT := "Position along the Y (vertical) axis of the screen."
ScreenXunit_TT := "Unit for the horizontal position on the screen.`nfraction : 0 is the left edge of the screen, 1 is the right edge.`npixels : specify position in pixels from the left edge of the screen.`ninsetPixels: specify position in pixels from the right edge of the screen."
ScreenYunit_TT := "Unit for the vertical position on the screen.  `nfraction : 0 is the bottom of the screen, 1 is the top.          `npixels : specify position in pixels from the bottom of the screen.   `ninsetPixels: specify position in pixels from the top of the screen."
; ================================================================================
ImageX=0
ImageY=0
Gui, Font, bold
Gui, Add, GroupBox, yp+50 xm w320 h100, Image Anchor
Gui, Font, norm
Gui, font,, Wingdings
Gui Add, Button, xm+8  yp+17 w26 vImageXYtl gImageXYtl, �
Gui Add, Button, xp+30 yp w26 vImageXYtc gImageXYtc, �
Gui Add, Button, xp+30 yp w26 vImageXYtr gImageXYtr, �
Gui Add, Button, xm+8  yp+26 w26 vImageXYcl gImageXYcl, �
Gui Add, Button, xp+30 yp w26 vImageXYcc gImageXYcc, �
Gui Add, Button, xp+30 yp w26 vImageXYcr gImageXYcr, �
Gui Add, Button, xm+8  yp+26 w26 vImageXYbl gImageXYbl, �
Gui Add, Button, xp+30 yp w26 vImageXYbc gImageXYbc, �
Gui Add, Button, xp+30 yp w26 vImageXYbr gImageXYbr, �
Gui, font,, Verdana
Gui, Add, Text, yp-36 xm+120, X:
Gui, Add, Edit, yp-3 xp+20 w46 vImageX gUpdateKML, %ImageX%
Gui, Add, DropDownList, yp xp+56 w86 Choose1 gUpdateKML vImageXunit, fraction|pixels|insetPixels
Gui, Add, Text, yp+30 xm+120, Y:
Gui, Add, Edit, yp-3 xp+20 w46 vImageY gUpdateKML, %ImageY%
Gui, Add, DropDownList, yp xp+56 w86 Choose1 gUpdateKML vImageYunit, fraction|pixels|insetPixels
ImageXYtl_TT := "Anchor at top-left corner within the image."
ImageXYtc_TT := "Anchor at top edge within the image"
ImageXYtr_TT := "Anchor at top-right corner within the image."
ImageXYcl_TT := "Anchor at left edge within the image."
ImageXYcc_TT := "Anchor at the center of the image."
ImageXYcr_TT := "Anchor at right edge within the image."
ImageXYbl_TT := "Anchor at bottom-left corner within the image."
ImageXYbc_TT := "Anchor at bottom edge within the image."
ImageXYbr_TT := "Anchor at bottom-right corner within the image."
ImageX_TT := "Anchor position along the X (horizontal) axis of the image."
ImageY_TT := "Anchor position along the Y (vertical) axis of the image."
ImageXunit_TT := "Unit for the horizontal position of the anchor within the image.`nfraction : 0 is the left edge of the image, 1 is the right edge.`npixels : specify position in pixels from the left edge of the image.`ninsetPixels: specify position in pixels from the right edge of the image."
ImageYunit_TT := "Unit for the vertical position of the anchor within the image.  `nfraction : 0 is the bottom of the image, 1 is the top.          `npixels : specify position in pixels from the bottom of the image.   `ninsetPixels: specify position in pixels from the top of the image."
; ================================================================================
SizeX=0
SizeY=0
Gui, Font, bold
Gui, Add, GroupBox, yp+50 xm w320 h100, Image Size
Gui, Font, norm
Gui Add, Button, xm+8  yp+17 w130 gSizeNative, Native Size
Gui Add, Button, xm+8  yp+26 w130 gSize20Width, 20`% of screen width
Gui Add, Button, xm+8  yp+26 w130 gSize30Height, 30`% of screen height
Gui, Add, Text, yp-36 xm+150, X:
Gui, Add, Edit, yp-3 xp+20 w46 vSizeX gUpdateKML, %ImageX%
Gui, Add, DropDownList, yp xp+56 w72 Choose1 gUpdateKML vSizeXunit, fraction|pixels
Gui, Add, Text, yp+30 xm+150, Y:
Gui, Add, Edit, yp-3 xp+20 w46 vSizeY gUpdateKML, %ImageY%
Gui, Add, DropDownList, yp xp+56 w72 Choose1 gUpdateKML vSizeYunit, fraction|pixels
SizeX_TT := "Size of image along the X (horizontal) axis of the screen.`nUse -1 to keep the image native dimensions.`nUse 0 for either X or Y to maintain the image aspect ratio."
SizeY_TT := "Size of image along the Y (vertical) axis of the screen.  `nUse -1 to keep the image native dimensions.`nUse 0 for either X or Y to maintain the image aspect ratio."
SizeXunit_TT := "Unit for the horizontal size of the image.`nfraction : 0.1 is 10% of the screen width, 1 is the full width of the screen.  `npixels : specify horizontal size in pixels."
SizeYunit_TT := "Unit for the vertical size of the image.  `nfraction : 0.1 is 10% of the screen height, 1 is the full height of the screen.`npixels : specify vertical size in pixels."
; ================================================================================
; Gui, Font, bold
Gui, Add, Text, yp+54 xm+5, Transparency:
Gui, Font, norm
Gui, Add, ComboBox, yp-3 xp+106 w60 Choose1 gUpdateKML vTransparency, 0`%|10`%|20`%|40`%|60`%|80`%
; Gui, Font, bold
Gui, Add, Text, yp+3 xm+200, Rotate:
Gui, Font, norm
Gui, Add, ComboBox, yp-3 xp+54 w60 Choose1 gUpdateKML vRotate, 0|-45|-90|-135|45|90|135|180
Transparency_TT := "Make the image semi-transparent in Google Earth."
Rotate_TT := "Rotate the image by a number of degrees."
; ================================================================================
; Gui, Font, bold
Gui, Add, Text, yp+30 xm+5, Draw Order:
Gui, Font, norm
Gui, Add, ComboBox, yp-3 xp+106 w60 Choose1 gUpdateKML vdrawOrder, 0|1|2|3|4|5|-1|-2|-3|-4|-5
drawOrder_TT := "Images with a higher Draw Order are drawn on top of other images in case images overlap on the screen"
; ================================================================================

Gui, Font, bold
Gui Add, Button, yp+34 xm+5 w160 h23 vKMLOpen gKMLOpen, &Show in Google Earth
Gui, Font, norm
Gui Add, Button, yp xm+175 w80 h23 gKMLSave, S&ave File
Gui, Add, Button, yp xm+271 w50 vAbout gAbout, &?
KMLOpen_TT := "Show the Screen Overlay image in Google Earth.`nIt will be automatically updated with any changes you make here."

Gui, Add, Button, ym xm greload hidden, reloa&d
WinPos := GetSavedWinPos("GoogleEarthScreenOverlay")
Gui, Show, %WinPos%, Google Earth ScreenOverlay %version%
Gui +LastFound
If OnTop
	WinSet AlwaysOnTop
OnMessage(0x200, "WM_MOUSEMOVE")
SetTimer, UpdateKMLGO, 200
return

; ================================================================================
ScreenXYtl:
	SetScreenXY(6,91, "pixels", "insetPixels", 0, 1)
return
ScreenXYtc:
	SetScreenXY(0.5,1)
return
ScreenXYtr:
	SetScreenXY(110,1, "insetPixels", "fraction", 1, 1)
return
ScreenXYcl:
	SetScreenXY(0,0.5)
return
ScreenXYcc:
	SetScreenXY(0.5,0.5)
return
ScreenXYcr:
	SetScreenXY(1,0.5)
return
ScreenXYbl:
	SetScreenXY(10,75, "pixels", "pixels", 0, 0)
return
ScreenXYbc:
	SetScreenXY(0.5,80, "fraction", "pixels", 0.5, 0)
return
ScreenXYbr:
	SetScreenXY(0.995,0.11, "fraction", "fraction", 1, 0)
return

SetScreenXY(x, y, xunit="fraction", yunit="fraction", imx="", imy="") {
	GuiControl,, ScreenX, %x%
	GuiControl,, ScreenY, %y%
	GuiControl,Choose, ScreenXunit, %xunit%
	GuiControl,Choose, ScreenYunit, %yunit%
	If (imy != "")
		SetImageXY(imx,imy)
	Else
		SetImageXY(x,y)
}
; ================================================================================
ImageXYtl:
	SetImageXY(0,1)
return
ImageXYtc:
	SetImageXY(0.5,1)
return
ImageXYtr:
	SetImageXY(1,1)
return
ImageXYcl:
	SetImageXY(0,0.5)
return
ImageXYcc:
	SetImageXY(0.5,0.5)
return
ImageXYcr:
	SetImageXY(1,0.5)
return
ImageXYbl:
	SetImageXY(0,0)
return
ImageXYbc:
	SetImageXY(0.5,0)
return
ImageXYbr:
	SetImageXY(1,0)
return

SetImageXY(x,y) {
	GuiControl,, ImageX, %x%
	GuiControl,, ImageY, %y%
	GuiControl,Choose, ImageXunit, fraction
	GuiControl,Choose, ImageYunit, fraction
}
; ================================================================================
SizeNative:
	SetSizeXY(-1,-1)
return
Size20Width:
	SetSizeXY(0.2,0)
return
Size30Height:
	SetSizeXY(0,0.3)
return

SetSizeXY(x,y) {
	GuiControl,, SizeX, %x%
	GuiControl,, SizeY, %y%
	GuiControl,Choose, SizeXunit, fraction
	GuiControl,Choose, SizeYunit, fraction
}
; ================================================================================

UpdateKML:
needupdate = 1
return

UpdateKMLGO:
If (!needupdate)
	return
Gui, Submit, NoHide
StringReplace, Transparency, Transparency, `%
Transparency := Round(Transparency/100*255)
SetFormat, IntegerFast, hex
Opacity := 0xff-Transparency
StringReplace, Opacity, Opacity, 0x
SetFormat, IntegerFast, d
SplitPath, ImageFile,, Dir,, Name
KML =
(
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
	<ScreenOverlay>
	  <name>%Name%</name>
	  <color>%Opacity%ffffff</color>
	  <Icon>
		<href>%ImageFile%</href>
	  </Icon>
	  <screenXY x="%ScreenX%" y="%ScreenY%" xunits="%ScreenXunit%" yunits="%ScreenYunit%"/>
	  <overlayXY x="%ImageX%" y="%ImageY%" xunits="%ImageXunit%" yunits="%ImageYunit%"/>
	  <rotation>%Rotate%</rotation>
	  <drawOrder>%drawOrder%</drawOrder>
	  <size x="%SizeX%" y="%SizeY%" xunits="%SizeXunit%" yunits="%SizeYunit%"/>
	</ScreenOverlay>
</Document>
</kml>
)
FileDelete, %KMLfile%
IfNotExist, %KMLfile%
	FileAppend, %KML%, %KMLfile%
needupdate = 0
return

OpenFileDialog:
  FileSelectFile, SelectedFile, 3, , Open an image file... (or a .kml file with a <ScreenOverlay> tag), Image files (*.png; *.jpg; *.gif; *.kml)
OpenFile:
  IfEqual SelectedFile,, return
  SplitPath, SelectedFile,,, Ext,
  If (Ext == "kml") {
	CoordFromKML(SelectedFile)
	return
  }
  GuiControl,, ImageFile,
  GuiControl,, ImageFile, %SelectedFile%
  SplitPath, SelectedFile,, Dir,, Name
  Gosub UpdateKML
return

KMLSave:
  FileSelectFile, SelectedFile, S 16, , Save as KML file..., KML files (*.kml)
  IfEqual SelectedFile,, return
  Gosub UpdateKML
  FileCopy, %KMLfile%, %SelectedFile%, 1
return

KMLOpen:
	Gosub UpdateKML
	KML_nw =
	(
	<?xml version="1.0" encoding="UTF-8"?>
	<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
		<NetworkLink>
			<name>GoogleEarthScreenOverlay</name>
			<open>1</open>
			<Link>
				<href>%KMLfile%</href>
				<refreshMode>onInterval</refreshMode>
				<refreshInterval>1</refreshInterval>
			</Link>
		</NetworkLink>
	</kml>
	)
	FileDelete, %KMLfile_nw%
	FileAppend, %KML_nw%, %KMLfile_nw%
	Run, %KMLfile_nw%
return

OpenKmlDialog:
  FileSelectFile, SelectedFile, 3, , Open a KML file with a <ScreenOverlay> tag..., KML files (*.kml)
  IfEqual SelectedFile,, return
  CoordFromKML(SelectedFile)
return

CoordFromKML(kmlcoordfile) {
	FileRead kmlcode, %kmlcoordfile%
	RegExMatch(kmlcode, "s).*<ScreenOverlay.*>.*<Icon>.*<href>(.*)</href>.*</Icon>.*</ScreenOverlay>.*", href)
	RegExMatch(kmlcode, "s).*<ScreenOverlay.*>.*<screenXY[^<>]*\sx=.([0-9\.-]*).\s.*/>.*</ScreenOverlay>.*", ScreenX)
	RegExMatch(kmlcode, "s).*<ScreenOverlay.*>.*<screenXY[^<>]*\sy=.([0-9\.-]*).\s.*/>.*</ScreenOverlay>.*", ScreenY)
	RegExMatch(kmlcode, "s).*<ScreenOverlay.*>.*<screenXY[^<>]*\sxunits=.([a-zA-Z]*)..*/>.*</ScreenOverlay>.*", ScreenXunit)
	RegExMatch(kmlcode, "s).*<ScreenOverlay.*>.*<screenXY[^<>]*\syunits=.([a-zA-Z]*)..*/>.*</ScreenOverlay>.*", ScreenYunit)
	RegExMatch(kmlcode, "s).*<ScreenOverlay.*>.*<overlayXY[^<>]*\sx=.([0-9\.-]*).\s.*/>.*</ScreenOverlay>.*", ImageX)
	RegExMatch(kmlcode, "s).*<ScreenOverlay.*>.*<overlayXY[^<>]*\sy=.([0-9\.-]*).\s.*/>.*</ScreenOverlay>.*", ImageY)
	RegExMatch(kmlcode, "s).*<ScreenOverlay.*>.*<overlayXY[^<>]*\sxunits=.([a-zA-Z]*)..*/>.*</ScreenOverlay>.*", ImageXunit)
	RegExMatch(kmlcode, "s).*<ScreenOverlay.*>.*<overlayXY[^<>]*\syunits=.([a-zA-Z]*)..*/>.*</ScreenOverlay>.*", ImageYunit)
	RegExMatch(kmlcode, "s).*<ScreenOverlay.*>.*<size[^<>]*\sx=.([0-9\.-]*).\s.*/>.*</ScreenOverlay>.*", SizeX)
	RegExMatch(kmlcode, "s).*<ScreenOverlay.*>.*<size[^<>]*\sy=.([0-9\.-]*).\s.*/>.*</ScreenOverlay>.*", SizeY)
	RegExMatch(kmlcode, "s).*<ScreenOverlay.*>.*<size[^<>]*\sxunits=.([a-zA-Z]*)..*/>.*</ScreenOverlay>.*", SizeXunit)
	RegExMatch(kmlcode, "s).*<ScreenOverlay.*>.*<size[^<>]*\syunits=.([a-zA-Z]*)..*/>.*</ScreenOverlay>.*", SizeYunit)
	RegExMatch(kmlcode, "s).*<ScreenOverlay.*>.*<rotation>([0-9\.-]*)</rotation>.*</ScreenOverlay>.*", Rotate)
	If (ScreenX1 != "" and ScreenY1 != "") {
		GuiControl,, ImageFile, %href1%
		GuiControl,, ScreenX, %ScreenX1%
		GuiControl,, ScreenY, %ScreenY1%
		GuiControl, ChooseString, ScreenXunit, %ScreenXunit1%
		GuiControl, ChooseString, ScreenYunit, %ScreenYunit1%
		GuiControl,, ImageX, %ImageX1%
		GuiControl,, ImageY, %ImageY1%
		GuiControl, ChooseString, ImageXunit, %ImageXunit1%
		GuiControl, ChooseString, ImageYunit, %ImageYunit1%
		GuiControl,, SizeX, %SizeX1%
		GuiControl,, SizeY, %SizeY1%
		GuiControl, ChooseString, SizeXunit, %SizeXunit1%
		GuiControl, ChooseString, SizeYunit, %SizeYunit1%
		GuiControl,, Rotate, %Rotate1%
		GuiControl, ChooseString, Rotate, %Rotate1%
	} else {
		Msgbox,48, No ScreenOverlay parameters found!, Error: Cannot find ScreenOverlay parameters in %kmlcoordfile%.
	}
}

GuiDropFiles:
  Loop, parse, A_GuiEvent, `n
  {
	SelectedFile := A_LoopField
	Gosub OpenFile
	Break
  }
return

WM_MOUSEMOVE() {
    static CurrControl, PrevControl, _TT  ; _TT is kept blank for use by the ToolTip command below.
    CurrControl := A_GuiControl
    If (CurrControl <> PrevControl and not InStr(CurrControl, " "))
    {
        ToolTip  ; Turn off any previous tooltip.
        SetTimer, DisplayToolTip, 1000
        PrevControl := CurrControl
    }
    return

    DisplayToolTip:
    SetTimer, DisplayToolTip, Off
    If !(RegExReplace(CurrControl,"[a-zA-Z0-9_]"))	; check to only do next line if CurrControl is a well formed variable name, to avoid errors.
	ToolTip % %CurrControl%_TT  ; The leading percent sign tell it to use an expression.
    SetTimer, RemoveToolTip, 8000
    return

    RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
    return
}

reload:
  Reload
return

AddWindow:
Run, %A_ScriptFullPath%
return

OnTop:
  Menu, context, ToggleCheck, %A_ThisMenuItem%
  Winset, AlwaysOnTop, Toggle, A
  OnTop := (OnTop - 1)**2	; toggle value 1/0
  RegWrite, REG_SZ, HKEY_CURRENT_USER, SOFTWARE\GoogleEarthScreenOverlay, OnTop, %OnTop%
return

GuiContextMenu:
  Menu, context, Show
return

GuiClose:
  SaveWinPos("GoogleEarthScreenOverlay")
ExitApp

About:
  Gui 2:Destroy
  Gui 2:+Owner
  Gui 1:+Disabled
  Gui 2:Font,Bold
  Gui 2:Add,Text,x+0 yp+10, Google Earth ScreenOverlay %version%
  Gui 2:Font
  Gui 2:Add,Text,xm yp+16, by David Tryse
  Gui 2:Add,Text,xm yp+22, A small program for adding screen overlay images to Google Earth.
  Gui 2:Font
  Gui 2:Add,Text,xm yp+22, License: GPLv2+
  Gui 2:Font
  Gui 2:Add,Text,xm yp+22, Check for updates here:
  Gui 2:Font,CBlue Underline
  Gui 2:Add,Text,xm gwebHome yp+15, http://earth.tryse.net
  Gui 2:Add,Text,xm gwebCode yp+15, http://googleearth-autohotkey.googlecode.com
  Gui 2:Font
  Gui 2:Add,Text,xm yp+24, For bug reports or suggestions email:
  Gui 2:Font,CBlue Underline
  Gui 2:Add,Text,xm gEmaillink yp+15, davidtryse@gmail.com
  Gui 2:Font
  Gui 2:Add,Button,gAboutOk Default w90 h60 yp-44 xm+260,&OK
  Gui 2:Show,,About: Google Earth ScreenOverlay
  Gui 2:+LastFound
  WinSet AlwaysOnTop
Return

webHome:
  Run, http://earth.tryse.net#programs,,UseErrorLevel
Return

webCode:
  Run, http://googleearth-autohotkey.googlecode.com,,UseErrorLevel
Return

webIM:
  Run, http://www.imagemagick.org/script/binary-releases.php#windows,,UseErrorLevel
Return

Emaillink:
  Run, mailto:davidtryse@gmail.com,,UseErrorLevel
Return

AboutOk:
2GuiClose:
2GuiEscape:
  Gui 1:-Disabled
  Gui 2:Destroy
return

SaveWinPos(HKCUswRegkey) {	; add SaveWinPos("my_program") in "GuiClose:" routine
  WinGetPos, X, Y, , , A  ; "A" to get the active window's pos.
  RegWrite, REG_SZ, HKEY_CURRENT_USER, SOFTWARE\%HKCUswRegkey%, WindowX, %X%
  RegWrite, REG_SZ, HKEY_CURRENT_USER, SOFTWARE\%HKCUswRegkey%, WindowY, %Y%
}

GetSavedWinPos(HKCURegkey) {	; add WinPos := GetSavedWinPos("my_program") before "Gui, Show, %WinPos%,.." command
  RegRead, WindowX, HKEY_CURRENT_USER, SOFTWARE\%HKCURegkey%, WindowX
  RegRead, WindowY, HKEY_CURRENT_USER, SOFTWARE\%HKCURegkey%, WindowY
  If ((WindowX+200) > A_ScreenWidth or (WindowY+200) > A_ScreenHeight or WindowX < 0 or WindowY < 0)
	return "Center"
  return "X" WindowX " Y" WindowY
}