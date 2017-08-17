
rancher_env=env-k8s-vxlan-oss-internal

#rancher --env ${rancher_env} ps -a -s -c
#rancher --env ${rancher_env} stacks ls -s

vxlan_containers=$(rancher --env ${rancher_env} ps -a -s -c | grep vxlan | grep -v driver | awk '{print "id:"$1",host_id:"$5",container_ip:"$6",container_id:"$7}')
for container in ${vxlan_containers[@]}; do
    id=$(echo ${container} | awk -F, '{print $1}' | awk -F: '{print $2}')
    host_id=$(echo ${container} | awk -F, '{print $2}' | awk -F: '{print $2}')
    container_ip=$(echo ${container} | awk -F, '{print $3}' | awk -F: '{print $2}')
    container_id=$(echo ${container} | awk -F, '{print $4}' | awk -F: '{print $2}')
    host_ip=$(rancher --env ${rancher_env} hosts | grep ${host_id} | awk '{print $5}')

    # need a rule like this 'MASQUERADE  all  --  anywhere             anywhere' in 'Chain POSTROUTING (policy ACCEPT)'
    rule_found=$(rancher --env ${rancher_env} exec ${id} iptables -t nat --list | grep -E "(MASQUERADE)[ ]+(all)[ ]+(.+)[ ]+(anywhere)[ ]+(anywhere)")
    if [ -z "${rule_found}" ]; then
        # on windows host, socket: An address incompatible with the requested protocol was used
        # see: https://github.com/rancher/rancher/issues/7262
        echo "if you are using windows, execute 'iptables -t nat -A POSTROUTING -j MASQUERADE' manually on container ${container_id} on host ${host_ip}"
        rancher --env ${rancher_env} exec ${id} iptables -t nat -A POSTROUTING -j MASQUERADE
        rancher --env ${rancher_env} exec ${id} iptables -t nat --list
    else
        echo "rule '${rule_found}' found"
    fi

    echo "run 'sudo ip route add 10.42.0.0/16 via ${host_ip}'/'route -n'/'route del default gw ${host_ip}' on linux to add/verify/delete static route."
    echo "run 'sudo route -n add -net 10.42.0.0/16 ${host_ip}'/'netstat -nr'/'sudo route delete 10.42.0.0/16 ${host_ip}' on mac to add/verify/delete static route."
    echo "run 'route ADD 10.42.0.0 MASK 255.255.0.0 ${host_ip}'/'route print'/'route delete 10.42.0.0' on windows to add/verify/delete static route."

    echo "run 'sudo ip route add 10.43.0.0/16 via ${host_ip}'/'route -n'/'route del default gw ${host_ip}' on linux to add/verify/delete static route."
    echo "run 'sudo route -n add -net 10.43.0.0/16 ${host_ip}'/'netstat -nr'/'sudo route delete 10.43.0.0/16 ${host_ip}' on mac to add/verify/delete static route."
    echo "run 'route ADD 10.43.0.0 MASK 255.255.0.0 ${host_ip}'/'route print'/'route delete 10.43.0.0' on windows to add/verify/delete static route."

    echo "then 'ping ${container_ip}' to test VXLAN access."
done
