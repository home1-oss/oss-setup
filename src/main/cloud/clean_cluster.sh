
# see: http://blog.yohanliyanage.com/2015/05/docker-clean-up-after-yourself/

HOSTS=()
HOSTS+=('192.168.199.100')
HOSTS+=('192.168.199.101')
HOSTS+=('192.168.199.102')
HOSTS+=('192.168.199.103')
HOSTS+=('192.168.199.104')

KEY="~/.vagrant.d/insecure_private_key"

for host in ${HOSTS[@]}; do
    echo "host: ${host}"

    ssh -i ${KEY} vagrant@${host} '
docker rm -fv $(docker ps -qa)

rm -rf /var/etcd/

for m in $(tac /proc/mounts | awk '"'"'{print $2}'"'"' | grep /var/lib/kubelet); do
  umount ${m} || true
done
rm -rf /var/lib/kubelet/

for m in $(tac /proc/mounts | awk '"'"'{print $2}'"'"' | grep /var/lib/rancher); do
  umount ${m} || true
done
rm -rf /var/lib/rancher/

rm -rf /run/kubernetes/

docker volume rm $(docker volume ls -q)

docker ps -a
docker volume ls

docker images | grep mirror.docker.internal | awk '"'"'{print $1":"$2}'"'"' | xargs docker rmi
'

done
