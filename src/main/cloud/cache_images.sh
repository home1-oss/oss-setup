
#vagrant ssh-config rancherhost1 > /tmp/ssh-config-rancherhost1
#cat pull_gcr_images.sh | ssh -F /tmp/ssh-config-rancherhost1 vagrant@rancherhost1

HOSTS=()
HOSTS+=('192.168.199.101')
HOSTS+=('192.168.199.102')
HOSTS+=('192.168.199.103')
HOSTS+=('192.168.199.104')

KEY="~/.vagrant.d/insecure_private_key"

function cache_images() {
    local host="$1"

    echo "host: ${host}"

    scp -i ${KEY} pull_gcr_images.sh vagrant@${host}:/tmp/
    ssh -i ${KEY} vagrant@${host} '/tmp/pull_gcr_images.sh "mirror.docker.internal"'
    ssh -i ${KEY} vagrant@${host} '/tmp/pull_gcr_images.sh "origin"'

    scp -i ${KEY} pull_rancher_images.sh vagrant@${host}:/tmp/
    ssh -i ${KEY} vagrant@${host} '/tmp/pull_rancher_images.sh "mirror.docker.internal"'
    ssh -i ${KEY} vagrant@${host} '/tmp/pull_rancher_images.sh "origin"'

    # untag mirror.docker.internal/*
    ssh -i ${KEY} vagrant@${host} "sudo docker images | grep mirror.docker.internal | awk '{print \$1\":\"\$2}' | xargs sudo docker rmi"
}

if [ ! -z "$1" ]; then
    cache_images "$1"
else
    for host in ${HOSTS[@]}; do
        cache_images "${host}"
    done
fi
