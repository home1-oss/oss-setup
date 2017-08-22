
# see: http://blog.yohanliyanage.com/2015/05/docker-clean-up-after-yourself/

HOSTS=()
HOSTS+=('192.168.199.51')
HOSTS+=('192.168.199.52')
HOSTS+=('192.168.199.53')

KEY="~/.vagrant.d/insecure_private_key"

for host in ${HOSTS[@]}; do
    echo "host: ${host}"

    ssh -i ${KEY} root@${host} '
sudo docker rm -fv $(sudo docker ps -qa)
sudo docker volume rm $(sudo docker volume ls -q)
sudo docker images -q | xargs sudo docker rmi

sudo docker ps -a
sudo docker volume ls
sudo docker images
'

done
