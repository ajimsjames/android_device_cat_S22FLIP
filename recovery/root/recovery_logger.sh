#!/system/bin/sh
# recovery_logger.sh - auto-log all recovery logs to MicroSD card

# Wait for SD card block device to appear
for i in $(seq 1 10); do
    if [ -b /dev/block/mmcblk1p1 ] || [ -b /dev/block/mmcblk1 ]; then
        break
    fi
    sleep 1
done

DEV=""
[ -b /dev/block/mmcblk1p1 ] && DEV="/dev/block/mmcblk1p1"
[ -z "$DEV" ] && [ -b /dev/block/mmcblk1 ] && DEV="/dev/block/mmcblk1"

mkdir -p /sdcard_ext

while true; do
    if [ -n "$DEV" ]; then
        mount -t vfat "$DEV" /sdcard_ext 2>/dev/null || mount "$DEV" /sdcard_ext 2>/dev/null
    fi

    if mountpoint -q /sdcard_ext || [ -d /sdcard_ext/cat_recovery_logs ]; then
        LOGDIR="/sdcard_ext/cat_recovery_logs"
        mkdir -p "$LOGDIR" 2>/dev/null

        dmesg > "$LOGDIR/recovery_dmesg.txt" 2>/dev/null
        logcat -d > "$LOGDIR/recovery_logcat.txt" 2>/dev/null
        
        [ -d /sys/fs/pstore ] && cp -r /sys/fs/pstore/* "$LOGDIR/" 2>/dev/null
        [ -d /tmp ] && cp /tmp/recovery.log "$LOGDIR/" 2>/dev/null
        [ -d /cache/recovery ] && cp -r /cache/recovery/* "$LOGDIR/" 2>/dev/null
        
        echo "recovery_logger active $(date)" >> "$LOGDIR/logger_status.txt"
        sync
    fi
    sleep 5
done
