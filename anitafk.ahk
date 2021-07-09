Keys := ["Right", "Left", "Down", "Up"]

Loop
{
  WinActivate, Tibia
    Send, {Ctrl down}
    Loop, 4
    {
      Random, ran, 1,Keys.MaxIndex()
      Key := Keys[ran]
      Send, {%Key%}
      Random, slp, 200,450
      Sleep, %slp%
    }
    Send, {Ctrl up}
  Sleep, 1000*60*7
}