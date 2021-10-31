#! /bin/bash



K8S_SUPPORT_INSTANCES_TYPE_ARRAYS=("zk"  "tdsql"  "credis"  "ces"  "mongo"  "kafka"  "rabbitmq"  "cmq")



function get_resources_360_version()
{
	resources_type=${1}
	resources_ns=${2}
	prev_func_transfer_argvs=$*

	for ins_type in ${K8S_SUPPORT_INSTANCES_TYPE_ARRAYS[*]}; do
		if [[ ${prev_func_transfer_argvs} =~ ${ins_type} ]]; then
			echo   ""
			YELLOW "get 360 ssm support instances ${resources_type} object: ${ins_type} \t namespaces: ${resources_ns}"
			BLUE   "[k8s action]: kubectl  get  ${resources_type}  -n ${resources_ns}  | grep  \"${ins_type}\""
			kubectl  get  ${resources_type}  -n ${resources_ns}  | grep  "${ins_type}"
		fi
	done
}



function get_ssm_store_secret()
{
	if [[ $* =~ "360" ]]; then
		get_resources_360_version  "secret"  "service-brokers"  $*
		return
	fi

	echo
	YELLOW "get ssm support instances store secret object: $* \t namespaces: ssm"
	BLUE   "[k8s action]: kubectl get secret -nssm | grep \"$*\" "
	kubectl get secret -nssm | grep "$*"
}


function get_ssm_mode_crd()
{
	ssm_crd_arrays=("zookeeperstandalones"  "rabbitmqstandalones"  "tdsqls"  "credis"  "ces"  "mongoes"  "kafkas"  "rabbitmqs")

	if [[ $* =~ "360" ]]; then
		get_resources_360_version  "crd"  "service-brokers"  $*
		return
	fi

	echo
	YELLOW "get ssm support instances crd object: $*"
	if [[ "$*" =~ "zk" ]]; then
		BLUE   "[k8s action]: kubectl  get crd  | grep  -E  \"^zookeeper|^zk\" "
		kubectl  get crd  | grep  -E  "^zookeeper|^zk"
		BLUE   "[k8s action]: kubectl  get zookeeperstandalones -nsso "
		kubectl  get zookeeperstandalones -nsso

	elif [[ "$*" =~ "mq" ]]; then
		BLUE   "[k8s action]: kubectl  get crd  | grep  -E  \"^rabbitmq\" "
		kubectl  get crd  | grep  "^rabbitmq"
		BLUE   "[k8s action]: kubectl  get rabbitmqstandalones -nsso "
		kubectl  get rabbitmqstandalones -nsso

	else
		BLUE   "[k8s action]: kubectl  get crd  | grep  \"^$*\" "
		kubectl  get crd  | grep  "^$*"

		for ssm_crd in ${ssm_crd_arrays[*]}; do
			if [[ ${ssm_crd} =~ $* ]]; then
				BLUE   "[k8s action]: kubectl  get  ${ssm_crd}  -nsso "
				kubectl  get  ${ssm_crd}  -nsso
			fi
		done
	fi
}



function get_ssm_mode_si()
{
	if [[ $* =~ "360" ]]; then
		get_resources_360_version  "serviceinstances.servicecatalog.k8s.io"  "tce"  $*
		return
	fi

	echo
	YELLOW "get ssm support instances serviceinstances object: $* \t namespaces: tce"
	BLUE   "[k8s action]: kubectl  get  serviceinstances.infra.tce.io  -ntce  | grep  \"$*\" "
	kubectl  get  serviceinstances.infra.tce.io  -ntce  | grep  "$*"
}


function get_ssm_mode_sb()
{
	if [[ $* =~ "360" ]]; then
		get_resources_360_version  "servicebindings.servicecatalog.k8s.io"  "tce"  $*
		return
	fi

	echo
	YELLOW "get ssm support instances servicebinding object: $* \t namespaces: tce"
	BLUE   "[k8s action]: kubectl  get  servicebindings.infra.tce.io  -ntce  | grep  \"$*\" "
	kubectl  get  servicebindings.infra.tce.io  -ntce  | grep  "$*"
}


function get_ssm_mode_sb_secret()
{
	if [[ $* =~ "360" ]]; then
		get_resources_360_version  "secret"  "tce"  $*
		return
	fi

	echo
	YELLOW "get ssm support instances sb_secret object: $* \t namespaces: tce"
	BLUE   "[k8s action]: kubectl  get  secret  -ntce | grep  \"$*\" "
	kubectl  get  secret  -ntce | grep  "$*"
}


function get_ssm_mode_pod()
{
	if [[ $* =~ "360" ]]; then
		get_resources_360_version  "pod"  "service-brokers"  $*
		return
	fi

	echo
	YELLOW "get ssm support instances pod object: $* \t namespaces: ssm"
	BLUE   "[k8s action]: kubectl  get  pod  -nssm | grep  \"$*\" "
	kubectl  get  pod  -nssm | grep  "$*"

	YELLOW "get sso support instances pod object: $* \t namespaces: sso"
	BLUE   "[k8s action]: kubectl  get  pod  -nsso | grep  \"$*\" "
	kubectl  get  pod  -nsso | grep  "$*"

}


function get_ssm_mode_svc()
{
	if [[ $* =~ "360" ]]; then
		get_resources_360_version  "svc"  "service-brokers"  $*
		return
	fi

	echo
	YELLOW "get ssm support instances svc object: $* \t namespaces: ssm"
	BLUE   "[k8s action]: kubectl  get  svc  -nssm | grep  \"$*\" "
	kubectl  get  svc  -nssm | grep  "$*"

	YELLOW "get ssm support instances svc object: $* \t namespaces: sso"
	BLUE   "[k8s action]: kubectl  get  svc  -nsso | grep  \"$*\" "
	kubectl  get  svc  -nsso | grep  "$*"
}



function get_ssm_mode_one_all()
{
	get_ssm_store_secret    $*
	get_ssm_mode_crd  $*
	get_ssm_mode_si   $*
	get_ssm_mode_sb   $*
	get_ssm_mode_sb_secret  $*
	get_ssm_mode_pod  $*
	get_ssm_mode_svc  $*
}


function  get_tcs_res_template()
{
	resources_type=${1}
	grep_argvs=${2}

	echo
	YELLOW "get tcs mode ${resources_type} object: $*"
	BLUE   "[k8s action]: kubectl  get  ${resources_type}  -A | grep  \"${grep_argvs}\" "
	kubectl  get   ${resources_type}  -A | grep  "${grep_argvs}"
}
function get_tcs_mode_pod() { get_tcs_res_template  "pod"  $*; }
function get_tcs_mode_svc() { get_tcs_res_template  "svc"  $*; }




function  get_tce_res_template()
{
	resources_type=${1}
	grep_argvs=${2}

	echo
	YELLOW "get tce mode ${resources_type} object: $*"
	BLUE   "[k8s action]: kubectl  get  ${resources_type}  -ntce | grep  \"${grep_argvs}\" "
	kubectl  get   ${resources_type}  -ntce | grep  "${grep_argvs}"
}
function get_tce_mode_pod() { get_tce_res_template  "pod"  $*; }
function get_tce_mode_svc() { get_tce_res_template  "svc"  $*; }
function get_tce_mode_ingress() { get_tce_res_template  "ingress"  $*; }




function get_k8s_resources()
{
	GET_K8S_RESOURCES_TYPE=${1}

	case ${GET_K8S_RESOURCES_TYPE} in

	ssm_mode_one_all)
		shift
		get_ssm_mode_one_all $*
	;;
	ssm_store_secret)
		shift
		get_ssm_store_secret  $*
	;;
	ssm_mode_crd)
		shift
		get_ssm_mode_crd  $*
	;;
	ssm_mode_si)
		shift
		get_ssm_mode_si  $*
	;;
	ssm_mode_sb)
		shift
		get_ssm_mode_sb  $*
	;;
	ssm_mode_sb_secret)
		shift
		get_ssm_mode_sb_secret  $*
	;;
	ssm_mode_svc)
		shift
		get_ssm_mode_svc  $*
	;;
	ssm_mode_pod)
		shift
		get_ssm_mode_pod  $*
	;;
	tce_mode_pod)
		shift
		get_tce_mode_pod  $*
	;;
	tce_mode_svc)
		shift
		get_tce_mode_svc  $*
	;;
	tce_mode_ingress)
		shift
		get_tce_mode_ingress  $*
	;;
	tcs_mode_pod)
		shift
		get_tcs_mode_pod  $*
	;;
	tcs_mode_svc)
		shift
		get_tcs_mode_svc  $*
	;;
	*)
		usage
		RED "please check your k8s get resources argvs!"
		exit 1
	;;
	esac
}

