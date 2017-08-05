netplwiz

see: https://superuser.com/questions/352616/automatically-login-and-lock

Step 1: Open notepad, then paste this code:

WScript.CreateObject("WScript.Shell").Run("rundll32 user32.dll,LockWorkStation")
Step 2: Click File>Save As and in Save as type dropdown menu, choose All Files

Step 3: In the File Name field, enter LockWorkStation.vbs and save the file to C:\Users\YourUserName\Documents

Step 4: Hit WindowsKey+R, type regedit and press ENTER

Step 5: Go to HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System

Step 6: Right Click on a blank space and click New> DWORD (32-bit) Value and press ENTER

Step 7: Double click the newly created REG_DWORD file. In the Value name type RunLogonScriptSync and in the Value data type1 and then press ENTER

Step 8: Hit WindowsKey+R, type gpedit.msc and press ENTER

Step 9: Under Computer Configuration, go to  Administrative Templates > System > Logon then Double Click Run these programs at user logon

Step 10: Click Enabled, and on Items to run at logon click Show...

Step 11: Type C:\Users\YourUserName\Documents\LockWorkStation.vbs and click OK repeatedly until all windows are closed
