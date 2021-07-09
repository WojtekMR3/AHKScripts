#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

~space::

if !(WinActive("Tibia -")) {
 return
}

sleep 35
SendInput, {Shift down}
sleep 1
;controlSend,, {Shift down}, Tibia -
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
;ControlSend,, {Shift up}, Tibia -

return