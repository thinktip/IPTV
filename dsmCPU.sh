#!/bin/sh
# DSM 7.2 CPU信息修改脚本
# 目标CPU: AMD Ryzen 3 2200G with Radeon Vega Graphics
# 适用版本: DSM 7.2

ver="1.0.0"
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
    MI_VER=$(cat $VER_FIL | grep minorversion | awk -F= '{print $2}' | sed 's/"//g')
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
SWORK_DIR="/var/packages/SurveillanceStation/target/ui/modules/System"
MWORK_DIR="/usr/syno/synoman/mobile/ui"
BKUP_DIR="/root/cpu_backup"
TIME=$(date +%Y%m%d%H%M%S)

# 检查必要文件是否存在
if [ ! -f "$WORK_DIR/admin_center.js" ] || [ ! -f "$MWORK_DIR/mobile.js" ]; then
    echo "错误: 找不到必要的系统文件"
    exit 1
fi

# 设置CPU信息
cpu_vendor="AMD"
cpu_family="Ryzen 3"
cpu_series="2200G with Radeon Vega Graphics"
cpu_cores="4 Cores (1 CPU/4 Cores | 4 Threads)"
cpu_detail="<a href='https://www.amd.com/en/search?keyword=Ryzen%203%202200G' target=_blank>detail</a>"

# DSM 7.x 使用的变量标识符
dt="t"
st="e"

echo "准备修改CPU信息为:"
echo "厂商: $cpu_vendor"
echo "系列: $cpu_family"
echo "型号: $cpu_series"
echo "核心: $cpu_cores"
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
# 备份文件
cp "$WORK_DIR/admin_center.js" "$BKUP_DIR/$TIME/"
cp "$MWORK_DIR/mobile.js" "$BKUP_DIR/$TIME/"
if [ -f "$SWORK_DIR/System.js" ]; then
    cp "$SWORK_DIR/System.js" "$BKUP_DIR/$TIME/"
fi

# 解压gzip文件（如果是压缩的）
if [ -f "$WORK_DIR/admin_center.js.gz" ]; then
    gunzip -c "$WORK_DIR/admin_center.js.gz" > "$BKUP_DIR/admin_center.js"
else
    cp "$WORK_DIR/admin_center.js" "$BKUP_DIR/"
fi

if [ -f "$MWORK_DIR/mobile.js.gz" ]; then
    gunzip -c "$MWORK_DIR/mobile.js.gz" > "$BKUP_DIR/mobile.js"
else
    cp "$MWORK_DIR/mobile.js" "$BKUP_DIR/"
fi

if [ -f "$SWORK_DIR/System.js" ]; then
    cp "$SWORK_DIR/System.js" "$BKUP_DIR/"
fi

echo "正在修改admin_center.js..."
# 修改admin_center.js
cpu_info="${dt}.cpu_vendor=\"${cpu_vendor}\",${dt}.cpu_family=\"${cpu_family}\",${dt}.cpu_series=\"${cpu_series}\",${dt}.cpu_cores=\"${cpu_cores}\",${dt}.cpu_detail=\"${cpu_detail}\","
sed -i "s/Ext.isDefined(${dt}.cpu_vendor/${cpu_info}Ext.isDefined(${dt}.cpu_vendor/g" "$BKUP_DIR/admin_center.js"
sed -i "s/${dt}.cpu_series)])/${dt}.cpu_series,${dt}.cpu_detail)])/g" "$BKUP_DIR/admin_center.js"
sed -i "s/{2}\",${dt}.cpu_vendor/{2} {3}\",${dt}.cpu_vendor/g" "$BKUP_DIR/admin_center.js"

echo "正在修改mobile.js..."
# 修改mobile.js
cpu_info_m="{name: \"cpu_series\",renderer: function(value){var cpu_vendor=\"${cpu_vendor}\";var cpu_family=\"${cpu_family}\";var cpu_series=\"${cpu_series}\";var cpu_cores=\"${cpu_cores}\";return Ext.String.format('{0} {1} {2} [ {3} ]', cpu_vendor, cpu_family, cpu_series, cpu_cores);},label: _T(\"status\", \"cpu_model_name\")},"
sed -i "s/\"ds_model\")},/\"ds_model\")},${cpu_info_m}/g" "$BKUP_DIR/mobile.js"

# 修改System.js（如果存在）
if [ -f "$BKUP_DIR/System.js" ]; then
    echo "正在修改System.js..."
    cpu_info_s=$(echo $cpu_info | sed "s/${dt}.cpu/${st}.cpu/g")
    sed -i "s/Ext.isDefined(${st}.cpu_vendor/${cpu_info_s}Ext.isDefined(${st}.cpu_vendor/g" "$BKUP_DIR/System.js"
    sed -i "s/${st}.cpu_series)])/${st}.cpu_series,${st}.cpu_detail)])/g" "$BKUP_DIR/System.js"
    sed -i "s/{2}\",${st}.cpu_vendor/{2} {3}\",${st}.cpu_vendor/g" "$BKUP_DIR/System.js"
fi

echo "正在应用修改..."
# 应用修改
if [ -f "$WORK_DIR/admin_center.js.gz" ]; then
    gzip -c "$BKUP_DIR/admin_center.js" > "$WORK_DIR/admin_center.js.gz"
else
    cp "$BKUP_DIR/admin_center.js" "$WORK_DIR/"
fi

if [ -f "$MWORK_DIR/mobile.js.gz" ]; then
    gzip -c "$BKUP_DIR/mobile.js" > "$MWORK_DIR/mobile.js.gz"
else
    cp "$BKUP_DIR/mobile.js" "$MWORK_DIR/"
fi

if [ -f "$BKUP_DIR/System.js" ]; then
    cp "$BKUP_DIR/System.js" "$SWORK_DIR/"
fi

# 清理临时文件
rm -f "$BKUP_DIR/admin_center.js" "$BKUP_DIR/mobile.js" "$BKUP_DIR/System.js"

echo ""
echo "修改完成!"
echo "备份文件保存在: $BKUP_DIR/$TIME/"
echo ""
echo "请按F5刷新DSM页面或重新登录来查看修改结果"
echo "修改生效可能需要1-2分钟时间"
echo ""
echo "如需恢复原始状态，请运行以下命令:"
echo "cp $BKUP_DIR/$TIME/* /usr/syno/synoman/webman/modules/AdminCenter/"
echo "cp $BKUP_DIR/$TIME/mobile.js /usr/syno/synoman/mobile/ui/"
if [ -f "$BKUP_DIR/$TIME/System.js" ]; then
    echo "cp $BKUP_DIR/$TIME/System.js /var/packages/SurveillanceStation/target/ui/modules/System/"
fi