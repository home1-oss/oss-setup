# flat-network-env
A home1-oss environment on vm and docker containers.

```sh
#ssh-add ${HOME}/.vagrant.d/insecure_private_key
#ssh-add ${HOME}/.ssh/id_rsa
#ssh-add -L

# If see 'Warning: Authentication failure. Retrying...'
#rm -f ${HOME}/.vagrant.d/insecure_private_key

vagrant up
ansible-playbook -v -u root -i hosts --private-key=${HOME}/.vagrant.d/insecure_private_key playbook-rancher.yml -e "docker_mirror_proxy=socks5://127.0.0.1:1080"
``` 

```sh
curl 'http://rancherserver.internal/v2-beta/apikey' \
    -H 'content-type: application/json' \
    --data-binary '{"type":"apikey","accountId":"1a1","name":"cli","description":"","created":null,"kind":null,"removeTime":null,"removed":null,"uuid":null}' \
    > ~/.oss/rancher-api-key.json

export RANCHER_URL=http://rancherserver.internal:80
export RANCHER_ACCESS_KEY=$(cat ~/.oss/rancher-api-key.json | jq -r ".publicValue")
export RANCHER_SECRET_KEY=$(cat ~/.oss/rancher-api-key.json | jq -r ".secretValue")

rancher env template import env_tmpl_k8s_vxlan.yml
rancher env templates

rancher env create -t k8s_vxlan env_k8s_vxlan_internal
rancher env ls

ansible-playbook -v -u root -i hosts --private-key=${HOME}/.vagrant.d/insecure_private_key playbook-rancher.yml --tags "rancher_reg" -e "rancher_project_name=env_k8s_vxlan_internal docker_mirror_proxy=socks5://127.0.0.1:1080"
```

```sh
vagrant destroy -f && rm -rf .vagrant
```

see: http://rancher.com/using-ansible-with-docker-to-deploy-a-wordpress-service-on-rancher/

## Supported kernel and docker versions
see: http://rancher.com/docs/rancher/v1.6/en/hosts/
see: http://rancher.com/docs/rancher/v1.6/en/hosts/#supported-docker-versions

## vxlan
https://github.com/rancher/rancher/issues/8229
http://rancher.com/docs/rancher/v1.6/en/rancher-services/networking/#mtu


curl ${RANCHER_URL}/v1/projects | prettyjson
