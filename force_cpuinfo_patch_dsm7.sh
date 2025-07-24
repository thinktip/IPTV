#!/bin/sh
# Manual CPU info patcher for DSM 7.2 (System.js)
# Author: ChatGPT for Ryzen 3 2200G
# 强制写入 CPU 信息到 DSM 7.2 的 System.js

cpu_vendor="AMD"
cpu_family="Ryzen 3"
cpu_series="2200G with Radeon Vega Graphics"
cpu_cores="4 Cores (4 CPUs | 4 Threads)"
cpu_detail="(Zen Architecture) | <a href='https://www.amd.com/en/products/apu/amd-ryzen-3-2200g' target=_blank>Detail</a>"

# DSM 7.2 默认路径
JS_FILE="/usr/lib/synoman/webman/modules/System/extjs/System.js"
BACKUP_FILE="/usr/lib/synoman/webman/modules/System/extjs/System.js.bak"

# 检查文件是否存在
if [ ! -f "$JS_FILE" ]; then
  echo "❌ 找不到目标文件：$JS_FILE"
  exit 1
fi

# 备份
if [ ! -f "$BACKUP_FILE" ]; then
  cp "$JS_FILE" "$BACKUP_FILE"
  echo "✔ 已备份原始 System.js 到 System.js.bak"
fi

# 清除原有 cpu_xxx 信息
sed -i "/cpu_vendor/d" "$JS_FILE"
sed -i "/cpu_family/d" "$JS_FILE"
sed -i "/cpu_series/d" "$JS_FILE"
sed -i "/cpu_cores/d" "$JS_FILE"
sed -i "/cpu_detail/d" "$JS_FILE"

# 插入 CPU 信息段（Ext.define 检测点前）
sed -i "s/if(Ext.isDefined(/${{
dt}}.cpu_vendor=\"$cpu_vendor\";${{
dt}}.cpu_family=\"$cpu_family\";${{
dt}}.cpu_series=\"$cpu_series\";${{
dt}}.cpu_cores=\"$cpu_cores\";${{
dt}}.cpu_detail=\"$cpu_detail\";\nif(Ext.isDefined(/" "$JS_FILE"

echo "✅ CPU 信息已写入 System.js：$cpu_vendor $cpu_family $cpu_series [$cpu_cores]"
