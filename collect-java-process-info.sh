#!/bin/bash
#
#      Author: neuwangcong@gmail.com
# Description: A simple shell that can help you collect some infomation about Java process,
#              such as cpu, memory, stack.
#

set -e

BASE_DIR=$(cd $(dirname "$BASH_SOURCE[0]"); pwd)

# keyword of java process
KEYWORD=""

# seconds between two collections
COLLECT_INTERVAL=1

# total count of the collections
COLLECT_COUNT=5

# jps must be found
function check_requirements() {
    if [ -x "$(command -v jps)" ]
    then 
        JPS=jps
    else
        if [ -x "$(command -v ${JAVA_HOME}/bin/jps)" ] 
        then 
            JPS="${JAVA_HOME}/bin/jps"
        else 
            echo 'jps not found in $PATH or $JAVA_HOME/bin'
            exit 1
        fi
    fi

    if [ -x "$(command -v jstack)" ]
    then 
        JSTACK=jstack
    else 
        if [ -x "$(command -v ${JAVA_HOME}/bin/jstack)" ]
        then 
            JSTACK="${JAVA_HOME}/bin/jstack"
        fi 
    fi 

    if [ -x "$(command -v jstat)" ]
    then 
        JSTAT=jstat
    else 
        if [ -x "$(command -v ${JAVA_HOME}/bin/jstat)" ]
        then 
            JSTAT="${JAVA_HOME}/bin/jstat"
        fi 
    fi 

    if [ -x "$(command -v jmap)" ]
    then 
        JMAP=jmap
    else 
        if [ -x "$(command -v ${JAVA_HOME}/bin/jmap)" ]
        then 
            JMAP="${JAVA_HOME}/bin/jmap"
        fi 
    fi
}

# $1 pid
function collect_top_info() {
    local pid="${1}"
    [[ -d "output/${pid}" ]] || mkdir -p "output/${pid}"
    if [ ! -z "${pid}" ]
    then 
        top -b -n "${COLLECT_COUNT}" -d "${COLLECT_INTERVAL}" -H -p "${pid}" >> output/${pid}/top.$(date +'%Y%m%d%H%M%S').txt
    fi 
}

# $1 pid
function collect_stack_info() {
    local pid="${1}"
    local time=$(date +'%Y%m%d%H%M%S')
    [[ -d "output/${pid}" ]] || mkdir -p "output/${pid}"
    for i in $(seq ${COLLECT_COUNT})
    do
        if [ ! -z "${JSTACK}" ] && [ ! -z "${pid}" ]
        then 
            ${JSTACK} -F "${pid}" >> output/${pid}/jstack.${time}.txt
            echo "" >> output/${pid}/jstack.${time}.txt
            echo "==================" >> output/${pid}/jstack.${time}.txt
            echo "" >> output/${pid}/jstack.${time}.txt
            sleep ${COLLECT_INTERVAL}
        fi 
    done
}

# $1 pid
function collect_gc_info() {
    local pid="${1}"
    [[ -d "output/${pid}" ]] || mkdir -p "output/${pid}"
    if [ ! -z "${JSTAT}" ] && [ ! -z "${pid}" ]
    then 
        ${JSTAT} -gcutil "${pid}" $[COLLECT_INTERVAL * 1000] ${COLLECT_COUNT} >> output/${pid}/jstat.$(date +'%Y%m%d%H%M%S').txt
    fi 
    
}

# $1 pid
function collect_heap_info() {
    local pid="${1}"
    [[ -d "output/${pid}" ]] || mkdir -p "output/${pid}"
    if [ ! -z "${JMAP}" ] && [ ! -z "${pid}" ]
    then 
        ${JMAP} -dump:format=b,file=output/${pid}/heap.$(date +'%Y%m%d%H%M%S').hprof "${pid}"
    fi 
}

function export_functions() {
    export -f collect_top_info
    export -f collect_gc_info
    export -f collect_stack_info
    export -f collect_heap_info
}

function export_envs() {
    export JMAP
    export JSTACK
    export JSTAT
    export JPS
    export COLLECT_INTERVAL
    export COLLECT_COUNT
}

function collect_java_process_info() {
    cd ${BASE_DIR} &>/dev/null
    if [ "x${KEYWORD}" = "x" ]
    then 
        JAVA_PROCESSES="$(${JPS} -l | grep -v 'sun.tools.jps.Jps')"
    else 
        JAVA_PROCESSES="$(${JPS} -lmvV | grep ${KEYWORD} | grep -v grep)"
    fi 
    if [ "x{JAVA_PROCESSES}" = "x" ] 
    then 
        echo "no java process that meeting the condtions"
        exit 1
    fi
    local IFS=$'\n'
    local process=""
    for process in $(echo "${JAVA_PROCESSES}")
    do
        local pid=$(echo "${process}" | awk '{ print $1 }')
        nohup bash -c "collect_top_info ${pid}" &>/dev/null &
        nohup bash -c "collect_gc_info ${pid}" &>/dev/null &
        nohup bash -c "collect_stack_info ${pid}" &>/dev/null &
        nohup bash -c "collect_heap_info ${pid}" &>/dev/null &
    done
}

check_requirements

export_functions

export_envs

collect_java_process_info
