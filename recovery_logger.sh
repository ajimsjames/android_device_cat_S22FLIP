#!/system/bin/sh

# Mount external microSD card if present
mkdir -p /sdcard_ext
mount -t vfat /dev/block/mmcblk1p1 /sdcard_ext 2>/dev/null || mount -t exfat /dev/block/mmcblk1p1 /sdcard_ext 2>/dev/null

LOGDIR="/sdcard_ext/cat_recovery_logs"
mkdir -p "$LOGDIR" 2>/dev/null

while true; do
    if [ -d "$LOGDIR" ]; then
        dmesg > "$LOGDIR/recovery_dmesg.txt" 2>/dev/null
        logcat -d > "$LOGDIR/recovery_logcat.txt" 2>/dev/null
        if [ -d /sys/fs/pstore ]; then
            cp -r /sys/fs/pstore/* "$LOGDIR/" 2>/dev/null
        fi
        if [ -d /tmp/recovery ]; then
            cp -r /tmp/recovery* "$LOGDIR/" 2>/dev/null
        fi
        if [ -d /cache/recovery ]; then
            cp -r /cache/recovery/* "$LOGDIR/" 2>/dev/null
        fi
        sync
    else
        # Try remounting if not found yet
        mount -t vfat /dev/block/mmcblk1p1 /sdcard_ext 2>/dev/null || mount -t exfat /dev/block/mmcblk1p1 /sdcard_ext 2>/dev/null
    fi
    sleep 10
done
