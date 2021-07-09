obf_copyright := " Date: 17:29 piątek, 28 maja 2021               "
obf_copyright := "                                                "
obf_copyright := " THE FOLLOWING AUTOHOTKEY SCRIPT WAS OBFUSCATED "
obf_copyright := " BY DYNAMIC OBFUSCATOR L FOR AUTOHOTKEY         "
obf_copyright := " By DigiDon                                     "
obf_copyright := "                                                "
obf_copyright := " Based on DYNAMIC OBFUSCATOR                    "
obf_copyright := " Copyright (C) 2011-2013  David Malia           "
obf_copyright := " DYNAMIC OBFUSCATOR is released under           "
obf_copyright := " the Open Source GPL License                    "

;autoexecute
#Include lib/iniMaker.ahk
#Include lib/JSON.ahk
#Include lib/obfuscation/encoder.ahk
#NoEnv 
#SingleInstance off
SendMode Input 
SetWorkingDir %A_ScriptDir% 
SetControlDelay -1
Global IniSections := []
Global IniSections ["Singular"]
:= { posx: "0"
,	posy: "0"
,	color: "0x00FF00"
,	htk: "f3"}
Global IniSections ["UhaczkaHotkeys"] := {}
cachePth = %A_ScriptFullPath%:Stream:$DATA
Global cachePath := cachePth
Global ini := ReadINI(cachePath)
if (!ini.Singular.count()) {
ini.Singular := IniSections.Singular.Clone()
ini.Singular.posx := IniSections.Singular.posx
ini.Singular.posy := IniSections.Singular.posy
ini.Singular.color := IniSections.Singular.color
ini.Singular.htk := IniSections.Singular.htk
}
Gui, Show, X200 Y200 W300 H300
Gui, Add, Button, w133 g@fff@ffk@k#fk@#f@k@kk##ff@f#k@ffk@f@@f, Select target position
Gui, Add, Text, vtargetPosX, 0
Gui, Add, Text, vtargetPosY, 0
Gui, Add, Text, vtargetColor, 0x000000
Gui, Add, Hotkey, vHtk, F2
Gui, Add, Button, w100 gkff#kkfkfkff#ff#fkkfk##kf##k@ff@fff@#fk@, Start
Gui, Add, Button, w100 gfkfffff@f#k#kff@k@#kk@k@k@f@fkkff@, Stop
GuiControl, Text, targetPosX, % ini["Singular"].posx
GuiControl, Move, targetPosX, W300
GuiControl, Text, targetPosY, % ini["Singular"].posy
GuiControl, Move, targetPosY, W300
GuiControl, Text, targetColor, % ini["Singular"].color
GuiControl, Move, targetColor, W300
GuiControl, Text, Htk, % ini["Singular"].htk
SB_S%#kkf%e%#ff##f%tText(decode_hidestr("aba4deb6be3bad1af18a31dbd21bd2cac238ad6bc1"))
kkf@k%#ff#ffkf%kkfkffk()
On%kkf@%%kkf@%Exit("@k#f@kfk@fkk")
return
GuiClose:
ExitApp
return
fkfffff@f#k#kff@k@#kk@k@k@f@fkkff@:
SetTimer, f%k@kff@#f%k#ffk#k%kkkkfkfk%f#ffk#kkkkkkf#ff#k@k#fkkk@k@, Off
return
return
@k#f@kfk@fkk(f#ff@kkkk#kf#k@f, f##k@kfk@kk#k@) { 
GuiControlGet, posx ,, targetPosX
IniSections["Singular"].posx := posx
GuiControlGet, posy ,, targetPosY
IniSections["Singular"].posy := posy
GuiControlGet, color ,, targetColor
IniSections["Singular"].color := color
GuiControlGet, htk ,, Htk
IniSections["Singular"].htk := htk
WriteINI(IniSections, cachePath)
}
kff#kkfkfkff#ff#fkkfk##kf##k@ff@fff@#fk@:
WinActivate, Tibia -
SetTimer, fk#ff%@f#kfk#f%k#kf#ffk#kkkkkkf#ff#k@k#fkkk@k@, 40
return
@fff@ffk@k#fk@#f@k@kk##ff@f#k@ffk@f@@f:
WinActivate, Tibia -
SetTimer, f#%k#f@%k#%f#f##kkk%fffff#k@#fffk@#k@k@kk@kf@kfkkk, 35
return
return
kkf@kkkfkffk() {
SB_S%fkk##f@k%etTe%@fff@f%xt(decode_hidestr("6b631ef57e7a6d59b1c9f11a925a920982776daa81"))
}
fk#ffk#kf#ffk#kkkkkkf#ff#k@k#fkkk@k@:
GuiControlGet, tPosX ,, targetPosX
GuiControlGet, tPosY ,, targetPosY
GuiControlGet, tColor ,, targetColor
GuiControlGet, hotkey ,, Htk
PixelGetColor, color, %tPosX%, %tPosY%
if (tColor = color) {
ControlSend,, {%hotkey%}, Tibia -
sleep 180
}
return
f#k#fffff#k@#fffk@#k@k@kk@kf@kfkkk:
CoordMode, Mouse, Relative
MouseGetPos, MouseX, MouseY
PixelGetColor, clr, %MouseX%, %MouseY%
ToolTip, `Select Position and Color`n`x: %MouseX% y: %MouseY% color: %clr%`
if (GetKeyState("LButton")) {
MsgBox, , , %MouseX% %MouseY%, 0.3
BlockInput, Mouse
GuiControl, Text, targetPosX, %MouseX%
GuiControl, Move, targetPosX, W300
GuiControl, Text, targetPosY, %MouseY%
GuiControl, Move, targetPosY, W300
GuiControl, Text, targetColor, %clr%
GuiControl, Move, targetColor, W300
SetTimer, f#%kf@fk@f@%k#fffff#k@#fffk@#k@k@kk@kf@kfkkk, Off
ToolTip
}
return
