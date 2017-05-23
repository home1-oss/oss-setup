#!/usr/bin/env bash

function aria2c_download {
    local download_url="${1}"
    local download_path="${2}"
    local original_file="${3}"

    mkdir -p ${download_path}
    if [[ ! -f ${download_path}/${original_file} ]]; then
        aria2c --header="Cookie: oraclelicense=accept-securebackup-cookie" \
            --file-allocation=none \
            -c -x 10 -s 10 -m 0 \
            --console-log-level=notice --log-level=notice --summary-interval=0 \
            -d "${download_path}" -o "${original_file}" "${download_url}"
    fi
}

# Java Version
JAVA_VERSION_MAJOR=8
JAVA_VERSION_MINOR=121
JAVA_VERSION_BUILD=13
JAVA_PACKAGE=jdk

build_fileserver="http://download.oracle.com"
download_path="src/vagrant"

download_url="${build_fileserver}/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/e9e7ea248e2c4826b92b3f075a80e441/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz"
original_file="${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz"
aria2c_download ${download_url} ${download_path} ${original_file}

download_url="${build_fileserver}/otn-pub/java/jce/${JAVA_VERSION_MAJOR}/jce_policy-${JAVA_VERSION_MAJOR}.zip"
original_file="jce_policy-${JAVA_VERSION_MAJOR}.zip"
aria2c_download ${download_url} ${download_path} ${original_file}
