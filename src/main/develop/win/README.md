Chocolatey

cmd.exe run as Administrator
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

#choco feature enable -n allowGlobalConfirmation

# see: https://github.com/chocolatey/choco/wiki/Proxy-Settings-for-Chocolatey
choco config set proxy <locationandport>
e.g. choco config set proxy http://127.0.0.1:8118
choco config set proxyUser <username> #optional
choco config set proxyPassword <passwordThatGetsEncryptedInFile> # optional

choco install docker-toolbox --ignore-checksums -y
docker-machine ssh default -t sudo vi /var/lib/boot2docker/profile
# Add something like:
#     EXTRA_ARGS="--default-ulimit core=-1"
docker-machine restart default
docker-machine ssh default "echo $'EXTRA_ARGS=\"--registry-mirror=http://172.22.101.10:25001 --insecure-registry 172.22.101.10:25001 --insecure-registry 172.22.101.10:25004\"' | sudo tee -a /var/lib/boot2docker/profile && sudo /etc/init.d/docker restart"

choco install docker-machine docker-compose -y

choco install git -y
git config --global core.autocrlf false
git config --global core.filemode false
git config --global core.ignorecase false
git config --global core.safecrlf warn

choco install cygwin -y

# in cygwin's bash
# edit /etc/nsswitch.conf
change '# db_home:  /home/%U' to 'db_home:  windows'
# see: https://stackoverflow.com/questions/1494658/how-can-i-change-my-cygwin-home-folder-after-installation
# move every thing into new home directory

# see: https://serverfault.com/questions/83456/cygwin-package-management
# List all installed packages
#cygcheck --check-setup --dump-only
# List files belonging to a package
#cygcheck --list-package bash
# Tell which package a file belongs to:
#cygcheck --find-package /usr/bin/bash.exe
# Install a new package
#C:\tools\cygwin\cygwinsetup.exe --quiet-mode --download --local-install --packages abook
#C:\ProgramData\chocolatey\lib\Cygwin\tools\setup-x86_64.exe --quiet-mode --download --local-install --packages abook

chere -i -t mintty .

# see: https://github.com/atom/atom/blob/master/docs/build-instructions/windows.md
choco install nvm --version 1.1.1 -y
nvm install v6.11.0
choco install python2 -y
choco install 7zip -y
#choco install 7zip.install -y
choco install visualcppbuildtools --version 14.0.25123.0 -y
# in powershell '[Environment]::SetEnvironmentVariable("GYP_MSVS_VERSION", "2015", "User")'
refreshenv
choco install atom -y

choco install kubernetes-cli -y
