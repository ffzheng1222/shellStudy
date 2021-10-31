#! /bin/bash


# configuration color show ...
GREEN='\e[0;32m'; YELLOW='\e[1;33m'; RED='\e[1;31m'; BLUE='\e[0;34m'; END='\e[0m';
RED(){ echo -e  "${RED}$1${END}"; }
GREEN(){ echo -e  "${GREEN}$1${END}"; }
YELLOW(){ echo -e  "${YELLOW}$1${END}"; }
BLUE() { echo -e  "${BLUE}$1${END}"; }



PAJERO_SERVICEID=""


SAVE_STORE_SECRET_TMP_FILE="/data1/tony/pajero_info/save_store_secret_tmp_file.txt"
SAVE_SB_TCE_SECRET_TMP_FILE="/data1/tony/pajero_info/save_sb_tce_secret_tmp_file.txt"
SAVE_SECRET_PAJERO_DATA_TMP_FILE="/data1/tony/pajero_info/save_secret_pajero_data_tmp_file.txt"



function print_4_tuple_for_pajero_data()
{
	one_record_data=${1}

	data_tuple_region=$(echo ${one_record_data} | jq -r  |grep '"region":' | sed 's/"//g' |sed 's/,//g' |awk '{print $NF}')
	data_tuple_serviceID=$(echo ${one_record_data} | jq -r  |grep '"serviceID":' | sed 's/"//g' |sed 's/,//g' |awk '{print $NF}')
	data_tuple_underlay=$(echo ${one_record_data} | jq -r  |grep '"underlay":' | sed 's/"//g' |sed 's/,//g' |awk '{print $NF}')
	data_tuple_zone=$(echo ${one_record_data} | jq -r  |grep '"zone":' | sed 's/"//g' |sed 's/,//g' |awk '{print $NF}')
	
	BLUE "region: ${data_tuple_region}"
	BLUE "serviceID: ${data_tuple_serviceID}"
	BLUE "underlay: ${data_tuple_underlay}"
	BLUE "zone: ${data_tuple_zone}"
	echo
}



function get_pajero_record_num()
{
	record_num=0

	while true; do 
		record_data_serviceID=$(curl --silent -X GET http://127.0.0.1:30150/api/v1alpha1/service/instances?serviceID=${PAJERO_SERVICEID} | jq ".[${record_num}]" |grep ${PAJERO_SERVICEID} )
		
		if [[ -z ${record_data_serviceID} ]]; then
			YELLOW "****** >> ${PAJERO_SERVICEID}: pajero_record_num: ${record_num}"
			return
		else
			record_data=$(curl --silent -X GET http://127.0.0.1:30150/api/v1alpha1/service/instances?serviceID=${PAJERO_SERVICEID} | jq ".[${record_num}]" )
			print_4_tuple_for_pajero_data  "${record_data}"
		fi
		record_num=$((${record_num}+1))
	done
}



function check_pajero_data()
{
	curr_sb_tce_secret=${1}


	PAJERO_SERVICEID=$(kubectl  get secret  -n tce  ${curr_sb_tce_secret}   -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}} {{end}}{{"\n"}}{{end}}' |grep  __service_id__  |awk '{print $NF}')
	#echo "... check_pajero_data: ${PAJERO_SERVICEID}"
	
	curl --silent -X GET http://127.0.0.1:30150/api/v1alpha1/service/instances?serviceID=${PAJERO_SERVICEID} | python -m json.tool  >> ${SAVE_SECRET_PAJERO_DATA_TMP_FILE}

	get_pajero_record_num ${PAJERO_SERVICEID}
}



function show_sb_tce_secret_decode()
{
	echo
	GREEN "###### >> ${1}"
	
	kubectl  get secret  -n tce  ${1}   -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}} {{end}}{{"\n"}}{{end}}'  >>  ${SAVE_SB_TCE_SECRET_TMP_FILE}
}



function show_store_secret_decode()
{
	curr_store_secret=${1}
	
	echo
	GREEN "====== >> ${curr_store_secret}"

	kubectl  get  secret   -n ssm  ${curr_store_secret}   -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}} {{end}}{{"\n"}}{{end}}' >>  ${SAVE_STORE_SECRET_TMP_FILE}
}



function main()
{
	store_secret_arrays=($(kubectl   get secret   -n ssm  | egrep   "i-ces|i-credis|i-zoo|i-tdsql|i-kafka|i-mongo|i-rabbitmq" | awk '{print $1}'))

	cat /dev/null > ${SAVE_STORE_SECRET_TMP_FILE}
	for ((i = 0; i < ${#store_secret_arrays[@]}; i++)); do
		store_secret=${store_secret_arrays[i]}

		show_store_secret_decode  ${store_secret}
	done



	sb_tce_secret_arrars=($(kubectl  get   secret   -ntce   --no-headers   |awk '{print $1}'))
	cat /dev/null > ${SAVE_SB_TCE_SECRET_TMP_FILE}
	cat /dev/null > ${SAVE_SECRET_PAJERO_DATA_TMP_FILE}
	
	for ((j = 0; j < ${#sb_tce_secret_arrars[@]}; j++)); do
		sb_tce_secret=${sb_tce_secret_arrars[j]}

		show_sb_tce_secret_decode  ${sb_tce_secret}
		check_pajero_data  ${sb_tce_secret}
	done
}


main $@
