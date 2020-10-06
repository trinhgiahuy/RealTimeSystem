#!/bin/sh

# Don't trust busybox `tee`!!!!

: ${EVIL_DATA:=/opt/evil-tests/share/data.txt}
: ${EVIL_SYSFS:=/sys/kernel/evil_module/evil}
: ${EVIL_MODULE_NAME:=evil}

EVIL_DATA=${1:-$EVIL_DATA}
EVIL_SYSFS=${2:-$EVIL_SYSFS}

pause() {
    sleep 0.3
}

msg() {
    echo -e "\n${@}\n" >&2
    pause
}

fail() {
    msg "ERR: ${@}"
    false
}

EVIL_TESTS_STEPS=25
EVIL_TESTS_STEP_COUNTER=0
step() {
    pause
    EVIL_TESTS_STEP_COUNTER=$((1+EVIL_TESTS_STEP_COUNTER))
    local STEP_PREFIX="#### EVIL_TESTS ($EVIL_TESTS_STEP_COUNTER/${EVIL_TESTS_STEPS})"
    msg "${STEP_PREFIX}: ${@}" >&2
}

read_evil() {
    cat ${EVIL_SYSFS} > ${EVIL_TESTS_STEP_COUNTER}.read
    pause
    LAST_READ=${EVIL_TESTS_STEP_COUNTER}.read ; cat ${LAST_READ}
}

write_evil() {
    local INPUT=${1:-${EVIL_DATA}}
    cat ${INPUT} > ${EVIL_TESTS_STEP_COUNTER}.write
    pause
    LAST_WRITE=${EVIL_TESTS_STEP_COUNTER}.write ; cat ${LAST_WRITE} > ${EVIL_SYSFS}
}

write_evil_n() {
    if [ $# -ne 1 ] || [ $1 -le 0 ]; then
        exit 126
    else
        local SZ=$(( $1 - 1 )) # count ending newline

        LAST_INPUT=${EVIL_TESTS_STEP_COUNTER}.input
        LAST_INPUT_CONCAT=${EVIL_TESTS_STEP_COUNTER}.input.concat

        if [ $SZ -gt 0 ]; then
            local UPL=$(( $SZ/16 ))
            for i in $(seq 0 $UPL); do
                echo -n "0123456789abcdef"
            done | cut -c -${SZ} > ${LAST_INPUT} # + 1 byte ("\n")
        else
            echo "" > ${LAST_INPUT} # + 1 byte ("\n")
        fi
        if [ $(cat ${LAST_INPUT} | wc -c) -eq $1 ]; then
            write_evil ${LAST_INPUT} && \
                cat ${LAST_WRITE} null >> ${LAST_INPUT_CONCAT}
        else
            fail "${LAST_INPUT} size != $1"
            exit 127
        fi
    fi
}

get_size() {
    if [ $# -eq 1 ]; then
        stat -c"%s" ${1}
    else
        exit 126
    fi
}

dmesg_evil() {
    dmesg | grep '^EVIL:'
}

dmesg_last_evil() {
    dmesg_evil | tail -n 1
}

get_size_from_dmesg() {
    dmesg_last_evil | grep '^EVIL: bytes stored: ' | cut -d" " -f4
}

reload_module() {
    set -e
    step "Unloading \"${EVIL_MODULE_NAME}\" module"
    rmmod ${EVIL_MODULE_NAME}

    step "Reloading \"${EVIL_MODULE_NAME}\" module"
    modprobe ${EVIL_MODULE_NAME}
}


# Remove the module if already loaded
rmmod ${EVIL_MODULE_NAME} >/dev/null 2>/dev/null || true

set -e

TMP__DIR=$(mktemp -p /tmp -d)
cd ${TMP__DIR}
dd if=/dev/zero bs=1 count=1 of=null
msg "EVIL_TESTS: STARTING (temp folder: ${TMP__DIR})"

###########################################################
step "Loading \"${EVIL_MODULE_NAME}\" module"
modprobe ${EVIL_MODULE_NAME}

###########################################################
step "Unloading \"${EVIL_MODULE_NAME}\" module"
rmmod ${EVIL_MODULE_NAME}

###########################################################
step "Loading \"${EVIL_MODULE_NAME}\" module (again)"
modprobe ${EVIL_MODULE_NAME}

msg "INFO: Data can be read from the evil storage with command \`cat ${EVIL_SYSFS}\`"

###########################################################
step "Reading from \"${EVIL_MODULE_NAME}\" sysfs entry: should be empty"
read_evil
SZ=$(get_size ${LAST_READ}) ; [ ${SZ} -eq 0 ] || false

###########################################################
step "Writing to \"${EVIL_MODULE_NAME}\" sysfs entry"
write_evil

###########################################################
step "Reading back from \"${EVIL_MODULE_NAME}\" sysfs entry"
read_evil
LAST_EXPECTED=${EVIL_TESTS_STEP_COUNTER}.expected ; cat ${LAST_WRITE} null | sed -e 's/a/ /g' > ${LAST_EXPECTED}
diff -q ${LAST_EXPECTED} ${LAST_READ}

###########################################################
step "Reading again from \"${EVIL_MODULE_NAME}\" sysfs entry: should be identical"
read_evil
diff -q ${LAST_EXPECTED} ${LAST_READ}

###########################################################
reload_module
###########################################################

###########################################################
step "Two consecutive small writes to \"${EVIL_MODULE_NAME}\" sysfs entry"
write_evil_n 99 # + 1 bytes "\0" used for storage by the module per write
SZ=$(get_size_from_dmesg) ; [ ${SZ} -eq 100 ] || fail "${EVIL_MODULE_NAME} reported ${SZ} bytes stored"
write_evil_n 199 # + 1 bytes "\0" used for storage by the module per write
SZ=$(get_size_from_dmesg) ; [ ${SZ} -eq 300 ] || fail "${EVIL_MODULE_NAME} reported ${SZ} bytes stored"

###########################################################
step "Reading back from \"${EVIL_MODULE_NAME}\" sysfs entry"
read_evil
LAST_EXPECTED=${EVIL_TESTS_STEP_COUNTER}.expected ; cat ${LAST_INPUT_CONCAT} | sed -e 's/a/ /g' > ${LAST_EXPECTED}
diff -q ${LAST_EXPECTED} ${LAST_READ}

###########################################################
reload_module
###########################################################

###########################################################
step "Writing 4095 bytes (a whole page considering overhead) at once to \"${EVIL_MODULE_NAME}\" sysfs entry: should fail"
# 4095 + 1 bytes "\0" used for storage by the module per write
if write_evil_n 4095; then
    fail "INPUT_BUFSIZE exceeded without error: potential buffer overflow"
else
    msg "DBG: 'write error' is expected"
fi

###########################################################
step "Writing 1000 bytes at once to \"${EVIL_MODULE_NAME}\" sysfs entry: should fail"
# 1000 + 1 bytes "\0" used for storage by the module per write
if write_evil_n 1000; then
    fail "INPUT_BUFSIZE exceeded without error: potential buffer overflow"
else
    msg "DBG: 'write error' is expected"
fi

###########################################################
step "Writing 999 bytes at once to \"${EVIL_MODULE_NAME}\" sysfs entry: should succeed"
# 999 + 1 bytes "\0" used for storage by the module per write
write_evil_n 999
SZ=$(get_size_from_dmesg) ; [ ${SZ} -eq 1000 ] || fail "${EVIL_MODULE_NAME} reported ${SZ} bytes stored"

###########################################################
step "Filling the module storage with 4095 B in multiple writes to \"${EVIL_MODULE_NAME}\" sysfs entry"
# Module storage must always ends with an empty string, so max limit of stored bytes is 4095
# Starts at 1000 bytes stored
LAST_INPUT_CONCAT=${EVIL_TESTS_STEP_COUNTER}.input.concat
cat ${LAST_WRITE} null >> ${LAST_INPUT_CONCAT}
write_evil_n 999 # + 1 bytes "\0" used for storage by the module per write
SZ=$(get_size_from_dmesg) ; [ ${SZ} -eq 2000 ] || fail "${EVIL_MODULE_NAME} reported ${SZ} bytes stored"
write_evil_n 999 # + 1 bytes "\0" used for storage by the module per write
SZ=$(get_size_from_dmesg) ; [ ${SZ} -eq 3000 ] || fail "${EVIL_MODULE_NAME} reported ${SZ} bytes stored"
write_evil_n 999 # + 1 bytes "\0" used for storage by the module per write
SZ=$(get_size_from_dmesg) ; [ ${SZ} -eq 4000 ] || fail "${EVIL_MODULE_NAME} reported ${SZ} bytes stored"
write_evil_n 92 # + 1 bytes "\0" used for storage by the module per write
SZ=$(get_size_from_dmesg) ; [ ${SZ} -eq 4093 ] || fail "${EVIL_MODULE_NAME} reported ${SZ} bytes stored"

# Next write fills the storage
write_evil_n 1 # + 1 bytes "\0" used for storage by the module per write
SZ=$(get_size_from_dmesg) ; [ ${SZ} -eq 4095 ] || fail "${EVIL_MODULE_NAME} reported ${SZ} bytes stored"

###########################################################
step "Reading back from \"${EVIL_MODULE_NAME}\" sysfs entry"
read_evil
LAST_EXPECTED=${EVIL_TESTS_STEP_COUNTER}.expected ; cat ${LAST_INPUT_CONCAT} | sed -e 's/a/ /g' > ${LAST_EXPECTED}
diff -q ${LAST_EXPECTED} ${LAST_READ}

###########################################################
step "Exceeding the module storage with an extra write to \"${EVIL_MODULE_NAME}\" sysfs entry"
# Next write should be ineffective (but not an error) because storage is full
write_evil_n 1 # + 1 bytes "\0" used for storage by the module per write
dmesg_last_evil | grep -q 'storage full'

###########################################################
step "Reading back from \"${EVIL_MODULE_NAME}\" sysfs entry: should be identical to previous read"
read_evil
diff -q ${LAST_EXPECTED} ${LAST_READ}

###########################################################
reload_module
###########################################################

###########################################################
step "Exceeding the module storage by writing 4096 B in multiple writes to \"${EVIL_MODULE_NAME}\" sysfs entry"
write_evil_n 999 # + 1 bytes "\0" used for storage by the module per write
SZ=$(get_size_from_dmesg) ; [ ${SZ} -eq 1000 ] || fail "${EVIL_MODULE_NAME} reported ${SZ} bytes stored"
write_evil_n 999 # + 1 bytes "\0" used for storage by the module per write
SZ=$(get_size_from_dmesg) ; [ ${SZ} -eq 2000 ] || fail "${EVIL_MODULE_NAME} reported ${SZ} bytes stored"
write_evil_n 999 # + 1 bytes "\0" used for storage by the module per write
SZ=$(get_size_from_dmesg) ; [ ${SZ} -eq 3000 ] || fail "${EVIL_MODULE_NAME} reported ${SZ} bytes stored"
write_evil_n 999 # + 1 bytes "\0" used for storage by the module per write
SZ=$(get_size_from_dmesg) ; [ ${SZ} -eq 4000 ] || fail "${EVIL_MODULE_NAME} reported ${SZ} bytes stored"
write_evil_n 93 # + 1 bytes "\0" used for storage by the module per write
SZ=$(get_size_from_dmesg) ; [ ${SZ} -eq 4094 ] || fail "${EVIL_MODULE_NAME} reported ${SZ} bytes stored"

# Next write should be ineffective (but not an error) because storage is full
LAST_EXPECTED=${EVIL_TESTS_STEP_COUNTER}.expected ; cat ${LAST_INPUT_CONCAT} | sed -e 's/a/ /g' > ${LAST_EXPECTED}
write_evil_n 1 # + 1 bytes "\0" used for storage by the module per write
dmesg_last_evil | grep -q 'storage full'


###########################################################
step "Reading back from \"${EVIL_MODULE_NAME}\" sysfs entry: should be truncated"
read_evil
diff -q ${LAST_EXPECTED} ${LAST_READ}

###########################################################
step "Unloading \"${EVIL_MODULE_NAME}\" module (finally)"
rmmod ${EVIL_MODULE_NAME}

msg '********** EVIL_TESTS: ALL DONE!!'

