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
BlockInput On
SendInput, {Shift down}
sleep 1
SetControlDelay -1

ControlClick, x1370 y560, Tibia ,,Right
ControlClick, x1370 y470, Tibia ,,Right
ControlClick, x1470 y470, Tibia ,,Right

ControlClick, x1470 y560, Tibia ,,Right
ControlClick, x1470 y660, Tibia ,,Right
ControlClick, x1370 y660, Tibia ,,Right

ControlClick, x1280 y660, Tibia ,,Right
ControlClick, x1280 y560, Tibia ,,Right
ControlClick, x1280 y470, Tibia ,,Right

SendInput, {Shift up}
BlockInput, Off
While(getKeyState("Shift")){
    SendInput, {Shift up}
    sleep 30
}

return