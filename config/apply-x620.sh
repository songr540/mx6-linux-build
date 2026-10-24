#!/bin/sh
# 基于 mt6797-mainline 自带 defconfig（mt6797_x620.config）的最小覆盖。
# 原则：能不改就不改；只关掉编译最耗时的 BTF，并把 cmdline 固定进内核。
set -e
K="${1:-$PWD}"
cd "$K" || exit 1

# 与 X620 dts 里 chosen/bootargs 基本一致，只把 panic=0 改成 10（失败能自动回 Android），
# 并去掉 earlycon=mt6797ram（该 earlycon 在源码里不存在，实测无此驱动）
CMDLINE='console=tty0 keep_bootcon loglevel=8 ignore_loglevel printk.time=1 clk_ignore_unused pd_ignore_unused maxcpus=1 cpuidle.off=1 rdinit=/init panic=10 fsck.mode=skip fbcon=nodefer'

C=scripts/config
$C --file .config -e CMDLINE_BOOL
$C --file .config -e CMDLINE_OVERRIDE
$C --file .config --set-str CMDLINE "$CMDLINE"

# 只关 BTF（pahole 很慢，且对本次验证无影响）
$C --file .config -d DEBUG_INFO_BTF

echo "--- apply-x620.sh done ---"
