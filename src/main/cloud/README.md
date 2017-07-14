# flat-network-env
A home1-oss environment on vm and docker containers.

```sh
#ssh-add ${HOME}/.vagrant.d/insecure_private_key
#ssh-add ${HOME}/.ssh/id_rsa
#ssh-add -L

# If see 'Warning: Authentication failure. Retrying...'
#rm -f ${HOME}/.vagrant.d/insecure_private_key

vagrant up
ansible-playbook -v -u root -i hosts --private-key=${HOME}/.vagrant.d/insecure_private_key playbook-rancher.yml
vagrant destroy -f && rm -rf .vagrant
``` 
