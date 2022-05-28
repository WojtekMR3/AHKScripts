#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance off
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetControlDelay -1
SetBatchLines, -1
SetMouseDelay -1
SetKeyDelay -1

Global HudTitleColor := "c00FBFF" ; c + Hex value
Global reloadHotkey := "Home"
Global exitHotkey := "End"

Hotkey, ~%reloadHotkey%, Reload, On
Hotkey, ~%exitHotkey%, Exit, On

Global BtnNum := 0
Global AutoSSHotkey := "F1"
Global SSAstatus := 0
Global execCount := 0

Global hudCoords := "x0 y0"

Global IniSections := []
Global IniSections ["Singular"] 
:= { coords1: "x0 y0"
	,	color: "0x00FF00"
	,	inverse: 0
	,	radioBox: 1
	,	coords2: "x0 y0"
	,	actionHtk: "f1"
	,	htk: "f3"
	, 	delay: 40
	, 	exhaust: 180
	,	guiHudCoords: "x200 y100"
	, 	HUDfontSize: 18
	,	HUDtransparency: 70
	,	ShowScans: 0}
Global IniSections ["UhaczkaHotkeys"] := {}

cachePth = %A_ScriptFullPath%:Stream:$DATA
Global cachePath := cachePth
Global ini := ReadINI(cachePath)

if (!ini.Singular.count()) {
	ini.Singular := IniSections.Singular.Clone()
	ini.Singular.coords1 := IniSections.Singular.coords1
	ini.Singular.inverse := IniSections.Singular.inverse
	ini.Singular.radioBox := IniSections.Singular.radioBox
	ini.Singular.coords2 := IniSections.Singular.coords2
	ini.Singular.actionHtk := IniSections.Singular.actionHtk
	ini.Singular.htk := IniSections.Singular.htk
	ini.Singular.delay := IniSections.Singular.delay
	ini.Singular.exhaust := IniSections.Singular.exhaust
	ini.Singular.guiHudCoords := IniSections.Singular.guiHudCoords
	ini.Singular.HUDfontSize := IniSections.Singular.HUDfontSize
	ini.Singular.HUDtransparency := IniSections.Singular.HUDtransparency
	ini.Singular.ShowScans := IniSections.Singular.ShowScans
}

Global MainGui := "mainGui"

Gui, %MainGui%:Add, Button, w150 gSelectCoords vBtn1 Section , Amulet/Ring EQ OBS Coords
Gui, %MainGui%:Add, Text, vCoords1 W100 ys, x0 y0
Gui, %MainGui%:Add, Text, vCoordsColor1 W75 xs Section, 0x000000

if (ini["Singular"].inverse = 0) {
	Gui, %MainGui%:Add, CheckBox, vInverseCheck ys, If not
} else {
	Gui, %MainGui%:Add, CheckBox, vInverseCheck Checked ys, If not
}

if (ini["Singular"].radioBox = 1) {
	Gui, %MainGui%:Add, Radio, yp+27 xs gRadioHotkey vRadioMouse Checked Section, Mouse
	Gui, %MainGui%:Add, Radio, yp+30 gRadioHotkey vRadioHotkey xs, Hotkey
	
	Gui, %MainGui%:Add, Button, ys w133 gSelectCoords vBtn2 Section, Amulet/Ring Bar Coords
	Gui, %MainGui%:Add, Text, vCoords2 W80 ys, x0 y0
	Gui, %MainGui%:Add, Hotkey, vScriptHtk w75 xs Disabled, % ini["Singular"].actionHtk
} else if (ini["Singular"].radioBox = 0) {
	Gui, %MainGui%:Add, Radio, yp+27 xs gRadioHotkey vRadioMouse Section, Mouse
	Gui, %MainGui%:Add, Radio, yp+30 gRadioHotkey vRadioHotkey Checked xs, Hotkey
	
	Gui, %MainGui%:Add, Button, ys w133 gSelectCoords vBtn2 Section Disabled, Amulet/Ring Bar Coords
	Gui, %MainGui%:Add, Text, vCoords2 W80 ys Disabled, x0 y0
	Gui, %MainGui%:Add, Hotkey, vScriptHtk w75 xs, % ini["Singular"].actionHtk
}

Gui, %MainGui%:Add, Text, xs xp-65 Section, Script on/off hotkey:
Gui, %MainGui%:Add, Hotkey, gSetScriptHotkey vSwitchHtk w75 ys, F2

Gui, %MainGui%:Add, Text, xs Section, Delay:
Gui, %MainGui%:Add, Edit, gDelayEv vDelay w35 ys, % ini["Singular"].delay

Gui, %MainGui%:Add, Text, xs Section, Exhaust:
Gui, %MainGui%:Add, Edit, vExhaust w35 ys, % ini["Singular"].exhaust

Gui, %MainGui%:Add, Text, xs Section, HUD font size:
Gui, %MainGui%:Add, Edit, vHUDFontSize gHUDFontChange ys w35, % ini["Singular"].HUDfontSize
Gui, %MainGui%:Add, Text, xs Section, HUD transparency:
Gui, %MainGui%:Add, Slider, vTransSlider gTransEv ys, % ini["Singular"].HUDtransparency

if (ini["Singular"].ShowScans = 0) {
	Gui, %MainGui%:Add, CheckBox, xs gScansSwitch vShowScans, Show scans/s
} else {
	Gui, %MainGui%:Add, CheckBox, xs gScansSwitch vShowScans Checked, Show scans/s
}

Gui, %MainGui%:Add, Button, yp+30 xs gHelp w50 Section, Guide
Gui, %MainGui%:Add, StatusBar,, AutoSSa by Frost

Gui, %MainGui%:Margin , 10, 10
Gui, %MainGui%:Show, AutoSize xCenter

	Global HUD := CreateHWND()
	Gui %HUD%:Color, 000000
	Gui %HUD%:Font, s16 w600
	Random, rand, 0, 10**17
	Global scriptName := StrReplace(A_ScriptName, .ahk, "")
	Gui %HUD%:Add, Text, vHudTitle %HudTitleColor%, %scriptName%
	Gui %HUD%:Add, Text, vHudHtk cWhite Section, F5:
	Gui %HUD%:Add, Text, vStatus cRed ys, Off
	Gui %HUD%:Add, Text, vScans cWhite xs w150 Section, Scans/s: 0
	Gui %HUD%:Show, % "Hide" "X" 50 " Y" 50 , %HUD%
	DetectHiddenWindows, on
	WinSet, TransColor, 000001 180, %HUD%
	DetectHiddenWindows, off
	OnMessage(0x0201, "WM_LBUTTONDOWN")

; Load values from store
GuiControl, %MainGui%:Text, Coords1, % ini["Singular"].coords1
GuiControl, %MainGui%:Text, CoordsColor1, % ini["Singular"].color
GuiControl, %MainGui%:Text, Coords2, % ini["Singular"].coords2

GuiControl, %MainGui%:Text, SwitchHtk, % ini["Singular"].htk
switchHotkey := ini["Singular"].htk
Hotkey, ~%switchHotkey%, AutoSSHandler, On
hudTxt := replaceSpecialChars(switchHotkey) . ":"
GuiControl, %HUD%:Text, HudHtk, %hudTxt%
AutoSSHotkey := switchHotkey

if (StrLen(ini["Singular"].guiHudCoords) = 3) {
	ini.Singular.guiHudCoords := "x10 y10"
}
Gui %HUD%:Show, % "Hide" ini["Singular"].guiHudCoords ,%HUD%

if (ini["Singular"].ShowScans = 0) {
	ToggleScans := 0
} else {
	ToggleScans := 1
	SetTimer, ShowScans, 1000
}

redrawGUI()

SetTimer, isTibiaActive, 50
OnExit("SaveCache")
return

Reload:
	Reload
return

Exit:
	ExitApp
return

mainGuiGuiClose:
	ExitApp
return

SetScriptHotkey:
	Hotkey, ~%AutoSSHotkey%, AutoSSHandler, Off
	GuiControlGet, hotkey, %MainGui%:, SwitchHtk
	Hotkey, ~%hotkey%, AutoSSHandler, On
	hudTxt := replaceSpecialChars(hotkey) . ":"
	GuiControl, %HUD%:Text, HudHtk, %hudTxt%
	AutoSSHotkey := hotkey
	redrawGUI()
Return

AutoSSHandler:
	ssa := ""
	(SSAstatus:=!SSAstatus) ? ssa := "On" : ssa := "Off"
	color := statusToColor(ssa)
	Gui, %HUD%:Font, %color%
	GuiControl, %HUD%:Font, Status
	GuiControl, %HUD%:Text, Status, %ssa%
	GuiControlGet, delay, %MainGui%:, Delay
	SetTimer, AutoSS, % (Toggle:=!Toggle) ? delay : "Off"
Return

SelectCoords:
	num := SubStr(A_GuiControl,A_GuiControl.length - 1)
	BtnNum := num
	WinActivate, Tibia -
	SetTimer, WatchCursor, 20
	return
return

WatchCursor:
	CoordMode, Mouse, Relative
	MouseGetPos, MouseX, MouseY
	PixelGetColor, clr, %MouseX%, %MouseY%
	ToolTip, `Press Space to save coordinates`n`x: %MouseX% y: %MouseY% color: %clr%`
	
	if (GetKeyState("Space")) {
		MsgBox, , , %MouseX% %MouseY%, 0.3
		BlockInput, Mouse
		GuiControl, %MainGui%:Text, Coords%BtnNum%, x%MouseX% y%MouseY%
		if (BtnNum = 1) {
			GuiControl, %MainGui%:Text, CoordsColor%BtnNum%, %clr%
		}
		SetTimer, WatchCursor, Off
		ToolTip
	}
return

AutoSS:
	if !(WinActive("Tibia -")) {
		return
	}
	GuiControlGet, Coords, %MainGui%:, Coords1
	coords := StripXYcoords(Coords)
	x0 := coords[1]
	y0 := coords[2]
	GuiControlGet, tColor , %MainGui%:, CoordsColor1
	GuiControlGet, inverse , %MainGui%:, InverseCheck
	
	PixelGetColor, obsColor, %x0%, %y0%
	execCount++
	GuiControlGet, radioMouse, %MainGui%:, RadioMouse
	if (inverse = 0) {
		if (tColor = obsColor) {
			if (radioMouse = 1) {
				GuiControlGet, Coords, %MainGui%:, Coords2
				ControlClick, %Coords%, Tibia -,,Left
			} else {
				GuiControlGet, htk, %MainGui%:, ScriptHtk
				ControlSend,, {%htk%}, Tibia -
			}
			GuiControlGet, exh , %MainGui%:, Exhaust
			Sleep %exh%
		}
	} else if (inverse = 1) {
		if (tColor != obsColor) {
			if (radioMouse = 1) {
				GuiControlGet, Coords, %MainGui%:, Coords2
				ControlClick, %Coords%, Tibia -,,Left
			} else {
				GuiControlGet, htk, %MainGui%:, ScriptHtk
				ControlSend,, {%htk%}, Tibia -
			}
			GuiControlGet, exh , %MainGui%:, Exhaust
			Sleep %exh%
		}
	}
return

RadioHotkey:
	GuiControlGet, radioMouse, %MainGui%:, RadioMouse
	GuiControlGet, radioHotkey, %MainGui%:, RadioHotkey
	
	if (radioMouse = 1) {
		GuiControl, %MainGui%:Enable, Btn2
		GuiControl, %MainGui%:Enable, Coords2
		
		GuiControl, %MainGui%:Disable, ScriptHtk
		
	} else if (radioHotkey = 1) {
		GuiControl, %MainGui%:Enable, ScriptHtk
	
		GuiControl, %MainGui%:Disable, Btn2
		GuiControl, %MainGui%:Disable, Coords2
		
	}
return

DelayEv:
	if (SSAstatus = 1) {
		SetTimer, AutoSS, Off
		GuiControlGet, delay, %MainGui%:, Delay
		SetTimer, AutoSS, %delay%
	}
return

HUDFontChange:
	redrawGUI()
return

TransEv:
	GuiControlGet, val, %MainGui%:, TransSlider
	transVal := val * 2.55
	DetectHiddenWindows, on
	WinSet, TransColor, 000001 %transVal%, %HUD%
	DetectHiddenWindows, off
return

Help: 
MsgBox,
(
1. If not: equip/use eq/food/spell if color doesn't match, good for auto healing / auto sio / trap.

2. Delay: Delay after each pixel color check, less delay - quicker the script - more cpu usage. Recommended value 10-100.

3. Exhaust: Wait time after each succesful action usage. Value ~180 for ssa/might ring/eq. Value ~500-1000 for healing.

4. Show scans: Shows amount of pixel checks for each second.

5. Home - Reload all scripts.

6. End - Exit all scripts.
)
return

ScansSwitch:
	SetTimer, ShowScans, % (ToggleScans:=!ToggleScans) ? 1000 : "Off"
	redrawGUI()
return

ShowScans:
	GuiControl, %HUD%:Text, Scans, Scans/s: %execCount%
	execCount := 0
return

redrawGUI() {
	SetTimer, isTibiaActive, Off
	DetectHiddenWindows, on
	WinGetPos, x, y,,, ahk_id %HUD%
	DetectHiddenWindows, off
	
	Gui, %HUD%:Destroy
	
	HUD := CreateHWND()
	Gui %HUD%:Color, 000000
	
	GuiControlGet, fontSize, %MainGui%:, HUDFontSize
	Gui %HUD%:Font, s%fontSize% w600
	
	;scriptName := StrReplace(A_ScriptName, .ahk, "")
	Gui %HUD%:Add, Text, vHudTitle %HudTitleColor%, %scriptName%
	
	htk := replaceSpecialChars(AutoSSHotkey)
	Gui %HUD%:Add, Text, vHudHtk cWhite section, %htk%:
	
	ssa := ""
	(SSAstatus) ? ssa := "On" : ssa := "Off"
	clr := statusToColor(ssa)
	Gui %HUD%:Add, Text, vStatus %clr% ys, %ssa%

	GuiControlGet, val, %MainGui%:, ShowScans
	if (val = 1) {
		width := fontSize * 13 * 0.66
		Gui %HUD%:Add, Text, vScans cWhite xs Section w%width%, Scans/s: 0
	}
	
	Gui %HUD%:Show, % "Hide" "X" x " Y" y , %HUD%
	
	GuiControlGet, val, %MainGui%:, TransSlider
	transVal := val * 2.55
	DetectHiddenWindows, on
	WinSet, TransColor, 000001 %transVal%, %HUD%
	DetectHiddenWindows, off
	OnMessage(0x0201, "WM_LBUTTONDOWN")
	
	SetTimer, isTibiaActive, On
}

CreateHWND() {
	Gui New, +AlwaysOnTop +Border -Caption +HwndhGui +ToolWindow +E0x08000000 +Hwndhwnd
	return hwnd
}

WM_LBUTTONDOWN()
{
	If (A_Gui = HUD) {
		PostMessage, 0xA1, 2
		Return 0
	}
}

isTibiaActive() {
	WinGetActiveTitle, ActWTitle
	if (WinActive("Tibia") or WinActive("ahk_class AutoHotkeyGUI")) and !(WinExist(HUD)) and !(InStr(ActWTitle, "Google Chrome")) {
		Gui %HUD%:Show, NoActivate
	} else if !(WinActive("Tibia") or WinActive("ahk_class AutoHotkeyGUI")) or InStr(ActWTitle, "Google Chrome") {
		Gui %HUD%:Hide
	}
}

statusToColor(status) {
	if (status = "Off") { 
		return statusColor := "cRed" 
	} else if (status = "On") { 
		return statusColor := "c03AC13"
	}
}

replaceSpecialChars(str) {
	str := StrReplace(str, "+", "Shift + ")
	str := StrReplace(str, "^", "Ctrl + ")
	str := StrReplace(str, "!", "Alt + ")
	return str
}

StripXYcoords(coords) {
  coords := StrReplace(coords, "x", "")
  coords := StrReplace(coords, "y", "")
  carray := StrSplit(coords, A_Space)
  return carray
}

SaveCache(ExitReason, ExitCode)
{
	GuiControlGet, coords, %MainGui%:, Coords1
	IniSections["Singular"].coords1 := coords
	GuiControlGet, color , %MainGui%:, CoordsColor1
	IniSections["Singular"].color := color
	GuiControlGet, val , %MainGui%:, InverseCheck
	IniSections["Singular"].inverse := val
	
	GuiControlGet, val, %MainGui%:, RadioMouse
	IniSections["Singular"].radioBox := val
	
	GuiControlGet, coords , %MainGui%:, Coords2
	IniSections["Singular"].coords2 := coords
	
	GuiControlGet, val , %MainGui%:, ScriptHtk
	IniSections["Singular"].actionHtk := val
	
	GuiControlGet, htk , %MainGui%:, SwitchHtk
	IniSections["Singular"].htk := htk
	
	GuiControlGet, delay , %MainGui%:, Delay
	IniSections["Singular"].delay := delay
	
	GuiControlGet, exh , %MainGui%:, Exhaust
	IniSections["Singular"].exhaust := exh

	GuiControlGet, val , %MainGui%:, HUDFontSize
	IniSections["Singular"].HUDfontSize := val
	GuiControlGet, transVal , %MainGui%:, TransSlider
	IniSections["Singular"].HUDtransparency := transVal
	GuiControlGet, val , %MainGui%:, ShowScans
	IniSections["Singular"].ShowScans := val
	
	;Gui Hud
	If !(WinExist(HUD)) {
		SetTimer, isTibiaActive, Off
		DetectHiddenWindows, on
	}
	WinGetPos, x, y,,, ahk_id %HUD%
	hudCoords := "x" . x . " y" y
	IniSections["Singular"].guiHudCoords := hudCoords
	WriteINI(IniSections, cachePath)
}

;-------------------------------------------------------------------------------
WriteINI(ByRef Array2D, INI_File) { ; write 2D-array to INI-file
;-------------------------------------------------------------------------------
    for SectionName, Entry in Array2D {
        Pairs := ""
        for Key, Value in Entry
            Pairs .= Key "=" Value "`n"
        IniWrite, %Pairs%, %INI_File%, %SectionName%
    }
}



;-------------------------------------------------------------------------------
ReadINI(INI_File) { ; return 2D-array from INI-file
;-------------------------------------------------------------------------------
    Result := []
    IniRead, SectionNames, %INI_File%
    for each, Section in StrSplit(SectionNames, "`n") {
        IniRead, OutputVar_Section, %INI_File%, %Section%
        for each, Haystack in StrSplit(OutputVar_Section, "`n")
            RegExMatch(Haystack, "(.*?)=(.*)", $)
            , Result[Section, $1] := $2
    }
    return Result
}

/*