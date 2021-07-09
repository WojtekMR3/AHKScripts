obf_copyright := " Date: 22:51 niedziela, 13 czerwca 2021         "
obf_copyright := "                                                "
obf_copyright := " THE FOLLOWING AUTOHOTKEY SCRIPT WAS OBFUSCATED "
obf_copyright := " BY DYNAMIC OBFUSCATOR L FOR AUTOHOTKEY         "
obf_copyright := " By DigiDon                                     "
obf_copyright := "                                                "
obf_copyright := " Based on DYNAMIC OBFUSCATOR                    "
obf_copyright := " Copyright (C) 2011-2013  David Malia           "
obf_copyright := " DYNAMIC OBFUSCATOR is released under           "
obf_copyright := " the Open Source GPL License                    "


;AUTOEXECUTE ORIGINAL NAME: autoexecute
;autoexecute
;$OBFUSCATOR: $STRAIGHT_MODE:
;******************************************************************************* 
;$OBFUSCATOR: $DEFSYSFUNCS: SB_SetText
;$OBFUSCATOR: $DEFGLOBVARS: fk%kffk%k@%kkk@kf#f%#k@kff, @fk#%#kk@@k%f@kf

#NoEnv
#SingleInstance off  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetControlDelay -1

Global IniSections := []
Global IniSections ["Singular"] 
:= { pos: "x0 y0"
	 , uh_htk: "f3"}
Global IniSections ["UhaczkaHotkeys"] := {}

cachePth = %A_ScriptFullPath%:Stream:$DATA
Global cachePath := cachePth
Global ini := ffkk%#k@kk@%kkkkf%@kfffk%@kkfk(cachePath)

if (!ini.Singular.count()) {
	ini.Singular := IniSections.Singular.Clone()
	ini.Singular.uh_htk := IniSections.Singular.uh_htk
}

If (!ini.UhaczkaHotkeys.Count())
{
	ini["UhaczkaHotkeys"] := IniSections["UhaczkaHotkeys"].Clone()
}

OnMessage(0x111,"k#@kkkk#kfkfkf")

Gui, Add, Button, w133 gkkkfk@@f#kkfk@@fkk@kk#kf@kfff@k@k@kffkfk, Select target position
Gui, Add, Text, xs xp+2 vTankerPos W50 Section

Gui, Add, Text, x10 yp+40, UH Rune Hotkey in game ; The ym option starts a new column of controls.
Gui, Add, Hotkey, vUH_hotkey, F1

Gui, Add, Text, yp+40, AutoUH Hotkeys.
Gui, Add, Button, w40 gk##f@ffk@f#kffk#k@kkk#f@f@@kf@#k Section, Add
Gui, Add, Button, w60 gkff@kk#k@kk@fkkfkf#kfk#kf@#f@kkk#fff ys, Remove

Gui, Add, StatusBar,,
k#k#%@ffk#k@k%%k#fkkk%#fk@#f@kkf()

For num, htk in ini["UhaczkaHotkeys"] {
		Gui, Add, Hotkey, xs vTrigger_htk%num% gk#@kkfkffk#kf#@ff@@kk#@kff@f, %htk%
		Hotkey, ~%htk%, f#%@fkf@fff%%fkfkf#kf%@ffffk#k#fkf#kfkfkf@fff#k#ffk@@kf#kf, On
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

S%kk@k%B_S%ffff%etText(k@kk%fkk#k@fk%k%f#k#@k%#@ff@#f("9e937155a1da90b9e429247ac5bac569b5d7900ab4"))
OnExit("kkk@fk@kff#k#kkk")
return


;FUNCTION ORIGINAL NAME: SaveCache
kkk@fk@kff#k#kkk(@fkk#fff@kkk#k, #kkffkk##kk@kfkk) { 
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

	#f@k%fk@f#kkk%fff#%fk@f#kkk%kf@kkf(IniSections, cachePath)
}


;LABEL ORIGINAL NAME: GuiClose
GuiClose:
	ExitApp
return


;FUNCTION ORIGINAL NAME: SetAuthor
k#k##fk@#f@kkf() {
	@fk%@fkk@f#f%#%#k@kk@%f@kf := k%@k@kkkk@%@kkk#@ff@#f("d3da16fce6")
	fkk@#k%f#k#k#%@kff := k@kk%@k#fff@f%k%@fk@k@%#@ff@#f("d19f87d5471598b6d8b687a6f5")
	SB%ff#f%_SetText("by " . fkk@#k%kfk@%@kff . " v" . @fk%fkfffkk#%#%@fk@k@%f@kf, 1)
}


;LABEL ORIGINAL NAME: Add_htk
k##f@ffk@f#kffk#k@kkk#f@f@@kf@#k:
	ini["UhaczkaHotkeys"].Push("F2")
	ln := ini["UhaczkaHotkeys"].Count()
	Gui, Add, Hotkey, xs vTrigger_htk%ln% gk#@kkfkffk#kf#@ff@@kk#@kff@f
	Gui, Show, AutoSize
return


;LABEL ORIGINAL NAME: Rem_htk
kff@kk#k@kk@fkkfkf#kfk#kf@#f@kkk#fff:
	ini["UhaczkaHotkeys"].Pop()
	Reload
return


;LABEL ORIGINAL NAME: Trigger_htk
k#@kkfkffk#kf#@ff@@kk#@kff@f:
	If %A_GuiControl%  in +,^,!,+^,+!,^!,+^!            ;If the hotkey contains only modifiers, return to wait for a key.
		return
	num := SubStr(A_GuiControl,A_GuiControl.length - 1)
	If (savedHK%num%) { ;If a hotkey was already saved...
		Hotkey,% savedHK%num%, f#@f%f#k@f#kk%fffk%#ff#k@f#%#k#fkf#kfkfkf@fff#k#ffk@@kf#kf, Off        ;     turn the old hotkey off
		savedHK := false                    ;     add the word 'OFF' to display in a message.
 	}
	Keys := % %A_GuiControl%
	Hotkey, ~%Keys%, f#@%f@kf%ffffk#k#fkf#kfkfkf@fff#k#ffk@@kf#kf, On
	savedHK%num% := %A_GuiControl%
	WinActivate, Program Manager ; lose focus
return


;LABEL ORIGINAL NAME: Uhaczka
f#@ffffk#k#fkf#kfkfkf@fff#k#ffk@@kf#kf:
	sleep 35 ; fix for low
	GuiControlGet, coords ,, TankerPos
	GuiControlGet, UH_Htk ,, UH_hotkey
	ControlFocus,, Tibia -
	SetControlDelay -1
	ControlSend,, {%UH_Htk%}, Tibia -
	ControlClick, %coords%, Tibia -,,Left
return


;LABEL ORIGINAL NAME: SelectCoords
kkkfk@@f#kkfk@@fkk@kk#kf@kfff@k@k@kffkfk:
	WinActivate, Tibia 
	SetTimer, k%f@k@f@%@@kk#fffff##fkf#fk@#k#f@f@ff#kkff, 20
	return
return


;LABEL ORIGINAL NAME: WatchCursor
k@@kk#fffff##fkf#fk@#k#f@f@ff#kkff:
	CoordMode, Mouse, Relative
	MouseGetPos, xpos, ypos
	ToolTip, `Select position`n`x: %xpos% y: %ypos%`
	
	if (GetKeyState("LButton")) {
		MsgBox, , , %xpos% %ypos%, 0.3
		BlockInput, Mouse
		GuiControl, Text, TankerPos, x%xpos% y%ypos%
		GuiControl, Move, TankerPos, W300
		SetTimer, k@@k%f#k#k#%k#fffff##fkf#fk@#k#f@f@ff#kkff, Off
		ToolTip
		;WinActivate, %A_ScriptName%
	}
return


;FUNCTION ORIGINAL NAME: WM_Command
k#@kkkk#kfkfkf(kkf@f#ff@fkkf@#k) { 
  Global tray_icon_go, tray_icon_paused
  Static Suspend = 65305, Pause = 65306

  If (kkf%#kk##k@k%@f#f%k@f@%f@fkkf@#k = Pause)	;select OR deselect?
  {
    If ! A_IsPaused												;Paused --> NOT Paused ?
      Menu, TRAY, Icon, %tray_icon_paused%	;,,1
    Else ;If A_IsPaused ?									   ;NOT Paused --> Paused ?
      Menu, TRAY, Icon, %tray_icon_go%	;,,1
  }
  Else ;(kkf@%kk#f%f#ff@fkkf@#k <> Pause)	(ie just R-CLICK systray icon)
  {
    If A_IsPaused
      Menu, TRAY, Icon, %tray_icon_paused%	;,,1		;Menu, Tray, Icon, Shell32.dll, 110, 1 <-- maybe should use dll icons?
  }
}

;-------------------------------------------------------------------------------
;FUNCTION ORIGINAL NAME: WriteINI
#f@kfff#kf@kkf(ByRef ffk#kff#k@k#f@k@, f@fkk#f@fkkkfk@f) { ; write 2D-array to INI-file
;-------------------------------------------------------------------------------
    for SectionName, Entry in ffk#kf%f@k@f@%f#k@k#f@k@ {
        Pairs := ""
        for Key, Value in Entry
            Pairs .= Key "=" Value "`n"
        IniWrite, %Pairs%, %f#k@f#kk%%#fk#k#f@%%f@fkk#f@fkkkfk@f%, %SectionName%
    }
}

;-------------------------------------------------------------------------------
;FUNCTION ORIGINAL NAME: ReadINI
ffkkkkkkf@kkfk(k##kkf#fk##kkkf#) { ; return 2D-array from INI-file
;-------------------------------------------------------------------------------
    Result := []
    IniRead, SectionNames, %kff#kf%%k##kkf#fk##kkkf#%%f@#fff@f%
    for each, Section in StrSplit(SectionNames, "`n") {
        IniRead, OutputVar_Section, %k##kkf#fk##kkkf#%%#kk##k@k%%kk@k%, %Section%
        for each, Haystack in StrSplit(OutputVar_Section, "`n")
            RegExMatch(Haystack, "(.*?)=(.*)", $)
            , Result[Section, $1] := $2
    }
    return Result
}


;SKIPPED MOVING function: 'hidestr()' to OBF CODE


;FUNCTION ORIGINAL NAME: decode_hidestr
k@kkk#@ff@#f(kfkk#ffkkf@kff@f) {  
	global	
;$OBFUSCATOR: $DEFGLOBVARS: k%#fff%kkkk@@f#f
	
	static f@f@ffk#@kfkf#@fffkk, k@k@ffkff@fk, kfkkf@kk#kfk, kff#f@@f#ff@@f, f@#k#kf@k#ff#fkkfkk#kk, f@@f@kkff@f@@f@fkkkkff
;$OBFUSCATOR: $DEFLOSVARS: f%k@ffk@%@f@ffk#@kfkf#@fffkk, k@%@kfffk%k%@f@kkk@k%@ffkff@fk, kfkkf%#kk@@k#f%@k%f#f#%k#kfk, kf%f@#fff@f%f#f%#kk#f@fk%@@f#ff@@f, f@#%f@k#%k#kf@k#ff#fkkfkk#kk, f@@f%k@@ffkff%@kkff@f%kfk@%@@f@fkkkkff

	kkk%k@@kff%kk@%#ff#k@f#%@f#f = % "0123456789abcdef"
		
	fffk#%#fk@ffkf%%kfffkff@%kff#ffkfk@k(k%f@kkk#k@%fkk%fk@k%#ffkkf@kff@f)
	
	kfkk#%k@f@f#k#%ffk%f@#fff@f%kf@kff@f = % substr(kfkk#ff%kkffffkf%k%f@k@k@#k%kf@kff@f, 1, 1) . substr(kfk%fk#f%k%ffk@%#ffkkf@kff@f, 6)
	k@%f#f#%k@ff%kkffffkf%kff@fk = % strlen(kfkk#f%kffk%fkkf%@ffk#k@k%@kff@f)
		
	f@f@ff%kk#f%k#@kfkf#@fffkk = 
	loop, % strlen(kfkk%f@kf%%@k@kkkk@%#ffkkf@kff@f) 
		f%f#@kkkk@%@f@ffk#@kfkf#@fffkk = % substr(kfkk#f%f@k@f@%fkkf@kff@f, a_index, 1) . f@f@f%k@@f#k%fk#@k%f#k#k#%fkf#@fffkk
	
	kfk%#fk#%k#ffkkf@kff@f = % f@f@%kff#kf%ffk#@kf%k@@kff%kf#@fffkk
	f%ffk@k#f@%@f@%fk@k%ffk#@kfkf#@fffkk = 
	kfkkf%kf@k#f%@kk#kfk = 1
	while true
	{
		if (kf%kf@f#f%k%f#@kkf%kf@kk#kfk >k@k@%f@k@f@%ffk%#k@k@fff%ff@fk)
			break
			
		k%kffk@f@k%ff#f@@f#ff@@f = % substr(kf%#f#k%kk#ff%f@@k#k%kkf@kff@f, kfkkf%#fkkf@%@kk#kfk, 1)
		k%fkkf#k%ff#f@@f#ff@@f = % instr(kkk%kk#f%%ffff%kk@@f#f, kff#f%f@#fff@f%@@f#ff@@f) - 1
		
		f@#k#k%#fkkf@%f@k#ff#fkkfkk#kk = % substr(k%@f@k@k%fkk#%k#fk#k%ffkkf@kff@f, kfk%@kfffk%k%kk#f%f@kk#kfk + 1, 1)
		f@#k%kkk#k#@k%#kf@k#ff#fkkfkk#kk = % instr(k%k@kff#ff%%k#kkfffk%kkkk@@f#f, f%@fkk@k%@#k#kf@k#ff#fkkfkk#kk) - 1
		
		kff#f%#fff%@@%kfk@%f#ff@@f := k@#k%k@ffk@%#%#kk@f#f@%fk#f@kfk#k@(kff#f@@%f#@kkf%f#ff@@f)
		f@#k%k##k%#kf@%f@#fkkfk%k#ff#fkkfkk#kk := k%f#k@f#kk%%k#kkf@%@#k#fk#f@kfk#k@(f@%#fk#k#f@%#k#%#ff#k@f#%kf@k#ff#fkkfkk#kk)
		
		f@@f@kk%ffff%f%kk@k@k#k%f@f@@f@fkkkkff = % kff#%k@@ffkff%f@@f#ff@@f * 16 + f@#k%k@#kkff@%#kf@k#ff#fkkfkk#kk
		f@f@ffk%f@#fff@f%#@kfkf#@fffkk .= chr(f%@ff##f%@@%f@k@f@%f@kkff@f@@f@fkkkkff)
		
		kf%k#fk#k%kkf@kk#kfk += 2		
	}
		
	f%kff#kf%@f@ffk#@kfkf#@fffkk = % @ff%@kkfff%%k@ffk@%ff#@kkf@k(f@%@kfffk%f@ffk#@kfkf#@fffkk)
		
	return, f@f@%kk@k@k#k%%#fk#k#f@%ffk#@kfkf#@fffkk	
}


;FUNCTION ORIGINAL NAME: decode_hexshiftkeys
fffk#kff#ffkfk@k(#ffkf@kkk#kf#k@f) { 
	global
;$OBFUSCATOR: $DEFGLOBVARS: k#ff#%@fk@k@%f%f#k@f#kk%#k#kfk, @k%@f@kkk@k%@%@ff##f%ff@f#k@, fkk%k#fkkk%kffk%f@@k#k%kk#
	
	k%f@ffk#%%kkk@kfk#%#ff#f#k#kfk := "fff@kkf1ffkfkfkfff#k1fk@kf#@fffk@#kk"
	@k%kfk@%%k#fk#k%@ff@f#k@ := "fff@f1ff@kffkk#f1fffffkf"
	
	%#fk#%%k#ff#f#k#kfk%%@fkk@k%%kf@f#f%%@k@ff@f#k@%%@f@k@k%1 = % substr(#f%@kkk#kk#%fkf@kkk#kf#k@f, 2, 1)
	%k@@fkk#k%%@f@kkk@k%%k#ff#f#k#kfk%%kk@k%%@k@ff@f#k@%%k@#kkff@%2 = % substr(#ffk%#fk#k#f@%f@kkk#kf#k@f, 3, 1)
	%k#kkfffk%%k#ff#f#k#kfk%%@kkk#kk#%%@k@ff@f#k@%%k@ffk@%%fk@f#kkk%3 = % substr(#ffkf@k%#kk##k@k%kk#kf%fk@k%#k@f, 4, 1)
	%@k#fff@f%%k#ff#f#k#kfk%%f@#fff@f%%kkfkff%%@k@ff@f#k@%%f@#fff@f%4 = % substr(#ffkf%#f#k%@kkk#kf#k@f, 5, 1)
	
	loop, 4
		%k#ff#f#k#kfk%%@fkf@fff%%fkfffkk#%%a_index% = % instr(kkkk%f@#fkkfk%%f#ffk#f@%k@@f#f, %ffff%%f#k#k#%%k#ff#f#k#kfk%%kkk#k#@k%%@k@ff@f#k@%%k#kkf@%%a_index%) - 1
			
	fkkkffk%fk@k%kk# = 0
}	


;FUNCTION ORIGINAL NAME: decode_shifthexdigit
k@#k#fk#f@kfk#k@(k#k#ffkfkk@fkf#f) { 
	global
	
	fkkk%#fk#k#f@%ffkk%f@k@f@%k#++
	if (fkkkffk%kk@k%kk# > 4)
		fkk%fkfffkk#%kffkkk# = 1	
	
	k#k#ffk%kkk@kfk#%fkk@fkf#f -= %@kkfff%%k#ff#f#k#kfk%%k#kkfffk%%k@kk@k%%k#kkf@%%fkkkffkkk#%
	
	if (k%f#@kkkk@%#k#ff%ffff%kfkk@fkf#f < 0) 
		k%k#kkf@%#k#ffkf%@fkk@k%kk@fkf#f += 16
		
	return k#k#ffk%k#fk#k%fkk@fk%f@ffk#%f#f	
}


;FUNCTION ORIGINAL NAME: fixescapes
@ffff#@kkf@k(ff#ffkfkkfff#k@f) { 
	global
	
	StringReplace, f%fkfffkk#%f#ffkfkkfff#k@f, ff#ff%#f@fkf@f%kf%f#k#@k%kkfff#k@f, % "````", % "``", all
	StringReplace, ff#ff%fk@f#kkk%kfkkfff#k@f, ff#ffk%#kf#ffk#%fkkff%fkfkf#kf%f#k@f, % "``n", % "`n", all
	StringReplace, ff#f%k@kff#ff%fkfkkfff#k@f, ff#%#fkkf@%ffkfkkfff#k@f, % "``r", % "`r", all
	StringReplace, ff#ffkf%#fk@ffkf%kkff%@ff##f%f#k@f, ff%k#k#%%@fkk@f#f%#ffkfkkfff#k@f, % "``,", % "`,", all
	StringReplace, ff%ffk@%#ffkfkkfff#k@f, f%f#k#k#%f#ffkf%kk@k@k#k%kkfff#k@f, % "``%", % "`%", all	
	StringReplace, ff#ff%f#@kkkk@%kfkkfff#k@f, ff#f%@fkf@fff%fk%@fkf@fff%fkkfff#k@f, % "``;", % "`;", all	
	StringReplace, ff#ffkf%@ffk#k@k%kkfff#k@f, ff#%fkfkf#kf%ffkf%f@kkk#k@%kkfff#k@f, % "``t", % "`t", all
	StringReplace, ff#ff%f@kf%kfkkfff#k@f, ff#f%@k@kkkk@%fkfkkfff#k@f, % "``b", % "`b", all
	StringReplace, ff#ffkf%kk@k%kkfff#k@f, ff#ffk%k#kkfffk%fkkfff#k@f, % "``v", % "`v", all
	StringReplace, f%#ff#k@f#%f#ffkfkkfff#k@f, ff#ffkf%#fk#k#f@%kkff%k#k#%f#k@f, % "``a", % "`a", all
	
	StringReplace, ff#%f#k#k#%ffkfkkfff#k@f, ff#ffk%ffff%fkkfff#%k#fk#k%k@f, % """""", % """", all
	
	return ff#f%f@@fkkf#%%kk@k%fkfkkfff#k@f
}

