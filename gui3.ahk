#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include lib/Graphics.ahk

f6::suspend
f11::ExitApp
f12::
  mousegetpos,,,win

  gui, +Lastfound -Caption +ToolWindow +Border
  myguihwnd := WinExist()
  gui, add, text,, helloworld

  DllCall("SetParent", "uint", myguihwnd, "uint", win)
  gui, show
return