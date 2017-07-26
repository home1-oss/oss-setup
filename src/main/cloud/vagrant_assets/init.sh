##!/usr/bin/env bash
#/usr/bin/env bash No such file or directory on ubuntu/trusty64

SHELL_PROFILE="/home/vagrant/.bash_profile"
TMP="/tmp"

# arguments: lead_pattern, tail_pattern, snippet_file, target_file
function append_or_replace() {
    local lead_pattern="$1"
    local tail_pattern="$2"
    local snippet_file="$3"
    local target_file="$4"

    local lead=$(echo "${lead_pattern}" | sed 's/^\^//' | sed 's/\$$//')
    local tail=$(echo "${tail_pattern}" | sed 's/^\^//' | sed 's/\$$//')

    if [[ -z $(grep -E "${lead_pattern}" ${target_file}) ]] || [[ -z $(grep -E "${tail_pattern}" ${target_file}) ]]; then
        if [ -w "${target_file}" ]; then
            echo "${lead}" >> ${target_file}
            cat ${snippet_file} >> ${target_file}
            echo "${tail}" >> ${target_file}
        else
            echo "need to append file '${target_file}', content is:"
            echo "${lead}"
            cat ${snippet_file}
            echo "${tail}"
            echo "please input password when prompt."
            sudo sh -c "echo '${lead}' >> ${target_file}"
            sudo sh -c "cat ${snippet_file} >> ${target_file}"
            sudo sh -c "echo '${tail}' >> ${target_file}"
        fi
    else
        local tmp_file=${TMP}/insert_or_replace.tmp
        # see: http://superuser.com/questions/440013/how-to-replace-part-of-a-text-file-between-markers-with-another-text-file
        sed -e "/$lead_pattern/,/$tail_pattern/{ /$lead_pattern/{p; r ${snippet_file}
        }; /$tail_pattern/p; d }" ${target_file} > ${tmp_file}
        if [ -w "${target_file}" ]; then
            cat ${tmp_file} > ${target_file}
        else
            echo "need to replace in file '${target_file}'"
            echo "replace content between ${lead} ... ${tail} to:"
            echo "${lead}"
            cat ${snippet_file}
            echo "${tail}"
            echo "please input password when prompt."
            sudo sh -c "cat ${tmp_file} > ${target_file}"
        fi
    fi
}

echo "executing init.sh on $(hostname) by $(whoami) at $(pwd)"

# see: http://stackoverflow.com/questions/17483723/command-not-found-when-using-sudo-ulimit
vagrant_limit_lead='^### VAGRANT LIMIT BEGIN$'
vagrant_limit_tail='^### VAGRANT LIMIT END$'

echo "*          soft    nofile     100000
*          hard    nofile     100000" > ${TMP}/etc_security_limits_conf
append_or_replace "${vagrant_limit_lead}" "${vagrant_limit_tail}" "${TMP}/etc_security_limits_conf" "/etc/security/limits.conf"

echo "session         required        pam_limits.so" > ${TMP}/etc_pam_d_su
append_or_replace "${vagrant_limit_lead}" "${vagrant_limit_tail}" "${TMP}/etc_pam_d_su" "/etc/pam.d/login"
sudo touch /etc/pam.d/common-session
append_or_replace "${vagrant_limit_lead}" "${vagrant_limit_tail}" "${TMP}/etc_pam_d_su" "/etc/pam.d/common-session"
sudo touch /etc/pam.d/common-session-noninteractive
append_or_replace "${vagrant_limit_lead}" "${vagrant_limit_tail}" "${TMP}/etc_pam_d_su" "/etc/pam.d/common-session-noninteractive"


if type -p lsb_release > /dev/null; then
    id="$(lsb_release -is)"
    codename=$(lsb_release -cs)
    if [ "${id}" == "Ubuntu" ]; then
        sudo sed -i 's#http://archive.ubuntu.com/ubuntu#http://mirrors.163.com/ubuntu#g' /etc/apt/sources.list
        sudo sed -i 's#http://security.ubuntu.com/ubuntu#http://mirrors.163.com/ubuntu#g' /etc/apt/sources.list
        sudo rm -vrf /var/lib/apt/lists/*
        sudo apt-get clean -y

        if [ "${codename}" == "xenial" ]; then
            sudo apt-get update -y || sudo apt-get update -y
            sudo apt-get install -y python
        fi
    fi
fi

#if ! type -p ifconfig > /dev/null; then sudo yum -y install net-tools; fi
#if ! type -p unzip > /dev/null; then sudo yum -y install unzip; fi
