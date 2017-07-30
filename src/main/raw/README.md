# Raw cluster (services on raw machine)
home1-oss infrastructure on raw machines cluster.

## Run

```sh
vagrant up
ansible-galaxy install -v --force -r requirements.yml
# start all
ansible-playbook -v -u root -i hosts --private-key=${HOME}/.vagrant.d/insecure_private_key playbook.yml -e "create_oss_network=True infrastructure=internal proxy=socks5://127.0.0.1:1080"
# or start specific services
ansible-playbook -v -u root -i hosts --private-key=${HOME}/.vagrant.d/insecure_private_key playbook.yml --tags "dns,privoxy,ldap,nexus3,mysql,postgresql" -e "create_oss_network=True branch=develop infrastructure=internal forwarders=10.0.2.3 proxy=socks5://127.0.0.1:1080"
```

## Destroy

```sh
vagrant destroy -f && rm -rf .vagrant
```

## References

Vagrant and VirtualBox's shared folder

[config.vm.synced_folder](https://www.vagrantup.com/docs/synced-folders/basic_usage.html)
[Vagrant can't mount shared folder in VirtualBox 4.3.10](https://github.com/mitchellh/vagrant/issues/3341)
