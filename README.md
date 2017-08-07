
# oss-setup
Setup a develop and runtime environment of home1-oss

Some things are slightly difficult to automate,
so I still have some manual installation steps,
but at least it's all documented here.

## Build local development environment

- [macos](./src/main/develop/mac/README.md)

- [linux](./src/main/develop/linux/README.md)

- [windows](./src/main/develop/windows/README.md)

## Build clusters

1. [Cluster of raw machines](./src/main/raw/README.md)
> run docker container on raw machine without orchestration platform such as k8s or rancher

Run infrastructure for development, CI, and service runtime

2. [Cluster of cloud](./src/main/cloud/README.md)
> run docker container on orchestration platform such as k8s or rancher

Run workloads (services)

## Gitlab -> New Project -> git Repo by URL

- import https://github.com/home1-oss/common-config.git
> into 'home1-oss/common-config' as internal project
> set or enable [deploy key](https://raw.githubusercontent.com/home1-oss/oss-configserver/master/src/main/resources/default_deploy_key.pub) for configserver access

- import https://github.com/home1-oss/oss-todomvc-app-config.git
> into 'home1-oss/oss-todomvc-app-config' as private project
> set or enable [deploy key](https://raw.githubusercontent.com/home1-oss/oss-configserver/master/src/main/resources/default_deploy_key.pub) for configserver access

- import https://github.com/home1-oss/oss-todomvc-thymeleaf-config.git
> into 'home1-oss/oss-todomvc-thymeleaf-config' as private project
> set or enable [deploy key](https://raw.githubusercontent.com/home1-oss/oss-configserver/master/src/main/resources/default_deploy_key.pub) for configserver access

- import https://github.com/home1-oss/oss-todomvc-gateway-config.git
> into 'home1-oss/oss-todomvc-gateway-config' as private project
> set or enable [deploy key](https://raw.githubusercontent.com/home1-oss/oss-configserver/master/src/main/resources/default_deploy_key.pub) for configserver access

- import https://github.com/home1-oss/oss-todomvc.git
> into 'home1-oss/oss-todomvc' as private project

## TODOS

- A template that generate oss-internal
- Move export BUILD_JIRA_PROJECTKEY=OSS
       export BUILD_JIRA_USER=gitlab
       export BUILD_JIRA_PASSWORD=zxcvmnbv
  from infrastructure config into project ci config
- A cron script do `sudo chmod a+rw /var/run/docker.sock` on all rancher/k8s hosts
- Fix CI build on github forked projects
- Change DNS by edit /etc/sysconfig/network-scripits/ifc-xxx (/etc/reslov.conf is not reboot safe)
- Auto set rancherhost' name by `hostnamectl set-hostname xxx`
- Index of LDAP doc of sub projects
- Put jenkins pipeline repo on github
- Move username and password of jenkins-swarm-slave-deploy.yaml from args to env secret
