
HOSTS=()
HOSTS+=('192.168.199.100')
HOSTS+=('192.168.199.101')
HOSTS+=('192.168.199.102')
HOSTS+=('192.168.199.103')
HOSTS+=('192.168.199.104')

declare -a IMAGES
for host in "${HOSTS[@]}"; do
    #echo "host: ${host}"
    found=("$(ssh vagrant@${host} 'sudo docker images --format {{.Repository}}:{{.Tag}}')")
    #printf "host: %s, found:\n%s\n" "${host}" "${found[@]}"
    for img in "${found[@]}"; do
        IMAGES+=("${img}")
    done
done

IMAGES=($(echo "${IMAGES[@]}" | sort | uniq))
#printf 'IMAGES:\n'
for img in "${IMAGES[@]}"; do printf '%s\n' "${img}"; done
