#!/bin/sh
# DSM 7.2 CPU信息修改脚本 - 简化版
# 目标CPU: AMD Ryzen 3 2200G with Radeon Vega Graphics

ver="1.1.0"
echo "DSM 7.2 CPU信息修改工具 ver. $ver"
echo "目标CPU: AMD Ryzen 3 2200G with Radeon Vega Graphics"
echo ""

# 检查DSM版本
VER_DIR="/etc.defaults"
if [ -d "$VER_DIR" ]; then
    VER_FIL="$VER_DIR/VERSION"
else
    VER_FIL="/etc/VERSION"
fi

if [ -f "$VER_FIL" ]; then
    MA_VER=$(cat $VER_FIL | grep majorversion | awk -F= '{print $2}' | sed 's/"//g')
    PD_VER=$(cat $VER_FIL | grep productversion | awk -F= '{print $2}' | sed 's/"//g')
    BL_NUM=$(cat $VER_FIL | grep buildnumber | awk -F= '{print $2}' | sed 's/"//g')
    echo "检测到DSM版本: DSM $PD_VER-$BL_NUM"
else
    echo "错误: 无法读取DSM版本信息"
    exit 1
fi

# 检查是否为DSM 7.x
if [ "$MA_VER" -ne "7" ]; then
    echo "错误: 此脚本仅适用于DSM 7.x版本"
    exit 1
fi

# 设置工作目录
WORK_DIR="/usr/syno/synoman/webman/modules/AdminCenter"
MWORK_DIR="/usr/syno/synoman/mobile/ui"
BKUP_DIR="/root/cpu_backup"
TIME=$(date +%Y%m%d%H%M%S)

# 检查必要文件是否存在
if [ ! -f "$WORK_DIR/admin_center.js" ] && [ ! -f "$WORK_DIR/admin_center.js.gz" ]; then
    echo "错误: 找不到admin_center.js文件"
    exit 1
fi

if [ ! -f "$MWORK_DIR/mobile.js" ] && [ ! -f "$MWORK_DIR/mobile.js.gz" ]; then
    echo "错误: 找不到mobile.js文件"
    exit 1
fi

# 设置CPU信息 - 简化版本
cpu_name="AMD Ryzen 3 2200G with Radeon Vega Graphics"

echo "准备修改CPU信息为: $cpu_name"
echo ""

# 询问是否继续
read -n1 -p "是否继续执行修改? [y/n]: " confirm
echo ""
if [ "$confirm" != "y" ]; then
    echo "操作已取消"
    exit 0
fi

# 创建备份目录
mkdir -p "$BKUP_DIR/$TIME"

echo "正在备份原始文件..."

# 处理admin_center.js
if [ -f "$WORK_DIR/admin_center.js.gz" ]; then
    cp "$WORK_DIR/admin_center.js.gz" "$BKUP_DIR/$TIME/"
    gunzip -c "$WORK_DIR/admin_center.js.gz" > "$BKUP_DIR/admin_center.js"
    is_admin_gzip=1
else
    cp "$WORK_DIR/admin_center.js" "$BKUP_DIR/$TIME/"
    cp "$WORK_DIR/admin_center.js" "$BKUP_DIR/"
    is_admin_gzip=0
fi

# 处理mobile.js
if [ -f "$MWORK_DIR/mobile.js.gz" ]; then
    cp "$MWORK_DIR/mobile.js.gz" "$BKUP_DIR/$TIME/"
    gunzip -c "$MWORK_DIR/mobile.js.gz" > "$BKUP_DIR/mobile.js"
    is_mobile_gzip=1
else
    cp "$MWORK_DIR/mobile.js" "$BKUP_DIR/$TIME/"
    cp "$MWORK_DIR/mobile.js" "$BKUP_DIR/"
    is_mobile_gzip=0
fi

echo "正在修改CPU信息..."

# 修改admin_center.js - 使用最简单的方法
# 查找并替换CPU型号显示逻辑
sed -i "s/t\.cpu_family,\" \",t\.cpu_series/\"$cpu_name\"/g" "$BKUP_DIR/admin_center.js"
sed -i "s/t\.cpu_vendor,\" \",t\.cpu_family,\" \",t\.cpu_series/\"$cpu_name\"/g" "$BKUP_DIR/admin_center.js"

# 也尝试其他可能的模式
sed -i "s/{0} {1} {2}/\"$cpu_name\"/g" "$BKUP_DIR/admin_center.js"

# 修改mobile.js
sed -i "s/cpu_vendor, cpu_family, cpu_series/\"$cpu_name\", \"\", \"\"/g" "$BKUP_DIR/mobile.js"
sed -i "s/{0} {1} {2}/\"$cpu_name\"/g" "$BKUP_DIR/mobile.js"

echo "正在应用修改..."

# 应用修改
if [ "$is_admin_gzip" -eq 1 ]; then
    gzip -c "$BKUP_DIR/admin_center.js" > "$WORK_DIR/admin_center.js.gz"
else
    cp "$BKUP_DIR/admin_center.js" "$WORK_DIR/"
fi

if [ "$is_mobile_gzip" -eq 1 ]; then
    gzip -c "$BKUP_DIR/mobile.js" > "$MWORK_DIR/mobile.js.gz"
else
    cp "$BKUP_DIR/mobile.js" "$MWORK_DIR/"
fi

# 清理临时文件
rm -f "$BKUP_DIR/admin_center.js" "$BKUP_DIR/mobile.js"

echo ""
echo "修改完成!"
echo "备份文件保存在: $BKUP_DIR/$TIME/"
echo ""
echo "请按F5刷新DSM页面或重新登录来查看修改结果"
echo "修改生效可能需要1-2分钟时间"
echo ""
echo "如需恢复原始状态，请运行以下命令:"
if [ "$is_admin_gzip" -eq 1 ]; then
    echo "cp $BKUP_DIR/$TIME/admin_center.js.gz $WORK_DIR/"
else
    echo "cp $BKUP_DIR/$TIME/admin_center.js $WORK_DIR/"
fi
if [ "$is_mobile_gzip" -eq 1 ]; then
    echo "cp $BKUP_DIR/$TIME/mobile.js.gz $MWORK_DIR/"
else
    echo "cp $BKUP_DIR/$TIME/mobile.js $MWORK_DIR/"
fi