#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetControlDelay -1

programName := "Trener Kukieł"

Gui, Show, X200 Y200 W300 H300, %programName%
Gui, Add, Button, w133 gSelectCoords, Wybierz pozycję kukły
Gui, Add, Text, vDummyPos, x0 y0
Gui, Add, Text,, Wybierz hotkey rózgi ; The ym option starts a new column of controls.
Gui, Add, DropDownList, vChosenHotkey gChosenHotkey, F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12
;Gui, Add, Hotkey, vChosenHotkey
Gui, Font, c6b6b6b
Gui, Add, Text, vScrStatus, Status: Idle
Gui, Add, Button, w100 gStartMain, Start
Gui, Add, Button, w100 gStopMain, Stop
Gui, Font, c000000
Gui, Add, Text, ym vExwpAmount, Ilość strzałow: 500

; Load values from store
IniRead, OutputVar, %A_ScriptFullPath%:Stream:$DATA, Options, DummyPosition, x0 y0
GuiControl, Text, DummyPos, %OutputVar%
GuiControl, Move, DummyPos, W300
IniRead, OutputVar, %A_ScriptFullPath%:Stream:$DATA, Options, WpHotkey, 1
GuiControl, Choose, ChosenHotkey, %OutputVar%

return

SelectCoords:
	SetTimer, WatchCursor, 20
	return
return

StartMain:
	Gui, Font, c098c00
	GuiControl, Font, ScrStatus
	GuiControl, Text, ScrStatus, Status: Running
	GuiControl, Move, ScrStatus, W300
	Gosub, Training
	tura := (1000*2)
	ilosc_tur := 500
	exwp := (ilosc_tur*tura)
	SetTimer, Training, %exwp%
	SetTimer, DecrementExwp, %tura%
	return
return

StopMain:
	Gui, Font, c6b6b6b
	GuiControl, Font, ScrStatus
	GuiControl, Text, ScrStatus, Status: Idle
	GuiControl, Move, ScrStatus, W300
	SetTimer, Training, Off
	SetTimer, DecrementExwp, Off
	return
return

GuiClose:
	ExitApp
return

Training:
    global shots := 500
	GuiControlGet, coords ,, DummyPos
	GuiControlGet, hotkeyWeapon ,, ChosenHotkey
	ControlFocus,, Tibia -
	ControlSend,, {%hotkeyWeapon% down}, Tibia -
	sleep 50
	ControlClick, %coords%, Tibia -,,Left
return

WatchCursor:
	CoordMode, Mouse, Screen 
	MouseGetPos, xpos, ypos
	ToolTip, `Select training dummy position`n`x: %xpos% y: %ypos%`
	
	if (GetKeyState("LButton")) {
		MsgBox, , , %xpos% %ypos%, 0.3
		BlockInput, Mouse
		GuiControl, Text, DummyPos, x%xpos% y%ypos%
		GuiControl, Move, DummyPos, W300
		SetTimer, WatchCursor, Off
		ToolTip
		WinActivate, %programName%
		GuiControlGet, coords ,, DummyPos
		IniWrite, %coords%, %A_ScriptFullPath%:Stream:$DATA, Options, DummyPosition
	} else {

	}
return

DecrementExwp:
 shots--
 GuiControl, Text, ExwpAmount, Ilość strzałów %shots%
return

ChosenHotkey:
	GuiControlGet, wphotkey ,, ChosenHotkey
	IniWrite, %wphotkey%, %A_ScriptFullPath%:Stream:$DATA, Options, WpHotkey
	return
return
