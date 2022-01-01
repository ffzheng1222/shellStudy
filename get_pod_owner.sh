#! /bin/bsh



# configuration color show ...
GREEN='\e[0;32m'; YELLOW='\e[1;33m'; RED='\e[1;31m'; BLUE='\e[0;34m'; END='\e[0m';
RED(){ echo -e  "${RED}$1${END}"; }
GREEN(){ echo -e  "${GREEN}$1${END}"; }
YELLOW(){ echo -e  "${YELLOW}$1${END}"; }
BLUE() { echo -e  "${BLUE}$1${END}"; }



POD_NAMESPACES="tce"


function get_pod_owner_owner()
{
	pod_owner_kind=${1}
	pod_owner_name=${2}

	k8s_resources=$(kubectl -n ${POD_NAMESPACES} get  ${pod_owner_kind} ${pod_owner_name} -o json | jq -r .metadata.ownerReferences)
	
	if [[ ${k8s_resources} != "null" ]]; then
		k8s_resources_kind=$(kubectl -n ${POD_NAMESPACES} get ${pod_owner_kind} ${pod_owner_name} -o  json | jq -r  .metadata.ownerReferences[].kind)
		k8s_resources_name=$(kubectl -n ${POD_NAMESPACES} get ${pod_owner_kind} ${pod_owner_name} -o  json | jq -r  .metadata.ownerReferences[].name)
	
		BLUE "Action: kubectl -n ${POD_NAMESPACES}   get   ${pod_owner_kind}   ${pod_owner_name}"
		YELLOW "owner info  -->  kind: ${k8s_resources_kind}  name: ${k8s_resources_name}"
		echo

		${FUNCNAME}  ${k8s_resources_kind}   ${k8s_resources_name}
	else
		BLUE "Action: kubectl -n ${POD_NAMESPACES}   get   components   ${k8s_resources_name}"
		YELLOW "owner info  -->  kind: components  name: ${k8s_resources_name}"
		echo
		
		RED "is top resources ^_^"
		exit 0
	fi
}



function get_pod_owner()
{
	pod_name=${1}
	
	k8s_resources=$(kubectl  -n ${POD_NAMESPACES} get  pod   ${pod_name} -o json | jq -r .metadata.ownerReferences)
	
	if [[ -n ${k8s_resources} ]]; then
		pod_owner_kind=$(kubectl -n ${POD_NAMESPACES} get  pod   ${pod_name} -o json | jq -r .metadata.ownerReferences[].kind)
		pod_owner_name=$(kubectl -n ${POD_NAMESPACES} get  pod   ${pod_name} -o json | jq -r .metadata.ownerReferences[].name)

		BLUE "Action: kubectl -n ${POD_NAMESPACES}   get   pod   ${pod_owner_name}"
		YELLOW "owner info  -->  kind: ${pod_owner_kind}  name: ${pod_owner_name}"
		echo

		${FUNCNAME}_owner  ${pod_owner_kind}   ${pod_owner_name}
	else
		RED "is top resources ^_^"
		exit 0
	fi
}



function main()
{
	# ${1} --> pod name
	get_pod_owner  ${1}
}



main $@
