# Raw cluster (services on raw machine)
home1-oss services on raw machines cluster.

## Run

```sh
vagrant up

ansible-galaxy install -v --force -r requirements.yml

ansible-playbook -v -u vagrant -i hosts --private-key=${HOME}/.vagrant.d/insecure_private_key playbook.yml \
    -e "create_oss_network=True infrastructure=internal forwarders=<e.g. 192.168.199.1>"
```

## Destroy

```sh
vagrant destroy -f && rm -rf .vagrant
```
