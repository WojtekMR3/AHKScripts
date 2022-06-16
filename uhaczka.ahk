#NoEnv
#SingleInstance off  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetControlDelay -1
SetBatchLines, -1

tempVal = %A_ScriptFullPath%:Stream:$DATA
Global cachePath := tempVal
Global Modifiers := {"Alt": "!", "Ctrl": "^", "Shift": "+"}
Global mouseButtons = ["LButton", "RButton", "MButton", "WheelUp", "WheelDown", "XButton1", "XButton2", "WheelLeft", "WheelRight"]

IniRead, res, %cachePath%, CacheSection, Settings
if (res = "ERROR") {
  Global ob2 := {1: {tabName: "ek", uhHotkey: "F12", coords: "x1337, y500", hotkeys: ["F6"]}, 2: {tabName: "rp"
  , uhHotkey: "F12", coords: "x800, y250", hotkeys: ["F7"]}}
} else {
  Global ob2 := JSON.load(res)
}

OnMessage(0x111,"WM_COMMAND")
;arr2 := [{tabName: "ek", coords: "x0, y0", hotkeys: [5, 6, 7, 8]}, {tabName: "rp", coords: "x0, y0", hotkeys: ["f2", "f3", 7, 8]}]
arr2 := {tabs: [{tabName: "ek", coords: "x0, y0", hotkeys: [5, 6, 7, 8]}, {tabName: "rp", coords: "x0, y0", hotkeys: ["f2", "f3", 7, 8]}], settings: {pauseHot: "F1", reloadHot: "F2", closeHot: "F3"}}
For key in arr2.tabs {
  MsgBox, % arr2.tabs[key].tabName
}
;MsgBox, % Obj2Str(ob2)

; For key, in ob2 {
; 	MsgBox, % key
; 	For i, in ob2[key].hotkeys {
; 		MsgBox, % ob2[key].hotkeys[i]
; 	}
; }
;MsgBox, % arr2[1].tabName
Gui, Add, Button, Section gNewTab, New tab
Gui, Add, Text, ys W50

tabNames := ""
For key, in ob2 {
  tabNames := tabNames . ob2[key].tabName . "|"
}
tabNames := SubStr(tabNames, 1, StrLen(tabNames) - 1)

Gui, Add, Tab3, xs Section vAutoUHTabs, %tabNames%
For key, in ob2 {
	Gui, Tab, %A_Index%
	
  Gui, Add, GroupBox, Section w160 h60, Tab Edit
  Gui, Add, Button, xp+10 yp+20 gRenameTab, Rename tab
  Gui, Add, Button, xp+80 yp gDeleteTab, Delete tab

	Gui, Add, Text, xs Section, UH Rune Hotkey in game ; The ym option starts a new column of controls.
	Gui, Add, Hotkey, ys vUH_hotkey%key% gUhRuneChange, % ob2[key].uhHotkey
	
	Gui, Add, Button, xs Section w133 gSelectCoords vPixelBtn%key%, Select target position
	Gui, Add, Text, ys yp+5 vTankerPos%key% W80, % ob2[key].coords

	Gui, Add, Text, xs yp+40 Section, AutoUH Hotkeys.
	Gui, Add, Button, w40 gAdd_htk Section, Add
	Gui, Add, Button, w60 gRem_htk ys, Remove
	
	For i, in ob2[key].hotkeys {
		htk2 := ob2[key].hotkeys[i]
		Gui, Add, Hotkey, xs Section vTrigger_htk%key%%i% gTrigger_htk, %htk2%
		Gui, Add, Text, ys vtHtkText%key%%i% w75,
	 	Loop % mouseButtons.Count() {
		  if (htk2 == mouseButtons[A_Index]) {
			GuiControl, , tHtkText%key%, %htk2%
		  }
		}
		Hotkey, ~%htk2%, Uhaczka, On
	}
}

Gui, Add, StatusBar,,
SB_SetText("AutoUH by Frostspiked", 1)

; Remove '.exe' from title
Title := StrReplace(A_ScriptName, .exe, " ")
Title = %Title%
Gui, Margin, 10, 5
Gui, Show, AutoSize, %Title%

OnExit("SaveCache")
return

;~Insert::Suspend
~Home::Reload
;~End::ExitApp

GuiClose:
	ExitApp
return

NewTab:
  if (ob2.Count() >= 9) {
    MsgBox, You can't have more than 9 tabs!
    return
  }
  newName := ob2.Count()+1
  InputBox, tabName, New tab, (New tab name),,220,150,,,,, ek%newName% 
  nameDup := false
  For key, in ob2 {
    if (ob2[key].tabName = tabName) {
      nameDup := True
      break
    }
  }
  ; check if name isnt blank and if it already exists
  if (StrLen(tabName) = 0 or (nameDup = true) and (ErrorLevel = 0)) {
     MsgBox, Tab name is either empty or already exists!
     return
  }
  if (ErrorLevel > 0) {
    return
  }
  ob2.push({tabName: tabName, uhHotkey: "f12", coords: "x1190, y500", hotkeys: []})
  Gosub, redrawGUIlabel
  GuiControl, ChooseString, AutoUHTabs, %tabName%
return

RenameTab:
  GuiControlGet, actTab , , AutoUHTabs
  InputBox, tabName, New tab, (New tab name),,220,150,,,,, %actTab%
  ; check if new tab name already exists
  nameDup := false
  For key, in ob2 {
    if (ob2[key].tabName = tabName) {
      nameDup := True
      break
    }
  }
  ; check if name isnt blank and if it already exists
  if (StrLen(tabName) = 0 or (nameDup = true) and (ErrorLevel = 0)) {
     MsgBox, Tab name is either empty or already exists!
     return
  }
  if (ErrorLevel > 0) {
    return
  }

  ; Search for the active tab key
  For key, in ob2 {
    if (ob2[key].tabName = actTab) {
      ; change tab name in the object
      ob2[key].tabName := tabName
      break
    }
  }
  Gosub, redrawGUIlabel
  GuiControl, ChooseString, AutoUHTabs, %tabName%
return

DeleteTab:
  GuiControlGet, actTab , , AutoUHTabs
  For key, in ob2 {
    if (ob2[key].tabName = actTab) {
      For i, in ob2[key].hotkeys {
        htk := ob2[key].hotkeys[i]
        Hotkey, ~%htk%, Uhaczka, Off
      }
      ob2.Delete(key)
      break
    }
  }
  ; create array from object
  arrayTemp := []
  For k, in ob2 {
    arrayTemp.push(ob2[k])
  }
  ob2 := {}
  ; create new object from an array
  For i, in arrayTemp {
    ob2.push(arrayTemp[i])
  }
  Gosub, redrawGUIlabel
return

UhRuneChange:
  key := SubStr(A_GuiControl,A_GuiControl.length - 1)
  GuiControlGet, htk,, %A_GuiControl%
  ob2[key].uhHotkey := htk
return

Add_htk:
	GuiControlGet, actTab , , AutoUHTabs
  For key, in ob2 {
    if (ob2[key].tabName = actTab) {
      tabid := key
      htkid := ob2[key].hotkeys.Count() + 1
      break
    }
  }
  if (htkid > 9) {
    MsgBox, You can't have more than 9 hotkeys.
    return
  }
	;Gui, Add, Hotkey, xs Section vTrigger_htk%tabid%%htkid% gTrigger_htk
	;Gui, Add, Text, ys vtHtkText%tabid%%htkid% w75,
	;GuiControl, MoveDraw, Trigger_htk%tabid%%htkid%, w75
  ; push new hotkey into the hotkey array
  ob2[tabid].hotkeys.Push("")
  Gosub, redrawGUIlabel
return

Rem_htk:
  GuiControlGet, actTab , , AutoUHTabs
  For key, in ob2 {
    if (ob2[key].tabName = actTab) {
      tabid := key
      htkid := ob2[key].hotkeys.Count()
      htk := ob2[key].hotkeys[ob2[key].hotkeys.MaxIndex()]
      ob2[key].hotkeys.Pop()
      ; check if hotkey isnt none
      len := StrLen(htk)
      if (len > 0) {
        Hotkey, ~%htk%, Uhaczka, Off
      }
      Gosub, redrawGUIlabel
      ; Turn off the hotkey
      break
    }
  }
return

redrawGUIlabel:
  WinGetPos, posX, posY, posW, posH, A
  GuiControlGet, actTab , , AutoUHTabs
  Gui, Destroy
  
  Gui, Add, Button, Section gNewTab, New tab
  Gui, Add, Text, ys W50

  tabNames := ""
  For key, in ob2 {
    tabNames := tabNames . ob2[key].tabName . "|"
  }
  tabNames := SubStr(tabNames, 1, StrLen(tabNames) - 1)

  Gui, Add, Tab3, xs Section vAutoUHTabs, %tabNames%
  GuiControl, ChooseString, AutoUHTabs, %actTab%
  For key, in ob2 {
    Gui, Tab, %A_Index%

    Gui, Add, GroupBox, Section w160 h60, Tab Edit
    Gui, Add, Button, xp+10 yp+20 gRenameTab, Rename tab
    Gui, Add, Button, xp+80 yp gDeleteTab, Delete tab

    Gui, Add, Text, xs Section, UH Rune Hotkey in game ; The ym option starts a new column of controls.
    Gui, Add, Hotkey, ys vUH_hotkey%key% gUhRuneChange, % ob2[key].uhHotkey
    
    Gui, Add, Button, xs Section w133 gSelectCoords vPixelBtn%key%, Select target position
    Gui, Add, Text, ys yp+5 vTankerPos%key% W90, % ob2[key].coords

    Gui, Add, Text, xs yp+40 Section, AutoUH Hotkeys.
    Gui, Add, Button, w40 gAdd_htk Section, Add
    Gui, Add, Button, w60 gRem_htk ys, Remove
    
    For i, in ob2[key].hotkeys {
      htk2 := ob2[key].hotkeys[i]
      Gui, Add, Hotkey, xs Section vTrigger_htk%key%%i% gTrigger_htk, %htk2%
      Gui, Add, Text, ys vtHtkText%key%%i% w75,
      Loop % mouseButtons.Count() {
        if (htk2 == mouseButtons[A_Index]) {
        GuiControl,, tHtkText%key%, %htk2%
        }
      }
      Hotkey, ~%htk2%, Uhaczka, On
    }
  }
  Gui, Margin, 10, 5
  Gui, Show, Y%posY% AutoSize, %Title%
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
    GuiControl, , %ctrl%, % Key  
    Loop % mouseButtons.Count() {
      if (Key == mouseButtons[A_Index]) {
        GuiControl, , tHtkText%num%, % Key
      }
    }
    SetHotkey(num, Key)
  return
#If

; Only triggers on hotkey change, if htk is same it doesn't trigger.
Trigger_htk:
	If %A_GuiControl%  in +,!,^,+^,+!,^!,+^!            ;If the hotkey contains only modifiers, return to wait for a key.
		return
	num := SubStr(A_GuiControl, -1)
  Key := % %A_GuiControl%
  SetHotkey(num, Key)
return

SetHotkey(num, key) {
	found1 := false
  	For k, in ob2 {
		numz := k
		For i, in ob2[k].hotkeys {
			iHotkey := ob2[k].hotkeys[i]
			if (key = iHotkey) {
				found1 := true
				dupx := k . i
				break
			}
		}

		if (found1 == true) {
      ; If duplicate hotkey is blank, do not alert it to user
      GuiControlGet, dupCtrl , , Trigger_htk%dupx%
      if (dupCtrl == "") {
        break
      }

      GuiControlGet, actTab , , AutoUHTabs
      For k, in ob2 {
        if (ob2[k].tabName = actTab) {
          duplicateTabID := k
          break
        }
      }
      ; search for current active tab id
      ; if current active id is different than duplicate hotkey tab id then msgbox it to the user
      ; if hotkey is duplicate but in different tab
      if (numz != duplicateTabID) {
        tabNm := ob2[numz].tabName
        MsgBox, Hotkey already exists in %tabNm% tab!
      }

      Loop,6 {
        GuiControl,% "Disable" b:=!b, Trigger_htk%dupx%   ;Flash the original hotkey to alert the user.
        Sleep,80
      }

      GuiControl, ,Trigger_htk%num%,% Trigger_htk%num% :=""       ;Delete the hotkey and clear the control.
			break
		}
	}

  i1 := SubStr(num, 1, 1)
  i2 := SubStr(num, 2, 1)
  oldHtk := ob2[i1].hotkeys[i2]
	If (oldHtk) { ;If a hotkey was already saved...
		Hotkey, %oldHtk%, Uhaczka, Off    ;     turn the old hotkey off
		oldHtk := ob2[i1].hotkeys[i2] := false        ;     add the word 'OFF' to display in a message.
    Loop % mouseButtons.Count() {
      if (oldHtk == mouseButtons[A_Index]) {
        GuiControl, , tHtkText%num%,
      }
    }
 	}

  if (!dupx) {
    Hotkey, ~%Key%, Uhaczka, On
    ob2[i1].hotkeys[i2] := key
    Loop % mouseButtons.Count() {
      if (Key == mouseButtons[A_Index]) {
        GuiControl, , tHtkText%num%, %key%
      }
    }
    WinActivate, Program Manager ; lose focus
  }
}

Uhaczka:
	if !(WinActive("Tibia -")) {
		return
	}
	thishot := A_ThisHotkey
	thishot := StrReplace(thishot, "~", "")
	; get last pressed hotkey, then search for this hotkey in the array of all
	found := false
	For key, in ob2 {
		numz := key
		For i, in ob2[key].hotkeys {
			if (thishot == ob2[key].hotkeys[i]) {
				found := true
				break
			}
		}
		if (found == true) {
			break
		}
	}

	GuiControlGet, coords , , TankerPos%numz%
	GuiControlGet, UH_Htk , , UH_hotkey%numz%

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

  ;sleep 35
  ;Send {k}

return

SelectCoords:
	PixelBtnNum := SubStr(A_GuiControl,A_GuiControl.length - 1)
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
		GuiControl, Text, TankerPos%PixelBtnNum%, x%xpos% y%ypos%
    xy := "x"xpos " y"ypos
    ob2[PixelBtnNum].coords := "x"xpos " y"ypos
		SetTimer, WatchCursor, Off
		ToolTip
		WinActivate, %A_ScriptName%
	}
return

SaveCache(ExitReason, ExitCode)
{
  parsedObj := JSON.Dump(ob2)
  SaveINI(parsedObj, cachePath)
}

SaveINI(json, file) {
  IniWrite, %json%, %file%, CacheSection, Settings
  return
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

Obj2Str(obj) { 
 
    Linear := isLinear(obj)
        
    For e, v in obj {
        if (Linear == False) {
            if (IsObject(v)) 
               r .= e ":" Obj2Str(v) ", "        
            else {                  
                r .= e ":"  
                if v is number 
                    r .= v ", "
                else 
                    r .= """" v """, " 
            }            
        } else {
            if (IsObject(v)) 
                r .= Obj2Str(v) ", "
            else {          
                if v is number 
                    r .= v ", "
                else 
                    r .= """" v """, " 
            }
        }
    }
    return Linear ? "[" trim(r, ", ") "]" 
                 : "{" trim(r, ", ") "}"
}

isLinear(obj) {

    n := obj.count(), i := 1   
    loop % (n / 2) + 1
        if (!obj[i++] || !obj[n--])
            return 0
    return 1
}

/**
 * Lib: JSON.ahk
 *     JSON lib for AutoHotkey.
 * Version:
 *     v2.1.3 [updated 04/18/2016 (MM/DD/YYYY)]
 * License:
 *     WTFPL [http://wtfpl.net/]
 * Requirements:
 *     Latest version of AutoHotkey (v1.1+ or v2.0-a+)
 * Installation:
 *     Use #Include JSON.ahk or copy into a function library folder and then
 *     use #Include <JSON>
 * Links:
 *     GitHub:     - https://github.com/cocobelgica/AutoHotkey-JSON
 *     Forum Topic - http://goo.gl/r0zI8t
 *     Email:      - cocobelgica <at> gmail <dot> com
 */


/**
 * Class: JSON
 *     The JSON object contains methods for parsing JSON and converting values
 *     to JSON. Callable - NO; Instantiable - YES; Subclassable - YES;
 *     Nestable(via #Include) - NO.
 * Methods:
 *     Load() - see relevant documentation before method definition header
 *     Dump() - see relevant documentation before method definition header
 */
class JSON
{
	/**
	 * Method: Load
	 *     Parses a JSON string into an AHK value
	 * Syntax:
	 *     value := JSON.Load( text [, reviver ] )
	 * Parameter(s):
	 *     value      [retval] - parsed value
	 *     text    [in, ByRef] - JSON formatted string
	 *     reviver   [in, opt] - function object, similar to JavaScript's
	 *                           JSON.parse() 'reviver' parameter
	 */
	class Load extends JSON.Functor
	{
		Call(self, ByRef text, reviver:="")
		{
			this.rev := IsObject(reviver) ? reviver : false
		; Object keys(and array indices) are temporarily stored in arrays so that
		; we can enumerate them in the order they appear in the document/text instead
		; of alphabetically. Skip if no reviver function is specified.
			this.keys := this.rev ? {} : false

			static quot := Chr(34), bashq := "\" . quot
			     , json_value := quot . "{[01234567890-tfn"
			     , json_value_or_array_closing := quot . "{[]01234567890-tfn"
			     , object_key_or_object_closing := quot . "}"

			key := ""
			is_key := false
			root := {}
			stack := [root]
			next := json_value
			pos := 0

			while ((ch := SubStr(text, ++pos, 1)) != "") {
				if InStr(" `t`r`n", ch)
					continue
				if !InStr(next, ch, 1)
					this.ParseError(next, text, pos)

				holder := stack[1]
				is_array := holder.IsArray

				if InStr(",:", ch) {
					next := (is_key := !is_array && ch == ",") ? quot : json_value

				} else if InStr("}]", ch) {
					ObjRemoveAt(stack, 1)
					next := stack[1]==root ? "" : stack[1].IsArray ? ",]" : ",}"

				} else {
					if InStr("{[", ch) {
					; Check if Array() is overridden and if its return value has
					; the 'IsArray' property. If so, Array() will be called normally,
					; otherwise, use a custom base object for arrays
						static json_array := Func("Array").IsBuiltIn || ![].IsArray ? {IsArray: true} : 0
					
					; sacrifice readability for minor(actually negligible) performance gain
						(ch == "{")
							? ( is_key := true
							  , value := {}
							  , next := object_key_or_object_closing )
						; ch == "["
							: ( value := json_array ? new json_array : []
							  , next := json_value_or_array_closing )
						
						ObjInsertAt(stack, 1, value)

						if (this.keys)
							this.keys[value] := []
					
					} else {
						if (ch == quot) {
							i := pos
							while (i := InStr(text, quot,, i+1)) {
								value := StrReplace(SubStr(text, pos+1, i-pos-1), "\\", "\u005c")

								static tail := A_AhkVersion<"2" ? 0 : -1
								if (SubStr(value, tail) != "\")
									break
							}

							if (!i)
								this.ParseError("'", text, pos)

							  value := StrReplace(value,  "\/",  "/")
							, value := StrReplace(value, bashq, quot)
							, value := StrReplace(value,  "\b", "`b")
							, value := StrReplace(value,  "\f", "`f")
							, value := StrReplace(value,  "\n", "`n")
							, value := StrReplace(value,  "\r", "`r")
							, value := StrReplace(value,  "\t", "`t")

							pos := i ; update pos
							
							i := 0
							while (i := InStr(value, "\",, i+1)) {
								if !(SubStr(value, i+1, 1) == "u")
									this.ParseError("\", text, pos - StrLen(SubStr(value, i+1)))

								uffff := Abs("0x" . SubStr(value, i+2, 4))
								if (A_IsUnicode || uffff < 0x100)
									value := SubStr(value, 1, i-1) . Chr(uffff) . SubStr(value, i+6)
							}

							if (is_key) {
								key := value, next := ":"
								continue
							}
						
						} else {
							value := SubStr(text, pos, i := RegExMatch(text, "[\]\},\s]|$",, pos)-pos)

							static number := "number", integer :="integer"
							if value is %number%
							{
								if value is %integer%
									value += 0
							}
							else if (value == "true" || value == "false")
								value := %value% + 0
							else if (value == "null")
								value := ""
							else
							; we can do more here to pinpoint the actual culprit
							; but that's just too much extra work.
								this.ParseError(next, text, pos, i)

							pos += i-1
						}

						next := holder==root ? "" : is_array ? ",]" : ",}"
					} ; If InStr("{[", ch) { ... } else

					is_array? key := ObjPush(holder, value) : holder[key] := value

					if (this.keys && this.keys.HasKey(holder))
						this.keys[holder].Push(key)
				}
			
			} ; while ( ... )

			return this.rev ? this.Walk(root, "") : root[""]
		}

		ParseError(expect, ByRef text, pos, len:=1)
		{
			static quot := Chr(34), qurly := quot . "}"
			
			line := StrSplit(SubStr(text, 1, pos), "`n", "`r").Length()
			col := pos - InStr(text, "`n",, -(StrLen(text)-pos+1))
			msg := Format("{1}`n`nLine:`t{2}`nCol:`t{3}`nChar:`t{4}"
			,     (expect == "")     ? "Extra data"
			    : (expect == "'")    ? "Unterminated string starting at"
			    : (expect == "\")    ? "Invalid \escape"
			    : (expect == ":")    ? "Expecting ':' delimiter"
			    : (expect == quot)   ? "Expecting object key enclosed in double quotes"
			    : (expect == qurly)  ? "Expecting object key enclosed in double quotes or object closing '}'"
			    : (expect == ",}")   ? "Expecting ',' delimiter or object closing '}'"
			    : (expect == ",]")   ? "Expecting ',' delimiter or array closing ']'"
			    : InStr(expect, "]") ? "Expecting JSON value or array closing ']'"
			    :                      "Expecting JSON value(string, number, true, false, null, object or array)"
			, line, col, pos)

			static offset := A_AhkVersion<"2" ? -3 : -4
			throw Exception(msg, offset, SubStr(text, pos, len))
		}

		Walk(holder, key)
		{
			value := holder[key]
			if IsObject(value) {
				for i, k in this.keys[value] {
					; check if ObjHasKey(value, k) ??
					v := this.Walk(value, k)
					if (v != JSON.Undefined)
						value[k] := v
					else
						ObjDelete(value, k)
				}
			}
			
			return this.rev.Call(holder, key, value)
		}
	}

	/**
	 * Method: Dump
	 *     Converts an AHK value into a JSON string
	 * Syntax:
	 *     str := JSON.Dump( value [, replacer, space ] )
	 * Parameter(s):
	 *     str        [retval] - JSON representation of an AHK value
	 *     value          [in] - any value(object, string, number)
	 *     replacer  [in, opt] - function object, similar to JavaScript's
	 *                           JSON.stringify() 'replacer' parameter
	 *     space     [in, opt] - similar to JavaScript's JSON.stringify()
	 *                           'space' parameter
	 */
	class Dump extends JSON.Functor
	{
		Call(self, value, replacer:="", space:="")
		{
			this.rep := IsObject(replacer) ? replacer : ""

			this.gap := ""
			if (space) {
				static integer := "integer"
				if space is %integer%
					Loop, % ((n := Abs(space))>10 ? 10 : n)
						this.gap .= " "
				else
					this.gap := SubStr(space, 1, 10)

				this.indent := "`n"
			}

			return this.Str({"": value}, "")
		}

		Str(holder, key)
		{
			value := holder[key]

			if (this.rep)
				value := this.rep.Call(holder, key, ObjHasKey(holder, key) ? value : JSON.Undefined)

			if IsObject(value) {
			; Check object type, skip serialization for other object types such as
			; ComObject, Func, BoundFunc, FileObject, RegExMatchObject, Property, etc.
				static type := A_AhkVersion<"2" ? "" : Func("Type")
				if (type ? type.Call(value) == "Object" : ObjGetCapacity(value) != "") {
					if (this.gap) {
						stepback := this.indent
						this.indent .= this.gap
					}

					is_array := value.IsArray
				; Array() is not overridden, rollback to old method of
				; identifying array-like objects. Due to the use of a for-loop
				; sparse arrays such as '[1,,3]' are detected as objects({}). 
					if (!is_array) {
						for i in value
							is_array := i == A_Index
						until !is_array
					}

					str := ""
					if (is_array) {
						Loop, % value.Length() {
							if (this.gap)
								str .= this.indent
							
							v := this.Str(value, A_Index)
							str .= (v != "") ? v . "," : "null,"
						}
					} else {
						colon := this.gap ? ": " : ":"
						for k in value {
							v := this.Str(value, k)
							if (v != "") {
								if (this.gap)
									str .= this.indent

								str .= this.Quote(k) . colon . v . ","
							}
						}
					}

					if (str != "") {
						str := RTrim(str, ",")
						if (this.gap)
							str .= stepback
					}

					if (this.gap)
						this.indent := stepback

					return is_array ? "[" . str . "]" : "{" . str . "}"
				}
			
			} else ; is_number ? value : "value"
				return ObjGetCapacity([value], 1)=="" ? value : this.Quote(value)
		}

		Quote(string)
		{
			static quot := Chr(34), bashq := "\" . quot

			if (string != "") {
				  string := StrReplace(string,  "\",  "\\")
				; , string := StrReplace(string,  "/",  "\/") ; optional in ECMAScript
				, string := StrReplace(string, quot, bashq)
				, string := StrReplace(string, "`b",  "\b")
				, string := StrReplace(string, "`f",  "\f")
				, string := StrReplace(string, "`n",  "\n")
				, string := StrReplace(string, "`r",  "\r")
				, string := StrReplace(string, "`t",  "\t")

				static rx_escapable := A_AhkVersion<"2" ? "O)[^\x20-\x7e]" : "[^\x20-\x7e]"
				while RegExMatch(string, rx_escapable, m)
					string := StrReplace(string, m.Value, Format("\u{1:04x}", Ord(m.Value)))
			}

			return quot . string . quot
		}
	}

	/**
	 * Property: Undefined
	 *     Proxy for 'undefined' type
	 * Syntax:
	 *     undefined := JSON.Undefined
	 * Remarks:
	 *     For use with reviver and replacer functions since AutoHotkey does not
	 *     have an 'undefined' type. Returning blank("") or 0 won't work since these
	 *     can't be distnguished from actual JSON values. This leaves us with objects.
	 *     Replacer() - the caller may return a non-serializable AHK objects such as
	 *     ComObject, Func, BoundFunc, FileObject, RegExMatchObject, and Property to
	 *     mimic the behavior of returning 'undefined' in JavaScript but for the sake
	 *     of code readability and convenience, it's better to do 'return JSON.Undefined'.
	 *     Internally, the property returns a ComObject with the variant type of VT_EMPTY.
	 */
	Undefined[]
	{
		get {
			static empty := {}, vt_empty := ComObject(0, &empty, 1)
			return vt_empty
		}
	}

	class Functor
	{
		__Call(method, ByRef arg, args*)
		{
		; When casting to Call(), use a new instance of the "function object"
		; so as to avoid directly storing the properties(used across sub-methods)
		; into the "function object" itself.
			if IsObject(method)
				return (new this).Call(method, arg, args*)
			else if (method == "")
				return (new this).Call(arg, args*)
		}
	}
}