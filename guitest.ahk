#SingleInstance, Force

#Include lib/GuiObj.ahk

TestGui := new GuiObj("MainWindow")

TestGui.Add("Text", "Sample Text", "s12", "MyTextCtrl1")

SampleText := TestGui.Controls["MyTextCtrl1"].GetText()

TestGui.Show("w300 h300")


MsgBox % SampleText ; "Sample Text"
return

MainWindowGuiClose() { 
	ExitApp
}