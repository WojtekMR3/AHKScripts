#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetControlDelay, 0

PgUp::
  ControlSend,, {R}, Tibia -
  SetTimer, SMP, % (Toggle:=!Toggle) ? 500 : "Off"
Return

Return

SMP:
  Random, rnd, 0, 15
  Sleep, %rnd%
  ControlSend,, {R}, Tibia -
return