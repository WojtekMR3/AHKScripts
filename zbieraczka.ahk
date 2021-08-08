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

Global IniSections := []
Global IniSections ["Coordinates"] := {}
Global IniSections ["Hotkeys"] := {}

cachePth = %A_ScriptFullPath%:Stream:$DATA
Global cachePath := cachePth
Global ini := ReadINI(cachePath)
Global CircleHWNDs := {}

If (!ini.Hotkeys.Count())
{
	ini["Hotkeys"] := IniSections["Hotkeys"].Clone()
}

If (!ini.Coordinates.Count())
{
	ini["Coordinates"] := IniSections["Coordinates"].Clone()
}

OnMessage(0x111,"WM_COMMAND")

Global mouseButtons = ["LButton", "RButton", "MButton", "WheelUp", "WheelDown", "XButton1", "XButton2", "WheelLeft", "WheelRight"]
Global Guihwnd := "InstantHotkey"
Gui, %Guihwnd%:New

Gui, Add, Button, w40 vPosEvent0 gAutoCoords Section, AutoCoords
Gui, Add, Text, yp+40, Coordinates
Gui, Add, Edit, xs vPos0 W75 Section hide, x0 y0
; Create coords GUI
Loop 9 {
  Gui, Add, Text, xs Section, %A_Index%
  Gui, Add, Edit, ys vPos%A_Index% gUpdateCoords W75, x0 y0
  Gui, Add, Button, w35 vPosEvent%A_Index% gSelectCoords ys, Pos
}

Gui, Add, Text, xs yp+40, AutoLoot Hotkeys.
Gui, Add, Button, w40 gAdd_htk Section, Add
Gui, Add, Button, w60 gRem_htk ys, Remove

Gui, Add, StatusBar,,
SB_SetText("AutoLoot by Frostspiked", 1)

; Remove '.exe' from title
Title := StrReplace(A_ScriptName, .exe, " ")
Title = %Title%

; Load values from store
For num, htk in ini["Hotkeys"] {
		Gui, Add, Hotkey, xs Section vTrigger_htk%num% gTrigger_htk, %htk%
    Gui, Add, Text, ys vtHtkText%num% w75,
    Loop % mouseButtons.Count() {
      if (htk == mouseButtons[A_Index]) {
        GuiControl, %Guihwnd%:, tHtkText%num%, %htk%
      }
    }
    ; if this htk contains mouse btns, guicontrol this htk
		Hotkey, ~%htk%, Zbieraczka, On
    ini["Hotkeys"][num] := htk
}

For num, coordPair in ini["Coordinates"] {
  GuiControl, %Guihwnd%:Text, Pos%num%, %coordPair%
}

Gui, Margin , 100, 5
Gui, Show, AutoSize xCenter, %Title%

FlashCircles(3000)

OnExit("SaveCache")
return

SaveCache(ExitReason, ExitCode)
{
	; Retrieve all hotkey binds.
	Loop % ini["Hotkeys"].Count() {
		GuiControlGet, htk , %Guihwnd%:, Trigger_htk%A_Index%
		; Create array and save it to db.
		IniSections["Hotkeys"].Push(htk)
	}

  Loop 9 {
		GuiControlGet, OutputVar, %Guihwnd%:, Pos%A_Index%
		; Create array and save it to db.
		IniSections["Coordinates"].Push(OutputVar)
	}

	WriteINI(IniSections, cachePath)
}

InstantHotkeyGuiClose:
	ExitApp
return

Add_htk:
  Gui, Margin, 10, 5
	ini["Hotkeys"].Push("F2")
	ln := ini["Hotkeys"].Count()
	Gui, Add, Hotkey, xs Section vTrigger_htk%ln% gTrigger_htk
  Gui, Add, Text, ys vtHtkText%ln% w75,
  Gui, Margin, 100, 5
	Gui, Show, AutoSize xCenter
return

Rem_htk:
	ini["Hotkeys"].Pop()
	Reload
return

HotkeyCtrlHasFocus() {
 GuiControlGet, ctrl, %Guihwnd%:Focus       ;ClassNN
 If InStr(ctrl,"hotkey") {
  GuiControlGet, ctrl, %Guihwnd%:FocusV     ;Associated variable
  Return, ctrl
 }
}

#If ctrl := HotkeyCtrlHasFocus()
  *Delete::
  *Escape::
  *Space::
  *Tab::
  *PgUp::
  *PgDn::
  *Home::
  *End::
  *RButton:: 
  *MButton::
  *XButton1::
  *XButton2::
  *WheelDown::
  *WheelUp::
  *WheelLeft::
  *WheelRight::
     modifier := ""
    If GetKeyState("Shift","P")
      modifier .= "+"
    If GetKeyState("Ctrl","P")
      modifier .= "^"
    If GetKeyState("Alt","P")
      modifier .= "!"
    num := SubStr(ctrl,ctrl.length - 1)
    Key := modifier SubStr(A_ThisHotkey,2)
    GuiControl, %Guihwnd%:, %ctrl%, % Key  
    Loop % mouseButtons.Count() {
      if (Key == mouseButtons[A_Index]) {
        GuiControl, %Guihwnd%:, tHtkText%num%, % Key
      }
    }
    SetZbieraczkaHotkey(num, Key)
  return
#If

; Only triggers on hotkey change, if htk is same it doesn't trigger.
Trigger_htk:
	If %A_GuiControl%  in +,!,^,+^,+!,^!,+^!            ;If the hotkey contains only modifiers, return to wait for a key.
		return
	num := SubStr(A_GuiControl,A_GuiControl.length - 1)
  Key := % %A_GuiControl%
  SetZbieraczkaHotkey(num, Key)
return

SetZbieraczkaHotkey(num, key) {
  ln := ini["Hotkeys"].Count()
  
  Loop % ln {
    if (key = ini["Hotkeys"][A_Index]) {
      
      dup := A_Index
      ; If duplicate hotkey is blank, do not alert it to user
      GuiControlGet, dupCtrl , %Guihwnd%:, Trigger_htk%dup%
      if (dupCtrl == "") {
        break
      }

      Loop,6 {
        GuiControl,% "Disable" b:=!b, Trigger_htk%dup%   ;Flash the original hotkey to alert the user.
        Sleep,120
      }

      GuiControl, %Guihwnd%:,Trigger_htk%num%,% Trigger_htk%num% :=""       ;Delete the hotkey and clear the control.
      break
    }
  }

	If (ini["Hotkeys"][num]) { ;If a hotkey was already saved...
    oldHtk := ini["Hotkeys"][num]
		Hotkey, %oldHtk%, Zbieraczka, Off        ;     turn the old hotkey off
		ini["Hotkeys"][num] := false        ;     add the word 'OFF' to display in a message.
    Loop % mouseButtons.Count() {
      if (oldHtk == mouseButtons[A_Index]) {
        GuiControl, %Guihwnd%:, tHtkText%num%,
      }
    }
 	}

  if (!dup) {
    Hotkey, ~%Key%, Zbieraczka, On
    ini["Hotkeys"][num] := key
    Loop % mouseButtons.Count() {
      if (Key == mouseButtons[A_Index]) {
        GuiControl, %Guihwnd%:, tHtkText%num%, %key%
      }
    }
    WinActivate, Program Manager ; lose focus
  }
}

AutoCoords:
  MsgBox, , , Select character position, 0.8
  Goto, SelectCoords
Return

SelectCoords:
	WinActivate, Tibia
  Global numx := SubStr(A_GuiControl,A_GuiControl.length - 1)
	SetTimer, WatchCursor, 20
return

UpdateCoords:
return

Zbieraczka:
  ;MsgBox, , , Zbiera, 0.3
  Sleep 25
  if !(WinActive("Tibia -")) {
    return
  }

  BlockInput, On
  SendInput {Shift Down}
  Sleep 10
  Loop 9 {
    GuiControlGet, coordsPair, %Guihwnd%:, Pos%A_Index%
    ControlClick, %coordsPair%, Tibia ,,Right
  }
  Sleep 10
  SendInput {Shift Up}
  BlockInput, Off
return

WatchCursor:
	CoordMode, Mouse, Relative
  
	MouseGetPos, xpos, ypos
	ToolTip, `Select position`n`x: %xpos% y: %ypos%`
	
	if (GetKeyState("LButton")) {
		MsgBox, , , %xpos% %ypos%, 0.3
		BlockInput, Mouse
		SetTimer, WatchCursor, Off
		ToolTip
    ;--------
    GuiControl, %Guihwnd%:Text, Pos%numx%, x%xpos% y%ypos%
    if (numx == 0) {
      ; Flash circles for longer
      CalcPositions()
      numx := 1
      ShowCircle(numx, 0xff1122)
      FlashCircles(3000)
    } else {
      ; Flash circles for shorter like 1s
      ShowCircle(numx, 0xff1122)
      FlashCircles(1500)
      WinActivate, %A_ScriptName%
    }
	}
return

CalcPositions() {
	GuiControlGet, center, %Guihwnd%:, Pos0
  coords := StripXYcoords(center)
  x0 := coords[1]
  y0 := coords[2]
  Global 1sqm := y0-28
  1sqm := Round(1sqm/5.5)

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

  GuiControl, %Guihwnd%:Text, Pos1, x%x5% y%y5%
  GuiControl, %Guihwnd%:Text, Pos2, x%x2% y%y2%
  GuiControl, %Guihwnd%:Text, Pos3, x%x3% y%y3%
  
  GuiControl, %Guihwnd%:Text, Pos4, x%x6% y%y6%
  GuiControl, %Guihwnd%:Text, Pos5, x%x9% y%y9%
  GuiControl, %Guihwnd%:Text, Pos6, x%x8% y%y8%

  GuiControl, %Guihwnd%:Text, Pos7, x%x7% y%y7%
  GuiControl, %Guihwnd%:Text, Pos8, x%x4% y%y4%
  GuiControl, %Guihwnd%:Text, Pos9, x%x1% y%y1%
}

makeCircle(color, r := 150, thickness := 10, transparency := 254, posx := 0, posy := 0, i := 0) {
	HWND := MakeGui()

	outer := DllCall("CreateEllipticRgn", "Int", 0, "Int", 0, "Int", r, "Int", r)
	DllCall("SetWindowRgn", "UInt", HWND, "UInt", outer, "UInt", true)
  offset := 6
  halfr := r/2
  WinGetPos, Xoff, Yoff, W, H, Tibia
  posx := posx-halfr+Xoff
  posy := posy-halfr+Yoff
	Gui %HWND%:Color, % color
  Gui %HWND%:Font, s8 w600,
  Gui %HWND%:Add, Text, cDefault, %i%
	Gui %HWND%:Show, x%posx% y%posy% w%r% h%r% NoActivate
	WinSet Transparent, % transparency, % "ahk_id " HWND
	return HWND
}

MakeGui() {
	Gui New, +E0x20 +AlwaysOnTop +ToolWindow -Caption +Hwndhwnd
	return hwnd
}

CalcR() {
  GuiControlGet, coords, %Guihwnd%:, Pos1
  coords := StripXYcoords(coords)
  y0 := coords[2]

  1sqm := y0-28
  1sqm := Round(1sqm/5.5)
  r := Round((1sqm/3)+5)
  return r
}

ShowCircle(index, clr := "0x00FF49") {
  if (CircleHWNDs[index]) {
    return
  }
  GuiControlGet, coords, %Guihwnd%:, Pos%index%
  If (coords = "") {
    return
  } else if (coords = "x0 y0") {
    return
  }
  coords := StripXYcoords(coords)
  cx := coords[1]
  yx := coords[2]
  r := CalcR()
  hCircle := makeCircle(clr, r, 2, 254, cx, yx, index)
  CircleHWNDs[index] := hCircle
}

HideCircle(index) {
    if (!CircleHWNDs[index]) {
      return
    }
    gui := CircleHWNDs[index]
    Gui %gui%: Hide
    CircleHWNDs.Delete(index)
}

FlashCircles(ms) {
  Loop 9 {
    ShowCircle(A_Index)
  }
  if (CircleHWNDs.Count() == 0)
    Return
  Sleep %ms%
  Loop 9 {
    HideCircle(A_Index)
  }
}

StripXYcoords(coords) {
  coords := StrReplace(coords, "x", "")
  coords := StrReplace(coords, "y", "")
  carray := StrSplit(coords, A_Space)
  return carray
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