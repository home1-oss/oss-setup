# Config windows 10 to disable auto restart

- Run cmd as Administrator
```cmd
# cmd administrator mode
schtasks /change /tn \Microsoft\Windows\UpdateOrchestrator\Reboot /DISABLE
```

- Hit `WindowsKey + R`, type `gpedit.msc` and press ENTER
Under `Computer Configuration`,
go to  `Administrative Templates > Windows Components > Windows Update` then Double Click `Configure Automatic Updates`
and enable the policy and configure it as needed (e.g. `3 - Auto download and notify for install`)

see also: https://superuser.com/questions/957267/how-to-disable-automatic-reboots-in-windows-10/
