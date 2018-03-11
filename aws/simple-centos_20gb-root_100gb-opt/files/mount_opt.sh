#!/bin/bash
set -e

function log {
    echo "$1"
    echo "$1" >> /var/log/mount_opt.log
}

device_name="/dev/xvdh"
cnt=$(lsblk ${device_name} | wc -l)
timeout=60

ts=$(date -D)
log "START: ${ts}"

# waiting until the device shows up
while [ ${cnt} -ne 2 ]; do

    log "waiting for the block device (${cnt}, ${timeout}) ..."
    ((timeout--))

    if [ ${timeout} -eq 0 ]; then
        log "FATAL: block device never showed up ..."
        exit 1
    fi

    sleep 1

    cnt=$(lsblk ${device_name} | wc -l)
done

log "block device present ..."

log "creating filesystem ..."
mkfs -t ext4 ${device_name} >> /var/log/mount_opt.log 2>&1

if [ $? -ne 0 ]; then
    log "FATAL: creating file system failed!"
    exit 1
fi

opt_uuid=$(blkid -s UUID -o value ${device_name})

if [ ! -z ${opt_uuid} ]; then
    log "updating /etc/fstab"
    echo "UUID=${opt_uuid} /opt ext4 defaults 0 2" >> /etc/fstab
    log "mounting /opt"
    mount /opt
else
    log "FATAL: failed to pickup uuid of ${device_name}"
    exit 1
fi

ts=$(date -D)
log "END: ${ts}"
