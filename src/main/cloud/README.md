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

> When using kubelet, gcr.io is not available from china，
> you can force k8s use a registry by option --pod-infra-container-image

Cache images from gcr.io
see: [Private Registry with Kubernetes in Rancher](http://rancher.com/docs/rancher/v1.6/en/kubernetes/private-registry/)
```sh
vagrant ssh-config rancherhost1 > /tmp/ssh-config-rancherhost1
cat pull_gcr_images.sh | ssh -F /tmp/ssh-config-rancherhost1 root@rancherhost1
```

Create a rancher environment for k8s
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
```

ADDING A PRIVATE REGISTRY TO KUBERNETES

ADDING REGISTRIES
1. Select Kubernetes environment (env_k8s_vxlan_internal)
2. Under INFRASTRUCTURE -> Registries
3. Add registry: 172.22.101.10:25001

CHANGING THE DEFAULT REGISTRY
1. Under Admin -> Setting -> Advanced Settings
2. Find the registry.default setting and click on the edit icon.
3. Add the registry value and click on Save.

```
ansible-playbook -v -u root -i hosts --private-key=${HOME}/.vagrant.d/insecure_private_key playbook.yml --tags "rancher_reg" -e "rancher_project_name=env_k8s_vxlan_internal"
```

## Destroy

```sh
vagrant destroy -f && rm -rf .vagrant
```

## References

see: http://rancher.com/using-ansible-with-docker-to-deploy-a-wordpress-service-on-rancher/
see: https://github.com/galal-hussein/Rancher-Ansible

### Supported kernel and docker versions
see: http://rancher.com/docs/rancher/v1.6/en/hosts/
see: http://rancher.com/docs/rancher/v1.6/en/hosts/#supported-docker-versions

### vxlan
https://github.com/rancher/rancher/issues/8229
http://rancher.com/docs/rancher/v1.6/en/rancher-services/networking/#mtu


curl ${RANCHER_URL}/v1/projects | prettyjson
