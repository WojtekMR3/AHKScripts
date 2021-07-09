#Persistent
SetTimer, WatchCursor, 100
return

WatchCursor:
MouseGetPos, xpos, ypos
ToolTip, x: %xpos% y: %ypos%
return