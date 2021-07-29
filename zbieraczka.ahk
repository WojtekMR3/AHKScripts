#NoEnv
#SingleInstance off  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetControlDelay -1
SetKeyDelay, 0
SetDefaultMouseSpeed, 0
SetMouseDelay, -1

SetWorkingDir %A_ScriptDir%

/*
; If ever wanted to use Send {Click} fnc
if not A_IsAdmin
{
    try
    {
      Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
    }
    ExitApp
}
*/

Version := "1.0"
Author := "Frostspiked"
Global IniSections := []
Global IniSections ["Coordinates"] := {}
Global IniSections ["Hotkeys"] := {}

Global guinum := 1

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

;Gui, Add, Text ,cRed border h0 W200 hide,
Gui, Add, Text, yp+40, Coordinates

; Create coords GUI
Loop 9 {
  Gui, Add, Edit, xs vPos%A_Index% gUpdateCoords W75 Section, x0 y0
  Gui, Add, Button, w35 vPosEvent%A_Index% gSelectCoords ys, Pos
}

;Gui, Add, Text, vPos0 gAutoCoords, AutoLoot Hotkeys.
Gui, Add, Edit, xs vPos0 gAutoCoords W75 Section hide, x0 y0
Gui, Add, Button, xs gCoordArray W75 Section, CoordArray
Gui, Add, Button, w40 vPosEvent0 gSelectCoords Section, AutoCoords

Gui, Add, Text, xs yp+40, AutoLoot Hotkeys.
Gui, Add, Button, w40 gAdd_htk Section, Add
Gui, Add, Button, w60 gRem_htk ys, Remove

Gui, Add, StatusBar,,
SB_SetText("by " . Author . " v" . Version, 1)

; Remove '.exe' from title
Title := StrReplace(A_ScriptName, .exe, " ")
Title = %Title%

; Load values from store
For num, htk in ini["Hotkeys"] {
		Gui, Add, Hotkey, xs vTrigger_htk%num% gTrigger_htk, %htk%
		Hotkey, ~%htk%, Zbieraczka, On
    ini["Hotkeys"][num] := htk
}

Gui, Margin , 100, 0
Gui, Show, AutoSize xCenter, %Title%

For num, coordPair in ini["Coordinates"] {
  GuiControl, Text, Pos%num%, %coordPair%
  Coordinates[num] := coordPair
}

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

CoordArray:
  For key, val in Coordinates
    MsgBox % val
return

UpdateCoords:
  index := SubStr(A_GuiControl,A_GuiControl.length - 1)
  ;MsgBox, , , , 0.5
  
  GuiControlGet, OutputVar, , Pos%index%
  ;MsgBox, , , %index%: %OutputVar%, 0.5
  Coordinates[index] := OutputVar
  ;ShowCircle(index)
  

  ;For key, val in Coordinates
      ;MsgBox % val
/*
  
  ;Loop 9 {
    coords := Coordinates[index]
    coords := StrReplace(coords, "x", "")
    coords := StrReplace(coords, "y", "")
    carray := StrSplit(coords, A_Space)
    cx := carray[1]
    yx := carray[2]
  
    ;xx := x%A_Index%
    ;yy := y%A_Index%
    ;1sqm := y0-28
    ;1sqm := Round(1sqm/5.5)
    r := CalcR()
    hCircle%index% := makeCircle(0x00FF49, r, 2, 254, cx, yx)
    ;Sleep 250
  ;}
  MsgBox, , , %index%: %OutputVar%, 0.5
    Sleep 500
  ;Loop 9 {
    gui := hCircle%index%
    Gui %gui%: Hide
    ;MsgBox, %index%
    
  ;}
*/
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
  Sleep 5
  Loop 9 {
    coords := Coordinates[A_Index]
    coords := StrReplace(coords, "x", "")
    coords := StrReplace(coords, "y", "")
    carray := StrSplit(coords, A_Space)
    cx := carray[1]
    yx := carray[2]
    ;Shift + Right
    ;SendInput +{Click %cx% %yx% Right}
    
    ;Send {Click %cx% %yx% Right}
    ControlClick, x%cx% y%yx%, Tibia ,,Right
    
  }
  Sleep 5
  SendInput {Shift Up}

  Send {Click %xpos% %ypos% 0}
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
  Global  1sqm := Round(1sqm/5.5)

  x1row := x0-1sqm
  Loop 3 {
    imain := (A_Index*3)-3
    yrow := y0+(1sqm*A_Index)-(1sqm*2)
    Loop 3 {
      i := imain+A_Index
      x%i% := x1row+(A_Index*1sqm)-1sqm
      y%i% := yrow
    }
  }

  GuiControl, Text, Pos1, x%x5% y%y5%
  GuiControl, Text, Pos2, x%x2% y%y2%
  GuiControl, Text, Pos3, x%x3% y%y3%
  
  GuiControl, Text, Pos4, x%x6% y%y6%
  GuiControl, Text, Pos5, x%x9% y%y9%
  GuiControl, Text, Pos6, x%x8% y%y8%

  GuiControl, Text, Pos7, x%x7% y%y7%
  GuiControl, Text, Pos8, x%x4% y%y4%
  GuiControl, Text, Pos9, x%x1% y%y1%
/*
  Global guinum := 1
  Loop 9 {
    xx := x%A_Index%
    yy := y%A_Index%
    r := Round(1sqm/2.5)
    hCircle%A_Index% := makeCircle(0x00FF49, r, 2, 254, xx, yy)
    Sleep 125
  }
  Sleep 4000
  Loop 9 {
    gui := hCircle%A_Index%
    Gui %gui%: Hide
  }
 */

  Loop 9 {
    ShowCircle(A_Index)
    Sleep 125
  }

  Sleep 1000
  Loop 9 {
    Sleep 250
    gui := hCircle%index%
    Gui %gui%: Hide
  }
Return

makeCircle(color, r := 150, thickness := 10, transparency := 254, posx := 0, posy := 0) {
	HWND := MakeGui()

	outer := DllCall("CreateEllipticRgn", "Int", 0, "Int", 0, "Int", r, "Int", r)
	DllCall("SetWindowRgn", "UInt", HWND, "UInt", outer, "UInt", true)
  offset := 6
  halfr := r/2
  posx := posx-halfr-offset
  posy := posy-halfr-offset
	Gui %HWND%:Color, % color
	Gui %HWND%:Show, x%posx% y%posy% w%r% h%r% NoActivate
	WinSet Transparent, % transparency, % "ahk_id " HWND
	guinum++
	return HWND
}

MakeGui() {
	Gui g%guinum%:New, +E0x20 +AlwaysOnTop +ToolWindow -Caption +Hwndhwnd
	return hwnd
}

CalcR() {
  coords := Coordinates[1]
  coords := StrReplace(coords, "x", "")
  coords := StrReplace(coords, "y", "")
  carray := StrSplit(coords, A_Space)
  y0 := carray[2]

  ;xx := x%A_Index%
  ;yy := y%A_Index%
  1sqm := y0-28
  1sqm := Round(1sqm/5.5)
  r := Round(1sqm/2.5)
  return r
}

ShowCircle(index) {
  coords := Coordinates[index]
  coords := StrReplace(coords, "x", "")
  coords := StrReplace(coords, "y", "")
  carray := StrSplit(coords, A_Space)
  cx := carray[1]
  yx := carray[2]

  r := CalcR()
  hCircle%index% := makeCircle(0x00FF49, r, 2, 254, cx, yx)
}

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