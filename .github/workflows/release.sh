#!/bin/sh
#############################
# V2ray for Android插件发布脚本
#############################

V2RAY_CORE_RELEASE_URL="https://github.com/v2fly/v2ray-core/releases"
V2RULES_RELEASE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases"


download_v2ray_core(){
  # 检查最新版本
  latest_ver=`curl -k -s -I "${V2RAY_CORE_RELEASE_URL}/latest" | grep -i location | grep -o "tag.*" | grep -o "v[0-9.]*"`
  if [ "${latest_ver}" = "" ] ; then
    echo "Error: Connect official V2Ray download link failed." 
    exit 1
  fi

  # 下载最新arm32版本V2ray
  arm32_link="${V2RAY_CORE_RELEASE_URL}/download/${latest_ver}/v2ray-linux-arm32-v7a.zip"

  curl "${arm32_link}" -k -L -o ./tmp/v2ray-core-arm32.zip >&2
  if [ "$?" != "0" ] ; then
    echo "Error: Download V2Ray core[arm32] failed."
    exit 1
  fi

  # 下载最新arm64版本V2ray
  arm64_link="${V2RAY_CORE_RELEASE_URL}/download/${latest_ver}/v2ray-android-arm64-v8a.zip"
  curl "${arm64_link}" -k -L -o ./tmp/v2ray-core-arm64.zip >&2
  if [ "$?" != "0" ] ; then
    echo "Error: Download V2Ray core[arm64] failed."
    exit 1
  fi

}

download_dat_file(){
  latest_ver=`curl -k -s -I "${V2RULES_RELEASE_URL}/latest" | grep -i location | grep -o "tag.*" | grep -o "[0-9.]*"`
  if [ "${latest_ver}" = "" ] ; then
    echo "Error: Connect official V2Ray rules dat download link failed." 
    exit 1
  fi

  geoip_link="${V2RULES_RELEASE_URL}/download/${latest_ver}/geoip.dat"
  curl "${geoip_link}" -k -L -o ./tmp/geoip.dat >&2
  if [ "$?" != "0" ] ; then
    echo "Error: Download geoip.dat failed."
    exit 1
  fi

  geosite_link="${V2RULES_RELEASE_URL}/download/${latest_ver}/geosite.dat"
  curl "${geosite_link}" -k -L -o ./tmp/geosite.dat >&2
  if [ "$?" != "0" ] ; then
    echo "Error: Download geosite.dat failed."
    exit 1
  fi
  
}

zip_files(){

  # 创建32位版本zip文件
  zip -q -r v2ray-magisk-android32.zip META-INF v2ray customize.sh README.md service.sh uninstall.sh
  
  # 创建64位版本zip文件
  zip -q -r v2ray-magisk-android64.zip META-INF v2ray customize.sh README.md service.sh uninstall.sh

  # 移动可能被覆盖的文件
  mv v2ray v2ray.bk
  mv module.prop module.prop.bk

  # 整理32位打包文件
  mkdir v2ray
  mkdir v2ray/bin
  cp tmp/geoip.dat v2ray/bin/geoip.dat
  cp tmp/geosite.dat v2ray/bin/geosite.dat
  # cp tmp/v2manager-v7a.apk v2ray/bin/v2manager.apk
  unzip -j -o tmp/v2ray-core-arm32.zip "v2ray" -d v2ray/bin/
  cp module.prop.bk module.prop
  # echo "updateJson=https://yatsuki.github.io/v2ray-release/release32.json" >> module.prop
  zip -q -r -u v2ray-magisk-android32.zip v2ray/bin module.prop
  
  rm -rf v2ray module.prop

  # 整理64位打包文件
  mkdir v2ray
  mkdir v2ray/bin
  cp tmp/geoip.dat v2ray/bin/geoip.dat
  cp tmp/geosite.dat v2ray/bin/geosite.dat
  # cp tmp/v2manager-v8a.apk v2ray/bin/v2manager.apk
  unzip -j -o tmp/v2ray-core-arm64.zip "v2ray" -d v2ray/bin/
  cp module.prop.bk module.prop
  # echo "updateJson=https://yatsuki.github.io/v2ray-release/release64.json" >> module.prop
  zip -q -r -u v2ray-magisk-android64.zip v2ray/bin module.prop
  
  rm -rf v2ray module.prop

  # 还原文件
  mv v2ray.bk v2ray
  mv module.prop.bk module.prop

}

# 检查代码是否检出

mkdir tmp

# 下载V2ray二进制文件
download_v2ray_core

# # 下载v2manager管理应用
# download_v2manager

# 下载增强路由规则文件
download_dat_file

# 打包文件
zip_files
