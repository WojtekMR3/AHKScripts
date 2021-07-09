#NoEnv
#SingleInstance off  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetControlDelay -1

Version := "1.0"
Author := "Frostspiked"
Global IniSections := []
Global IniSections ["Coordinates"] := {}
Global IniSections ["Hotkeys"] := {}

cachePth = %A_ScriptFullPath%:Stream:$DATA
Global cachePath := cachePth
Global ini := ReadINI(cachePath)
Global Coordinates := []

If (!ini.Hotkeys.Count())
{
	ini["Hotkeys"] := IniSections["Hotkeys"].Clone()
}

If (!ini.Coordinates.Count())
{
	ini["Coordinates"] := IniSections["Coordinates"].Clone()
}

OnMessage(0x111,"WM_COMMAND")

Gui, Add, Text, yp+40, Coordinates

; Create coords GUI
Loop 9 {
  Gui, Add, Edit, xs vPos%A_Index% gUpdateCoords W75 Section, x0 y0
  Gui, Add, Button, w35 vPosEvent%A_Index% gSelectCoords ys, Pos
}

Gui, Add, Text, xs yp+40, AutoLoot Hotkeys.
Gui, Add, Button, w40 gAdd_htk Section, Add
Gui, Add, Button, w60 gRem_htk ys, Remove

Gui, Add, StatusBar,,
SB_SetText("by " . Author . " v" . Version, 1)

; Load values from store
For num, htk in ini["Hotkeys"] {
		Gui, Add, Hotkey, xs vTrigger_htk%num% gTrigger_htk, %htk%
		Hotkey, ~%htk%, Zbieraczka, On
		savedHK%num% = %htk%
}

For num, coordPair in ini["Coordinates"] {
  GuiControl, Text, Pos%num%, %coordPair%
}

; Remove '.exe' from title
Title := StrReplace(A_ScriptName, .exe, " ")
Title = %Title%
Gui, Show, AutoSize, %Title%

OnExit("SaveCache")
return

SaveCache(ExitReason, ExitCode)
{
	; Retrieve all hotkey binds.
	Loop % ini["Hotkeys"].Count() {
		GuiControlGet, htk ,, Trigger_htk%A_Index%
		; Create array and save it to db.
		IniSections["Hotkeys"].Push(htk)
	}

  Loop 9 {
		GuiControlGet, OutputVar, , Pos%A_Index%
		; Create array and save it to db.
		IniSections["Coordinates"].Push(OutputVar)
	}

	WriteINI(IniSections, cachePath)
}

GuiClose:
	ExitApp
return

Add_htk:
	ini["Hotkeys"].Push("F2")
	ln := ini["Hotkeys"].Count()
	Gui, Add, Hotkey, xs vTrigger_htk%ln% gTrigger_htk
	Gui, Show, AutoSize
return

Rem_htk:
	ini["Hotkeys"].Pop()
	Reload
return

Trigger_htk:
	If %A_GuiControl%  in +,^,!,+^,+!,^!,+^!            ;If the hotkey contains only modifiers, return to wait for a key.
		return
	num := SubStr(A_GuiControl,A_GuiControl.length - 1)
	If (savedHK%num%) { ;If a hotkey was already saved...
		Hotkey,% savedHK%num%, Zbieraczka, Off        ;     turn the old hotkey off
		savedHK := false                    ;     add the word 'OFF' to display in a message.
 	}
	Keys := % %A_GuiControl%
	Hotkey, ~%Keys%, Zbieraczka, On
	savedHK%num% := %A_GuiControl%
	WinActivate, Program Manager ; lose focus
return

SelectCoords:
	WinActivate, Tibia 
  Global numx := SubStr(A_GuiControl,A_GuiControl.length - 1)
	SetTimer, WatchCursor, 20
	return
return

UpdateCoords:
  Loop 9 {
    GuiControlGet, OutputVar, , Pos%A_Index%
    Coordinates[A_Index] := OutputVar
  }

  For key, val in Coordinates
      ;MsgBox % val

return

Zbieraczka:
  if !(WinActive("Tibia -")) {
    return
  }
  sleep 35
  BlockInput On
  SendInput, {Shift down}
  sleep 1

  Loop 9 {
    ControlClick, Coordinates[A_Index], Tibia ,,Right
  }

  SendInput, {Shift up}
  BlockInput, Off
  While(getKeyState("Shift")){
      SendInput, {Shift up}
      sleep 30
  }
return

WatchCursor:
	CoordMode, Mouse, Relative
  
	MouseGetPos, xpos, ypos
	ToolTip, `Select position`n`x: %xpos% y: %ypos%`
	
	if (GetKeyState("LButton")) {
		MsgBox, , , %xpos% %ypos%, 0.3
		BlockInput, Mouse
		GuiControl, Text, Pos%numx%, x%xpos% y%ypos%
		SetTimer, WatchCursor, Off
		ToolTip
		;WinActivate, %A_ScriptName%
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


; INI MAKER
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