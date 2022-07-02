#NoEnv
#SingleInstance off  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetControlDelay -1
SetBatchLines, -1
SetMouseDelay, -1

tempVal = %A_ScriptFullPath%:Stream:$DATA
Global cachePath := tempVal
Global Modifiers := {"Alt": "!", "Ctrl": "^", "Shift": "+"}
Global mouseButtons = ["LButton", "RButton", "MButton", "WheelUp", "WheelDown", "XButton1", "XButton2", "WheelLeft", "WheelRight"]
Global kbdKeys = ["Delete", "Escape", "Space", "Tab", "PgUp", "PgDn", "Home", "End"]

IniRead, res, %cachePath%, CacheSection, Settings
if (res = "ERROR") {
  Global settings := {tabs: {"Elite Knight": {coords: "x10, y10", hotkeys: ["F4"]}, "Royal Paladin": {coords: "x20, y20", hotkeys: []}}
  , globals: {pauseHot: "F1", reloadHot: "F2", closeHot: "F3", uhHotkey: "F12", guiPos: "x0 y0"}}
} else {
  Global settings := JSON.load(res)
}

;MsgBox, % Obj2Str(arr2)

rowC := settings.tabs.Count()
if (rowC <= 5) {
  LrowC := 5 
} else {
  LrowC := settings.tabs.Count() + 1
}
Gui, Add, ListView, Section r%LrowC% w150 -Multi vLVtabs, Name
For tab in settings.tabs {
  LV_Add(, tab)
}
LV_ModifyCol(1, Auto)

Gui, Add, GroupBox, xp+160 yp w100 h115, Tab Editor
Gui, Add, Button, xp+10 yp+20 w80 gNewTab, New tab
Gui, Add, Button, xp yp+30 w80 gRenameTab, Rename tab
Gui, Add, Button, xp yp+30 w80 gDeleteTab, Delete tab

Gui, Margin, 10, 15

Gui, Add, Text, xs Section, UH Rune Hotkey in game ; The ym option starts a new column of controls.
uhHtk := settings.globals.uhHotkey
Gui, Add, Hotkey, ys vUhRune_hotkey, %uhHtk%

Gui, Margin, 10, 5

tabNames := ""
For tab, in settings.tabs {
  tabNames := tabNames . tab . "|"
}
tabNames := SubStr(tabNames, 1, StrLen(tabNames) - 1)

Gui, Add, Tab3, xs Section vAutoUHTabs, %tabNames%
For tab, in settings.tabs {
  ;tabI := tab
  tabI := A_Index
	Gui, Tab, %tabI%

	Gui, Add, Button, Section w133 gSelectCoords vPixelBtn%tabI%, Select target position
	Gui, Add, Text, ys yp+5 vTankerPos%tabI% W80, % settings.tabs[tab].coords

	Gui, Add, Text, xs yp+40 Section, AutoUH Hotkeys.
	Gui, Add, Button, w40 gAdd_htk Section, Add
	Gui, Add, Button, w60 gRem_htk ys, Remove
	
	For i, in settings.tabs[tab].hotkeys {
		htk := settings.tabs[tab].hotkeys[i]
		Gui, Add, Hotkey, xs Section vTrigger_htk%tabI%_%i% gTrigger_htk, %htk%
		Gui, Add, Text, ys vtHtkText%tabI%_%i% w75,
	 	Loop % mouseButtons.Count() {
		  if (htk == mouseButtons[A_Index]) {
			GuiControl, , tHtkText%tabI%_%i%, %htk%
		  }
		}
		Hotkey, ~%htk%, Uhaczka, On
	}
}

Gui, Add, StatusBar,,
SB_SetText("AutoUH by Frostspiked", 1)

; Remove '.ahk' from title
;Global Title := StrReplace(A_ScriptName, .ahk, " ")
Global Title = A_ScriptName
Gui, Margin, 10, 5
guiPos := settings.globals.guiPos
guiPos := guiPosVerify(guiPos)
Gui, Show, %guiPos% AutoSize, %Title%

OnExit("SaveCache")
return

~^s::
    if WinExist("ahk_exe Code.exe") or WinExist("ahk_class Notepad++") {
      Reload
    }
return

~End::
    if WinExist("ahk_exe Code.exe") or WinExist("ahk_class Notepad++") {
      ExitApp
    }
return

GuiClose:
	ExitApp
return

NewTab:
  len := settings.tabs.Count()+1
  InputBox, tabName, New tab, (New tab name),,220,150,,,,, ek%len% 

 if (ErrorLevel != 0) {
    return
 }

 if (StrLen(tabName) = 0) {
    MsgBox, Tab name is empty!
    return
 }

  if (settings.tabs.HasKey(tabName)) {
    MsgBox, Tab name exists!
    return
  }

  settings.tabs[tabName] := {coords: "x0, y0", hotkeys: []}
  Gosub, redrawGUIlabel
  GuiControl, ChooseString, AutoUHTabs, %tabName%
return

RenameTab:
  rn := LV_GetNext()
  if (rn = 0) {
    MsgBox, select tab to edit!
    return
  }
  LV_GetText(actTab, rn)
  ;GuiControlGet, actTab , , AutoUHTabs
  InputBox, newTname, New tab, (New tab name),,220,150,,,,, %actTab%
  if (ErrorLevel != 0) {
      return
  }

  if (StrLen(newTname) = 0) {
      MsgBox, Tab name is empty!
      return
  }

  if (settings.tabs.HasKey(newTname)) {
    MsgBox, Tab name exists!
    return
  }
  settings.tabs[newTname] := settings.tabs[actTab]
  settings.tabs.Delete(actTab)
  Gosub, redrawGUIlabel
  GuiControl, ChooseString, AutoUHTabs, %newTname%
return

DeleteTab:
  rn := LV_GetNext()
  if (rn = 0) {
    MsgBox, select tab to edit!
    return
  }
  LV_GetText(actTab, rn)
  ;GuiControlGet, actTab , , AutoUHTabs
  For i, in settings.tabs[actTab].hotkeys {
    htk := settings.tabs[actTab].hotkeys[i]
    Hotkey, ~%htk%, Uhaczka, Off
  }
  settings.tabs.Delete(actTab)
  Gosub, redrawGUIlabel
return

Add_htk:
	GuiControlGet, actTab , , AutoUHTabs
  settings.tabs[actTab].hotkeys.Push("")
  Gosub, redrawGUIlabel
return

Rem_htk:
  GuiControlGet, actTab , , AutoUHTabs
  htk := settings.tabs[actTab].hotkeys[settings.tabs[actTab].hotkeys.MaxIndex()]
  settings.tabs[actTab].hotkeys.Pop()
  ; check if hotkey isnt none
  len := StrLen(htk)
  if (len > 0) {
    Hotkey, ~%htk%, Uhaczka, Off
  }
  Gosub, redrawGUIlabel
  ; Turn off the hotkey
return

redrawGUIlabel:
  WinGetPos, posX, posY, posW, posH, A
  GuiControlGet, actTab , , AutoUHTabs
  Gui, Destroy
  
  rowC := settings.tabs.Count()
  if (rowC < 5) {
    LrowC := 5 
  } else {
    LrowC := settings.tabs.Count()
  }
  Gui, Add, ListView, Section r%LrowC% w150 -Multi vLVtabs, Name
  For tab in settings.tabs {
    LV_Add(, tab)
  }
  LV_ModifyCol(1, Auto)

  Gui, Add, GroupBox, xp+160 yp w100 h115, Tab Editor
  Gui, Add, Button, xp+10 yp+20 w80 gNewTab, New tab
  Gui, Add, Button, xp yp+30 w80 gRenameTab, Rename tab
  Gui, Add, Button, xp yp+30 w80 gDeleteTab, Delete tab

  Gui, Add, Text, xs Section, UH Rune Hotkey in game ; The ym option starts a new column of controls.
  Gui, Add, Hotkey, ys vUhRune_hotkey, F12

  tabNames := ""
  For tab, in settings.tabs {
    tabNames := tabNames . tab . "|"
  }
  tabNames := SubStr(tabNames, 1, StrLen(tabNames) - 1)

  Gui, Add, Tab3, xs Section vAutoUHTabs, %tabNames%
  GuiControl, ChooseString, AutoUHTabs, %actTab%
  For tab, in settings.tabs {
    tabI := A_Index
    Gui, Tab, %tabI%

    Gui, Add, Button, Section w133 gSelectCoords vPixelBtn%tabI%, Select target position
    Gui, Add, Text, ys yp+5 vTankerPos%tabI% W80, % settings.tabs[tab].coords

    Gui, Add, Text, xs yp+40 Section, AutoUH Hotkeys.
    Gui, Add, Button, w40 gAdd_htk Section, Add
    Gui, Add, Button, w60 gRem_htk ys, Remove
    
    For i, in settings.tabs[tab].hotkeys {
      htk := settings.tabs[tab].hotkeys[i]
      Gui, Add, Hotkey, xs Section vTrigger_htk%tabI%_%i% gTrigger_htk, %htk%
      Gui, Add, Text, ys vtHtkText%tabI%_%i% w75,
      Loop % mouseButtons.Count() {
        if (htk == mouseButtons[A_Index]) {
        GuiControl, , tHtkText%tabI%_%i%, %htk%
        }
      }
      Hotkey, ~%htk%, Uhaczka, On
    }
  }
  Gui, Margin, 10, 5
  Gui, Show, AutoSize X%posX% Y%posY%, %Title%
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
    num := StrReplace(ctrl, "Trigger_htk", "")
    Key := modifier SubStr(A_ThisHotkey,2)
    if (HasVal(mouseButtons, key) > 0) { 
      textControl := StrReplace(ctrl, "Trigger_htk", "tHtkText")
      GuiControl, , %textControl%, % Key
    }
    SetHotkey(num, Key)
  return
#If

; Only triggers on hotkey change, if htk is same it doesn't trigger.
Trigger_htk:
	If %A_GuiControl%  in +,!,^,+^,+!,^!,+^!            ;If the hotkey contains only modifiers, return to wait for a key.
		return
	num := StrReplace(A_GuiControl, "Trigger_htk", "")
  Key := % %A_GuiControl%
  SetHotkey(num, Key)
return

SetHotkey(num, key) {
	found1 := false
  	For tab, in settings.tabs {
      tabI := A_Index
      dupTabName := tab
      For i, in settings.tabs[tab].hotkeys {
        iHotkey := settings.tabs[tab].hotkeys[i]
        if (key = iHotkey) {
          found1 := true
          dupx := tabI . "_" . i
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
      if (dupTabName != actTab) {
        MsgBox, Hotkey already exists in %dupTabName% tab!
      }

      Loop,6 {
        GuiControl,% "Disable" b:=!b, Trigger_htk%dupx%   ;Flash the original hotkey to alert the user.
        Sleep,80
      }

      GuiControl, ,Trigger_htk%num%,% Trigger_htk%num% :=""       ;Delete the hotkey and clear the control.
			break
		}
	}

  word_array := StrSplit(num, "_", "")
  tabI := word_array[1]
  ; convert tabI to key
  For tab in settings.tabs {
    if (tabI == A_Index) {
      tabK := tab
      break
    }
  }
  hotI := word_array[2]
  ;MsgBox, % tabI
  ;MsgBox, % hotI
  oldHtk := settings.tabs[tabK].hotkeys[hotI]
	If (oldHtk) { ;If a hotkey was already saved...
		Hotkey, %oldHtk%, Uhaczka, Off    ;     turn the old hotkey off
		settings.tabs[tabK].hotkeys[hotI] := false        ;     add the word 'OFF' to display in a message.
    if (HasVal(mouseButtons, oldHtk) > 0) { 
      GuiControl, , tHtkText%tabI%_%hotI%,
    }
 	}

  if (!dupx) {
    Hotkey, ~%Key%, Uhaczka, On
    settings.tabs[tabK].hotkeys[hotI] := key

    if (HasVal(mouseButtons, key) > 0) { 
      GuiControl, , tHtkText%tabI%_%hotI%, %key%
      GuiControl, , Trigger_htk%tabI%_%hotI%,
    }

    if (HasVal(kbdKeys, key) > 0) {
      GuiControl, , Trigger_htk%tabI%_%hotI%, %key%
    }

    WinActivate, Program Manager ; lose focus
  }
}

Uhaczka:
	if !(WinActive("Tibia -")) or (WinActive("ahk_class Chrome_WidgetWin_1")) {
		return
	}
  ;MsgBox, uha
	thishot := A_ThisHotkey
	thishot := StrReplace(thishot, "~", "")
	; get last pressed hotkey, then search for this hotkey in the array of all
	found := false
  targetCoords := "x0 y0"
	For tab, in settings.tabs {
		fnTab := tab
		For i, in settings.tabs[tab].hotkeys {
			if (thishot == settings.tabs[tab].hotkeys[i]) {
				found := true
        targetCoords := settings.tabs[tab].coords
				break
			}
		}
		if (found == true) {
			break
		}
	}

	GuiControlGet, UH_Htk , , UhRune_hotkey

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
	ControlClick, %targetCoords%, Tibia -,,Left
  Sleep 50

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
    For tab in settings.tabs {
      if (A_Index == PixelBtnNum) {
        settings.tabs[tab].coords := "x"xpos " y"ypos
        break
      }
    }
		SetTimer, WatchCursor, Off
		ToolTip
		WinActivate, %A_ScriptName%
	}
return

SaveCache(ExitReason, ExitCode)
{
  GuiControlGet, UH_Htk , , UhRune_hotkey
  settings.globals.uhHotkey := UH_Htk

  WinGetPos, guiX, guiY,,, %Title%
  guiPos := "x" . guiX . " y" guiY
  settings.globals.guiPos := guiPos

  parsedObj := JSON.Dump(settings)
  SaveINI(parsedObj, cachePath)
}

SaveINI(json, file) {
  IniWrite, %json%, %file%, CacheSection, Settings
  return
}

guiPosVerify(guiPos) {
  guiPos := RegExReplace(guiPos, "x|y", "")
  guiPosArr := StrSplit(guiPos, " ", "")
  guiX := guiPosArr[1]
  guiY := guiPosArr[2]

  SysGet, minX, 76
  SysGet, minY, 77

  SysGet, totalX, 78
  SysGet, maxY, 79

  ;MsgBox, %guiX% %guiY% %minX% %totalX%
  if ((guiX < minX) or (guiX > totalX)) {
    guiX := Floor(A_ScreenWidth/2)-100
  }

  if ((guiY < minY) or (guiY > maxY)) {
    guiY := Floor(A_ScreenHeight/2)-50
  }

  guiPos := "x" guiX " y"guiY
  return guiPos
}

HasVal(haystack, needle) {
	if !(IsObject(haystack)) || (haystack.Length() = 0)
		return 0
	for index, value in haystack
		if (value = needle)
			return index
	return 0
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