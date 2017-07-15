
# oss-setup

Some things are slightly difficult to automate, 
so I still have some manual installation steps, 
but at least it's all documented here.

## Setup as a home1-oss user

### macOS Sierra

1. Ensure Apple's command line tools are installed (`xcode-select --install` to launch the installer).

2. Install HomeBrew and Ansible

HomeBrew installed (Install Ansible by HomeBrew)
```sh
#/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install ansible
```

No HomeBrew installed (Install HomeBrew by Ansible)
```sh
sudo easy_install pip
sudo pip install ansible --quiet
#sudo pip install ansible --upgrade
#ansible-galaxy install geerlingguy.homebrew
```

3. Clone this repository

```sh
git clone https://github.com/home1-oss/oss-setup.git
```

4. Install

```sh
cd oss-setup/src/main/playbook/mac
ansible-galaxy install -r requirements.yml
ansible-playbook -v main.yml -i inventory -K
```

> Note: If some Homebrew commands fail, you might need to agree to Xcode's license or fix some other Brew issue. Run `brew doctor` to see if this is the case.


see:
https://blog.vandenbrand.org/2016/01/04/how-to-automate-your-mac-os-x-setup-with-ansible/
