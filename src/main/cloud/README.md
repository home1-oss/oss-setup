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

## Install and config docker

```sh
ansible-galaxy install -v --force -r requirements.yml
../infrastructure/cache_files.sh
```

Using proxy
```sh
ansible-playbook -v -u vagrant -i hosts --private-key=${HOME}/.vagrant.d/insecure_private_key playbook.yml \
    --tags "docker,docker-config" \
    -e "infrastructure=internal fileserver=http://fileserver.internal http_proxy=http://smart-http-proxy.internal:28119 https_proxy=http://smart-http-proxy.internal:28119 forwarders=<e.g. 192.168.199.1>"
```

Or direct connection
```sh
ansible-playbook -v -u vagrant -i hosts --private-key=${HOME}/.vagrant.d/insecure_private_key playbook.yml \
    --tags "docker,docker-config" \
    -e "infrastructure=internal fileserver=http://fileserver.internal forwarders=<e.g. 192.168.199.1>"
```

## Run rancher

```sh
ansible-galaxy install -v --force -r requirements.yml
ansible-playbook -v -i hosts -u vagrant --private-key=${HOME}/.vagrant.d/insecure_private_key playbook.yml \
    --tags "rancher_server,rancher_reg" \
    -e "infrastructure=internal"
```

## Run k8s

> When using kubelet, gcr.io is not available from china，
> you can force k8s use a registry by option --pod-infra-container-image

- Cache images from gcr.io
see: [Private Registry with Kubernetes in Rancher](http://rancher.com/docs/rancher/v1.6/en/kubernetes/private-registry/)
`cache_images.sh`

- Deactivate Default (cattle) environment `rancher --env Default env deactivate Default`, this step is optional

- Run runcher server

```sh
ansible-galaxy install -v --force -r requirements.yml
ansible-playbook -v -u vagrant -i hosts --private-key=${HOME}/.vagrant.d/insecure_private_key playbook.yml \
    --tags "rancher_server" \
    -e "infrastructure=internal"

# Set up DNS to 192.168.199.5 or bind hosts '192.168.199.100 rancherserver.internal'
mkdir -p ~/.oss
curl 'http://rancherserver.internal/v2-beta/apikey' \
    -H 'content-type: application/json' \
    --data-binary '{"type":"apikey","accountId":"1a1","name":"cli","description":"","created":null,"kind":null,"removeTime":null,"removed":null,"uuid":null}' \
    > ~/.oss/rancher-api-key.json
```

Edit ~/.bash_profile, add following lines
```sh
export RANCHER_URL=http://rancherserver.internal:80
#export RANCHER_URL=http://rancherserver.internal:80/v2-beta
export RANCHER_ACCESS_KEY=$(cat ~/.oss/rancher-api-key.json | jq -r ".publicValue")
export RANCHER_SECRET_KEY=$(cat ~/.oss/rancher-api-key.json | jq -r ".secretValue")
```
`source ~/.bash_profile`

- Install rancher cli

```sh
curl -L https://github.com/rancher/cli/releases/download/v0.6.2/rancher-darwin-amd64-v0.6.2.tar.xz | tar --strip-components=2 -xJ -C /usr/local/bin
# or
curl --socks5-hostname <proxyhost:port -L https://github.com/rancher/cli/releases/download/v0.6.2/rancher-darwin-amd64-v0.6.2.tar.xz | tar --strip-components=2 -xJ -C /usr/local/bin

# for windows user using cygwin
curl -L -o rancher-windows-amd64-v0.6.2.zip https://github.com/rancher/cli/releases/download/v0.6.2/rancher-windows-amd64-v0.6.2.zip
unzip rancher-windows-amd64-v0.6.2.zip
rm -f rancher-windows-amd64-v0.6.2.zip
mv rancher-v0.6.2/rancher.exe /usr/local/bin/
rm -rf rancher-v0.6.2
```

- Create a rancher environment for k8s

Add a custom catalog, which has a modified k8s cluster domain.
(custom --cluster-domain of infra-templates/k8s/*/docker-compose.yml.tpl)
1. Under Admin -> Setting -> Catalog
2. Add catalog
 Name: catalog-oss-internal
 URL: https://github.com/home1-oss/rancher-catalog.git
 Branch:
 - v1.6-release (with default 'cluster-domain=cluster.local')
 - v1.6-release-oss-internal (with modified cluster domain 'internal.k8s')

There is a issue that k8s DNS not use modified cluster domain, even if kubelet's --cluster-domain option is set.
I found this issue when using rancher/server:1.6.3 and rancher-catalog's v1.6-release branch.

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
3. Add registry: mirror.docker.internal

CHANGING THE DEFAULT REGISTRY
1. Under Admin -> Setting -> Advanced Settings
2. Find the registry.default setting and click on the edit icon.
3. Add the registry value and click on Save.

- Run k8s cluster hosts
```
ansible-playbook -v -u vagrant -i hosts --private-key=${HOME}/.vagrant.d/insecure_private_key playbook.yml \
    --tags "rancher_reg" \
    -e "rancher_project_name=env-k8s-vxlan-oss-internal"
```

- Enable access VXLAN (packet forward through VXLAN between hosts)

```sh
./enable_access_vxlan.sh
```

  I run VXLAN (rancher/k8s hosts) on VirtualBox VMs that using bridged network.  
  I added static route on my router (`/ip route> add dst-address=10.42.0.0/16 gateway=192.168.199.103`) 
  or hosts in LAN but it not works at first.  
  
  I can't access/ping target container on VXLAN (request timeout) 
  until I add static route and access/ping target container on host that has bridged rancher/k8s VMs on it.  
  
  Once reached container on VXLAN from host that has bridged VM on it, 
  I can access/ping container on VXLAN from any host under the router or host has static route, 
  even If delete static route set on that host.  
  
  If delete rancher/k8s's contains and re-create them, we need to redo these steps to access VXLAN.  
  
  I think this is a issue of VXLAN container of rancher.  

  Verify ping packet received: `cat /proc/net/snmp | grep Icmp`

- Play with dashboard

If dashboard not available
KUBERNETES -> Infrastructure Stacks -> kubernetes
1. Find container addon-starter
2. Execute `addons-update.sh` on its cli

Or use shell script:
```sh
# on windows host, socket: An address incompatible with the requested protocol was used
# see: https://github.com/rancher/rancher/issues/7262
rancher --env env-k8s-vxlan-oss-internal exec $(rancher --env env-k8s-vxlan-oss-internal ps -a -s -c | grep kubernetes-addon-starter  | awk '{print $1}') addons-update.sh
```

> May be it is because vm resource too low to create k8s pods

- Play with `kubectl`

When hosts added and services ready, there will be a 'KUBERNETES' drop down menu on nav bar.
1. KUBERNETES -> CLI -> Generate Config
2. Copy generated content into `~/.kube/config`, may be need to add port in `server: <url>` property.

```sh
curl -o /usr/local/bin/kubectl -LO https://storage.googleapis.com/kubernetes-release/release/v1.6.6/bin/darwin/amd64/kubectl
chmod +x /usr/local/bin/kubectl
```

```sh
kubectl get nodes
kubectl get pods --all-namespaces
kubectl describe --namespace=kube-system pod <pod_name>
```

## Destroy

```sh
vagrant destroy -f && rm -rf .vagrant
```

## References

see: http://rancher.com/using-ansible-with-docker-to-deploy-a-wordpress-service-on-rancher/
see: https://github.com/galal-hussein/Rancher-Ansible
see: https://mritd.me/2016/10/29/set-up-kubernetes-cluster-by-kubeadm/

### Supported kernel and docker versions
see: http://rancher.com/docs/rancher/v1.6/en/hosts/
see: http://rancher.com/docs/rancher/v1.6/en/hosts/#supported-docker-versions

### vxlan
https://github.com/rancher/rancher/issues/8229
http://rancher.com/docs/rancher/v1.6/en/rancher-services/networking/#mtu


curl ${RANCHER_URL}/v1/projects | prettyjson

## Disaster recovery

see: https://github.com/rancher/rancher/wiki/Kubernetes-Management#disaster-recovery

## Re-config docker

```sh
ansible-playbook -v -i hosts -u vagrant --private-key=${HOME}/.vagrant.d/insecure_private_key playbook.yml \
    --tags "docker-config" \
    -e "http_proxy=http://smart-http-proxy.internal:28119 https_proxy=http://smart-http-proxy.internal:28119"
```

## Ansible SNI/SSL issue

Failed to validate the SSL certificate for download.docker.com:443.
Make sure your managed systems have a valid CA certificate installed.
If the website serving the url uses SNI you need python >= 2.7.9 on your managed machine or you can install the
`urllib3`, `pyOpenSSL`, `ndg-httpsclient`, and `pyasn1` python modules to perform SNI verification in python >= 2.6.
You can use validate_certs=False if you do not need to confirm the servers identity but this is unsafe and not recommended.

Test
```sh
ansible rancherhost3 -u vagrant -i hosts --private-key=${HOME}/.vagrant.d/insecure_private_key \
    -m get_url -a 'url=https://download.docker.com/linux/ubuntu/gpg dest=/tmp'
```

```sh
python -c 'import ssl; print(ssl.OPENSSL_VERSION)'
```
