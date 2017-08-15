
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

- import https://github.com/home1-oss/oss-jenkins-pipeline.git
> into 'home1-oss/oss-jenkins-pipeline' as private project

## Run eureka, configserver, todomvc

## TODOS

- Put jenkins pipeline repo on github

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


- clear docker network and bridges in clear_hosts.sh 
- Move install python script into inline script
- Ubuntu 16.04 disk space issue

- Move username and password of jenkins-swarm-slave-deploy.yaml from args to env secret
- Index of LDAP doc of sub projects
- Time sync in inline script

# References

[docker debug log](https://success.docker.com/KBase/How_do_I_enable_%22debug%22_logging_of_the_Docker_daemon%3F)
