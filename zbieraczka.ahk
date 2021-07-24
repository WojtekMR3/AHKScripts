#NoEnv
#SingleInstance off  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetControlDelay -1
SetDefaultMouseSpeed, 0
SetMouseDelay, -1

SetWorkingDir %A_ScriptDir%

if not A_IsAdmin
{
    try
    {
      ;Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
    }
    ;ExitApp
}
;#Include obj2str.ahk
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

;Gui, Add, Text, vPos0 gAutoCoords, AutoLoot Hotkeys.
Gui, Add, Edit, xs vPos0 gAutoCoords W75 Section hide, x0 y0
Gui, Add, Button, w40 vPosEvent0 gSelectCoords Section, AutoCoords

Gui, Add, Text, xs yp+40, AutoLoot Hotkeys.
Gui, Add, Button, w40 gAdd_htk Section, Add
Gui, Add, Button, w60 gRem_htk ys, Remove

Gui, Add, StatusBar,,
SB_SetText("by " . Author . " v" . Version, 1)

; Load values from store
For num, htk in ini["Hotkeys"] {
		Gui, Add, Hotkey, xs vTrigger_htk%num% gTrigger_htk, %htk%
		Hotkey, ~%htk%, Zbieraczka, On
    ini["Hotkeys"][num] := htk
}

For num, coordPair in ini["Coordinates"] {
  GuiControl, Text, Pos%num%, %coordPair%
  Coordinates[num] := coordPair
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

; Only triggers on hotkey change, if htk is same it doesn't trigger.
Trigger_htk:
	If %A_GuiControl%  in +,!,^,+^,+!,^!,+^!            ;If the hotkey contains only modifiers, return to wait for a key.
		return
	num := SubStr(A_GuiControl,A_GuiControl.length - 1)
  Key := % %A_GuiControl%
  SetZbieraczkaHotkey(num, Key)
return

#If ctrl := HotkeyCtrlHasFocus()
  *Delete::
  *Escape::
  *Space::
  *Tab::
     modifier := ""
    If GetKeyState("Shift","P")
      modifier .= "+"
    If GetKeyState("Ctrl","P")
      modifier .= "^"
    If GetKeyState("Alt","P")
      modifier .= "!"
    num := SubStr(ctrl,ctrl.length - 1)
    Key := modifier SubStr(A_ThisHotkey,2)
    GuiControl,,%ctrl%, % Key
    SetZbieraczkaHotkey(num, Key)
  return
#If

HotkeyCtrlHasFocus() {
 GuiControlGet, ctrl, Focus       ;ClassNN
 If InStr(ctrl,"hotkey") {
  GuiControlGet, ctrl, FocusV     ;Associated variable
  Return, ctrl
 }
}

SetZbieraczkaHotkey(num, key) {
  ln := ini["Hotkeys"].Count()
  Loop % ln {
    if (key = ini["Hotkeys"][A_Index]) {
      dup := A_Index
      ; If duplicate hotkey is blank, do not alert it to user
      if (Trigger_htk%dup% == "") {
        break
      }
      Loop,6 {
        GuiControl,% "Disable" b:=!b, Trigger_htk%dup%   ;Flash the original hotkey to alert the user.
        Sleep,120
      }
      GuiControl,,Trigger_htk%num%,% Trigger_htk%num% :=""       ;Delete the hotkey and clear the control.
      break
    }
  }

	If (ini["Hotkeys"][num]) { ;If a hotkey was already saved...
    oldHtk := ini["Hotkeys"][num]
		Hotkey, %oldHtk%, Zbieraczka, Off        ;     turn the old hotkey off
		ini["Hotkeys"][num] := false        ;     add the word 'OFF' to display in a message.
 	}

  if (!dup) {
    Hotkey, ~%Key%, Zbieraczka, On
    ini["Hotkeys"][num] := key
    ;savedHK%num% := key
    WinActivate, Program Manager ; lose focus
  }
}

SelectCoords:
	WinActivate, Tibia 
  Global numx := SubStr(A_GuiControl,A_GuiControl.length - 1)
  ;Global numx := A_GuiControl
	SetTimer, WatchCursor, 20
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
  ;MsgBox, , , Zbieracz, 0.3
  ;WinActivate, Program Manager
  if !(WinActive("Tibia -")) {
    return
  }

  BlockInput, On
  MouseGetPos, xpos, ypos

  SendInput {Shift Down}
  ; If sleep is less than 1, theres high chance tibia wont detect shift keypress before mouse clicks.
  ;Sleep 5
  Loop 9 {
    coords := Coordinates[A_Index]
    coords := StrReplace(coords, "x", "")
    coords := StrReplace(coords, "y", "")
    carray := StrSplit(coords, A_Space)
    cx := carray[1]
    yx := carray[2]
    ;Shift + Right
    ;SendInput +{Click %cx% %yx% Right}
    
    ;SendInput {Click %cx% %yx% Right}
    ControlClick, x%cx% y%yx%, Tibia ,,Right
    ;SendInput {Shift Down}{Click %cx% %yx% Right}{Shift Up}
    
  }
  ;Sleep 5
  SendInput {Shift Up}

  SendInput {Click %xpos% %ypos% 0}
  BlockInput, Off
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

AutoCoords:
	GuiControlGet, center, , Pos0
  coords := center
  coords := StrReplace(coords, "x", "")
  coords := StrReplace(coords, "y", "")
  carray := StrSplit(coords, A_Space)
  x0 := carray[1]
  y0 := carray[2]
  1sqm := y0-28
  1sqm := Round(1sqm/5.5)
  ;MsgBox, , ,c is: %1sqm%, 0.8
  x1 := x0
  y1 := y0

  x2 := x0
  y2 := y0-1sqm

  x3 := x0+1sqm
  y3 := y0-1sqm

  x4 := x0+1sqm
  y4 := y0

  x5 := x0+1sqm
  y5 := y0+1sqm

  x6 := x0
  y6 := y0+1sqm

  x7 := x0-1sqm
  y7 := y0+1sqm

  x8 := x0-1sqm
  y8 := y0

  x9 := x0-1sqm
  y9 := y0-1sqm

  GuiControl, Text, Pos1, x%x1% y%y1%
  GuiControl, Text, Pos2, x%x2% y%y2%
  GuiControl, Text, Pos3, x%x3% y%y3%

  GuiControl, Text, Pos4, x%x4% y%y4%
  GuiControl, Text, Pos5, x%x5% y%y5%
  GuiControl, Text, Pos6, x%x6% y%y6%

  GuiControl, Text, Pos7, x%x7% y%y7%
  GuiControl, Text, Pos8, x%x8% y%y8%
  GuiControl, Text, Pos9, x%x9% y%y9%
Return

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