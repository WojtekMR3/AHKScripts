Keys := ["Right", "Left", "Down", "Up"]

Loop
{
  WinActivate, Tibia
    Send, {Ctrl down}
    Loop, 8
    {
      Random, ran, 1,Keys.MaxIndex()
      Key := Keys[ran]
      Send, {%Key%}
      Random, slp, 50,250
      Sleep, %slp%
    }
    Send, {Ctrl up}

  Loop, 10 ; food
  {
    Send, {Shift down}
    Sleep, 33
    Send, {F9}
    Send, {Shift up}
  }
  
  Sleep, 1000
  ; arrowki
  Send, {Shift down}
  Sleep, 33
  Send, {F8}
  Send, {Shift up}
  Sleep, 1000*60*10
}