#!/bin/bash

#注意:给变量赋值时，“=” 前后都不要有空格
function patch_list_s905x2_hailstorm_aosp()
{
    ROOT_DIR=~/workspace/s905x2 # 根目录，这里约定为 auto_build.sh 所在目录
    PROJECT_NAME=hailstorm-2.0.1-s905x2-AOSP   #项目名称，可自行修改，注意不能与其他项目名称相同
    PROJECT_LUNCH_NAME=franklin									# sdk编译对应的工程product名
    SDK_MANIFEST=p-amlogic_openlinux-hailstorm-v2.0.1.xml # sdk manifest, 即指定公版 sdk 的版本
    SDK_BRANCH=p-amlogic # sdk 分支
    SDK_PATCH_LIST=${FUNCNAME}.txt # path list，即项目对应的patch list
    SDK_PATCH_BRANCH=hailstorm-2.0 # patch 分支
    SDK_PATH=${ROOT_DIR}/${PROJECT_NAME}/${SDK_MANIFEST} # 下载的 sdk 存在在此路径
    SDK_PATCH_PATH=${ROOT_DIR}/${PROJECT_NAME}/sdk_patch # 下载的 patch 存放在此路径

    BOARD_COMPILE_ATV=false  # 是否是 ATV 项目

    SDK_URL=ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/p-amlogic/platform/manifest.git # 远程 sdk 路径，一般不需要修改
    SDK_REPO_URL=ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/repo.git #远程 repo 路径，一般不需要修改

    SDK_PATCH_ROOT_URL=${USER}@10.10.61.20:/home/svn/sdmc_lib/sdk_patch_tool # 远程 sdmc patch 根路径
    SDK_PATCH_PLAT_PATH=platform/amlogic_p_gxx.git # sdmc patch 路径, 与 SDK_PATCH_ROOT_URL 组成完整的 patch 路径

	#检测SDK media audio so的md5sum值存储文件
	SDK_MEDIA_AUDIO_MANIFEST=${ROOT_DIR}/${PROJECT_NAME}/sdk_media_audio.txt
}


add_lunch_combo patch_list_s905x2_hailstorm_aosp # 这里约定 add_lunch_combo 的参数、上面的 function 都跟 SDK_PATCH_LIST 相同
