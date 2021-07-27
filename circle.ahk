#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#NoEnv
#SingleInstance Force
SetBatchLines -1
SetTitleMatchMode 2
/*
GUIName := "InstantHotkey"
Gui, %GUIName%: new
Gui, %GUIName%:Add, Edit, w120, x0 y0
Gui, %GUIName%:Add, Button, w200, AutoCoords
Gui, %GUIName%:Show, AutoSize,
*/
Gui, Add, Edit, w120, x0 y0
Gui, Add, Button, w200, AutoCoords
Gui, Show, AutoSize,

GAME_TITLE := "Tibia"
X_OFFSET := 50
Y_OFFSET := 50
Global num := 1

Loop 9 {
	hCircle%A_Index% := makeCircle(0x00FF00, 50, 2, 200)
}

;SetTimer MoveCircle, 100
Return

F12::Reload

/*
MoveCircle:
	if (hGame := WinActive(GAME_TITLE))
	{
		WinGetPos x, y, , , % "ahk_id " hGame
		Gui %hCircle%: Show, % Format("NoActivate x{} y{}", x + X_OFFSET, y + Y_OFFSET)
	}
	else
		Gui %hCircle%: Hide
Return
*/

makeCircle(color, r := 300, thickness := 10, transparency := 254) {
	HWND := MakeGui()

	; https://autohotkey.com/board/topic/7377-create-a-transparent-circle-in-window-w-winset-region/
	outer := DllCall("CreateEllipticRgn", "Int", 0, "Int", 0, "Int", r, "Int", r)
	;inner := DllCall("CreateEllipticRgn", "Int", thickness, "Int", thickness, "Int", r - thickness, "Int", r - thickness)
	;DllCall("CombineRgn", "UInt", outer, "UInt", outer, "UInt", inner, "Int", 3) ; RGN_XOR = 3
	DllCall("SetWindowRgn", "UInt", HWND, "UInt", outer, "UInt", true)

  posx := 250+(50*num)
  posy := 500+(50*num)
	Gui %HWND%:Color, % color
	Gui %HWND%:Show, x%posx% y%posy% w%r% h%r% NoActivate
	WinSet Transparent, % transparency, % "ahk_id " HWND
	num++
	return HWND
}

MakeGui() {
  ;Gui, g%num%:New +AlwaysOnTop +ToolWindow -Caption
	Gui g%num%:New, +E0x20 +AlwaysOnTop +ToolWindow -Caption +Hwndhwnd
	return hwnd
}

space::
  Loop 9 {
    gui := hCircle%A_Index%
    Gui %gui%: Hide
  }
Return