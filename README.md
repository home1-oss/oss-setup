
# oss-setup

Some things are slightly difficult to automate, 
so I still have some manual installation steps, 
but at least it's all documented here.

## Setup as a home1-oss user

### macOS Sierra

1. Ensure Apple's command line tools are installed (`xcode-select --install` to launch the installer).

2. Install homebrew and ansible

```sh
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install ansible
ansible-galaxy install geerlingguy.homebrew
```

3. Clone this repository

```sh
git clone https://github.com/home1-oss/oss-setup.git
cd oss-setup
```
