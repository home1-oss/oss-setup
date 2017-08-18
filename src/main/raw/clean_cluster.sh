
# see: http://blog.yohanliyanage.com/2015/05/docker-clean-up-after-yourself/

HOSTS=()
HOSTS+=('192.168.199.51')
HOSTS+=('192.168.199.52')
HOSTS+=('192.168.199.53')

KEY="~/.vagrant.d/insecure_private_key"

for host in ${HOSTS[@]}; do
    echo "host: ${host}"

    ssh -i ${KEY} root@${host} '
docker rm -fv $(docker ps -qa)
docker volume rm $(docker volume ls -q)
docker images -q | xargs docker rmi

docker ps -a
docker volume ls
docker images
'

done
