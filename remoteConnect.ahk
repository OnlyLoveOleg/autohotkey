; remoteConnect.ahk is a simple script to help you connect to remote nodes
; using Putty or WinSCP on Windows hosts and other good functions.
;
; Help:
; http://www.autohotkey.com


; Configurations:
; Please update the fillowing to based on your needs.
UserName         = <USER_NAME_HERE> 
Putty            = Z:\Path\To\putty.exe
plink            = Z:\Path\To\plink.exe
pskill           = Z:\Path\To\pskill.exe
WinSCP           = Z:\Path\To\WinSCP.exe
; WinSCP protocol to use <ftp,sftp,scp>
WinSCPProtocol   = scp


; Win+m Tile PuTTY Windows
#m::
  WinGetPos,,, desk_width, desk_height, Program Manager
  numberOfScreens := 2
  desk_width := desk_width / numberOfScreens
  desk_height := desk_height-30
  maxPuttyWinsX := 3
  maxPuttyWinsY := 3
  puttyWidth := desk_width/maxPuttyWinsX
  puttyHeight := desk_height/maxPuttyWinsY

  SetTitleMatchMode, 2
  IfWinExist, ahk_class PuTTY
  {
    yPos := 0
    xPos := 0
    yCount := 0
    Winget windows, list
    loop, %windows%
    {
      id := windows%A_Index%
      WinGetClass, winclass, ahk_id %id%
      if (InStr(winclass, "PuTTY"))
      {
        WinActivate, ahk_id %id%
        WM_ENTERSIZEMOVE=0x0231
        WM_EXITSIZEMOVE=0x0232
        SendMessage, WM_ENTERSIZEMOVE , 0, 0,, ahk_id %id%
        WinMove, ahk_id %id% , , xPos, yPos, puttyWidth, puttyHeight
        SendMessage, WM_EXITSIZEMOVE
        yCount++
        yPos := yPos + puttyHeight
        if (yCount >= maxPuttyWinsY)
        {
          xPos := xPos + puttyWidth
          yPos := 0
          yCount := 0
        }
      }
    }
  }
  return


; Win+t - This section adds transparency by set percentage every time the combination used
#t::
  DetectHiddenWindows, on
  WinGet, curtrans, Transparent, A
  if ! curtrans
    curtrans = 255
    newtrans := curtrans - 10
  if newtrans > 0
  {
    WinSet, Transparent, %newtrans%, A
  }
  else
  {
    WinSet, Transparent, 255, A
    WinSet, Transparent, OFF, A
  }
  return


; Win+w - Set full active window to full transparency
#w::
  DetectHiddenWindows, on
  WinSet, TransColor, Black 128, A
  return


; Win+o - reset active window transparency to zero
#o::
  WinSet, Transparent, 255, A
  WinSet, Transparent, OFF, A
  return


; Win+g - print active window attributes (TransColor,TransColor) useless option left only as example
#g::
  MouseGetPos,,, MouseWin
  WinGet, Transparent, Transparent, ahk_id %MouseWin%
  WinGet, TransColor, TransColor, ahk_id %MouseWin%
  ToolTip Translucency:`t%Transparent%`nTransColor:`t%TransColor%
  SetTimer, RemoveToolTip, 5000
  return


; Called by Win+g to remove the ToolTip after a set timeout
RemoveToolTip:
  SetTimer, RemoveToolTip, Off
  ToolTip
  return


; "End of working day" Close all listed programs
^AppsKey::
  Process Close, putty.exe
  Process Close, chrome.exe
  Process Close, pageant.exe
  Process Close, AutoHotkey.exe
  return


; Use the windows apps key to start the remote connect dialog
AppsKey::
  Gui, Add, Text,, Please enter hostname or IP:
  Gui, Add, Edit, vHost ym  ; The ym option starts a new column of controls.
  Gui, Add, Checkbox, vConnectByWinSCP, Use WinSCP.
  Gui, Add, Button, default, Connect  ; The label ButtonConnect (if it exists) will be run when the button is pressed.
  Gui, Show, W300 H100, Where do you want to go?
  return  ; End of auto-execute section. The script is idle until the user does something.
  GuiClose:
  GuiEscape:

  ButtonConnect:
  Gui, Submit  ; Save the input from the user to each control's associated variable.  


  if !ConnectByWinSCP {
    if InStr(Host, ":") ; Host range to connect for example app2:8 = app2,app3,app4 etc
    {
      clipboard = %Host%
      RegExMatch(Host, "([a-zA-Z0-9]+)\d:", hostname)
      RegExMatch(Host, "(\d+):", start)
      RegExMatch(Host, ":(\d+)", end)
      delta := end1-start1
      delta := ++delta
      NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
      loop, %delta% 
      {
        Run, %Putty% -ssh %UserName%@%hostname1%%start1%.example.org
        ifAlertSayYes()
        start1 := ++start1
        delta := --delta
      }
    }
    else if InStr(Host, ".") ; If there is a dot (for IP or FQDN), then use as is
    {
      Run, %Putty% -ssh %Host%
      ifAlertSayYes()
    }
  }
  else if ConnectByWinSCP
  {
    if InStr(Host, ".") ; If there is a dot (for IP or FQDN), then use as is
    {
      Run, %WinSCP% %WinSCPProtocol%://%Host%
    }
    else
    {
      Run, %WinSCP% %WinSCPProtocol%://%UserName%:%Password%@%Host%.example.org:22
    }
  }
  Gui, Destroy


; Helper function to supress alerts
ifAlertSayYes()
{
  WinWait, PuTTY Security Alert,,1.5
  IfWinExist, PuTTY Security Alert
  {
    WinActivate
    Send, Yes.{Enter}
  }
  IfWinExist, Security risk
  {
    WinActivate
    Send, Yes.{Enter}
  }
  IfWinExist, Warning
  {
    WinActivate
    Send, Yes.{Enter}
  }
  return
}

exit
