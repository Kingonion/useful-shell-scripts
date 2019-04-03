#!/bin/bash
#
#      Author: neuwangcong@gmail.com
#        Date: 2019-04-02
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

# $1 pid
function collect_top_info() {
    local pid="${1}"
    top -b -n "${COUNT}" -d "${INTERVAL}" -H -p "${pid}"
}

# $1 pid
function collect_stack_info() {
    local pid="${1}"
    local time=$(date +'%Y%m%d%H%M%S')
    JSTACK "${pid}"
}

# $1 pid
function collect_gc_info() {
    local pid="${1}"
    JSTAT -gcutil "${pid}" $[INTERVAL * 1000] ${COUNT}
}

# $1 pid
function collect_heap_info() {
    JMAP -dump:format=b,file=${BASE_DIR}/output/${pid}/heap.$(date +'%Y%m%d%H%M%S').hprof "${pid}"
}
