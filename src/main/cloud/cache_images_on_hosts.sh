
#vagrant ssh-config rancherhost1 > /tmp/ssh-config-rancherhost1
#cat pull_gcr_images.sh | ssh -F /tmp/ssh-config-rancherhost1 root@rancherhost1

HOSTS=()
HOSTS+=('172.22.101.101')
HOSTS+=('172.22.101.102')
HOSTS+=('172.22.101.103')

for host in ${HOSTS[@]}; do
    echo "host: ${host}"

    scp pull_gcr_images.sh root@${host}:/tmp/
    ssh root@${host} '/tmp/pull_gcr_images.sh "origin"'

    scp pull_rancher_images.sh root@${host}:/tmp/
    ssh root@${host} '/tmp/pull_rancher_images.sh "origin"'
done
