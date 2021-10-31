#! /bin/bash
#################################################################
#
# vectra_dolby.sh 
#  	sdk1029 merge patch ...
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




SDK_PATH=$(pwd)
AML_PATCH_PATH="/home/zhengfanfan/amlogic/w_code/s905x2/vectra/vectra_1029_patch/hailstom2.1-patch0110"
SECURE_PATCH_NAME="1000-merge-aml-patch-to-sdk1029"
SDK_GIT_PATH_TXT="${SDK_PATH}/sdk_git_path.txt"
GIT_COMMIT_NAME="Amlogic: 1000-merge-aml-patch-to-sdk1029"




function creat_aml_path_to_sdmc()
{
	local creat_aml_patch_gits=()

	creat_aml_patch_gits=($(cat ${1} | uniq))

	for ((i = 0; i < ${#creat_aml_patch_gits[@]}; i++)); do
		((count=${i}+1))
		creat_modify_git_path=${creat_aml_patch_gits[i]}

		is_git=$(find ${SDK_PATH}/${creat_modify_git_path} -name ".git")
		if [[ ! -z ${is_git} ]]; then
			modify_git_path=${creat_modify_git_path}
		else
			prev_path_is_git=$(find ${SDK_PATH}/${creat_modify_git_path}/../ -name ".git")
			if [[ ! -z ${prev_path_is_git} ]]; then
				modify_git_path=${creat_modify_git_path%/*}
			else
				RED "!!! not git patch !!!"
				exit 1
			fi
		fi
		
		GREEN "${1}"
		source sdmc_patch_creat.sh	"${modify_git_path}"   "${SECURE_PATCH_NAME}"	  "${count}"
		YELLOW "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
		echo " "
	done

	
}


function commit_aml_patch_to_sdk()
{
	local commit_aml_patch_gits=()

	commit_aml_patch_gits=($(cat ${1} | uniq))

	for ((i = 0; i < ${#commit_aml_patch_gits[@]}; i++)); do
		commit_modify_git_path=${commit_aml_patch_gits[i]}
		
		RED "${commit_modify_git_path}: aml patch commit start ..."
		cd ${SDK_PATH}/${commit_modify_git_path} 1>/dev/null

		git add -A ; git commit -m "${GIT_COMMIT_NAME}"

		cd - 1>/dev/null

		RED "aml patch commit end ..." 
		YELLOW "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
		echo " "
	done
}



function clean_aml_patch_from_sdk()
{
	local clean_aml_patch_gits=()

	clean_aml_patch_gits=($(cat ${1} | uniq))

	for ((i = 0; i < ${#clean_aml_patch_gits[@]}; i++)); do
		clean_modify_git_path=${clean_aml_patch_gits[i]}
		
		RED "${clean_modify_git_path}: clean aml patch start ..."
		cd ${SDK_PATH}/${clean_modify_git_path} 1>/dev/null

		git clean -fd  && git reset --hard
		#git reset  --soft  HEAD^ && git reset  HEAD  *

		cd - 1>/dev/null

		RED "clean aml patch end ..." 
		YELLOW "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
		echo " "
	done
}



function aml_patch_merge()
{
	#YELLOW "${1} ---- ${2} ($LINENO)"

	cd ${SDK_PATH}/${1} 1>/dev/null

	merge_result=$(git apply  ${2})

	if [[ -z ${merge_result} ]]; then
		YELLOW "path: ${1}"
		GREEN "${2} merge success."
	else
		YELLOW "path: ${1}"
		RED "${2} merge failed !!!"
		exit
	fi

	cd - 1>/dev/null
}



function find_aml_patch()
{
	local aml_patch_dirs=()
	local aml_sample_dir_patchs=()

	rm -rf ${SDK_GIT_PATH_TXT}

	aml_patch_dirs=($(ls ${AML_PATCH_PATH}))
	
	for ((i = 0; i < ${#aml_patch_dirs[@]}; i++)); do

		aml_patch_dir=${aml_patch_dirs[i]}
		YELLOW "${aml_patch_dir} ($LINENO) ....................................................."

		aml_sample_dir_patchs=($(find ${AML_PATCH_PATH}/${aml_patch_dir} -name "*.patch" | sort))

		for ((j = 0; j < ${#aml_sample_dir_patchs[@]}; j++)); do

			aml_patch_name=${aml_sample_dir_patchs[j]}
			#YELLOW "... ${aml_patch_name} ($LINENO)"
			
			sdk_git_dir_tmp=$(echo ${aml_patch_name} | sed "s/${aml_patch_dir}/ ${aml_patch_dir}/g" | awk '{print $2}')
			#YELLOW "... ${sdk_git_dir_tmp} ($LINENO)"

			sdk_git_dir=${sdk_git_dir_tmp%/*}
			#YELLOW "... ${sdk_git_dir} ($LINENO)"
			echo "${sdk_git_dir}" >> ${SDK_GIT_PATH_TXT}

			aml_patch_merge    ${sdk_git_dir}   ${aml_patch_name}
			YELLOW "==========================================================================="
			echo " "
		done
		#exit
	done
}



function main()
{
	if   [[ ${1} == "creat" ]]; then
		creat_aml_path_to_sdmc    ${SDK_GIT_PATH_TXT}
		exit 1

	elif [[ ${1} == "commit" ]]; then
		commit_aml_patch_to_sdk   ${SDK_GIT_PATH_TXT}
		exit 1
	
	elif [[ ${1} == "clean" ]]; then
		clean_aml_patch_from_sdk   ${SDK_GIT_PATH_TXT}
		exit 1
	fi


	#查找所有的patch然后合并
	find_aml_patch $*
}

main $@