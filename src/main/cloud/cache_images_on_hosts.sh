
#vagrant ssh-config rancherhost1 > /tmp/ssh-config-rancherhost1
#cat pull_gcr_images.sh | ssh -F /tmp/ssh-config-rancherhost1 root@rancherhost1

HOSTS=()
HOSTS+=('192.168.199.101')
HOSTS+=('192.168.199.102')
HOSTS+=('192.168.199.103')

KEY="~/.vagrant.d/insecure_private_key"

for host in ${HOSTS[@]}; do
    echo "host: ${host}"

    scp -i ${KEY} pull_gcr_images.sh root@${host}:/tmp/
    ssh -i ${KEY} root@${host} '/tmp/pull_gcr_images.sh "origin"'

    scp -i ${KEY} pull_rancher_images.sh root@${host}:/tmp/
    ssh -i ${KEY} root@${host} '/tmp/pull_rancher_images.sh "origin"'
done
