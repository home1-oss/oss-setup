
if ! type -p jq > /dev/null; then sudo apt-get update -y; sudo apt-get install -y jq; fi

RANCHER_IMAGES=()
RANCHER_IMAGES+=('_/rancher/agent')
#RANCHER_IMAGES+=('_/rancher/container-crontab')
RANCHER_IMAGES+=('_/rancher/dns')
RANCHER_IMAGES+=('_/rancher/etcd')
RANCHER_IMAGES+=('_/rancher/etcd-host-updater')
#RANCHER_IMAGES+=('_/rancher/external-dns')
RANCHER_IMAGES+=('_/rancher/healthcheck')
#RANCHER_IMAGES+=('_/rancher/lb-service-haproxy')
RANCHER_IMAGES+=('_/rancher/lb-service-rancher')
RANCHER_IMAGES+=('_/rancher/metadata')
RANCHER_IMAGES+=('_/rancher/net')
RANCHER_IMAGES+=('_/rancher/net:holder')
RANCHER_IMAGES+=('_/rancher/network-manager')
RANCHER_IMAGES+=('_/rancher/server')
#RANCHER_IMAGES+=('_/rancher/swarmkit')
# rancher k8s
RANCHER_IMAGES+=('_/rancher/k8s')
RANCHER_IMAGES+=('_/rancher/kubectld')
RANCHER_IMAGES+=('_/rancher/kubernetes-agent')
RANCHER_IMAGES+=('_/rancher/kubernetes-auth')

REGISTRIES=()
REGISTRIES+=('172.22.101.10:25001')

for registry in ${REGISTRIES[@]}; do
    echo "registry: ${registry}"

    for image in ${RANCHER_IMAGES[@]}; do
        image=$(echo ${image} | sed -E 's#[^/]+/(.+)#\1#')
        tag=$(echo ${image} | awk -F: '{print $2}')
        tags=()
        if [ -z "${tag}" ]; then
            echo "curl http://${registry}/v2/${image}/tags/list | jq -r '.tags'"
            tags=$(curl http://${registry}/v2/${image}/tags/list | jq -r '.tags | to_entries[] | "\(.value)"' | grep -v null)
        else
            tags+=("${tag}")
        fi
        printf "all tags     : %s\n" "$(echo "${tags[@]}" | sort -V -r)"
        tags=("$(echo "${tags[@]}" | grep -Ev "[-]?rc[0-9]*\$")")
        tags=("$(echo "${tags[@]}" | grep -Ev "[-]?alpha[0-9]*\$")")
        tags=("$(echo "${tags[@]}" | grep -Ev "[-]?beta[0-9]*\$")")
        tags=("$(echo "${tags[@]}" | sort -V -r | head -n5)")
        printf "selected tag: %s\n" "$(echo "${tags[@]}")"

        for tag in ${tags[@]}; do
            full_image="${registry}/${image}:${tag}"
            echo pull image ${full_image}
            docker pull ${full_image}
        done
    done
done
