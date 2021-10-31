#! /bin/bash


function show_resources_yaml_template()
{
	resources_type=${1}
	resources_ns=${2}
	object_name=${3}

	echo   ""
	YELLOW "show ${resources_type} object: ${object_name} \t namespaces: ${resources_ns}"
	BLUE   "[k8s action]: kubectl  get  ${resources_type}  -n ${resources_ns}  ${object_name}  -o yaml"
	kubectl  get  ${resources_type}  -n ${resources_ns}  ${object_name}  -o yaml
}


function show_ssm_secret_decode_template()
{
	resources_type=${1}
	resources_ns=${2}
	object_name=${3}

	echo   ""
	YELLOW "show ${resources_type} object: ${object_name} \t namespaces: ${resources_ns}"
	BLUE   "[k8s action]: kubectl  get  ${resources_type}  -n ${resources_ns}  ${object_name} -o go-template='{{range \$k,\$v := .data}}{{printf \"%s: \" \$k}}{{if not \$v}}{{\$v}}{{else}}{{\$v | base64decode}} {{end}}{{\"\\\n\"}}{{end}}'"

	kubectl  get  ${resources_type}  -n ${resources_ns}  ${object_name} -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}} {{end}}{{"\n"}}{{end}}'
}


function show_ssm_store_secret() { show_resources_yaml_template  "secret"  $*; show_ssm_secret_decode_template  "secret"  $*; }
function show_ssm_mode_si() { show_resources_yaml_template  "si"  $*; }
function show_ssm_mode_sb() { show_resources_yaml_template  "sb"  $*; }
function show_ssm_mode_si() { show_resources_yaml_template  "si"  $*; }
function show_ssm_mode_sb_secret() { show_resources_yaml_template  "secret"  $*; show_ssm_secret_decode_template  "secret"  $*; }


function show_common_pod() { show_resources_yaml_template  "pod"  $*; }
function show_common_svc() { show_resources_yaml_template  "svc"  $*; }



function show_k8s_resources()
{
	SHOW_K8S_RESOURCES_TYPE=${1}

	case ${SHOW_K8S_RESOURCES_TYPE} in

	ssm_store_secret)
		shift
		show_ssm_store_secret $*
	;;
	ssm_mode_si)
		shift
		show_ssm_mode_si $*
	;;
	ssm_mode_sb)
		shift
		show_ssm_mode_sb  $*
	;;
	ssm_mode_sb_secret)
		shift
		show_ssm_mode_sb_secret  $*
	;;
	ssm_mode_pod|tcs_mode_pod|tce_mode_pod)
		shift
		show_common_pod  $*
	;;
	ssm_mode_svc|tcs_mode_svc|tce_mode_svc)
		shift
		show_common_svc  $*
	;;
	*)
		usage
		RED "please check your k8s show resources argvs!"
		exit 1
	;;
	esac
}
