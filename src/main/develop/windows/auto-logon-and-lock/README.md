# Config windows 10 to auto logon and auto lock after logon

- Auto logon

1. `Win + R` run `netplwiz`
2. Uncheck `Users must enter a user name and password to use this computer` then click `Apply`
3. Input user name and password on the pop-up dialog

- Auto lock after logon
1. Open notepad, then paste this code:
```vbs
WScript.CreateObject("WScript.Shell").Run("rundll32 user32.dll,LockWorkStation")
```
Click File>Save As and in Save as type dropdown menu, choose All Files
In the File Name field, enter LockWorkStation.vbs and save the file to `C:\Users\<YourUserName>`

2. Hit `WindowsKey + R`, type `regedit` and press ENTER
Go to `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System`
Right Click on a blank space and click `New> DWORD (32-bit)` Value and press ENTER
Double click the newly created REG_DWORD file.
In the Value name type `RunLogonScriptSync` and in the Value data type `1` and then press ENTER

3. Hit `WindowsKey + R`, type `gpedit.msc` and press ENTER
Under `Computer Configuration`,
go to  `Administrative Templates > System > Logon` then Double Click `Run these programs at user logon`
Click `Enabled`, and on `Items to run at logon` click `Show...`
Type `C:\Users\<YourUserName>\LockWorkStation.vbs` and click `OK` repeatedly until all windows are closed

see also: [https://superuser.com/questions/352616/automatically-login-and-lock](https://superuser.com/questions/352616/automatically-login-and-lock)
