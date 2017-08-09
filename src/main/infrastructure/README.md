# Infrastructure cluster
home1-oss infrastructure cluster.

## Run

```sh
vagrant up
ansible-galaxy install -v --force -r requirements.yml
# start all
ansible-playbook -v -u root -i hosts --private-key=${HOME}/.vagrant.d/insecure_private_key playbook.yml \
    -e "create_oss_network=True branch=develop infrastructure=internal forwarders=<e.g. 10.0.2.3> proxy=<e.g. socks5://127.0.0.1:1080>"
# or start specific services
ansible-playbook -v -u root -i hosts --private-key=${HOME}/.vagrant.d/insecure_private_key playbook.yml \
    --tags "dns,privoxy,ldap,nexus3,mysql,postgresql,cloudbus,docker-config,sonarqube,gitlab,jenkins" \
    -e "create_oss_network=True branch=develop infrastructure=internal forwarders=<e.g. 10.0.2.3> proxy=<e.g. socks5://127.0.0.1:1080>"
```

## Check proxy

- Test proxy to https://gcr.io/v2/
`http_proxy=http://smart-http-proxy.internal:28119 https_proxy=http://smart-http-proxy.internal:28119 curl -SL https://gcr.io`

Clear the DNS cache in macOS Sierra
```sh
sudo killall -HUP mDNSResponder
```

- Re-config proxy only
```sh
ansible-playbook -v -u root -i hosts --private-key=${HOME}/.vagrant.d/insecure_private_key playbook.yml \
    --tags "privoxy" \
    -e "branch=develop infrastructure=internal proxy=<e.g. socks5://127.0.0.1:1080>"
```

## Services

- [DNS(bind) https://bind.internal:10000/](https://bind.internal:10000/)
> Default username/password: root/root_pass
- [Internet proxy (privoxy) http://http-to-socks.internal:28118](http://http-to-socks.internal:28118)
> Test: `curl -x http://http-to-socks.internal:28118 -L https://google.com`
- [Smart internet proxy (privoxy) http://smart-http-proxy.internal:28119](http://smart-http-proxy.internal:28119)
> Test: `curl -x http://smart-http-proxy.internal:28119 -L https://google.com`
- [OpenLDAP (phpldapadmin) https://phpldapadmin.internal:6443](https://phpldapadmin.internal:6443)
> Default username/password: cn=admin,dc=internal/admin_pass


- [Nexus3 http://nexus3.internal:28081/nexus/](http://nexus3.internal:28081/nexus/)
> Default username/password: admin/admin123
- [registry.docker.internal http://registry.docker.internal](http://registry.docker.internal)
> Proxy to nexus3
Test: `docker pull busybox:latest`
then `docker tag busybox:latest registry.docker.internal/busybox:latest; docker push registry.docker.internal/busybox:latest`
- [nexus.internal http://nexus.internal/nexus/](http://nexus.internal/nexus/)
> Proxy to nexus3
- [mvnsite.internal http://mvnsite.internal](http://mvnsite.internal)
> Proxy to nexus3, Default username/password: deployment/deployment
Test: `curl --user "deployment:deployment" -T "README.md" "http://mvnsite.internal/README.md"`
then `curl -L http://mvnsite.internal/README.md`
- [mirror.docker.internal http://mirror.docker.internal](http://mirror.docker.internal)
> Proxy to nexus3
Test: `docker pull mirror.docker.internal/busybox:latest`
- [fileserver.internal http://fileserver.internal](http://fileserver.internal)
> Proxy to nexus3, Default username/password: deployment/deployment
Test: `curl --user "deployment:deployment" -T "README.md" "http://fileserver.internal/README.md"`
then `curl -L http://fileserver.internal/README.md`

- [gcr.io.internal](http://gcr.io.internal:25004)
> mirror of gcr.io
Test: `docker pull gcr.io.internal:25004/google_containers/pause-amd64:3.0`

- [cloudbus.internal http://cloudbus.internal:15672](http://cloudbus.internal:15672)
> Default username/password: user/user_pass

- postgresql.internal
> Default username/password: user/user_pass
Test: `psql -h postgresql.internal -p 5432 --username "user"`
- mysql.internal
> Default username/password: root/root
Test: `mysql -h mysql.internal -P 3306 -u root`
On 1130 error: `docker exec -it mysql.internal mysql -u root -e "SELECT user,host FROM mysql.user;"`
then
`docker exec -it mysql.internal mysql -u root mysql -e "UPDATE user SET host='%' WHERE user='root' AND host='localhost'; FLUSH PRIVILEGES;"`
or
`docker exec -it mysql.internal mysql -u root -e "GRANT ALL ON db.* TO user@'%' IDENTIFIED BY 'user_pass'; FLUSH PRIVILEGES;"`


- [Gitlab http://gitlab.internal:10080](http://gitlab.internal:10080)
> Default username/password: user/user_pass
- [git.internal http://git.internal](http://git.internal)
> Proxy to gitlab

- [Jenkins http://jenkins.internal:18083](http://jenkins.internal:18083)
> Default username/password: run `docker logs -f jenkins.internal` on ci host to find generated password.

- [Sonarqube http://sonarqube.internal:9000](http://sonarqube.internal:9000)
> Default username/password: admin/admin
- [sonar.internal http://sonar.internal](http://sonar.internal)
> Proxy to sonarqube

## Destroy

```sh
vagrant destroy -f && rm -rf .vagrant
```

## References

Vagrant and VirtualBox's shared folder

[config.vm.synced_folder](https://www.vagrantup.com/docs/synced-folders/basic_usage.html)
[Vagrant can't mount shared folder in VirtualBox 4.3.10](https://github.com/mitchellh/vagrant/issues/3341)
