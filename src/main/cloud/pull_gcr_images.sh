
if ! type -p jq > /dev/null; then sudo apt-get update -y; sudo apt-get install -y jq; fi

GCR_IO_IMAGES=()
GCR_IO_IMAGES+=('gcr.io/google_containers/dnsmasq-metrics-amd64')
GCR_IO_IMAGES+=('gcr.io/google_containers/kube-dnsmasq-amd64')
GCR_IO_IMAGES+=('gcr.io/google_containers/kubedns-amd64')
GCR_IO_IMAGES+=('gcr.io/google_containers/exechealthz-amd64')
# POD INFRA CONTAINER IMAGE
GCR_IO_IMAGES+=('gcr.io/google_containers/pause-amd64')
# KUBERNETES ADD-ONS
## IMAGES FOR HELM
GCR_IO_IMAGES+=('gcr.io/kubernetes-helm/tiller')
## IMAGES FOR DASHBOARD
GCR_IO_IMAGES+=('gcr.io/google_containers/kubernetes-dashboard-amd64')
## IMAGES FOR HEAPSTER
GCR_IO_IMAGES+=('gcr.io/google_containers/heapster')
GCR_IO_IMAGES+=('gcr.io/kubernetes/heapster_influxdb')
GCR_IO_IMAGES+=('gcr.io/google_containers/heapster_grafana')

REGISTRIES=()
REGISTRIES+=('172.22.101.10:25004')
REGISTRIES+=('172.22.101.10:25001')

for registry in ${REGISTRIES[@]}; do
    echo "registry: ${registry}"

    for image in ${GCR_IO_IMAGES[@]}; do
        image=$(echo ${image} | sed -E 's#[^/]+/(.+)#\1#')
        echo "curl http://${registry}/v2/${image}/tags/list | jq -r '.tags'"

        tags=$(curl http://${registry}/v2/${image}/tags/list | jq -r '.tags | to_entries[] | "\(.value)"' | grep -v null)
        for tag in ${tags[@]}; do
            full_image="${registry}/${image}:${tag}"
            echo pull image ${full_image}
            docker pull ${full_image}
        done
    done
done
