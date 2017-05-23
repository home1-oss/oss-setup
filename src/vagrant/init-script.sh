#!/usr/bin/env bash

SHELL_PROFILE="/home/vagrant/.bash_profile"
SED=sed
TMP="/tmp"

# arguments: lead_pattern, tail_pattern, snippet_file, target_file
function append_or_replace() {
    local lead_pattern="$1"
    local tail_pattern="$2"
    local snippet_file="$3"
    local target_file="$4"

    local lead=$(echo "${lead_pattern}" | ${SED} 's/^\^//' | ${SED} 's/\$$//')
    local tail=$(echo "${tail_pattern}" | ${SED} 's/^\^//' | ${SED} 's/\$$//')

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
        $SED -e "/$lead_pattern/,/$tail_pattern/{ /$lead_pattern/{p; r ${snippet_file}
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

echo "executing init-script.sh on $(hostname) by $(whoami) at $(pwd)"

if ! type -p ifconfig > /dev/null; then
    sudo yum -y install net-tools
fi
if ! type -p unzip > /dev/null; then
    sudo yum -y install unzip
fi

# Java Version
JAVA_VERSION_MAJOR=8
JAVA_VERSION_MINOR=121
JAVA_VERSION_BUILD=13
JAVA_PACKAGE=jdk

# unarchive Java
if [[ -f jdk8.tar.gz ]]; then
    tar -xzf jdk8.tar.gz -C /opt &&\
    ln -s /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} /opt/jdk &&\
    rm -rf /opt/jdk/*src.zip \
           /opt/jdk/lib/missioncontrol \
           /opt/jdk/lib/visualvm \
           /opt/jdk/lib/*javafx* \
           /opt/jdk/jre/lib/plugin.jar \
           /opt/jdk/jre/lib/ext/jfxrt.jar \
           /opt/jdk/jre/bin/javaws \
           /opt/jdk/jre/lib/javaws.jar \
           /opt/jdk/jre/lib/desktop \
           /opt/jdk/jre/plugin \
           /opt/jdk/jre/lib/deploy* \
           /opt/jdk/jre/lib/*javafx* \
           /opt/jdk/jre/lib/*jfx* \
           /opt/jdk/jre/lib/amd64/libdecora_sse.so \
           /opt/jdk/jre/lib/amd64/libprism_*.so \
           /opt/jdk/jre/lib/amd64/libfxplugins.so \
           /opt/jdk/jre/lib/amd64/libglass.so \
           /opt/jdk/jre/lib/amd64/libgstreamer-lite.so \
           /opt/jdk/jre/lib/amd64/libjavafx*.so \
           /opt/jdk/jre/lib/amd64/libjfx*.so \
           jdk8.tar.gz
fi

if [[ -f jce_policy-8.zip ]]; then
    POLICY_DIR="UnlimitedJCEPolicyJDK${JAVA_VERSION_MAJOR}" \
        && unzip jce_policy-8.zip \
        && cp -f ${POLICY_DIR}/US_export_policy.jar /opt/jdk/jre/lib/security/US_export_policy.jar \
        && cp -f ${POLICY_DIR}/local_policy.jar /opt/jdk/jre/lib/security/local_policy.jar \
        && rm -rf ${POLICY_DIR} \
                  jce_policy-8.zip
fi

vagrant_java_home_lead='^### VAGRANT JAVA_HOME BEGIN$'
vagrant_java_home_tail='^### VAGRANT JAVA_HOME END$'
echo "export JAVA_HOME=\"/opt/jdk\"
export PATH=\"\${PATH}:\${JAVA_HOME}/bin\"" > ${TMP}/java_home
append_or_replace "${vagrant_java_home_lead}" "${vagrant_java_home_tail}" "${TMP}/java_home" "${SHELL_PROFILE}"

# see: http://stackoverflow.com/questions/17483723/command-not-found-when-using-sudo-ulimit
vagrant_limit_lead='^### VAGRANT LIMIT BEGIN$'
vagrant_limit_tail='^### VAGRANT LIMIT END$'
#echo "sudo sh -c \"ulimit -n 100000 && exec su \$LOGNAME\"" > ${TMP}/limit
#append_or_replace "${vagrant_limit_lead}" "${vagrant_limit_tail}" "${TMP}/limit" "${SHELL_PROFILE}"

echo "*          soft    nofile     100000
*          hard    nofile     100000" > ${TMP}/etc_security_limits_conf
append_or_replace "${vagrant_limit_lead}" "${vagrant_limit_tail}" "${TMP}/etc_security_limits_conf" "/etc/security/limits.conf"

echo "session         required        pam_limits.so" > ${TMP}/etc_pam_d_su
append_or_replace "${vagrant_limit_lead}" "${vagrant_limit_tail}" "${TMP}/etc_pam_d_su" "/etc/pam.d/login"
sudo touch /etc/pam.d/common-session
append_or_replace "${vagrant_limit_lead}" "${vagrant_limit_tail}" "${TMP}/etc_pam_d_su" "/etc/pam.d/common-session"
sudo touch /etc/pam.d/common-session-noninteractive
append_or_replace "${vagrant_limit_lead}" "${vagrant_limit_tail}" "${TMP}/etc_pam_d_su" "/etc/pam.d/common-session-noninteractive"

vagrant_hosts_lead='^### VAGRANT HOSTS BEGIN$'
vagrant_hosts_tail='^### VAGRANT HOSTS END$'
echo "192.168.50.50 demo-quasar" > ${TMP}/etc_hosts
append_or_replace "${vagrant_hosts_lead}" "${vagrant_hosts_tail}" "${TMP}/etc_hosts" "/etc/hosts"

rm -rf /home/vagrant/application
mkdir -p /home/vagrant/application
if [[ -f application.tar.gz ]]; then
    tar -xzf application.tar.gz --strip-components=1 -C /home/vagrant/application
elif [[ -f application.tar ]]; then
    tar -xf application.tar --strip-components=1 -C /home/vagrant/application
fi
