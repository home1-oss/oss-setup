# Cloud cluster (rancher, k8s)
home1-oss services on container cloud cluster.

***Rancher and k8s depends on specific version of docker***
see:[Supported Docker version](http://docs.rancher.com/rancher/v1.6/en/hosts/#supported-docker-versions)。

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

- Cache images from gcr.io
see: [Private Registry with Kubernetes in Rancher](http://rancher.com/docs/rancher/v1.6/en/kubernetes/private-registry/)
```sh
vagrant ssh-config rancherhost1 > /tmp/ssh-config-rancherhost1
cat pull_gcr_images.sh | ssh -F /tmp/ssh-config-rancherhost1 root@rancherhost1
```

- Deactivate Default (cattle) environment `rancher --env Default env deactivate Default`, this step is optional

- Run runcher server

```sh
ansible-galaxy install -r requirements.yml
ansible-playbook -v -u root -i hosts --private-key=${HOME}/.vagrant.d/insecure_private_key playbook.yml --tags "docker,docker-config,rancher_server"

curl 'http://rancherserver.internal/v2-beta/apikey' \
    -H 'content-type: application/json' \
    --data-binary '{"type":"apikey","accountId":"1a1","name":"cli","description":"","created":null,"kind":null,"removeTime":null,"removed":null,"uuid":null}' \
    > ~/.oss/rancher-api-key.json

export RANCHER_URL=http://rancherserver.internal:80
#export RANCHER_URL=http://rancherserver.internal:80/v2-beta
export RANCHER_ACCESS_KEY=$(cat ~/.oss/rancher-api-key.json | jq -r ".publicValue")
export RANCHER_SECRET_KEY=$(cat ~/.oss/rancher-api-key.json | jq -r ".secretValue")
```

- Install rancher cli

```sh
curl -L https://github.com/rancher/cli/releases/download/v0.6.2/rancher-darwin-amd64-v0.6.2.tar.xz | tar --strip-components=2 -xJ -C /usr/local/bin
# or
curl --socks5-hostname <proxyhost:port -L https://github.com/rancher/cli/releases/download/v0.6.2/rancher-darwin-amd64-v0.6.2.tar.xz | tar --strip-components=2 -xJ -C /usr/local/bin
```

- Create a rancher environment for k8s

Add a custom catalog, which has a modified k8s cluster domain.
(custom --cluster-domain of infra-templates/k8s/*/docker-compose.yml.tpl)
1. Under Admin -> Setting -> Catalog
2. Add catalog
 Name: catalog-oss-internal
 URL: https://github.com/home1-oss/rancher-catalog.git
 Branch: v1.6-release-oss-internal

```sh
rancher env template import env-tmpl-k8s-vxlan-oss-internal.yml
rancher env templates

rancher env create -t env-tmpl-k8s-vxlan-oss-internal env-k8s-vxlan-oss-internal
rancher env ls
```

- ADDING A PRIVATE REGISTRY TO KUBERNETES

ADDING REGISTRIES
1. Select Kubernetes environment (env-k8s-vxlan-oss-internal)
2. Under INFRASTRUCTURE -> Registries
3. Add registry: 172.22.101.10:25001

CHANGING THE DEFAULT REGISTRY
1. Under Admin -> Setting -> Advanced Settings
2. Find the registry.default setting and click on the edit icon.
3. Add the registry value and click on Save.

```
ansible-playbook -v -u root -i hosts --private-key=${HOME}/.vagrant.d/insecure_private_key playbook.yml --tags "rancher_reg" -e "rancher_project_name=env-k8s-vxlan-oss-internal"
```

- Enable access VXLAN (packet forward through VXLAN between hosts)

```sh
./enable_access_vxlan.sh
```

- Play with dashboard

If dashboard not available
KUBERNETES -> Infrastructure Stacks -> kubernetes
1. Find container addon-starter
2. Execute `addons-update.sh` on its cli

Or use shell script:
```sh
rancher --env env-k8s-vxlan-oss-internal exec $(rancher --env env-k8s-vxlan-oss-internal ps -a -s -c | grep kubernetes-addon-starter  | awk '{print $1}') addons-update.sh
```

> May be it is because vm resource too low to create k8s pods

- Play with `kubectl`

When hosts added and services ready, there will be a 'KUBERNETES' drop down menu on nav bar.
1. KUBERNETES -> CLI -> Generate Config
2. Copy generated content into `~/.kube/config`, may be need to add port in `server: <url>` property.

```sh
kubectl get nodes
kubectl get pods --all-namespaces
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
