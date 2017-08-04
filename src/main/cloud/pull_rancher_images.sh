
if ! type -p jq > /dev/null; then
    if type -p apt-get > /dev/null; then
        sudo apt-get update -y; sudo apt-get install -y jq;
    elif type -p yum > /dev/null; then
        sudo yum install -y --force-yes jq
    else
        printf 'please install jq manually\n'
        exit 1
    fi
fi

RANCHER_IMAGES=()
RANCHER_IMAGES+=('_/rancher/agent:v1.2.5')
#RANCHER_IMAGES+=('_/rancher/container-crontab')
RANCHER_IMAGES+=('_/rancher/dns:v0.15.1')
RANCHER_IMAGES+=('_/rancher/etc-host-updater:v0.0.2')
RANCHER_IMAGES+=('_/rancher/etcd:v2.3.7-11')
#RANCHER_IMAGES+=('_/rancher/external-dns')
RANCHER_IMAGES+=('_/rancher/healthcheck:v0.3.1')
#RANCHER_IMAGES+=('_/rancher/lb-service-haproxy')
RANCHER_IMAGES+=('_/rancher/lb-service-rancher:v0.7.4')
RANCHER_IMAGES+=('_/rancher/metadata:v0.9.2')
RANCHER_IMAGES+=('_/rancher/net:v0.11.3')
RANCHER_IMAGES+=('_/rancher/net:holder')
RANCHER_IMAGES+=('_/rancher/network-manager:v0.7.4')
RANCHER_IMAGES+=('_/rancher/scheduler:v0.8.2')
RANCHER_IMAGES+=('_/rancher/server:v1.6.3')
#RANCHER_IMAGES+=('_/rancher/swarmkit')
# rancher k8s
RANCHER_IMAGES+=('_/rancher/k8s:v1.6.6-rancher1-4')
RANCHER_IMAGES+=('_/rancher/kubectld:v0.6.8')
RANCHER_IMAGES+=('_/rancher/kubernetes-agent:v0.6.2')
RANCHER_IMAGES+=('_/rancher/kubernetes-auth:v0.0.4')

from="$1"
if [ -z "${from}" ]; then from="registries"; fi

REGISTRIES=()
if [ "${from}" == "registries" ]; then
    REGISTRIES+=('mirror.docker.internal')
else
    REGISTRIES+=('')
fi

for registry in "${REGISTRIES[@]}"; do
    echo "registry: ${registry}"

    for image in "${RANCHER_IMAGES[@]}"; do
        if [ ! -z "${registry}" ] || [[ "${image}" == _/* ]]; then
            image=$(echo ${image} | sed -E 's#[^/]+/(.+)#\1#')
        fi
        tag=$(echo ${image} | awk -F: '{print $2}')
        tags=()
        if [ -z "${tag}" ]; then
            if [ ! -z "${registry}" ]; then
                echo "curl http://${registry}/v2/${image}/tags/list | jq -r '.tags'"
                tags=$(curl http://${registry}/v2/${image}/tags/list | jq -r '.tags | to_entries[] | "\(.value)"' | grep -v null)
            else
                tags+=("latest")
            fi
        else
            image=$(echo ${image} | awk -F: '{print $1}')
            tags+=("${tag}")
        fi
        printf "all tags     : %s\n" "$(echo "${tags[@]}" | sort -V -r)"
        tags=("$(echo "${tags[@]}" | grep -Ev "[-]?rc[0-9]*\$")")
        tags=("$(echo "${tags[@]}" | grep -Ev "[-]?alpha[0-9]*\$")")
        tags=("$(echo "${tags[@]}" | grep -Ev "[-]?beta[0-9]*\$")")
        tags=("$(echo "${tags[@]}" | sort -V -r | head -n5)")
        printf "selected tag: %s\n" "$(echo "${tags[@]}")"

        for tag in ${tags[@]}; do
            if [ ! -z "${registry}" ]; then
                full_image="${registry}/${image}:${tag}"
            else
                full_image="${image}:${tag}"
            fi
            echo pull image ${full_image}
            docker pull ${full_image}
        done
    done
done
