
HOSTS=()
HOSTS+=('172.22.101.100')
HOSTS+=('172.22.101.101')
HOSTS+=('172.22.101.102')
HOSTS+=('172.22.101.103')

declare -a IMAGES
for host in "${HOSTS[@]}"; do
    #echo "host: ${host}"
    found=("$(ssh root@${host} 'docker images --format {{.Repository}}:{{.Tag}}')")
    #printf "host: %s, found:\n%s\n" "${host}" "${found[@]}"
    for img in "${found[@]}"; do
        IMAGES+=("${img}")
    done
done

#printf 'ALL IMAGES:\n'
#for img in "${IMAGES[@]}"; do printf '%s\n' "${img}"; done

IMAGES=($(echo "${IMAGES[@]}" | sort | uniq))
#printf 'IMAGES:\n'
for img in "${IMAGES[@]}"; do printf '%s\n' "${img}"; done

#gcr.io/google_containers/heapster-amd64:v1.3.0-beta.1
#gcr.io/google_containers/heapster-grafana-amd64:v4.0.2
#gcr.io/google_containers/heapster-influxdb-amd64:v1.1.1
#gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.2
#gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.2
#gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.2
#gcr.io/google_containers/kubernetes-dashboard-amd64:v1.6.1
#gcr.io/google_containers/pause-amd64:3.0
#rancher/scheduler:v0.8.2
#gcr.io/kubernetes-helm/tiller:v2.3.0
#rancher/agent:v1.2.5
#rancher/dns:v0.15.1
#rancher/etc-host-updater:v0.0.2
#rancher/etcd:v2.3.7-11
#rancher/healthcheck:v0.3.1
#rancher/k8s:v1.6.6-rancher1-4
#rancher/kubectld:v0.6.8
#rancher/kubernetes-agent:v0.6.2
#rancher/kubernetes-auth:v0.0.4
#rancher/lb-service-rancher:v0.7.4
#rancher/metadata:v0.9.2
#rancher/net:v0.11.3
#rancher/network-manager:v0.7.4
#rancher/server:v1.6.3
#rancher/scheduler:v0.8.2
