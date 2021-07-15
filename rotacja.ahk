#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;NumpadEnd::Reload

; Aktywacja rotacji klawiszem
~space::
  ; Ilość powtórzen pętli
  Loop, 2 {
    ; Odstęp 55 ms po auto ataku
    Sleep 55
    ; Mas San
    ControlSend,, {6}, Tibia -
    ; 2s CD przed kolejnym auto atakiem
    Sleep 2000
    ; Odstęp 55 ms po auto ataku
    Sleep 55
    ; Ava
    ControlSend,, {5}, Tibia -
    ; 2s CD przed kolejnym auto atakiem
    Sleep 2000
  }