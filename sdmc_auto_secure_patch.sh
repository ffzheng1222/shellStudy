#! /bin/bash
#################################################################
#
# sdmc_auto_secure_patch.sh   
#  	auto fix into secure patch to sdk
#
###############################################################

GREEN='\e[0;32m'
YELLOW='\e[1;33m'
RED='\e[1;31m'
END='\e[0m'
RED()
{
	echo -e  "${RED}$1${END}"
}

GREEN()
{
	echo -e  "${GREEN}$1${END}"
}

YELLOW()
{
    echo -e  "${YELLOW}$1${END}"
}

########################################################################################################################################################
SECURE_PATCH_08="/home/zhengfanfan/amlogic/sdmc_Base/secure_patch/bulletin_2019_08_preview_v2/patches/android-9.0.0_r1/platform/"
SECURE_PATCH_09="/home/zhengfanfan/amlogic/sdmc_Base/secure_patch/bulletin_2019_09_preview/bulletin_2019_09_preview/patches/android-9.0.0_r1/platform"
SECURE_PATCH_10="/home/zhengfanfan/amlogic/sdmc_Base/secure_patch/bulletin_2019_10_preview/bulletin_2019_10_preview/patches/android-9.0.0_r1/platform"
SECURE_PATCH_11="/home/zhengfanfan/amlogic/sdmc_Base/secure_patch/bulletin_2019_11_preview/bulletin_2019_11_preview/patches/android-9.0.0_r1/platform"
SECURE_PATCH_12="/home/zhengfanfan/amlogic/sdmc_Base/secure_patch/bulletin_2019_12_preview/bulletin_2019_12_preview/patches/android-9.0.0_r1/platform"

SH_USER_SECURE_PATCH=${SECURE_PATCH_12}

#SECURE_PATCH_NAME 表示当前被做成sdmc patch的安全补丁的文件名
#PLATFORM_SECURITY_PATCH_DATA 表示当前安全补丁的bulid/make 日期
SECURE_PATCH_NAME="0308-update-android-security-Dec"
PLATFORM_SECURITY_PATCH_DATA="2019-12-05"

########################################################################################################################################################



#SDMC_SDK_PATCH_COMMIT 为 true：表示将当前的安全补丁提交到SDK
SDMC_SDK_PATCH_COMMIT="true"
#SDMC_SECURE_PATCH 为 true：表示将当前的安全补丁做成sdmc patch文件
CREAT_SDMC_SECURE_PATCH="true"




function patch_to_sdk()
{
	echo
	YELLOW "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	cd ${2} >/dev/null

	GREEN "${1}	 merge start..."
	patch -p1 < ${1}
	merge_err=$(git status | grep -E "rej")

	if [[ ! -z ${merge_err} ]]; then
		RED "${2}:${1}, merge failed!"
		cd - >/dev/null
		return -1
	fi

	git clean -fd *.orig

	cd - >/dev/null
	YELLOW "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}



function handle_patch()
{
	#echo "${1} : ${2} : ${3}

	patch_file=${1}
	patch_name=${patch_file##*/}

	patch_to_sdk    "${patch_file}"	  ${2}

	if [ $? -eq 0 ]; then
		GREEN "${2}: $patch_name  sucess ^_^"
	else
		RED "${2}: $patch_name  fail @_@"
		#return  1
	fi
}



function find_secure_patch()
{
	all_patch_files=($(find ${SH_USER_SECURE_PATCH}  -name "*.patch" | sort))

	#echo "${#all_patch_files[@]}, ($LINENO)"
	for ((i = 0; i < ${#all_patch_files[@]}; i++)); do
		all_patch_file="${all_patch_files[i]}"

		patch_path=${all_patch_file%/*}
		sdk_git_patch_path=$(echo ${patch_path} | sed 's/\/platform\// /g' | awk '{print $2}')

		#echo "$patch_path, ($LINENO)"
		#echo "$sdk_git_patch_path, ($LINENO)"

		CURR_SECURE_PATCH_PATH=${sdk_git_patch_path}
		handle_patch  "${all_patch_file}"  "${sdk_git_patch_path}"

	done
}


function clean_patch_modify()
{	
	GREEN "${1}"
	cd ${1}
	git clean -fd && git reset --hard
	#git clean -fd && git reset --hard HEAD^
	cd -
	YELLOW "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}


function commit_patch_modify()
{
	GREEN "${1}"
	cd ${1}
	git add -A; git commit -m "sdmc: $SECURE_PATCH_NAME"
	cd -
	YELLOW "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}


function creat_sdmc_patch()
{
	GREEN "${1}"
	source sdmc_patch_creat.sh	"${1}"   "${SECURE_PATCH_NAME}"	 "${2}"
	YELLOW "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}



function modify_secure_patch_data()
{
	secure_patch_data_file="build/make/core/version_defaults.mk"
	curr_secure_data=$(cat ${secure_patch_data_file} | grep "PLATFORM_SECURITY_PATCH :=" | awk '{print $3}')

	cat ${secure_patch_data_file} | grep "PLATFORM_SECURITY_PATCH :=" | awk '{print $3}' | \
		sed -i "s/${curr_secure_data}/${PLATFORM_SECURITY_PATCH_DATA}/g"  ${secure_patch_data_file}
}



function handle_sdk_secure_patch()
{
	all_patch_git_path=($(find ${SH_USER_SECURE_PATCH}  -name "*.patch" | sort | sed 's/\/platform\// /g' | sed 's/\/000/ /g' | awk '{print $2}' | uniq))

	#如果参数1为clean 代表会清除当前安全补丁patch
	if [[ "clean" == "${1}" ]]; then
		for ((i = 0; i < ${#all_patch_git_path[@]}; i++)); do
			clean_patch_modify	"${all_patch_git_path[i]}"
		done

		clean_patch_modify	"build/make"
		exit 1
	fi

	
	#如果参数1为creat 代表会提交当前安全补丁patch
	if [[ "creat" == "${1}" ]]; then
		modify_secure_patch_data
		for ((i = 0; i < ${#all_patch_git_path[@]}; i++)); do
			if [[ "true" == "${CREAT_SDMC_SECURE_PATCH}" ]]; then
				((count=${i}+1))
				creat_sdmc_patch	"${all_patch_git_path[i]}"	"${count}"
			fi
		done

		if [[ "true" == "${CREAT_SDMC_SECURE_PATCH}" ]]; then
			((count=${count}+1))
			creat_sdmc_patch  "build/make"	"${count}"
		fi
		exit 1
	fi


	#如果参数1为commit 代表会提交当前安全补丁patch
	if [[ "commit" == "${1}" ]]; then
		for ((i = 0; i < ${#all_patch_git_path[@]}; i++)); do
			if [[ "true" == "${SDMC_SDK_PATCH_COMMIT}" ]]; then
				commit_patch_modify	"${all_patch_git_path[i]}"
			fi
		done

		if [[ "true" == "${SDMC_SDK_PATCH_COMMIT}" ]]; then
			commit_patch_modify "build/make"
		fi
		exit 1
	fi
	
	#如果参数1为help 代表提示命令行串口此 .sh脚本 用法
	if [[ "--help" == "${1}" ]]; then
		RED "please run this script in android top directory"
		RED "Usage:	sdmc_auto_secure_patch.sh [opts]"
		RED "	clean: 	clean current secure patch"
		RED "	creat:	creat sdmc secure patch"
		RED "	commit: commit secure patch to sdk"
	fi
}



function main()
{
	if [ $# -eq 0 ]; then
		find_secure_patch $*
	else
		handle_sdk_secure_patch $*
	fi
}

main $@
