#! /bin/bash


########################################################
#
#  k8s_info.sh
#
#  基于tcs底座，快速获取k8s 资源对象信息
#  usage: k8s_info.sh [operate] [resources]
#
########################################################


# configuration color show ...
GREEN='\e[0;32m'; YELLOW='\e[1;33m'; RED='\e[1;31m'; BLUE='\e[0;34m'; END='\e[0m';
RED(){ echo -e  "${RED}$1${END}"; }
GREEN(){ echo -e  "${GREEN}$1${END}"; }
YELLOW(){ echo -e  "${YELLOW}$1${END}"; }
BLUE() { echo -e  "${BLUE}$1${END}"; }


# import k8s operate module *.sh file
SSM_ROOT_PATH=$(cd `dirname $0` && pwd)
source ${SSM_ROOT_PATH}/get_k8s_resources.sh
source ${SSM_ROOT_PATH}/describe_k8s_resources.sh
source ${SSM_ROOT_PATH}/show_k8s_resources.sh
source ${SSM_ROOT_PATH}/logs_k8s_resources.sh


function usage()
{
	echo   ""
	RED    "please run this script in k8s_info root directory"
	RED    "Usage:  $0 [operate] [resources] [xxx]"
	echo   "   operate menu:"
	echo   "       get             -----> get k8s resources overview"
	echo   "       describe        -----> describe k8s resources"
	echo   "       show            -----> show k8s resources details"
	YELLOW "   get resources menu:"
	echo   "       ssm_mode_one_all  ssm_store_secret     ssm_mode_crd        ssm_mode_si"
	echo   "       ssm_mode_sb       ssm_mode_sb_secret   ssm_mode_svc        ssm_mode_pod"
	echo   "       tce_mode_pod      tce_mode_svc         tce_mode_ingress"
	echo   "       tcs_mode_pod      tcs_mode_svc"
	echo   ""
	YELLOW "   describe resources menu:"
	echo   "       ssm_mode_si       ssm_mode_sb          ssm_mode_pod        ssm_mode_svc"
	echo   "       tce_mode_pod      tce_mode_svc"
	echo   "       tcs_mode_pod      tcs_mode_svc"
   	echo   ""
    YELLOW "   show resources menu:"
	echo   "       ssm_store_secret  ssm_mode_si          ssm_mode_sb         ssm_mode_sb_secret"
	echo   "       ssm_mode_pod      ssm_mode_svc"
	echo   "       tce_mode_pod      tce_mode_svc"
	echo   "       tcs_mode_pod      tcs_mode_svc"
	echo   ""
    YELLOW "   logs resources menu:"
	echo   "       ssm_mode_pod      tce_mode_pod         tcs_mode_pod"
	echo   ""
	echo   "example:"
	echo   "	$0 get ssm_store_secret  xxx    ----->  get xxx k8s store secret info in ssm namespaces"
	echo   "	$0 describe ssm_mode_si  xxx    ----->  describe xxx k8s serviceinstances res in tce namespaces"
	echo   ""
}



function main()
{
	K8S_OPERATE_TYPE=${1}

	case ${K8S_OPERATE_TYPE} in

	get)
		shift
		get_k8s_resources  $*
	;;

	describe)
		shift
		describe_k8s_resources  $*
	;;

	show)
		shift
		show_k8s_resources  $*
	;;

	logs)
		shift
		logs_k8s_resources  $*
	;;

	*)
		usage
		RED "please check your operate cmdline argvs!"
		exit 1
	;;
	esac
}

main $@

