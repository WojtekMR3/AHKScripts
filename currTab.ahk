TextVar := "Default text here"
GuiMsg1 := "You are on the first tab"
GuiMsg2 := "You are on the second tab"
GuiMsg3 := "You are on the third tab"


Gui, Add, Text, vGuiMsg w200,%TextVar%


Gui, Add, Tab2, vCurrTab gTabChanged,TabOne|TabTwo|TabThree


Gui, Tab, TabOne
;; some controls here..


Gui, Tab, TabTwo
;; some controls here..


Gui, Tab, TabThree
;; some controls here..

Gui, Show, ,SomeTitle
return

TabChanged:
Gui, Submit, NoHide
If (CurrTab == "TabOne")
{
  TextVar := GuiMsg1
  GuiControl, ,GuiMsg,%TextVar%
}

If (CurrTab == "TabTwo")
{
TextVar := GuiMsg2
GuiControl, ,GuiMsg,%TextVar%
}

If (CurrTab == "TabThree")
{
TextVar := GuiMsg3
GuiControl, ,GuiMsg,%TextVar%
}
Gui, Submit, NoHide
return


GuiClose:
Gui, Destroy
ExitApp
return