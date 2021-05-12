#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include lib/Graphics.ahk

global cycles := 12
global delay:= 0
global g := new Graphics.TextRenderer
g.Draw("Status: Active", "c:Off", "s:18pt f:(Avenir LT Pro 55 Roman) c:00A900 x:1375 y:50")
g.Render()
return

f7::
	suspend
	if (A_IsSuspended) {
		g.Draw("Status: Suspended", "c:Off", "s:18pt f:(Avenir LT Pro 55 Roman) c:FFB900 x:1375 y:50")
		g.Render()
	} else {
		g.Draw("Status: Active", "c:Off", "s:18pt f:(Avenir LT Pro 55 Roman) c:00A900 x:1375 y:50")
		g.Render()
	}
return

~space::

if !(WinActive("Tibia -")) {
 return
}

sleep 35
SendInput, {Shift down}
sleep 1
SetControlDelay -1

ControlClick, x963 y384, Tibia ,,Right
ControlClick, x967 y321, Tibia ,,Right
ControlClick, x1031 y327, Tibia ,,Right

ControlClick, x1019 y387, Tibia ,,Right
ControlClick, x1025 y455, Tibia ,,Right
ControlClick, x959 y447, Tibia ,,Right

ControlClick, x913 y455, Tibia ,,Right
ControlClick, x911 y385, Tibia ,,Right
ControlClick, x900 y321, Tibia ,,Right

SendInput, {Shift up}
KeyWait, Shift

return