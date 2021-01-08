#Include lib/obj2str.ahk
#Include lib/iniMaker.ahk

#NoEnv
#SingleInstance off  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetControlDelay -1

programName := "Uhaczka by Frostspiked"
Global IniSections := []
Global IniSections ["Singular"] 
:= { pos: 0
	 , uh_htk: "f3"
	 , bind_htks: 3}
Global IniSections ["Uhaczka Hotkeys"] := {}

pth = %A_ScriptFullPath%:Stream:$DATA
Global ini := ReadINI(pth)

Global Bind_htks := ini["Singular"].bind_htks
If (!Bind_htks) {
	Bind_htks := 3
}

ln := % ini["Uhaczka Hotkeys"].Length()
If ln = 0
{
	ini["Uhaczka Hotkeys"] := IniSections ["Uhaczka Hotkeys"]
}

OnMessage(0x111,"WM_COMMAND")

;Gui, Show, X200 Y200 W300 H300, %programName%
Gui, Add, Button, w133 gSelectCoords, Wybierz pozycję celu
Gui, Add, Text, vTankerPos W100, x0 y0
Gui, Add, Text,, Hotkey UHa ; The ym option starts a new column of controls.
Gui, Add, Hotkey, vUH_hotkey, F1
Gui, Add, Button, w133 gAdd_htk, Dodaj hotkey'a
Gui, Add, Button, w133 gRem_htk, Usuń hotkey'a

Gui, Add, Text,, Hotkeye odpalające uhaczkę.
;Loop %Bind_htks% {
    ;Gui, Add, Hotkey, vTrigger_htk%A_Index% gTrigger_htk, F2	
;}

For key, value in ini["Uhaczka Hotkeys"]
		Gui, Add, Hotkey, vTrigger_htk%key% gTrigger_htk, %value%

;Gui, Add, Picture, x0 y0 +BackgroundTrans, insta.png
;Gui, Add, Picture, x0 y0 +BackgroundTrans, %A_ScriptDir%\bg\gray.jpg

; Load values from store

GuiControl, Text, TankerPos, % ini["Singular"].pos
GuiControl, Move, TankerPos, W300
GuiControl, Text, UH_hotkey, % ini["Singular"].uh_htk
Gui, Show, AutoSize, %programName%

OnExit("SaveCache")
return

SaveCache(ExitReason, ExitCode)
{
	GuiControlGet, TankerPos ,, TankerPos
	IniSections["Singular"].pos := TankerPos
	GuiControlGet, htk ,, UH_hotkey
	IniSections["Singular"].uh_htk := htk
	IniSections["Singular"].bind_htks := Bind_htks

	; Retrieve all hotkey binds.
	Loop % ini["Uhaczka Hotkeys"].Length() {
		GuiControlGet, htk ,, Trigger_htk%A_Index%
		; Create array and save it to db.
		IniSections["Uhaczka Hotkeys"].Push(htk)
	}

	path = %A_ScriptFullPath%:Stream:$DATA
	WriteINI(IniSections, path)
}

GuiClose:
	ExitApp
return

Add_htk:
	ini["Uhaczka Hotkeys"].Push("F2")
	Bind_htks++
	ln := ini["Uhaczka Hotkeys"].Length()
	Gui, Add, Hotkey, vTrigger_htk%ln% gTrigger_htk, F2
	Gui, Show, AutoSize
return

Rem_htk:
	Bind_htks--
	ini["Uhaczka Hotkeys"].Pop()
	;Gui, Show, AutoSize
	;WinSet, Redraw
	Reload
return

Trigger_htk:
	If %A_GuiControl%  in +,^,!,+^,+!,^!,+^!            ;If the hotkey contains only modifiers, return to wait for a key.
		return
	num := SubStr(A_GuiControl,A_GuiControl.length - 1)
	If (savedHK%num%) { ;If a hotkey was already saved...
		Hotkey,% savedHK%num%, Uhaczka, Off        ;     turn the old hotkey off
		savedHK := false                    ;     add the word 'OFF' to display in a message.
 	}
	Keys := % %A_GuiControl%
	Hotkey, ~%Keys%, Uhaczka, On
	savedHK%num% := %A_GuiControl%
	WinActivate, Program Manager ; lose focus
return

Uhaczka:
	sleep 35 ; fix for low
	GuiControlGet, coords ,, TankerPos
	GuiControlGet, UH_Htk ,, UH_hotkey
	ControlFocus,, Tibia -
	ControlSend,, {%UH_Htk% down}, Tibia -
	SetControlDelay -1
	ControlClick, %coords%, Tibia -,,Left
return

SelectCoords:
	WinActivate, Tibia 
	SetTimer, WatchCursor, 20
	return
return

WatchCursor:
	CoordMode, Mouse, Relative
	MouseGetPos, xpos, ypos
	ToolTip, `Select position`n`x: %xpos% y: %ypos%`
	
	if (GetKeyState("LButton")) {
		MsgBox, , , %xpos% %ypos%, 0.3
		BlockInput, Mouse
		GuiControl, Text, TankerPos, x%xpos% y%ypos%
		GuiControl, Move, TankerPos, W300
		SetTimer, WatchCursor, Off
		ToolTip
		WinActivate, %programName%
	}
return

WM_Command(wP)
{
  Global tray_icon_go, tray_icon_paused
  Static Suspend = 65305, Pause = 65306

  If (wP = Pause)	;select OR deselect?
  {
    If ! A_IsPaused												;Paused --> NOT Paused ?
      Menu, TRAY, Icon, %tray_icon_paused%	;,,1
    Else ;If A_IsPaused ?									   ;NOT Paused --> Paused ?
      Menu, TRAY, Icon, %tray_icon_go%	;,,1
  }
  Else ;(wP <> Pause)	(ie just R-CLICK systray icon)
  {
    If A_IsPaused
      Menu, TRAY, Icon, %tray_icon_paused%	;,,1		;Menu, Tray, Icon, Shell32.dll, 110, 1 <-- maybe should use dll icons?
  }
}