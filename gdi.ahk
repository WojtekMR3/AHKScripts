#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include lib/Graphics.ahk

global cycles := 12
global g := new Graphics.TextRenderer
g.Draw("Status: Active", "c:Off", "s:18pt f:(Avenir LT Pro 55 Roman) c:00A900 x:1375 y:200")
g.Render()
return

f5::
	suspend
	if (A_IsSuspended) {
		g.Draw("Status: Suspended", "c:Off", "s:18pt f:(Avenir LT Pro 55 Roman) c:FFB900 x:1375 y:200")
		g.Render()
	} else {
		g.Draw("Status: Active", "c:Off", "s:18pt f:(Avenir LT Pro 55 Roman) c:00A900 x:1375 y:200")
		g.Render()
	}
return

f11::ExitApp
f10::
	g := new Graphics.TextRenderer
	g := new Graphics.INTERACTIVE(g) ; Not really needed other than for fun! :D


	; Draw backing rectangles.
	;g.Draw(, "c:33FAB4  x:27.5vw  w:15vw h:160")
	;g.Draw(, "c:FBDDB5  x:42.5vw  w:15vw h:160")
	;g.Draw(, "c:F77563  x:57.5vw  w:15vw h:160")

	; Draw Text
	g.Draw("Status"cycles, "c:Off", "s:50pt f:(Avenir LT Pro 55 Roman) c:C1BCA6")

	; Draw Outline Glow. This is a unique method, because the font color is set to "off" which makes the text transparent.
	; Additionally, the outline fill method would normally be used instead of the draw text method contributing to a mismatch in the two font fills.
	; In other words when the outline parameter is set, the graphics engine uses a different method to draw the text.
	; In this case we use the normal method of drawing text and proceed to use the outline engine to draw the text glow. 
	; If these two lines were combined the outline engine would both draw the text and draw the text glow.
	g.Draw("Status" A_IsSuspended, "c:Off", "s:50pt f:(Avenir LT Pro 55 Roman) c:Off outline:(stroke:0px color:#070707 glow:2px tint:#070707)")
	g.Render()
	;g.Save("hi2.png")