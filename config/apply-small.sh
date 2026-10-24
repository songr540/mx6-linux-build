#!/bin/sh
# 超小内核：目标 Image < 19MiB（原厂 3.18 是 18.9MiB，是唯一能启动的样本）
set -e
K="${1:-$PWD}"
cd "$K" || exit 1

CMDLINE='console=tty0 keep_bootcon loglevel=8 ignore_loglevel printk.time=1 clk_ignore_unused pd_ignore_unused maxcpus=1 cpuidle.off=1 rdinit=/init panic=10 fbcon=nodefer'

C=scripts/config
$C --file .config -e CMDLINE_BOOL
$C --file .config -e CMDLINE_OVERRIDE
$C --file .config --set-str CMDLINE "$CMDLINE"

# 体积：调试信息、BTF、LTO 之外的大家伙
$C --file .config -d DEBUG_INFO
$C --file .config -d DEBUG_INFO_BTF
$C --file .config -d DEBUG_INFO_DWARF5

# 网络栈（最大的一块）
$C --file .config -d NET
$C --file .config -d INET
$C --file .config -d PACKET
$C --file .config -d CFG80211
$C --file .config -d MAC80211
$C --file .config -d WLAN

# 音视频
$C --file .config -d SOUND
$C --file .config -d SND
$C --file .config -d MEDIA_SUPPORT
$C --file .config -d DRM

# 存储
$C --file .config -d MMC
$C --file .config -d MTD
$C --file .config -d BLK_DEV_LOOP

# 输入（不需要触摸/键盘）
$C --file .config -d INPUT

echo "--- apply-small.sh done ---"
