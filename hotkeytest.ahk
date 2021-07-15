gui, add, hotkey, w100 vhotKey, None
gui, add, hotkey, w100 vhotKey1, None
gui, add, hotkey, w100 vhotKey2, None

gui show
return

#ifWinActive, ahk_class AutoHotkeyGUI
  space::     addKey( a_thisHotkey )
  backspace:: addKey( a_thisHotkey )
  tab::       addKey( a_thisHotkey )
  LWin::      addKey( a_thisHotkey )
#ifWinActive

addKey( uKey ) {
  while getKeyState( curKey := subStr( uKey, regexMatch( uKey, "[a-zA-Z]" )
   , inStr( uKey, a_space ) ? inStr( uKey, a_space )-2 : strLen( uKey ) ), "P" )
    guiControl,, hotKey, % regexReplace( curKey, "\w+", "$T0" )
}