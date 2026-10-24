#!/bin/sh
# 在 CI 里对 .config 做最后一步覆盖（幂等）
set -e
K="${1:-$PWD}"
cd "$K" || exit 1

CMDLINE='console=tty0 fbcon=nodefer keep_bootcon loglevel=8 ignore_loglevel printk.time=1 maxcpus=1 cpuidle.off=1 clk_ignore_unused pd_ignore_unused rdinit=/init panic=10'

C=scripts/config
$C --file .config -e CMDLINE_BOOL
$C --file .config -e CMDLINE_OVERRIDE
$C --file .config --set-str CMDLINE "$CMDLINE"

# 调试信息太吃时间；BTF 更甚
$C --file .config -d DEBUG_INFO_BTF
$C --file .config -d DEBUG_INFO_DWARF5

# MX6 的真实 UDC 是 MUSB，不是 MTU3
$C --file .config -e USB_GADGET
$C --file .config -e USB_MUSB_HDRC
$C --file .config -e USB_MUSB_GADGET
$C --file .config -e USB_MUSB_MEDIATEK
$C --file .config -d USB_MTU3

echo "--- apply.sh done ---"
