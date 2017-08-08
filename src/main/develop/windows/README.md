
# Development environment on windows host
Setup a mac windows machine

## Install chocolatey

Run cmd as Administrator
```cmd
# cmd administrator mode
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
choco feature enable -n allowGlobalConfirmation
```

You can config proxy optionally
see: [https://github.com/chocolatey/choco/wiki/Proxy-Settings-for-Chocolatey](https://github.com/chocolatey/choco/wiki/Proxy-Settings-for-Chocolatey)
```cmd
# e.g. choco config set proxy http://127.0.0.1:8118
choco config set proxy <locationandport>
choco config set proxyUser <username> #optional
choco config set proxyPassword <passwordThatGetsEncryptedInFile> # optional
```

## Install tools

```cmd
# cmd administrator mode
choco install chromium GoogleChrome -y
choco install git -y
choco install cygwin -y
```

Docker tools
```cmd
# cmd administrator mode
choco install virtualbox vagrant -y
choco install VBoxHeadlessTray VBoxVmService -y --allow-empty-checksums
choco install docker-toolbox --ignore-checksums -y
choco install docker-machine docker-compose kubernetes-cli -y
```

Atom
see: [https://github.com/atom/atom/blob/master/docs/build-instructions/windows.md](https://github.com/atom/atom/blob/master/docs/build-instructions/windows.md)
```cmd
# cmd administrator mode
choco install nvm --version 1.1.1 -y
choco install python2 7zip -y
choco install visualcppbuildtools --version 14.0.25123.0 -y
nvm install v6.11.0
refreshenv
```
```powershell
# powershell
'[Environment]::SetEnvironmentVariable("GYP_MSVS_VERSION", "2015", "User")'
```

```cmd
# cmd administrator mode
choco install atom -y
```

Install atom plugins
```cmd
# cmd
apm install editorconfig
```

## Config git

In git bash and cygwin bash both
```bash
# git bash or cygwin bash
git config --global user.email "username@users.noreply.github.com"
git config --global user.name "username"

git config --global core.autocrlf false
git config --global core.filemode false
git config --global core.ignorecase false
git config --global core.safecrlf warn
```

## Clone oss-setup repository

```bash
# git bash
mkdir -p ~/ws/home1
cd ~/ws/home1
git clone https://github.com/home1-oss/oss-setup.git
```

## Config cygwin

- Install packages
Run `oss-setup/src/main/develop/windows/install_cygwin_packages.cmd` by windows cmd

- Cygwin here
Run cygwin's bash as 'Administrator', then `chere -i -t mintty .`

- home directory

    see: [https://stackoverflow.com/questions/1494658/how-can-i-change-my-cygwin-home-folder-after-installation](https://stackoverflow.com/questions/1494658/how-can-i-change-my-cygwin-home-folder-after-installation)  
    1. edit `vi /etc/nsswitch.conf` in cygwin's bash
    2. change `# db_home:  /home/%U` to `db_home:  windows`
    3. move every thing (at `C:\tools\home\cygwin`) into new home directory (at `C:\Users\<username>` aka `/cygdrive/c/Users/<username>`)

- Generate ssh key
Run `ssh-keygen -t rsa` in cygwin's bash

- package-management

    see: [https://serverfault.com/questions/83456/cygwin-package-management](https://serverfault.com/questions/83456/cygwin-package-management)
    1. List all installed packages `cygcheck --check-setup --dump-only`
    2. List files belonging to a package `cygcheck --list-package bash`
    3. Tell which package a file belongs to `cygcheck --find-package /usr/bin/bash.exe`
    4. Install a new package
```cmd
#C:\tools\cygwin\cygwinsetup.exe --quiet-mode --download --local-install --packages abook
C:\ProgramData\chocolatey\lib\Cygwin\tools\setup-x86_64.exe --quiet-mode --download --local-install --packages abook
```

## Create default docker machine

- Download `https://github.com/boot2docker/boot2docker/releases/download/v17.06.0-ce/boot2docker.iso`
to `C:\Users\<YourUserName>\.docker\machine\cache\boot2docker.iso`

- Double click `Docker Quickstart Terminal` to create default docker machine (in virtualbox)

## Make windows host be ansible control

- Run `oss-setup/src/main/develop/windows/make_windows_host_ansible_control.sh` in cygwin's bash
- Run `printf '\nexport PATH=/opt/ansible/bin:$PATH\n' >> ~/.bashrc` in cygwin's bash
- Run `source ~/.bash_profile` in cygwin's bash
- Run `ansible --version` in cygwin's bash to verify
- If has error, `cd /opt/ansible && source ./hacking/env-setup` and try again

## Auto logon and auto lock after logon

- see: [auto-logon-and-lock/README.md](auto-logon-and-lock/README.md)

## Graceful restart or shutdown (do this after [raw cluster](../../raw/README.md) up)

- see: [graceful-restart-shutdown/README.md](graceful-restart-shutdown/README.md)
- Merge `oss-setup/src/main/develop/windows/graceful-restart-shutdown/WaitToKillServiceTimeout.reg`
- Config VBoxVmService, Edit `C:\vms\VBoxVmService.ini`, Add vms
> note that `PauseShutdown` must less than value in `WaitToKillServiceTimeout.reg`

see also: https://superuser.com/questions/959567/virtualbox-windows-graceful-shutdown-of-guests-on-host-shutdown

## Config docker (do this after [raw cluster](../../raw/README.md) up)

- `docker-machine ssh default -t sudo vi /var/lib/boot2docker/profile`
- Add something like:
> EXTRA_ARGS="--default-ulimit core=-1"
- `docker-machine restart default`

Or all in one line:
```bash
# cygwin bash
docker-machine ssh default "echo $'EXTRA_ARGS=\"--registry-mirror=http://mirror.docker.internal --insecure-registry mirror.docker.internal --insecure-registry registry.docker.internal --insecure-registry gcr.io.internal:25004\"' | sudo tee -a /var/lib/boot2docker/profile && sudo /etc/init.d/docker restart"
```
