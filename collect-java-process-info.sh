#!/bin/bash
#
#      Author: neuwangcong@gmail.com
# Description: A simple shell that can help you collect some infomation about Java process,
#              such as cpu, memory, stack.
#

set -e

BASE_DIR=$(cd $(dirname "$BASH_SOURCE[0]"); pwd)

# seconds between two outputs
INTERVAL=1

# total output count
COUNT=5

function make_dirs() {
    [[ -d "${BASE_DIR}/output" ]] && mkdir -p "${BASE_DIR}/output"
}

# jps must be found
function check_requirements() {
    if [ -x $(command -v jps) ]
    then 
        JPS=jps
    else
        if [ -x $(command -v "${JAVA_HOME}/bin/jps") ] 
        then 
            JPS="${JAVA_HOME}/bin/jps"
        else 
            echo 'jps not found in $PATH or $JAVA_HOME/bin'
            exit 1
        fi
    fi

    if [ -x $(command -v jstack) ]
    then 
        JSTACK=jstack
    else 
        if [ -x $(command -v "${JAVA_HOME}/bin/jstack") ]
        then 
            JSTACK="${JAVA_HOME}/bin/jstack"
        fi 
    fi 

    if [ -x $(command -v jstat) ]
    then 
        JSTAT=jstat
    else 
        if [ -x $(command -v "${JAVA_HOME}/bin/jstat") ]
        then 
            JSTAT="${JAVA_HOME}/bin/jstat"
        fi 
    fi 

    if [ -x $(command -v jmap) ]
    then 
        JMAP=jmap
    else 
        if [ -x $(command -v "${JAVA_HOME}/bin/jmap") ]
        then 
            JMAP="${JAVA_HOME}/bin/jmap"
        fi 
    fi
}

# check if the process is a java process
# $1 pid
function check_process() {
    local pid="${1}"
    if [[ ! $($JPS | awk '$1 == '"${pid}"' { print $1 }') ]]
    then
        echo "pid[${pid}] not exists or not a java process"
        return 1
    fi
}

# $1 pid
function collect_top_info() {
    local pid="${1}"
    if [ ! -z "${pid}"]
    then 
        top -b -n "${COUNT}" -d "${INTERVAL}" -H -p "${pid}" >> ${BASE_DIR}/output/${pid}/top.$(date +'%Y%m%d%H%M%S').txt
    fi 
}

# $1 pid
function collect_stack_info() {
    local pid="${1}"
    local time=$(date +'%Y%m%d%H%M%S')
    for i in $(seq ${COUNT})
    do
        if [ ! -z "${JSTACK}" ] && [ ! -z "${pid}" ]
        then 
            ${JSTACK} -F "${pid}" >> ${BASE_DIR}/output/${pid}/jstack.$(date +'%Y%m%d%H%M%S').txt
            sleep ${INTERVAL}
            echo "" >> ${BASE_DIR}/output/${pid}/jstack.$(date +'%Y%m%d%H%M%S').txt
            echo "==================" >> ${BASE_DIR}/output/${pid}/jstack.$(date +'%Y%m%d%H%M%S').txt
        fi 
    done
}

# $1 pid
function collect_gc_info() {
    local pid="${1}"
    if [ ! -z "${JSTAT}" ] && [ ! -z "${pid}" ]
    then 
        ${JSTAT} -gcutil "${pid}" $[INTERVAL * 1000] ${COUNT} >> ${BASE_DIR}/output/${pid}/jstat.$(date +'%Y%m%d%H%M%S').txt
    fi 
    
}

# $1 pid
function collect_heap_info() {
    local pid="${1}"
    if [ ! -z "${JMAP}" ] && [ ! -z "${pid}" ]
    then 
        ${JMAP} -dump:format=b,file=${BASE_DIR}/output/${pid}/heap.$(date +'%Y%m%d%H%M%S').hprof "${pid}"
    fi 
}

function export_functions() {
    export -f collect_top_info
    export -f collect_gc_info
    export -f collect_stack_info
    export -f collect_heap_info
}

check_requirements
