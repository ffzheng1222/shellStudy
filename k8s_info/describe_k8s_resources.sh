#! /bin/bash


SHOW_DESCRIBE_EVENTS_NUM=100


function describe_resources_template()
{
	resources_type=${1}
	resources_ns=${2}
	object_name=${3}

	echo   ""
	YELLOW "describe ${resources_type} object: ${object_name} \t namespaces: ${resources_ns}"
	BLUE   "[k8s action]: kubectl  describe  ${resources_type}  -n ${resources_ns}  ${object_name}  |grep  'Events:' -A${SHOW_DESCRIBE_EVENTS_NUM}"
	kubectl  describe  ${resources_type}  -n ${resources_ns}  ${object_name}  | grep  'Events:' -A${SHOW_DESCRIBE_EVENTS_NUM}
}


function describe_ssm_mode_si() { describe_resources_template  "si"  $*; }


function describe_ssm_mode_sb() { describe_resources_template  "sb"  $*; }


function describe_common_pod() { describe_resources_template  "pod"  $*; }


function describe_common_svc() { describe_resources_template  "svc"  $*; }




function describe_k8s_resources()
{
	DESCRIBE_K8S_RESOURCES_TYPE=${1}

	case ${DESCRIBE_K8S_RESOURCES_TYPE} in

	ssm_mode_si)
		shift
		describe_ssm_mode_si $*
	;;
	ssm_mode_sb)
		shift
		describe_ssm_mode_sb  $*
	;;
	ssm_mode_pod|tcs_mode_pod|tce_mode_pod)
		shift
		describe_common_pod  $*
	;;
	ssm_mode_svc|tcs_mode_svc|tce_mode_svc)
		shift
		describe_common_svc  $*
	;;
	*)
		usage
		RED "please check your k8s  describe resources argvs!"
		exit 1
	;;
	esac
}
