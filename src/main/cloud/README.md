# Cloud cluster (rancher, k8s)
home1-oss services on container cloud cluster.

## Run vm

```sh
#ssh-add ${HOME}/.vagrant.d/insecure_private_key
#ssh-add ${HOME}/.ssh/id_rsa
#ssh-add -L

# If see 'Warning: Authentication failure. Retrying...'
#rm -f ${HOME}/.vagrant.d/insecure_private_key

vagrant up
```

## Run rancher

```sh
ansible-galaxy install -r requirements.yml
ansible-playbook -v -u root -i hosts --private-key=${HOME}/.vagrant.d/insecure_private_key playbook.yml
```

## Run k8s

```sh
ansible-galaxy install -r requirements.yml
ansible-playbook -v -u root -i hosts --private-key=${HOME}/.vagrant.d/insecure_private_key playbook.yml --tags "docker,docker_config,rancher_server"

curl 'http://rancherserver.internal/v2-beta/apikey' \
    -H 'content-type: application/json' \
    --data-binary '{"type":"apikey","accountId":"1a1","name":"cli","description":"","created":null,"kind":null,"removeTime":null,"removed":null,"uuid":null}' \
    > ~/.oss/rancher-api-key.json

export RANCHER_URL=http://rancherserver.internal:80
export RANCHER_ACCESS_KEY=$(cat ~/.oss/rancher-api-key.json | jq -r ".publicValue")
export RANCHER_SECRET_KEY=$(cat ~/.oss/rancher-api-key.json | jq -r ".secretValue")

curl -L https://github.com/rancher/cli/releases/download/v0.6.2/rancher-darwin-amd64-v0.6.2.tar.xz | tar --strip-components=2 -xJ -C /usr/local/bin
# or
curl --socks5-hostname <proxyhost:port -L https://github.com/rancher/cli/releases/download/v0.6.2/rancher-darwin-amd64-v0.6.2.tar.xz | tar --strip-components=2 -xJ -C /usr/local/bin

rancher env template import env_tmpl_k8s_vxlan.yml
rancher env templates

rancher env create -t k8s_vxlan env_k8s_vxlan_internal
rancher env ls

ansible-playbook -v -u root -i hosts --private-key=${HOME}/.vagrant.d/insecure_private_key playbook.yml --tags "rancher_reg" -e "rancher_project_name=env_k8s_vxlan_internal"
```

## Destroy

```sh
vagrant destroy -f && rm -rf .vagrant
```

## References

see: http://rancher.com/using-ansible-with-docker-to-deploy-a-wordpress-service-on-rancher/

### Supported kernel and docker versions
see: http://rancher.com/docs/rancher/v1.6/en/hosts/
see: http://rancher.com/docs/rancher/v1.6/en/hosts/#supported-docker-versions

### vxlan
https://github.com/rancher/rancher/issues/8229
http://rancher.com/docs/rancher/v1.6/en/rancher-services/networking/#mtu


curl ${RANCHER_URL}/v1/projects | prettyjson
