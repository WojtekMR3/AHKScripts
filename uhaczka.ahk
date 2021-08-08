#NoEnv
#SingleInstance off  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetControlDelay -1


Version := "1.0"
Author := "Frostspiked"
Global IniSections := []
Global IniSections ["Singular"] 
:= { pos: "x0 y0"
	 , uh_htk: "f3"}
Global IniSections ["UhaczkaHotkeys"] := {}

cachePth = %A_ScriptFullPath%:Stream:$DATA
Global cachePath := cachePth
Global ini := ReadINI(cachePath)
Global Modifiers := {"Alt": "!", "Ctrl": "^", "Shift": "+"}

if (!ini.Singular.count()) {
	ini.Singular := IniSections.Singular.Clone()
	ini.Singular.uh_htk := IniSections.Singular.uh_htk
}

If (!ini.UhaczkaHotkeys.Count())
{
	ini["UhaczkaHotkeys"] := IniSections["UhaczkaHotkeys"].Clone()
}

OnMessage(0x111,"WM_COMMAND")

Gui, Add, Button, w133 gSelectCoords, Select target position
Gui, Add, Text, xs xp+2 vTankerPos W50 Section

Gui, Add, Text, x10 yp+40, UH Rune Hotkey in game ; The ym option starts a new column of controls.
Gui, Add, Hotkey, vUH_hotkey, F1

Gui, Add, Text, yp+40, AutoUH Hotkeys.
Gui, Add, Button, w40 gAdd_htk Section, Add
Gui, Add, Button, w60 gRem_htk ys, Remove

Gui, Add, StatusBar,,
SB_SetText("by " . Author . " v" . Version, 1)

For num, htk in ini["UhaczkaHotkeys"] {
		Gui, Add, Hotkey, xs vTrigger_htk%num% gTrigger_htk, %htk%
		Hotkey, ~%htk%, Uhaczka, On
		savedHK%num% = %htk%
}

; Load values from store
GuiControl, Text, TankerPos, % ini["Singular"].pos
GuiControl, Move, TankerPos, W300
GuiControl, Text, UH_hotkey, % ini["Singular"].uh_htk

; Remove '.exe' from title
Title := StrReplace(A_ScriptName, .exe, " ")
Title = %Title%
Gui, Show, AutoSize, %Title%

OnExit("SaveCache")
return

SaveCache(ExitReason, ExitCode)
{
	GuiControlGet, TankerPos ,, TankerPos
	IniSections["Singular"].pos := TankerPos
	GuiControlGet, htk ,, UH_hotkey
	IniSections["Singular"].uh_htk := htk

	; Retrieve all hotkey binds.
	Loop % ini["UhaczkaHotkeys"].Count() {
		GuiControlGet, htk ,, Trigger_htk%A_Index%
		; Create array and save it to db.
		IniSections["UhaczkaHotkeys"].Push(htk)
	}

	WriteINI(IniSections, cachePath)
}

GuiClose:
	ExitApp
return

Add_htk:
	ini["UhaczkaHotkeys"].Push("F2")
	ln := ini["UhaczkaHotkeys"].Count()
	Gui, Add, Hotkey, xs vTrigger_htk%ln% gTrigger_htk
	Gui, Show, AutoSize
return

Rem_htk:
	ini["UhaczkaHotkeys"].Pop()
	Reload
return

HotkeyCtrlHasFocus() {
 GuiControlGet, ctrl, Focus       ;ClassNN
 If InStr(ctrl,"hotkey") {
  GuiControlGet, ctrl, FocusV     ;Associated variable
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
     modifier := ""
    If GetKeyState("Shift","P")
      modifier .= "+"
    If GetKeyState("Ctrl","P")
      modifier .= "^"
    If GetKeyState("Alt","P")
      modifier .= "!"
    num := SubStr(ctrl,ctrl.length - 1)
    Key := modifier SubStr(A_ThisHotkey,2)
    GuiControl, , %ctrl%, % Key
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
      GuiControlGet, dupCtrl , , Trigger_htk%dup%
      if (dupCtrl == "") {
        break
      }

      Loop,6 {
        GuiControl,% "Disable" b:=!b, Trigger_htk%dup%   ;Flash the original hotkey to alert the user.
        Sleep,120
      }

      GuiControl, ,Trigger_htk%num%,% Trigger_htk%num% :=""       ;Delete the hotkey and clear the control.
      break
    }
  }

	If (ini["Hotkeys"][num]) { ;If a hotkey was already saved...
    oldHtk := ini["Hotkeys"][num]
		Hotkey, %oldHtk%, Uhaczka, Off        ;     turn the old hotkey off
		ini["Hotkeys"][num] := false        ;     add the word 'OFF' to display in a message.
 	}

  if (!dup) {
    Hotkey, ~%Key%, Uhaczka, On
    ini["Hotkeys"][num] := key
    ;savedHK%num% := key
    WinActivate, Program Manager ; lose focus
  }
}

Uhaczka:
  ;MsgBox, , , uhaczka, 0.3
  if !(WinActive("Tibia -")) {
    return
  }
	sleep 35 ; fix for low
	GuiControlGet, coords ,, TankerPos
	GuiControlGet, UH_Htk ,, UH_hotkey
	ControlFocus,, Tibia -
	SetControlDelay -1
  BlockInput On

  LMod := false
  For LiteralMod, Mod in Modifiers {
    if (InStr(UH_Htk, Mod)) {
      UH_Htk := StrReplace(UH_Htk, Mod, "")
      LMod := LiteralMod
      break
    }
  }

  if (LMod) {
    SendInput, {%LMod% Down}{%UH_Htk%}{%LMod% Up}
  } else {
    SendInput, {%UH_Htk%}
  }
  
  Sleep 1
  ControlClick, %coords%, Tibia -,,Left

  BlockInput Off
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
		WinActivate, %A_ScriptName%
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