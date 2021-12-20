#! /bin/bash


# configuration color show ...
GREEN='\e[0;32m'; YELLOW='\e[1;33m'; RED='\e[1;31m'; BLUE='\e[0;34m'; END='\e[0m';
RED(){ echo -e  "${RED}$1${END}"; }
GREEN(){ echo -e  "${GREEN}$1${END}"; }
YELLOW(){ echo -e  "${YELLOW}$1${END}"; }
BLUE() { echo -e  "${BLUE}$1${END}"; }



DOCKER_CONTAINER_IDS=""
NODE_PASSWORD="Tcdn@2007"

function get_docker_container_id()
{
	pod_name=${1}
	pod_node_ip=${2}
	
	dcids_str=$(sshpass -p "${NODE_PASSWORD}" ssh -oStrictHostKeyChecking=no  ${pod_node_ip}  "docker ps -a |grep   ${pod_name}  | grep -v pause " | awk '{print $1}')
	
	dcids=($(echo "${dcids_str}"))
	for ((i = 0; i < ${#dcids[@]}; i++)); do
		docker_container_id=${dcids[i]}
		YELLOW "node: ${pod_node_ip}  ----  docker_container_id: ${docker_container_id}"
		DOCKER_CONTAINER_IDS="${DOCKER_CONTAINER_IDS} ${docker_container_id}"

		((i=${i}+1))
	done
	GREEN "node: ${pod_node_ip}  ----  DOCKER_CONTAINER_IDS：${DOCKER_CONTAINER_IDS}"
}



function show_docker_inspect()
{
	pod_name=${1}
	pod_node_ip=${2}

	pod_docker_container_ids=($(echo ${DOCKER_CONTAINER_IDS}))
	for ((i = 0; i < ${#pod_docker_container_ids[@]}; i++)); do
		pod_docker_container_id=${pod_docker_container_ids[i]}
		
		YELLOW "sshpass -p "${NODE_PASSWORD}" ssh -oStrictHostKeyChecking=no  ${pod_node_ip} \"docker inspect ${pod_docker_container_id} | python -m json.tool\" "
		sshpass -p "${NODE_PASSWORD}" ssh -oStrictHostKeyChecking=no  ${pod_node_ip} "docker inspect ${pod_docker_container_id} | python -m json.tool" 
		
		((i=${i}+1))
		echo
	done
}



function main()
{
	#####################################################
	##  ${1}: pod name
	##	${2}: pod 所在的node节点
	#####################################################
	pod_name=${1}
	pod_node_ip=${2}

	get_docker_container_id  ${pod_name}  ${pod_node_ip}
	show_docker_inspect      ${pod_name}  ${pod_node_ip}
}


main $@


