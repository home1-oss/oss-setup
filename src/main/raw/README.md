# Raw cluster (services on raw machine)
home1-oss infrastructure on raw machines cluster.

## Run

```sh
vagrant up
ansible-galaxy install -r requirements.yml
ansible-playbook -v -u root -i hosts --private-key=${HOME}/.vagrant.d/insecure_private_key playbook.yml -e "proxy=socks5://127.0.0.1:1080"
```

## Destroy

```sh
vagrant destroy -f && rm -rf .vagrant
```
