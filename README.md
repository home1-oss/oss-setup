
# oss-setup
Setup a develop and runtime environment of home1-oss

Some things are slightly difficult to automate,
so I still have some manual installation steps,
but at least it's all documented here.

## Build local development environment

- [macos](src/main/develop/macos/README.md)

- [linux](./src/main/develop/linux/README.md)

- [windows](./src/main/develop/windows/README.md)

## Build clusters

1. [Cluster of infrastructure](./src/main/infrastructure/README.md)
> DNS, proxy, code and artifact repositories, CI

2. [Cluster of raw machines](./src/main/raw/README.md)
> run docker container on raw machine without orchestration platform such as k8s or rancher

3. [Cluster of cloud](./src/main/cloud/README.md)
> run docker container on orchestration platform such as k8s or rancher

Run workloads (services)

## Run gitlab-runner and jenkins-slave on k8s

- [gitlab-runner](https://github.com/home1-oss/docker-gitlab/blob/develop/gitlab-runner/README.md)
- [jenkins-jnlp-slave](https://github.com/home1-oss/docker-jenkins/blob/develop/jenkins-jnlp-slave/README.md)
- [jenkins-swarm-slave](https://github.com/home1-oss/docker-jenkins/blob/develop/jenkins-swarm-slave/README.md)

## Build oss-internal repository on gitlab.internal

- import https://github.com/home1-oss/oss-internal-template.git
> into 'home1-oss/oss-internal' as private or internal project


## Gitlab -> New Project -> git Repo by URL

- import https://github.com/home1-oss/common-config.git
> into 'home1-oss/common-config' as internal project
> set or enable [deploy key](https://raw.githubusercontent.com/home1-oss/oss-configserver/master/src/main/resources/default_deploy_key.pub) for oss-configserver access

- import https://github.com/home1-oss/oss-todomvc-app-config.git
> into 'home1-oss/oss-todomvc-app-config' as private project
> set or enable [deploy key](https://raw.githubusercontent.com/home1-oss/oss-configserver/master/src/main/resources/default_deploy_key.pub) for oss-configserver access

- import https://github.com/home1-oss/oss-todomvc-thymeleaf-config.git
> into 'home1-oss/oss-todomvc-thymeleaf-config' as private project
> set or enable [deploy key](https://raw.githubusercontent.com/home1-oss/oss-configserver/master/src/main/resources/default_deploy_key.pub) for oss-configserver access

- import https://github.com/home1-oss/oss-todomvc-gateway-config.git
> into 'home1-oss/oss-todomvc-gateway-config' as private project
> set or enable [deploy key](https://raw.githubusercontent.com/home1-oss/oss-configserver/master/src/main/resources/default_deploy_key.pub) for oss-configserver access

- import https://github.com/home1-oss/oss-todomvc.git
> into 'home1-oss/oss-todomvc' as private project

- import https://github.com/home1-oss/oss-jenkins-pipeline.git
> into 'home1-oss/oss-jenkins-pipeline' as private project

## Run oss-eureka, oss-configserver, oss-todomvc, oss-admin, oss-hystrixboard, oss-turbine

- oss-eureka (docker-compose)
  Project: oss-eureka
  Environment: staging
  Docker registry: home1oss
  Version: 1.0.7.OSS
  Preposition deploy: 192.168.199.51
  All nodes: 192.168.199.51;192.168.199.52;192.168.199.53
  
  TODO Add DNS record

- oss-eureka (k8s)
  Project: oss-eureka-k8s
  Environment: staging
  Version: 1.0.7.OSS

```sh
kubectl get services
kubectl describe services/oss-eureka
```

  Find service's address
```sh
pod=$(kubectl get pods | grep oss-eureka- | awk '{print $1}')
kubectl exec -it ${pod} nslookup oss-eureka.default.svc.cluster.local 127.0.0.1:10053
```

  Find endpoint's address
```sh
pod=$(kubectl get pods --all-namespaces | grep kube-dns | awk '{print $2}')
kubectl --namespace=kube-system exec -it ${pod} -c kubedns -- nslookup oss-eureka.default.svc.cluster.local 127.0.0.1:10053
#kubectl --namespace kube-system describe pods/${pod} | grep IP
```
  
  Find kube-dns service
```sh
kubectl describe --namespace=kube-system svc kube-dns
```

  Cluster DNS is 10.43.0.10
  Run `nslookup oss-eureka.default.svc.cluster.local 10.43.0.10` on pod's container

- oss-configserver (k8s)

## TODOS

- Add DNS setup for privoxy container
- Test download file from fileserver.internal through smart-http-proxy.internal:28119

- A cron script do `sudo chmod a+rw /var/run/docker.sock` on all rancher/k8s hosts

- Fix CI build on github forked projects

- Move export BUILD_JIRA_PROJECTKEY=OSS
       export BUILD_JIRA_USER=gitlab
       export BUILD_JIRA_PASSWORD=zxcvmnbv
  from infrastructure config into project ci config

- Change DNS by edit /etc/sysconfig/network-scripits/ifc-xxx (/etc/reslov.conf is not reboot safe)
- Auto set rancherhost' name by `hostnamectl set-hostname xxx`


- Move install python script into inline script
- Ubuntu 16.04 disk space issue

- Move username and password of jenkins-swarm-slave-deploy.yaml from args to env secret
- Index of LDAP doc of sub projects
- Time sync in inline script

- setenforce 0 ?

- issue: rancher/server:v1.6.3 rancher/k8s:v1.6.6-rancher1-4 k8s cluster-domain not set correctly.

# References

[docker debug log](https://success.docker.com/KBase/How_do_I_enable_%22debug%22_logging_of_the_Docker_daemon%3F)
