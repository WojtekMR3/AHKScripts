~LButton::MouseMoveCircle()

MouseMoveCircle()
{
	; r is radius of circle, nLaps is number of laps to turn, can be -1 for keep on going until lbutton is released.
	; Set direction via, dir. dir:=1 is clockwise, dir:=-1 is counter-clockwise
	static r:=50, speed:=15, nLaps:=1,	dir:=1
	static pi:=3.1415, n:=Ceil(2*r*pi)
	SetMouseDelay,-1
	CoordMode, Mouse, Screen
	MouseGetPos,OX,OY
	t:=0	
	while ((nLaps=-1 || t<=2*pi*nLaps) && GetKeyState("LButton", "p"))
		MouseMove, OX+r*cos(t:=((A_Index-1)/n)), OY+dir*r*sin(t), speed
	return
}