Gui, Add, Hotkey, vChosenHotkey gSetHtk
Gui Show
return

SetHtk:
  MsgBox, %ChosenHotkey%
  Hotkey, %ChosenHotkey%, fn, On
return

fn:
  MsgBox %A_ThisHotkey%
return

GuiClose:
GuiEscape:
ExitApp