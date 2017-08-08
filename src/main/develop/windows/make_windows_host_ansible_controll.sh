#!/usr/bin/bash

if [ ! -d "PyYAML-3.12" ]; then
    curl -L -O "https://pypi.python.org/packages/4a/85/db5a2df477072b2902b0eb892feb37d88ac635d36245a72a6a69b23b383a/PyYAML-3.12.tar.gz"
    tar -xvf PyYAML-3.12.tar.gz
    (cd PyYAML-3.12; python setup.py install)
fi
if [ ! -d "Jinja2-2.9.6" ]; then
    curl -L -O "https://pypi.python.org/packages/90/61/f820ff0076a2599dd39406dcb858ecb239438c02ce706c8e91131ab9c7f1/Jinja2-2.9.6.tar.gz"
    tar -xvf Jinja2-2.9.6.tar.gz
    (cd Jinja2-2.9.6; python setup.py install)
fi

if [ ! -f ~/.ssh/id_rsa ] || [ ! -f ~/.ssh/id_rsa.pub ]; then
    ssh-keygen
fi

# see: http://docs.ansible.com/ansible/latest/intro_installation.html#tarballs-of-tagged-releases
if [ ! -d /opt/ansible ]; then
    git clone https://github.com/ansible/ansible --recursive /opt/ansible
    cd /opt/ansible
    source ./hacking/env-setup
    easy_install-2.7 pip
    pip install -r ./requirements.txt
    pip install jmespath

    git pull --rebase

    #git checkout v2.0.1.0-1)
    # v2.2 or older
    #git submodule update --init lib/ansible/modules/core
    #git submodule update --init lib/ansible/modules/extras
    #git submodule update --init --recursive

    git checkout v2.3.1.0-1
    source ./hacking/env-setup
fi
