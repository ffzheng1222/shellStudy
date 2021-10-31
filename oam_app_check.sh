# /bin/bash

BLUE='\e[0;34m';GREEN='\e[0;32m';YELLOW='\e[1;33m';RED='\e[1;31m';END='\e[0m'
RED(){ echo -e  "${RED}$1${END}"; }
GREEN(){ echo -e  "${GREEN}$1${END}"; }
YELLOW(){ echo -e  "${YELLOW}$1${END}"; }
BLUE(){ echo -e  "${BLUE}$1${END}"; }
#######################################################################################

APP_LIST="/data1/tony/oam_app_check/oam_app.list"
COMPONENTNAME_LIST="/data1/tony/oam_app_check/oam_componentname.list"
app_uid_file="/data1/tony/oam_app_check/app_uid.txt"
controller_ownerReferences_uid_file="/data1/tony/oam_app_check/controller_ownerReferences_uid.txt"

function get_app_list()
{
    app_yaml_file=${1}
    app_name=${app_yaml_file%.yaml}
    if [[ -z ${1} ]]; then
		kubectl  get app -ntce  | grep '[o|t]cloud-' |awk '{print $1}' > ${APP_LIST}
    else
		echo "check application: ${app_name}"
		kubectl  get app -ntce  | grep "${app_name}" |awk '{print $1}' > ${APP_LIST}
	fi
}

function get_app_componentName_list()
{
	for i in $(cat ${APP_LIST}); do kubectl  get app -ntce ${i}  -o yaml | grep  'workloads:' -A1 ; done  | grep componentName |awk '{print $NF}' > ${COMPONENTNAME_LIST}
}

function check_pod_rebuild()
{
	BLUE "====> check_pod_rebuild start ..."
	for comp_name in $(cat ${COMPONENTNAME_LIST} ); do
		#YELLOW ${comp_name} 
		controller_type=$(kubectl  -ntce get  comp ${comp_name} | grep -v NAME  |awk '{print $2}')
		if [[ "Deployment"x == "${controller_type}"x ]]; then
			GREEN "please check deployment pod ${comp_name} start time ..."
			kubectl  get Deployment -ntce ${comp_name}
			kubectl  get pod -ntce |grep ${comp_name}
		elif [[ "StatefulSet"x == "${controller_type}"x ]]; then
			GREEN "please check statefulset pod ${comp_name} start time ..."
			kubectl  get StatefulSet -ntce ${comp_name}
			kubectl  get pod -ntce |grep ${comp_name}
		fi
		echo
	done
	BLUE "====> check_pod_rebuild end ..."
}

function check_field_uid()
{
	BLUE "====> check_field_uid start ..."
	echo '' > ${app_uid_file}
	echo '' > ${controller_ownerReferences_uid_file}
	GREEN "get all application uid:"
	for app_name in  $(cat ${APP_LIST}) ; do
		application_uid=$(kubectl get  app -ntce ${app_name} -o yaml | grep 'uid:' | sed 's/ //g')
		echo ${application_uid}
		kubectl get  app -ntce ${app_name} -o yaml | grep 'uid:' | sed 's/ //g' >> ${app_uid_file}
	done

	GREEN "get all app_comp_controller uid:"
	for controller_app_name in  $(cat ${COMPONENTNAME_LIST}) ; do
		controller_type=$(kubectl  -ntce get comp ${controller_app_name} | grep -v NAME  |awk '{print $2}')
		if [[ "Deployment"x == "${controller_type}"x ]]; then
			ctr_deply_uid=$(kubectl get Deployment -ntce ${controller_app_name} -o yaml  |grep 'ownerReferences:' -A7 |grep  'uid:' | sed 's/ //g')
			echo ${ctr_deply_uid}
			kubectl get Deployment -ntce ${controller_app_name} -o yaml  |grep 'ownerReferences:' -A7 |grep  'uid:' | sed 's/ //g' >> ${controller_ownerReferences_uid_file}
		elif [[ "StatefulSet"x == "${controller_type}"x ]]; then
			ctr_statefulset_uid=$(kubectl get StatefulSet -ntce ${controller_app_name} -o yaml  |grep 'ownerReferences:' -A7 |grep 'uid:' | sed 's/ //g')
			echo ${ctr_statefulset_uid}
			kubectl get StatefulSet -ntce ${controller_app_name} -o yaml  |grep 'ownerReferences:' -A7 |grep 'uid:' | sed 's/ //g' >> ${controller_ownerReferences_uid_file}
		fi
	done

	YELLOW "please check app_uid.txt and controller_ownerReferences_uid.txt diff ..."
	diff_info=$(diff ${app_uid_file} ${controller_ownerReferences_uid_file})
	if [[ -s ${diff_info} ]]; then
		RED "Field uid check failed @_@"
	else
		GREEN "Field uid check ok ^_^"
	fi
	BLUE "====> check_field_uid end ..."
}

function main()
{
    mkdir -p /data1/tony/oam_app_check
	get_app_list $*
	get_app_componentName_list
	check_pod_rebuild
	check_field_uid
}

main $@

