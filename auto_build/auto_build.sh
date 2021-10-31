#!/bin/bash

function jenkins_project_demo()
{
    ROOT_DIR=${JENKINS_HOME}/workspace # 根目录，这里约定为 auto_build.sh 所在目录
    PROJECT_NAME=${JOB_NAME%/*} #项目名称，可自行修改
    PROJECT_LUNCH_NAME=franklin		# sdk编译对应的工程product名
    SDK_MANIFEST=p-amlogic_openlinux-hailstorm-v2.0.1.xml # sdk manifest, 即指定公版 sdk 的版本
    SDK_BRANCH=p-amlogic # sdk 分支
    SDK_PATCH_LIST=patch_list_s905x2_hailstorm.txt # path list，即项目对应的patch list
    SDK_PATCH_BRANCH=hailstorm-2.0 # patch 分支
    SDK_PATH=${ROOT_DIR}/${PROJECT_NAME}/${JOB_BASE_NAME} # 下载的 sdk 存在在此路径
    SDK_PATCH_PATH=${ROOT_DIR}/${PROJECT_NAME}/sdk_patch # 下载的 patch 存放在此路径

    BOARD_COMPILE_ATV=true  # 是否是 ATV 项目

    SDK_URL=ssh://binkun@10.10.61.21/home/binkun/amlogic_p_mirror/p-amlogic/platform/manifest.git # 远程 sdk 路径，一般不需要修改
    SDK_REPO_URL=ssh://binkun@10.10.61.21/home/binkun/amlogic_p_mirror/repo.git #远程 repo 路径，一般不需要修改

    SDK_PATCH_ROOT_URL=${USER}@10.10.61.20:/home/svn/sdmc_lib/sdk_patch_tool # 远程 sdmc patch 根路径
    SDK_PATCH_PLAT_PATH=platform/amlogic_p_gxx.git # sdmc patch 路径, 与 SDK_PATCH_ROOT_URL 组成完整的 patch 路径
}

function env_setup()
{
    if [ -z ${SDK_URL} ];then
        SDK_URL=ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/p-amlogic/platform/manifest.git # 远程 sdk 路径，一般不需要修改
    fi

    if [ -z ${SDK_REPO_URL} ];then
        SDK_REPO_URL=ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/repo.git #远程 repo 路径，一般不需要修改
    fi

    if [ -z ${SDK_PATCH_ROOT_URL} ];then
        SDK_PATCH_ROOT_URL=${USER}@10.10.61.20:/home/svn/sdmc_lib/sdk_patch_tool # 远程 sdmc patch 根路径
    fi

    if [ -z ${SDK_PATCH_PLAT_PATH} ];then
        SDK_PATCH_PLAT_PATH=platform/amlogic_p_gxx.git # sdmc patch 路径
    fi

    if [ -z ${ROOT_DIR} ];then
        echo "ROOT_DIR:${ROOT_DIR} is empty,exit"
        exit 1
    fi

    if [ -z ${PROJECT_NAME} ];then
        echo "PROJECT_NAME is empty,exit"
        exit 1
    fi

    if [ -z ${PROJECT_LUNCH_NAME} ];then
        echo "PROJECT_LUNCH_NAME is empty,exit"
        exit 1
    fi

    if [ -z ${SDK_MANIFEST} ];then
        echo "SDK_MANIFEST is empty,exit"
        exit 1
    fi

    if [ -z ${SDK_BRANCH} ];then
        echo "SDK_BRANCH is empty,exit"
        exit 1
    fi

    if [ -z ${SDK_PATCH_LIST} ];then
        echo "SDK_PATCH_LIST is empty,exit"
        exit 1
    fi

    if [ -z ${SDK_PATCH_BRANCH} ];then
        echo "SDK_PATCH_BRANCH is empty,exit"
        exit 1
    fi

	if [ -z ${SDMC_SDK_DRIVERS_GIT_BRANCH} ];then
		echo ""
		echo "sdmc drivers branch is empty, default master branch!"
		SDMC_SDK_DRIVERS_GIT_BRANCH="master"
		#exit 1
	else
		echo ""
		echo "sdmc drivers current branch is $SDMC_SDK_DRIVERS_GIT_BRANCH!"
	fi

	if [ -z ${SDMC_SDK_PREBUILDS_GIT_BRANCH} ];then
		echo "sdmc prebuilds branch is empty,  default master branch!"
		SDMC_SDK_PREBUILDS_GIT_BRANCH="master"
		#exit 1
	else
		echo "sdmc prebuilds current branch is $SDMC_SDK_PREBUILDS_GIT_BRANCH!"
	fi

	if [ -z ${SDMC_SDK_SAMPLES_GIT_BRANCH} ];then
		echo "sdmc samples branch is empty,  default master branch!"
		SDMC_SDK_SAMPLES_GIT_BRANCH="master"
		#exit 1
	else
		echo "sdmc samples current branch is $SDMC_SDK_SAMPLES_GIT_BRANCH!"
	fi

	if [ -z ${SDMC_SDK_SDMC_LIBS_GIT_BRANCH} ];then
		echo "sdmc sdmc-libs branch is empty,  default master-p branch!"
		echo ""
		SDMC_SDK_SDMC_LIBS_GIT_BRANCH="master-p"
		#exit 1
	else
		echo "sdmc sdmc-libs current branch is $SDMC_SDK_SDMC_LIBS_GIT_BRANCH!"
		echo ""
	fi

    if [ -z ${SDK_PATH} ];then
        echo "SDK_PATH is empty,exit"
        exit 1
    fi

    if [ -z ${SDK_PATCH_PATH} ];then
        echo "SDK_PATCH_PATH is empty,exit"
        exit 1
    fi

    if [ -z ${SDK_URL} ];then
        echo "SDK_URL is empty,exit"
        exit 1
    fi

    if [ -z ${SDK_REPO_URL} ];then
        echo "SDK_REPO_URL is empty,exit"
        exit 1
    fi

    if [ -z ${SDK_PATCH_ROOT_URL} ];then
        echo "SDK_PATCH_ROOT_URL is empty,exit"
        exit 1
    fi

    if [ -z ${SDK_PATCH_PLAT_PATH} ];then
        echo "SDK_PATCH_PLAT_PATH is empty,exit"
        exit 1
    fi


    if [ -z ${BOARD_COMPILE_SDK} ];then
        BOARD_COMPILE_SDK=true # 是否编译sdk
    fi

    if [ -z ${MERGER_COMMON_PATCH} ];then
        MERGER_COMMON_PATCH=true # 是否不合并patch_list_com
    fi

    if [ -z ${CREAT_SDK_PATCH} ];then
        CREAT_SDK_PATCH=true # 是否不合并patch_list_com
    fi

	if [ -z ${CHECK_MEDIA_AUDIO_SO} ];then
		CHECK_MEDIA_AUDIO_SO=true
	fi

	if [ -z ${SELETE_LUNCH} ];then
		SELETE_LUNCH=true
	fi

    FILE_DIFF=${ROOT_DIR}/${PROJECT_NAME}/diff.txt
    SDK_PUBLIC_MANIFEST=${ROOT_DIR}/${PROJECT_NAME}/sdk_public.xml
    SDK_PUBLIC_PACTH_MANIFEST=${ROOT_DIR}/${PROJECT_NAME}/sdk_public_patch.xml
	SDK_OUT_PRODUCT_PATH=${SDK_PATH}/out/target/product/${PROJECT_LUNCH_NAME}/

    echo "ROOT_DIR              : ${ROOT_DIR}"
    echo "PROJECT_NAME          : ${PROJECT_NAME}"
    echo "PROJECT_LUNCH         : ${PROJECT_LUNCH}"
    echo "SDK_MANIFEST          : ${SDK_MANIFEST}"
    echo "SDK_BRANCH            : ${SDK_BRANCH}"
    echo "SDK_PATCH_LIST        : ${SDK_PATCH_LIST}"
    echo "SDK_PATCH_BRANCH      : ${SDK_PATCH_BRANCH}"
    echo "SDK_PATH              : ${SDK_PATH}"
    echo "SDK_PATCH_PATH        : ${SDK_PATCH_PATH}"
    echo "SDK_URL               : ${SDK_URL}"
    echo "SDK_REPO_URL          : ${SDK_REPO_URL}"
    echo "SDK_PATCH_ROOT_URL    : ${SDK_PATCH_ROOT_URL}"
    echo "SDK_PATCH_PLAT_PATH   : ${SDK_PATCH_PLAT_PATH}"
	echo "SDK_OUT_PRODUCT_PATH	: ${SDK_OUT_PRODUCT_PATH}"
	echo "SDK_MEDIA_AUDIO_MANIFEST	: ${SDK_MEDIA_AUDIO_MANIFEST}"
}

function reparse_line()
{
    OLD_IFS="$IFS" 
    IFS=" "

    arr=($1)
    IFS="$OLD_IFS"

    for s in ${arr[@]} 
    do
        path=""
        revision=""

        if [[ ${s:0:4} == "path" ]];then
            path=${s##*=}
            path=`echo ${path} | sed 's/"//g'` #去除双引号
#            echo "path:${path}"
        fi

        if [ ! -z ${path} ];then
            echo "${path} modified, delete it"
            rm -rf ${SDK_PATH}/${path}
        else
            path=""
        fi

        IFS=" "
    done
}

function sdk_revert()
{
    if [ ! -f $1 ]; then
        echo "$1 not exist"
        exit 1
    fi

    if [ ! -f $2 ]; then
        echo "$2 not exist"
        exit 1
    fi

    diff $1 $2 > ${FILE_DIFF}

    IFS_OLD=$IFS
    IFS=$'\n'
    while read LINE
    do
#        echo ${LINE:0:1}
        if [[ ">" == ${LINE:0:1} ]]; then
            reparse_line ${LINE}
        fi
        IFS=$'\n'
    done < ${FILE_DIFF}

    rm ${FILE_DIFF}
    IFS="$IFS_OLD"
}

function check_err()
{
    #echo "$2, ret $1"
    if [ $1 != "0" ]
    then
        cd -
        echo "$2 failed, ret $1 path:$PWD  LINENO:$3"
        exit 1
    else
        return 0
    fi
}

function download_sdk()
{
    mkdir -p ${SDK_PATH}
    cd ${SDK_PATH}

    if [ -d ${SDK_PATH}/.repo/manifests ] && [ -f ${SDK_PUBLIC_MANIFEST} ] && [ -f ${SDK_PUBLIC_PACTH_MANIFEST} ];then
        echo "check sdk modified"
        cd ${SDK_PATH}/.repo/manifests/
        git pull
        check_err $?  "git pull" ${LINENO}
        cd -

        repo init -m ${SDK_MANIFEST}
        check_err $? "repo init -m ${SDK_MANIFEST}" ${LINENO}


        sdk_revert ${SDK_PUBLIC_MANIFEST} ${SDK_PUBLIC_PACTH_MANIFEST}
    else
        echo "notice: delete sdk:${SDK_PATH}"
        rm -rf ${SDK_PATH}/*
        rm -rf ${SDK_PATH}/.repo

        repo init -u ${SDK_URL} -b ${SDK_BRANCH} -m ${SDK_MANIFEST}  --repo-url=${SDK_REPO_URL}
        check_err $? "repo init -u ${SDK_URL} -b p-amlogic -m ${SDK_MANIFEST}  --repo-url=${SDK_REPO_URL}" ${LINENO}

        repo init -m ${SDK_MANIFEST}
        check_err $? "repo init -m ${SDK_MANIFEST}" ${LINENO}
    fi

    repo sync -f -d -j8
    check_err $? "repo sync -f -d -j8" ${LINENO}

    repo manifest -r -o ${SDK_PUBLIC_MANIFEST}
    check_err $? "repo manifest -r -o ${SDK_PUBLIC_MANIFEST}" ${LINENO}

    cd -
}

# $1 下载 code 存放的本地目录
# $2 git clone 远程路径
# $3 git clone 远程分支
function download_moudle()
{
    local_code_dir=$1
    code_url=$2
    code_branch=$3

    if [ -z ${local_code_dir} ];then
        echo "${local_code_dir} is empty,exit"
        exit 1
    fi

    if [ -z ${code_url} ];then
        echo "${code_url} is empty,exit"
        exit 1
    fi

    if [ -z ${code_branch} ];then
        echo "${code_branch} is empty,exit"
        exit 1
    fi

    if [ -d ${local_code_dir} ] && [ -d ${local_code_dir}/.git ];then
        cd ${local_code_dir}
        echo "git pull origin ${code_branch}"
        git add -f .
        check_err $? "git add -f ." ${LINENO}
        git reset --hard
        check_err $? "git reset --hard" ${LINENO}
        git pull origin ${code_branch}
        check_err $? "git pull origin ${code_branch}" ${LINENO}
        cd -
        return 0
    fi

    rm -rf ${local_code_dir}
    mkdir -p ${local_code_dir}
    cd ${local_code_dir}/..

    echo "git clone ${code_url} -b ${code_branch}"
    git clone ${code_url} -b ${code_branch}
    check_err $? "git clone ${code_url} -b ${code_branch}" ${LINENO}

    cd -
}


function download_sdmc_sdk()
{
    download_moudle ${SDK_PATH}/vendor/sdmc/drivers ${SDK_PATCH_ROOT_URL}/platform/vendor/amlogic/drivers.git ${SDMC_SDK_DRIVERS_GIT_BRANCH}

    download_moudle ${SDK_PATH}/vendor/sdmc/sdmc-libs ${SDK_PATCH_ROOT_URL}/platform/vendor/amlogic/sdmc-libs.git ${SDMC_SDK_SDMC_LIBS_GIT_BRANCH}

    download_moudle ${SDK_PATH}/vendor/sdmc/samples ${SDK_PATCH_ROOT_URL}/platform/vendor/amlogic/samples.git ${SDMC_SDK_SAMPLES_GIT_BRANCH}

    download_moudle ${SDK_PATH}/vendor/sdmc/prebuilds ${SDK_PATCH_ROOT_URL}/platform/vendor/amlogic/prebuilds.git ${SDMC_SDK_PREBUILDS_GIT_BRANCH}
}

function download_sdk_patch()
{
    download_moudle ${SDK_PATCH_PATH}/tool ${SDK_PATCH_ROOT_URL}/tool.git master

    path_dir=${SDK_PATCH_PLAT_PATH##*/}
    download_moudle ${SDK_PATCH_PATH}/${path_dir%.*} ${SDK_PATCH_ROOT_URL}/${SDK_PATCH_PLAT_PATH} ${SDK_PATCH_BRANCH}
#    git clone /home/yangyufeng/amlogic/p/amlogic_p_gxx -b ${SDK_PATCH_BRANCH}

}

function download_gtvs()
{
    download_moudle ${SDK_PATH}/vendor/google ${SDK_PATCH_ROOT_URL}/platform/vendor/google/gtvs/p/google.git master
}

function merger_patch()
{
    cd ${SDK_PATCH_PATH}

    path_dir=${SDK_PATCH_PLAT_PATH##*/}

    if [ ${MERGER_COMMON_PATCH} == "true" ];then
        source ${SDK_PATCH_PATH}/tool/patch.sh ${path_dir%.*}/${SDK_PATCH_LIST} ${SDK_PATH}
	else
        source ${SDK_PATCH_PATH}/tool/patch.sh ${path_dir%.*}/${SDK_PATCH_LIST} ${SDK_PATH} -o
    fi
    check_err $? "sh ${SDK_PATCH_PATH}/tool/patch.sh ${path_dir%.*}/${SDK_PATCH_LIST} ${SDK_PATH}" ${LINENO}
    cd -

    cd ${SDK_PATH}
    repo manifest -r -o ${SDK_PUBLIC_PACTH_MANIFEST}
    check_err $? "repo manifest -r -o ${SDK_PUBLIC_PACTH_MANIFEST}" ${LINENO}

    cd -
}

function delete_sdk_patch()
{
    cd ${ROOT_DIR}/${PROJECT_NAME}/
	rm -rf sdk_patch
	rm -rf sdk_public.xml
	rm -rf sdk_public_patch.xml
    cd -
}

function compile_sdk()
{
    cd ${SDK_PATH}
    source ~/env_n.sh
    source build/envsetup.sh
    lunch ${PROJECT_LUNCH}
    check_err $? "lunch ${PROJECT_LUNCH}" ${LINENO}

    repo manifest -r -o ${SDK_PUBLIC_PACTH_MANIFEST}
    check_err $? "repo manifest -r -o ${SDK_PUBLIC_PACTH_MANIFEST}" ${LINENO}

    make installclean 
    check_err $? "make installclean" ${LINENO}

	rm -rf out
	echo "delete out for make ..."

    make otapackage -j8
    check_err $? "make otapackage -j8" ${LINENO}
    repo manifest -r -o ${SDK_PUBLIC_PACTH_MANIFEST}
    check_err $? "repo manifest -r -o ${SDK_PUBLIC_PACTH_MANIFEST}" ${LINENO}
    cd -
}


function check_sdk_media_audio_so()
{
	source ${SDK_PATCH_PATH}/tool/sdk_check_media_audio_so.sh	${SDK_PATH}	 ${SDK_OUT_PRODUCT_PATH}
}


function add_lunch_combo()
{
    local new_combo=$1
    local c
    for c in ${LUNCH_MENU_CHOICES[@]} ; do
        if [ "$new_combo" = "$c" ] ; then
            return
        fi
    done
    LUNCH_MENU_CHOICES=(${LUNCH_MENU_CHOICES[@]} $new_combo)
}

function print_lunch_menu()
{
    local uname=$(uname)
    echo
    echo "You're building on" $uname
    echo
    echo "auto build tool info:"
    echo "version	: v1.0"
    echo "Author	: yangyufeng"
    echo "email 	: yangyufeng@mail.sdmc.com"
    echo "Lunch menu...:"

    local i=1
    local choice
    for choice in ${LUNCH_MENU_CHOICES[@]}
    do
        echo "     $i. $choice"
        i=$(($i+1))
    done

    echo
}

function lunch_items_variant()
{
	local answer  curr_project_file  curr_project_name

	local items_variant=(user userdebug eng)

	PROJECT_LUNCH=""

	if [[ ! -z $2 ]]; then
		if [[ $2 == "user" ]] || [[ $2 == "userdebug" ]] || [[ $2 == "eng" ]]; then
			PROJECT_LUNCH="${PROJECT_LUNCH_NAME}-${2}"
			return 0
		else
			echo "Sorry, lunch args is $2  error!!!"
			exit 1
		fi
	fi

	for ((i = 0 ; i < ${#items_variant[@]}; i++)); do
		echo "     $(($i+1)). ${items_variant[i]}"
	done

	echo -n "Which would you like? [user userdebug eng] "
	read answer

	curr_project_file=$(find ./projects/  -name "${1}.sh")
	curr_project_name=$(cat $curr_project_file | grep "PROJECT_LUNCH_NAME" | sed 's/=/ /g'| awk '{print $2}')
	#echo "lunch_items_variant: $curr_project_file  ${LINENO}"
	#echo "lunch_items_variant: $curr_project_name  ${LINENO}"


	if [[ $answer == "user" ]] || [[ $answer == "userdebug" ]] || [[ $answer == "eng" ]]; then
		PROJECT_LUNCH="${PROJECT_LUNCH_NAME}-${answer}"

	elif (echo -n $answer | grep -q -e "^[0-9][0-9]*$"); then
		if [ $answer -le ${#items_variant[@]} ]; then

			lunch_variant_tmp=${items_variant[$(($answer-1))]}
			PROJECT_LUNCH="${PROJECT_LUNCH_NAME}-${lunch_variant_tmp}"
			#echo -e "\e[1;33m lunch_items_variant : $PROJECT_LUNCH \e[0m"
		fi
	fi

	if [ -z $PROJECT_LUNCH ]; then
		echo -e "\e[1;31m Not choose lunch, will be exit!!! \e[0m"
		exit 1
	fi
}

function lunch_menu()
{
    local answer variant

    add_lunch_combo jenkins_project_demo

    for f in `test -d projects && find -L projects -maxdepth 2 -name '*.sh' 2> /dev/null | sort`
    do
        echo "including $f"
        . $f
    done

    if [ "$1" ] ; then
        answer=$1
    else
        print_lunch_menu
        echo -n "Which would you like? [jenkins_project_demo] "
        read answer
    fi

    local selection=

    if [ -z "$answer" ]
    then
        selection=jenkins_project_demo
    elif (echo -n $answer | grep -q -e "^[0-9][0-9]*$")
    then
        if [ $answer -le ${#LUNCH_MENU_CHOICES[@]} ]
        then
            selection=${LUNCH_MENU_CHOICES[$(($answer-1))]}
        fi
    else
        selection=$answer
    fi

    $selection

	if [ "$2" ]; then
		variant=$2
	else
		variant=""
	fi

    env_setup
    if [ ${SELETE_LUNCH} == "true" ];then
		lunch_items_variant	"$selection" "$variant"
	fi

    #env_setup
	echo -e "\e[1;33m selection : $selection --> $PROJECT_LUNCH \e[0m"
}

function main()
{
#    rm -rf ${CUR_DRI}/${PROJECT_NAME}
    echo -e "\033[32m step1: select project start \033[0m"
    lunch_menu $@
    echo -e "\033[32m step1: select project end \033[0m"

    echo -e "\033[32m step2: down load sdk start \033[0m"
    download_sdk
    echo -e "\033[32m step2: down load sdk end \033[0m"

    echo -e "\033[32m step3: down load sdmc sdk patch start \033[0m"
    download_sdk_patch
    echo -e "\033[32m step3: down load sdmc sdk patch end \033[0m"

    echo -e "\033[32m step4: down load sdmc sdk start \033[0m"
    download_sdmc_sdk
    echo -e "\033[32m step4: down load sdmc sdk end \033[0m"

    if [ ${BOARD_COMPILE_ATV} == "true" ];then
        echo -e "\033[32m step5: down load google gtvs start \033[0m"
        download_gtvs
        echo -e "\033[32m step5: down load google gtvs end \033[0m"
    fi


    echo -e "\033[32m step6: merger patch start \033[0m"
    merger_patch
    echo -e "\033[32m step6: merger patch end \033[0m"

    if [ ${CREAT_SDK_PATCH} == "false" ];then
		echo -e "\033[32m step7: delete sdk_patch start \033[0m"
		delete_sdk_patch
		echo -e "\033[32m step7: delete sdk_patch end \033[0m"
	fi

    if [ ${BOARD_COMPILE_SDK} == "true" ];then
        echo -e "\033[32m step8: compile sdk start \033[0m"
        compile_sdk
        echo -e "\033[32m step8: compile sdk end \033[0m"
    fi

    if [ ${CHECK_MEDIA_AUDIO_SO} == "true" ];then
		echo -e "\033[32m step9: check sdk media audio so start \033[0m"
		check_sdk_media_audio_so
		echo -e "\033[32m step9: check sdk media audio so end \033[0m"
	fi

}

if [ ! -z ${JENKINS_HOME} ];then #使用 jenkins 构建
    main 1
else
    main $@ # parse all paras to function
fi
