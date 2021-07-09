#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetControlDelay, 0

PgDn::
  ControlSend,, {F10}, Tibia -
  SetTimer, Exura, % (Toggle:=!Toggle) ? 1000 : "Off"
Return

Return

Exura:
  Random, rnd, 0, 40
  Sleep, %rnd%
  ControlSend,, {F10}, Tibia -
  Random, rnd, 0, 20
  Sleep, %rnd%
  ControlSend,, {F10}, Tibia -
return