#!/bin/sh
# Manual CPU info patcher for Synology DSM
# Author: ChatGPT for Ryzen 3 2200G
# 强制写入 CPU 信息

cpu_vendor="AMD"
cpu_family="Ryzen 3"
cpu_series="2200G with Radeon Vega Graphics"
cpu_cores="4 Cores (4 CPUs | 4 Threads)"
cpu_detail="(Zen Architecture) | <a href='https://www.amd.com/en/products/apu/amd-ryzen-3-2200g' target=_blank>Detail</a>"

# 备份路径（请根据你的系统调整）
JS_FILE="/usr/syno/synoman/webman/modules/AdminCenter/extjs/admin_center.js"
BACKUP_FILE="/usr/syno/synoman/webman/modules/AdminCenter/extjs/admin_center.js.bak"

# 创建备份
if [ ! -f "$BACKUP_FILE" ]; then
    cp "$JS_FILE" "$BACKUP_FILE"
fi

# 插入或替换 CPU 信息段（简化方式处理）
sed -i "/cpu_vendor/d" "$JS_FILE"
sed -i "/cpu_family/d" "$JS_FILE"
sed -i "/cpu_series/d" "$JS_FILE"
sed -i "/cpu_cores/d" "$JS_FILE"
sed -i "/cpu_detail/d" "$JS_FILE"

sed -i "s/if(Ext.isDefined(/${{
dt}}.cpu_vendor=\"$cpu_vendor\";${{
dt}}.cpu_family=\"$cpu_family\";${{
dt}}.cpu_series=\"$cpu_series\";${{
dt}}.cpu_cores=\"$cpu_cores\";${{
dt}}.cpu_detail=\"$cpu_detail\";\nif(Ext.isDefined(/" "$JS_FILE"

echo "✔ CPU 信息已强制修改为：$cpu_vendor $cpu_family $cpu_series [$cpu_cores]"
