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

# binary of jstat
JSTAT=jstat 

# binary of jstack
JSTACK=jstack 

# binary of jmap
JMAP=jmap

function make_dirs() {
    [[ -d "${BASE_DIR}/output" ]] && mkdir -p "${BASE_DIR}/output"
}

# check if the process is a java process
# $1 pid
function check_process() {
    local pid="${1}"
    if [[ ! $($JPS | awk '$1 == '"${pid}"' { print $1 }') ]]
    then
        return 1
    fi
}

# $1 pid
function collect_top_info() {
    local pid="${1}"
    top -b -n "${COUNT}" -d "${INTERVAL}" -H -p "${pid}" >> ${BASE_DIR}/output/${pid}/top.$(date +'%Y%m%d%H%M%S').txt
}

# $1 pid
function collect_stack_info() {
    local pid="${1}"
    local time=$(date +'%Y%m%d%H%M%S')
    for i in $(seq ${COUNT})
    do
        $JSTACK -F "${pid}" >> ${BASE_DIR}/output/${pid}/jstack.$(date +'%Y%m%d%H%M%S').txt
        sleep ${INTERVAL}
        echo "" >> ${BASE_DIR}/output/${pid}/jstack.$(date +'%Y%m%d%H%M%S').txt
        echo "==================" >> ${BASE_DIR}/output/${pid}/jstack.$(date +'%Y%m%d%H%M%S').txt
    done
}

# $1 pid
function collect_gc_info() {
    local pid="${1}"
    $JSTAT -gcutil "${pid}" $[INTERVAL * 1000] ${COUNT} >> ${BASE_DIR}/output/${pid}/jstat.$(date +'%Y%m%d%H%M%S').txt
}

# $1 pid
function collect_heap_info() {
    local pid="${1}"
    $JMAP -dump:format=b,file=${BASE_DIR}/output/${pid}/heap.$(date +'%Y%m%d%H%M%S').hprof "${pid}"
}

function export_functions() {
    export -f collect_top_info
    export -f collect_gc_info
    export -f collect_stack_info
    export -f collect_heap_info
}


