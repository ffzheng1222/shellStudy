#! /bin/bash


function logs_resources_template()
{
	resources_type=${1}
	resources_ns=${2}
	object_name=${3}

	echo   ""
	YELLOW "print ${resources_type} logs details info: ${object_name} \t namespaces: ${resources_ns}"
	BLUE   "[k8s action]: kubectl  logs  -n ${resources_ns}  ${object_name}"
	kubectl  logs  -n  ${resources_ns}  ${object_name}
}


function logs_common_pod() { logs_resources_template  "pod" $*; }



function logs_k8s_resources()
{
	LOGS_K8S_RESOURCES_TYPE=${1}

	case ${LOGS_K8S_RESOURCES_TYPE} in

	ssm_mode_pod)
		shift
		logs_common_pod $*
	;;
	tce_mode_pod)
		shift
		logs_common_pod $*
	;;
	tcs_mode_pod)
		shift
		logs_common_pod  $*
	;;
	*)
		usage
		RED "please check your k8s logs resources argvs!"
		exit 1
	;;
	esac
}
