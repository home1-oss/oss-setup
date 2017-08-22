
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
sudo docker rm -fv $(sudo docker ps -qa)

sudo rm -rf /var/etcd/

for m in $(tac /proc/mounts | awk '"'"'{print $2}'"'"' | grep /var/lib/kubelet); do
  sudo umount ${m} || true
done
sudo rm -rf /var/lib/kubelet/

for m in $(tac /proc/mounts | awk '"'"'{print $2}'"'"' | grep /var/lib/rancher); do
  sudo umount ${m} || true
done
sudo rm -rf /var/lib/rancher/

sudo rm -rf /run/kubernetes/

sudo docker volume rm $(sudo docker volume ls -q)

sudo docker ps -a
sudo docker volume ls

sudo docker images | grep mirror.docker.internal | awk '"'"'{print $1":"$2}'"'"' | xargs sudo docker rmi
'

done
