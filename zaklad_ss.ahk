#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


^z::
CoordMode, Screen
PixelGetColor, clr, -219, 247
MsgBox The color at the current cursor position is %clr%.
If (clr = 0x4D4A48) {
 Send, {F2}
}

return
