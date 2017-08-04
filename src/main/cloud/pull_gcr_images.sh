
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

GCR_IO_IMAGES=()
#GCR_IO_IMAGES+=('gcr.io/google_containers/dnsmasq-metrics-amd64')
#GCR_IO_IMAGES+=('gcr.io/google_containers/kube-dnsmasq-amd64')
#GCR_IO_IMAGES+=('gcr.io/google_containers/kubedns-amd64')
#GCR_IO_IMAGES+=('gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64')
GCR_IO_IMAGES+=('gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.2')
#GCR_IO_IMAGES+=('gcr.io/google_containers/k8s-dns-kube-dns-amd64')
GCR_IO_IMAGES+=('gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.2')
#GCR_IO_IMAGES+=('gcr.io/google_containers/k8s-dns-sidecar-amd64')
GCR_IO_IMAGES+=('gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.2')
#GCR_IO_IMAGES+=('gcr.io/google_containers/exechealthz-amd64')
# POD INFRA CONTAINER IMAGE
#GCR_IO_IMAGES+=('gcr.io/google_containers/pause-amd64')
GCR_IO_IMAGES+=('gcr.io/google_containers/pause-amd64:3.0')
# KUBERNETES ADD-ONS
## IMAGES FOR HELM
#GCR_IO_IMAGES+=('gcr.io/kubernetes-helm/tiller')
GCR_IO_IMAGES+=('gcr.io/kubernetes-helm/tiller:v2.3.0')
## IMAGES FOR DASHBOARD
#GCR_IO_IMAGES+=('gcr.io/google_containers/kubernetes-dashboard-amd64')
GCR_IO_IMAGES+=('gcr.io/google_containers/kubernetes-dashboard-amd64:v1.6.1')
## IMAGES FOR HEAPSTER
#GCR_IO_IMAGES+=('gcr.io/google_containers/heapster')
#GCR_IO_IMAGES+=('gcr.io/google_containers/heapster-amd64')
GCR_IO_IMAGES+=('gcr.io/google_containers/heapster-amd64:v1.3.0-beta.1')
#GCR_IO_IMAGES+=('gcr.io/kubernetes/heapster_influxdb')
GCR_IO_IMAGES+=('gcr.io/kubernetes/heapster_influxdb:v1.1.1')
#GCR_IO_IMAGES+=('gcr.io/google_containers/heapster_grafana')
#GCR_IO_IMAGES+=('gcr.io/google_containers/heapster-grafana-amd64')
GCR_IO_IMAGES+=('gcr.io/google_containers/heapster-grafana-amd64:v4.0.2')

from="$1"
if [ -z "${from}" ]; then from="registries"; fi

REGISTRIES=()
if [ "${from}" == "registries" ]; then
    REGISTRIES+=('gcr.io.internal:25004')
    REGISTRIES+=('mirror.docker.internal')
else
    REGISTRIES+=('')
fi

for registry in "${REGISTRIES[@]}"; do
    echo "registry: ${registry}"

    for image in "${GCR_IO_IMAGES[@]}"; do
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
