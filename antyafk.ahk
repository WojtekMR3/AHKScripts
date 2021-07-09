#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


SetControlDelay -1
Loop {
	rot()
	Sleep 1000*60*14
}

rot() {
    ControlFocus,, Tibia -
    Directions := ["Right", "Left", "Down", "Up"]
    Random, ran, 1,Directions.MaxIndex()
    stDir := Directions[ran]
    Directions.RemoveAt(ran)
    Random, ran, 1,Directions.MaxIndex()
    ndDir := Directions[ran]
   	Send, {Ctrl down}
    
	sleep 150
	ControlSend, ,^{%stDir% Down}, Tibia -
    ControlSend, , ^{%stDir% Up}, Tibia -
    sleep 250
    ControlSend, ,^{%ndDir% Down}, Tibia -
    ControlSend, , ^{%ndDir% Up}, Tibia -
    
    ;ControlSend, ,{^ Up}, Tibia -
	Send, {Ctrl up}
   return
}