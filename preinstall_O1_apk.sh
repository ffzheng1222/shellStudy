#!/bin/bash
# ##############################################################################
# @file        preinstall_apk.sh
# @author      Hexh
# @brief       自动生成预置APK的Android.mk
# @date        2016/04/25
# @History
# 1、
# ##############################################################################
APK_PATH="/home-ext/maxw/apk"
ANDROID_MK_PATH=""
PROJECT=""
TIP="################################################################################"

function apk_can_uninstall(){
    #echo apk_can_uninstall
    apk_name=$(basename $1 .apk)
    echo "$TIP" >> ${ANDROID_MK_PATH}
    echo 'include $(CLEAR_VARS)'>> ${ANDROID_MK_PATH}
    echo "LOCAL_MODULE := $apk_name" >> ${ANDROID_MK_PATH}
    echo 'LOCAL_MODULE_CLASS := APPS' >> ${ANDROID_MK_PATH}
    echo 'LOCAL_MODULE_TAGS := optional' >> ${ANDROID_MK_PATH}
    echo 'LOCAL_BUILT_MODULE_STEM := package.apk' >> ${ANDROID_MK_PATH}
    echo 'LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)' >> ${ANDROID_MK_PATH}
    echo 'LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/operator/app' >> ${ANDROID_MK_PATH}
    echo '#LOCAL_DEX_PREOPT := false' >> ${ANDROID_MK_PATH}
    echo 'LOCAL_CERTIFICATE := PRESIGNED' >> ${ANDROID_MK_PATH}
    echo 'LOCAL_SRC_FILES := $(LOCAL_MODULE).apk' >> ${ANDROID_MK_PATH}
    lib_index=0
    arr=(`unzip -l ${1} | grep " lib/arm64-v8a"`)
    if [ ${#arr[@]} -gt 0 ]; then
        echo 'LOCAL_MULTILIB :=64' >> ${ANDROID_MK_PATH}
        search_str=" lib/arm64-v8a"
    else
        #echo 'LOCAL_MULTILIB :=32' >> ${ANDROID_MK_PATH}
        arr=(`unzip -l ${1} | grep " lib/armeabi-v7a"`)

        if [ ${#arr[@]} -gt 0 ]; then
	    echo 'LOCAL_MULTILIB :=32' >> ${ANDROID_MK_PATH}
            search_str=" lib/armeabi-v7a"
        else
	    arr=(`unzip -l ${1} | grep " lib/armeabi"`)
	    if [ ${#arr[@]} -gt 0 ]; then
	    echo 'LOCAL_MULTILIB :=32' >> ${ANDROID_MK_PATH}
            search_str=" lib/armeabi"
	    else
	    search_str=" lib/armeabi"
	    fi
        fi
    fi

    echo "" >> ${ANDROID_MK_PATH}
    echo 'include $(BUILD_PREBUILT)' >> ${ANDROID_MK_PATH}
}

function apk_can_not_uninstall(){
    #echo apk_can_not_uninstall
    apk_name=$(basename $1 .apk)
    echo "$TIP" >> ${ANDROID_MK_PATH}
    echo 'include $(CLEAR_VARS)'>> ${ANDROID_MK_PATH}
    echo "LOCAL_MODULE := $apk_name" >> ${ANDROID_MK_PATH}
    echo 'LOCAL_MODULE_CLASS := APPS' >> ${ANDROID_MK_PATH}
    echo 'LOCAL_MODULE_TAGS := optional' >> ${ANDROID_MK_PATH}
    echo 'LOCAL_BUILT_MODULE_STEM := package.apk' >> ${ANDROID_MK_PATH}
    echo 'LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)' >> ${ANDROID_MK_PATH}
    echo '#LOCAL_PRIVILEGED_MODULE := true' >> ${ANDROID_MK_PATH}
    echo '#LOCAL_DEX_PREOPT := false' >> ${ANDROID_MK_PATH}
    echo 'LOCAL_CERTIFICATE := PRESIGNED' >> ${ANDROID_MK_PATH}
    echo 'LOCAL_SRC_FILES := $(LOCAL_MODULE).apk' >> ${ANDROID_MK_PATH}
    echo "" >> ${ANDROID_MK_PATH}

    lib_index=0
    arr=(`unzip -l ${1} | grep " lib/arm64-v8a"`)
    if [ ${#arr[@]} -gt 0 ]; then
        echo 'LOCAL_MULTILIB :=64' >> ${ANDROID_MK_PATH}
        search_str=" lib/arm64-v8a"
    else
        #echo 'LOCAL_MULTILIB :=32' >> ${ANDROID_MK_PATH}
        arr=(`unzip -l ${1} | grep " lib/armeabi-v7a"`)

        if [ ${#arr[@]} -gt 0 ]; then
            echo 'LOCAL_MULTILIB :=32' >> ${ANDROID_MK_PATH}
            search_str=" lib/armeabi-v7a"
        else
            arr=(`unzip -l ${1} | grep " lib/armeabi"`)
            if [ ${#arr[@]} -gt 0 ]; then
            echo 'LOCAL_MULTILIB :=32' >> ${ANDROID_MK_PATH}
            search_str=" lib/armeabi"
	    else
	    search_str=" lib/armeabi"
            fi
        fi
    fi
    
    LIB_COUNT=`unzip -l ${1} | grep -c "${search_str}"`
    #echo LIB_COUNT: $LIB_COUNT
   
    echo ${search_str}

    unzip -l ${1} | grep "${search_str}" | while read -r line
    do
        if [ $lib_index -eq 0 ]; then
            echo 'LOCAL_PREBUILT_JNI_LIBS := \' >> ${ANDROID_MK_PATH}
        fi
        #echo ${line}
        arr=($line)
        lib_array[lib_index]=${arr[3]}
        if [ $(($lib_index+1)) -eq $LIB_COUNT ]; then 
            echo "    @${lib_array[lib_index]}" >> ${ANDROID_MK_PATH}
        else
            echo "    @${lib_array[lib_index]} \\" >> ${ANDROID_MK_PATH}
        fi
        ((lib_index++))
        echo $lib_index: ${lib_array[$lib_index-1]}
    done
    
    echo "" >> ${ANDROID_MK_PATH}
    echo 'include $(BUILD_PREBUILT)' >> ${ANDROID_MK_PATH}
}

if [ $# -lt 1 ]; then
    echo -e "\033[35mPlease input a parameter about the path of custom's apks.\033[0m"
    exit    
fi

APK_PATH=$1

if [ ! -d "${APK_PATH}" ]; then
    echo -e "\033[35m${APK_PATH} does not exist.\033[0m"
    exit
fi

ANDROID_MK_PATH=${APK_PATH}/Android.mk

if [ -f ${ANDROID_MK_PATH} ]; then
    rm ${ANDROID_MK_PATH}
fi

#write head begin
PROJECT=${APK_PATH%/*}
PROJECT=${PROJECT##*/}
echo $PROJECT
#echo 'ifeq ($(TARGET_PRODUCT)'",full_${PROJECT})" >> ${ANDROID_MK_PATH}
echo "" >> ${ANDROID_MK_PATH}
echo 'LOCAL_PATH := $(call my-dir)' >> ${ANDROID_MK_PATH}
#write head end

ls ${APK_PATH}/*.apk | while read -r apk_name
do
    input_valid=0
    while [ ${input_valid} -eq 0 ]
    do
        echo -e "\033[32m$(basename $apk_name)\033[0m: 
    \033[31mplease input: 
        1(can be uninstalled)
        0(can not be uninstalled)\033[0m"
        #echo $(basename $apk_name) >> apk_test.txt
        read -u 1 uninstall_flag
        expr $uninstall_flag + 10 1>/dev/null 2>&1
        if [ $? -eq 0 ];then
            input_valid=1
    		if [ $uninstall_flag -le 0 ]; then
                apk_can_not_uninstall ${apk_name}
            else
                apk_can_uninstall ${apk_name}
            fi
        else
            echo -e "\033[31mInvalid input, please input a number.\033[0m"
        fi
    done
done

#write tail begin
echo "$TIP" >> ${ANDROID_MK_PATH}
#write tail end
