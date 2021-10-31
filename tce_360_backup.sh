#! /bin/bash

########################################################################
#
#  tce_360_backup.sh
#
#  基于tce 360版本，备份管控组件版本信息以及k8s相关资源备份
#  usage: tce_360_backup.sh [operate]
#
########################################################################



BACKUP_ROOT_DIR="/data1/360_info_backup"

config_inpt="/data/tce_dc/config"
config_output="${BACKUP_ROOT_DIR}/config_info_backup"

component_output="${BACKUP_ROOT_DIR}/component_info_backup"
component_inpt="/data/tce_dc/software/latest"


k8s_resources_output="${BACKUP_ROOT_DIR}/360_k8s_resources"
container_image_output="${BACKUP_ROOT_DIR}/containers_image_backup"




# configuration color show ...
GREEN='\e[0;32m'; YELLOW='\e[1;33m'; RED='\e[1;31m'; BLUE='\e[0;34m'; END='\e[0m';
RED(){ echo -e  "${RED}$1${END}"; }
GREEN(){ echo -e  "${GREEN}$1${END}"; }
YELLOW(){ echo -e  "${YELLOW}$1${END}"; }
BLUE() { echo -e  "${BLUE}$1${END}"; }
BAK_DATE=$(date '+%Y%m%d')



function usage()
{
	echo   ""
	RED    "please run this script in backup root directory"
	RED    "Usage:  $0 [operate]"
	echo   "   operate menu:"
	echo   "       config             -----> backup TCE old version config"
	echo   "       component          -----> backup TCE old version component"
	echo   "       k8s_resources      -----> backup TCS old version k8s resources"
	echo   "       images             -----> backup TCE old version container image version"
	echo   ""
}



function backup_config()
{
	YELLOW "backup 360 version config ..."

	if [[ -d  ${config_output} ]]; then
		echo "${output_file} has backup info !!!"
		return 0
	else
		mkdir -p ${config_output}
	fi

	ls -al    ${config_inpt} > ${config_output}/config_link_${BAK_DATE}.bak
	cp -raf   $(ls -l  "${config_inpt}/cc"  |awk  '{print $NF}')  ${config_output}
	cp -raf   ${config_inpt}/self   ${config_output}
	cp -raf   ${config_inpt}/env   ${config_output}
}



function backup_component()
{
	YELLOW "backup 360 version component ..."

	if [[ -d  ${component_output} ]]; then
		echo "${component_output} has backup info !!!"
		return 0
	else
		mkdir -p ${component_output}
	fi

	for  comp_type in $(ls ${component_inpt}); do
		echo "... backup_comp: ${comp_type}"
		mkdir  -p  ${component_output}/${comp_type}

		cp -raf  ${component_inpt}/${comp_type}/modlist.txt   ${component_output}/${comp_type}/
		ls -al   ${component_inpt}/${comp_type}  >  ${component_output}/${comp_type}/${comp_type}_link_${BAK_DATE}.bak

	done
}



function backup_k8s_resources()
{
	YELLOW "backup 360 version k8s resources object "
	echo
	
	
	if [[ -d  ${k8s_resources_output} ]]; then
		echo "${k8s_resources_output} has backup info !!!"
		return 0
	else
		pod_yaml_bak="${k8s_resources_output}/pod_backup/all_pod_yaml_bak"
		mkdir -p  ${pod_yaml_bak}

		svc_list_bak="${k8s_resources_output}/service_backup/all_service.list"
		svc_yaml_bak="${k8s_resources_output}/service_backup/all_service_yaml_bak"
		vpcservice_yaml_bak="${k8s_resources_output}/service_backup/all_vpcservice_yaml_bak"
		mkdir -p  ${svc_list_bak}
		mkdir -p  ${svc_yaml_bak}
		mkdir -p  ${vpcservice_yaml_bak}
		
		serviceinstances_yaml_bak="${k8s_resources_output}/service_brokers_backup/serviceinstances/all_serviceinstances_yaml_bak"
		servicebinding_yaml_bak="${k8s_resources_output}/service_brokers_backup/servicebinding/all_servicebinding_yaml_bak"
		store_secret_yaml_bak="${k8s_resources_output}/service_brokers_backup/store_secret/all_store_secret_yaml_bak"
		tce_secret_yaml_bak="${k8s_resources_output}/service_brokers_backup/tce_secret/all_tce_secret_yaml_bak"
		mkdir -p  ${serviceinstances_yaml_bak}
		mkdir -p  ${servicebinding_yaml_bak}
		mkdir -p  ${store_secret_yaml_bak}
		mkdir -p  ${tce_secret_yaml_bak}

		pajero_backup_info="${k8s_resources_output}/pajero_backup"
		mkdir -p  ${pajero_backup_info}
	fi

	echo
	BLUE "backup 360 version k8s pod resources object start"
	YELLOW  "备份所有pod的yaml文件，此处执行需要一定时间，请耐心等待 ..."
	kubectl  get  pod -A  --no-headers  | awk '{print "kubectl get pod -n "$1, $2, " -o yaml" " > "  "'"$pod_yaml_bak/"'"$1"_"$2".yaml && sleep 1 "}'  | sh
	kubectl  get  pod -A  -owide  --no-headers > ${pod_yaml_bak}/all_pod.list
	BLUE "backup 360 version k8s pod resources object end ^_^"


	echo
	BLUE "backup 360 version k8s service resources object start"
	YELLOW  "备份所有service的yaml文件，此处执行需要一定时间，请耐心等待 ..."
	kubectl  get  svc -A  --no-headers  | awk '{print "kubectl get svc -n "$1, $2, " -o yaml" " > "  "'"$svc_yaml_bak/"'"$1"_"$2".yaml && sleep 1 "}'  | sh
	kubectl  get  vpcservice -A  --no-headers  | awk '{print "kubectl get vpcservice -n "$1, $2, " -o yaml" " > "  "'"$vpcservice_yaml_bak/"'"$1"_"$2".yaml && sleep 1 "}'  | sh
	kubectl  get  svc -A   --no-headers > ${svc_list_bak}/all_ns_svc_360.list
	kubectl  get  vpcservice -A   --no-headers > ${svc_list_bak}/all_ns_vpcservice_360.list
	BLUE "backup 360 version k8s service resources object end ^_^"


	echo
	BLUE "backup 360 version k8s service-brokers  namespaces resources object start"
	YELLOW  "备份所有service-brokers  namespaces下的k8s资源文件，此处执行需要一定时间，请耐心等待 ..."
	kubectl  get  serviceinstances  -A    --no-headers  | awk  '{print "kubectl get serviceinstances -n"$1, $2 " -o yaml"  " > "   "'"$serviceinstances_yaml_bak/serviceinstances_"'"$1"_"$2".yaml && sleep 1 "}' | sh
	kubectl  get  serviceinstances  -ntce --no-headers  > ${serviceinstances_yaml_bak}/../serviceinstances_360.list

	kubectl  get  servicebinding  -A    --no-headers  | awk  '{print "kubectl get servicebinding -n"$1, $2 " -o yaml"  " > "   "'"$servicebinding_yaml_bak/servicebinding_"'"$1"_"$2".yaml && sleep 1 "}' | sh
	kubectl  get  servicebinding  -ntce --no-headers  > ${servicebinding_yaml_bak}/../servicebinding_360.list
	
	kubectl get  secret  -n service-brokers  --no-headers  | awk  '{print "kubectl get  secret  -nservice-brokers "$1 " -o yaml"  " > "  "'"$store_secret_yaml_bak/secret_service-brokers_"'"$1".yaml && sleep 1 "}' | sh
	kubectl get  secret  -n service-brokers    --no-headers  >   ${store_secret_yaml_bak}/../srore_secret_360.list

    kubectl get  secret  -n tce  --no-headers  | awk  '{print "kubectl get  secret  -ntce "$1 " -o yaml"  " > "  "'"$tce_secret_yaml_bak/secret_tce_"'"$1".yaml && sleep 1 "}'| sh
	kubectl get  secret  -n tce    --no-headers  >   ${tce_secret_yaml_bak}/../tce_secret_360.list
	BLUE "backup 360 version k8s service-brokers  namespaces resources object end ^_^"


	echo
	BLUE "backup 360 version pajero info"
	curl -X GET http://127.0.0.1:30150/api/v1alpha1/service/instances | python -m json.tool > ${pajero_backup_info}/tony_pajero.txt
}



function backup_containers_image()
{
	YELLOW "backup 360 version containers image ..."

	if [[ -d  ${container_image_output} ]]; then
		echo "${container_image_output} has backup info !!!"
		return 0
	else
		mkdir -p ${container_image_output}
	fi

	image_backup_file="${container_image_output}/images_${BAK_DATE}.bak"
	kubectl get pods --all-namespaces -o jsonpath="{..image}" |tr -s '[[:space:]]' '\n' | sort -u > ${image_backup_file}
}





function main()
{
	BACKUP_INFO_TYPE=${1}

	case ${BACKUP_INFO_TYPE} in

	config)
		# backup TCE old version config
		backup_config  $*
	;;

	component)
		# backup TCE old version component
		backup_component  $*
	;;

	k8s_resources)
		# backup TCS old version k8s resources
		backup_k8s_resources  $*
	;;

	images)
		# backup TCE old version container image version
		backup_containers_image  $*
	;;

	*)
		usage
		RED "please check your operate cmdline argvs!"
		exit 1
	;;
	esac
}

main $@
