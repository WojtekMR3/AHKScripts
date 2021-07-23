; Script by lord_ne

; Some code taken from the "Using a Joystick as a Mouse" sample script

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

ActiveMode = 1 ; 1 attempts to click without activating the target window (behavior may be inconsistent)
;                2 activates the target window but immediately deactivates it in favor of the previously active window
;                3 activates the target window and allows it to remain active (keyboard inputs will be sent to that window)

JoyMultiplier = 0.25 ; Multiplier for mouse speed

JoyThreshold = 3 ; Joystick threshold for mouse movement; prevents cursor drift

InvertYAxis := false ; "true" inverts the YAxis

JoystickNumber = 1 ; If you have multiple joysticks connected

Xres=1600
;   ↑↓ Screen resolution
Yres=900

CursorImage=C:\Users\Laptop\Documents\arrowicon.png ; Image to be used as second cursor

;End of config section. To change the Left and Right Click buttons, edit the hotkeys at the bottom of the script

#SingleInstance

JoystickPrefix = %JoystickNumber%Joy

JoyThresholdUpper := 50 + JoyThreshold
JoyThresholdLower := 50 - JoyThreshold
if InvertYAxis
    YAxisMultiplier = -1
else
    YAxisMultiplier = 1
	
Xpos=0

Ypos=0

Coordmode, Mouse, Screen

Gui, MouseGui: New, , Cursor
Gui, MouseGui:Margin , 0, 0
Gui, MouseGui:Add, Picture, +BackgroundTrans, %CursorImage%
Gui, MouseGui:Color, ECE9D8
Gui, MouseGui:+LastFound -Caption +AlwaysOnTop +ToolWindow -Border
Winset, TransColor, ECE9D8
Gui, MouseGui:Show, x%Xpos% y%Ypos% NoActivate, Cursor

SetTimer, WatchJoystick, 10  


return  ; End of auto-execute section.


WatchJoystick:
MouseNeedsToBeMoved := false  
SetFormat, float, 03
GetKeyState, joyx, %JoystickNumber%JoyX
GetKeyState, joyy, %JoystickNumber%JoyY
if joyx > %JoyThresholdUpper%
{
    MouseNeedsToBeMoved := true
    DeltaX := joyx - JoyThresholdUpper
}
else if joyx < %JoyThresholdLower%
{
    MouseNeedsToBeMoved := true
    DeltaX := joyx - JoyThresholdLower
}
else
    DeltaX = 0
if joyy > %JoyThresholdUpper%
{
    MouseNeedsToBeMoved := true
    DeltaY := joyy - JoyThresholdUpper
}
else if joyy < %JoyThresholdLower%
{
    MouseNeedsToBeMoved := true
    DeltaY := joyy - JoyThresholdLower
}
else
    DeltaY = 0
if MouseNeedsToBeMoved
{
    Xpos:=Xpos+(DeltaX * JoyMultiplier)
	Ypos:=Ypos+(DeltaY * JoyMultiplier * YAxisMultiplier)
	if (Xpos<0)
	{
	  Xpos=0
	}
	if (Ypos<0)
	{
	  Ypos=0
	}
	if (Xpos>Xres)
	{
	  Xpos:=Xres
	}
	if (Ypos>Yres)
	{
	  Ypos:=Yres
	}
	
    Gui, MouseGui:Show, NoActivate x%Xpos% y%Ypos%, Cursor
}
return

!F1::
  ActiveMode=1
return

!F2::
  ActiveMode=2
return

!F3::
  ActiveMode=3
return

#If (ActiveMode = 1)

Joy5::
   PX:=Xpos - 1
   PY:=Ypos - 1
   VarSetCapacity(POINT, 8, 0)
   NumPut(PX, POINT, 0, "Int"), NumPut(PY, POINT, 4, "Int")
   HWND := DllCall("WindowFromPoint", "Int64", NumGet(POINT, 0, "Int64"))
   HWND := DllCall("GetAncestor", "UInt", HWND, "UInt", GA_ROOT := 2)
   WinExist("ahk_id" . HWND)
   WinGetTitle, Title
   WinGetClass, Class
   WinGetPos, X, Y, W, H
   XWin:= Xpos - X
   Ywin:= Ypos - Y
   WinGetTitle, TitleA, A
   SetControlDelay -1
   ControlClick, x%XWin% y%YWin%, %Title%, , LEFT, , NA
   WinActivate, %TitleA%
   Sleep, 10
   WinActivate, %TitleA%
   Sleep, 10
   WinActivate, %TitleA%
   Sleep, 10
   WinActivate, %TitleA%
   Sleep, 10
   WinActivate, %TitleA%
return

Joy6::
   PX:=Xpos - 1
   PY:=Ypos - 1
   VarSetCapacity(POINT, 8, 0)
   NumPut(PX, POINT, 0, "Int"), NumPut(PY, POINT, 4, "Int")
   HWND := DllCall("WindowFromPoint", "Int64", NumGet(POINT, 0, "Int64"))
   HWND := DllCall("GetAncestor", "UInt", HWND, "UInt", GA_ROOT := 2)
   WinExist("ahk_id" . HWND)
   WinGetTitle, Title
   WinGetClass, Class
   WinGetPos, X, Y, W, H
   XWin:= Xpos - X
   Ywin:= Ypos - Y
   WinGetTitle, TitleA, A
   SetControlDelay -1
   ControlClick, x%XWin% y%YWin%, %Title%, , RIGHT, , NA
   WinActivate, %TitleA%
   Sleep, 10
   WinActivate, %TitleA%
   Sleep, 10
   WinActivate, %TitleA%
   Sleep, 10
   WinActivate, %TitleA%
   Sleep, 10
   WinActivate, %TitleA%
return

#If (ActiveMode = 2)

Joy5::
   PX:=Xpos - 1
   PY:=Ypos - 1
   WinGetTitle, TitleA, A
   mousegetpos, start_x, start_y
   mouseclick, left, %PX%, %PY%, 1, 0
   mousemove, %start_x%, %start_y%, 0
   WinActivate, %TitleA%
   Sleep, 10
   WinActivate, %TitleA%
   Sleep, 10
   WinActivate, %TitleA%
   Sleep, 10
   WinActivate, %TitleA%
   Sleep, 10
   WinActivate, %TitleA%
return

Joy6::
   PX:=Xpos - 1
   PY:=Ypos - 1
   WinGetTitle, TitleA, A
   mousegetpos, start_x, start_y
   mouseclick, right, %PX%, %PY%, 1, 0
   mousemove, %start_x%, %start_y%, 0
   WinActivate, %TitleA%
   Sleep, 10
   WinActivate, %TitleA%
   Sleep, 10
   WinActivate, %TitleA%
   Sleep, 10
   WinActivate, %TitleA%
   Sleep, 10
   WinActivate, %TitleA%
return

#If (ActiveMode = 3)

Joy5::
   PX:=Xpos - 1
   PY:=Ypos - 1
   mousegetpos, start_x, start_y
   mouseclick, left, %PX%, %PY%, 1, 0
   mousemove, %start_x%, %start_y%, 0
return

Joy6::
   PX:=Xpos - 1
   PY:=Ypos - 1
   mousegetpos, start_x, start_y
   mouseclick, right, %PX%, %PY%, 1, 0
   mousemove, %start_x%, %start_y%, 0

return