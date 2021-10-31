#! /bin/bash



SSM_ROOT_PATH="/data1/ssm_sb_user_passwd"
SUPPORT_ROOT_PATH=""

OLD_TCE_SECRET_FLODER="/data/upgrade/ssm/binding_secret_backup/ssm-backup-20210615173035"

SAVE_OLD_SECRET_DECODE_FILE=""
SAVE_OLD_SB_PARAMETERS_FILE=""
SAVE_NEW_SECRET_DECODE_FILE=""
SAVE_NEW_SB_PARAMETERS_FILE=""


source ${SSM_ROOT_PATH}/shell_color_show.sh


function test_secret_to_mysql()
{
	MYSQL_HOST=${1}
	MYSQL_USER=${2}
	MYSQL_PASSWORD=${3}
	MYSQL_PORT=${4}
	TCE_VERION=${5}
	
	mysql -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -P"${MYSQL_PORT}" -e "show status;" >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		GREEN "${TCE_VERION}: mysql -h\"${MYSQL_HOST}\" -u\"${MYSQL_USER}\" -p\"${MYSQL_PASSWORD}\" -P\"${MYSQL_PORT}\" is ok ^_^" 
	else
		RED "${TCE_VERION}: mysql -h\"${MYSQL_HOST}\" -u\"${MYSQL_USER}\" -p\"${MYSQL_PASSWORD}\" -P\"${MYSQL_PORT}\" is failed T_T" 
	fi
}


function test_secret_to_ckv()
{
	REDIS_HOST=${1}
	REDIS_PORT=${2}
	REDIS_USER=${3}
	REDIS_PASSWORD=${4}
	TCE_VERION=${5}
	#./redis-cli -h ckv-amp.yinlian.tcecqpoc.fsphere.cn  -p 12002   --raw  auth redis-amp:redis
	${SSM_ROOT_PATH}/redis-cli -h ${REDIS_HOST} -p ${REDIS_PORT} --raw  auth  ${REDIS_USER}:${REDIS_PASSWORD} >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		GREEN "${TCE_VERION}: redis-cli -h ${REDIS_HOST} -p ${REDIS_PORT} --raw  auth  ${REDIS_USER}:${REDIS_PASSWORD} is ok ^_^" 
	else
		RED "${TCE_VERION}: redis-cli -h ${REDIS_HOST} -p ${REDIS_PORT} --raw  auth  ${REDIS_USER}:${REDIS_PASSWORD} is failed T_T" 
	fi
}


function test_secret_to_mongodb()
{
	MONGODB_USER=${1}
	MONGODB_PASSWORD=${2}
	MONGODB_PORT=${3}
	MONGODB_DBNAME=${4}
	TCE_VERION=${5}
	# kubectl -n sso exec -it `kubectl -n sso get po  |grep mongo | grep -E 'mongos' |head -n 1 |awk '{print $1}'`  -c mongo  --  /usr/bin/mongo   -ub922auyh  -p9ctofxitqe0a  --port 27017  --authenticationDatabase=txscanner  --eval "db.stats()"


	kubectl -n sso exec -it `kubectl -n sso get po  |grep mongo | grep -E 'mongos' |head -n 1 |awk '{print $1}'`  -c mongo  --  /usr/bin/mongo -u${MONGODB_USER}  -p${MONGODB_PASSWORD}  --port ${MONGODB_PORT}  --authenticationDatabase=${MONGODB_DBNAME}  --eval "db.stats()" >/dev/null 2>&1
	
	if [ $? -eq 0 ]; then
		GREEN "${TCE_VERION}: mongo -u${MONGODB_USER}  -p${MONGODB_PASSWORD}  --port ${MONGODB_PORT}  --authenticationDatabase=${MONGODB_DBNAME} is ok ^_^" 
	else
		RED "${TCE_VERION}: mongo -u${MONGODB_USER}  -p${MONGODB_PASSWORD}  --port ${MONGODB_PORT}  --authenticationDatabase=${MONGODB_DBNAME} is failed T_T" 
	fi
}


function test_secret_to_rabbitmq()
{
	RABBITMQ_USER=${1}
	IS_PHY_RABBITMQ=${2}
	TCE_VERION=${3}

	if [[ ${IS_PHY_RABBITMQ} == "true" ]]; then
		phy_rabbitmq_node=$(kubectl  get svc -nsso |grep mq  |grep phy |awk '{print "kubectl  get svc -nsso " $1 " -o yaml"}' | sh | grep end | awk -F',' '{print $2}')
		dptool   cmd  "rabbitmqctl list_users | grep ${RABBITMQ_USER}"  ${phy_rabbitmq_node}
		if [ $? -eq 0 ]; then
			GREEN "phy: ${TCE_VERION}: rabbitmqctl user ${RABBITMQ_USER} is ok ^_^" 
		else
			RED "phy: ${TCE_VERION}: rabbitmqctl user ${RABBITMQ_USER} is failed T_T" 
		fi
	else
		kubectl exec -ti -nsso  `kubectl  get pod -nsso | grep -v exporter |grep mq -w | head -n1 |awk '{print $1}'` -c rabbitmq  -- rabbitmqctl  list_users | grep ${RABBITMQ_USER}
		if [ $? -eq 0 ]; then
			GREEN "pod: ${TCE_VERION}: rabbitmqctl user ${RABBITMQ_USER} is ok ^_^"
		else
			RED "pod: ${TCE_VERION}: rabbitmqctl user ${RABBITMQ_USER} is failed T_T" 
		fi
	fi
}





function get_360_tce_secret()
{
	ssm_instance_type=${1}


	cat /dev/null > ${SAVE_OLD_SECRET_DECODE_FILE}
	
	for secret_name in `ls ${OLD_TCE_SECRET_FLODER} | grep "^secret\.tce-${ssm_instance_type}" | sort` ; do

		echo "get 360 tce secret: ${secret_name}"
		echo ${secret_name} | awk -F'tce-' '{print $NF}' | awk -F'.' '{print $1}' >> ${SAVE_OLD_SECRET_DECODE_FILE}
		old_tce_secret_host=$(cat ${OLD_TCE_SECRET_FLODER}/${secret_name}  |grep -w 'host:' | awk '{print $2}')
		old_tce_secret_user=$(cat ${OLD_TCE_SECRET_FLODER}/${secret_name}  |grep -w 'user:' | awk '{print $2}') 
		old_tce_secret_pass=$(cat ${OLD_TCE_SECRET_FLODER}/${secret_name}  |grep -w 'pass:' | awk '{print $2}')
		old_tce_secret_port=$(cat ${OLD_TCE_SECRET_FLODER}/${secret_name}  |grep -w 'port:' | awk '{print $2}')

		# decode secret user pass
		decode_old_tce_secret_host=$(echo "${old_tce_secret_host}" | base64 -d)
		decode_old_tce_secret_user=$(echo "${old_tce_secret_user}" | base64 -d)
		decode_old_tce_secret_pass=$(echo "${old_tce_secret_pass}" | base64 -d)
		decode_old_tce_secret_port=$(echo "${old_tce_secret_port}" | base64 -d)
		echo "user:${decode_old_tce_secret_user}  pass:${decode_old_tce_secret_pass}" >> ${SAVE_OLD_SECRET_DECODE_FILE}

		if [[ ${ssm_instance_type} == "dbsql" ]]; then
			test_secret_to_mysql ${decode_old_tce_secret_host} ${decode_old_tce_secret_user} ${decode_old_tce_secret_pass} ${decode_old_tce_secret_port}  "360"

		elif [[ ${ssm_instance_type} == "ckv" ]]; then
			test_secret_to_ckv  ${decode_old_tce_secret_host} ${decode_old_tce_secret_port} ${decode_old_tce_secret_user} ${decode_old_tce_secret_pass}  "360"

		elif [[ ${ssm_instance_type} == "mongodb" ]]; then
			old_tce_secret_dbname=$(cat ${OLD_TCE_SECRET_FLODER}/${secret_name}  |grep -w 'db_name:' | awk '{print $2}')
			decode_old_tce_secret_dbname=$(echo "${old_tce_secret_dbname}" | base64 -d)
			test_secret_to_mongodb ${decode_old_tce_secret_user} ${decode_old_tce_secret_pass} ${decode_old_tce_secret_port} ${decode_old_tce_secret_dbname}  "360"

		elif [[ ${ssm_instance_type} == "mq" ]]; then
			old_tce_secret_nodelist=$(cat ${OLD_TCE_SECRET_FLODER}/${secret_name}  |grep -w 'node_list:' | awk '{print $2}')
			decode_old_tce_secret_nodelist=$(echo "${old_tce_secret_nodelist}" | base64 -d)
			is_phy_or_conrainer=$(echo ${decode_old_tce_secret_nodelist} | grep  '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*')
			if [[ ! -z ${is_phy_or_conrainer} ]]; then
				# use phy rabbitmq
				test_secret_to_rabbitmq  ${decode_old_tce_secret_user}  "true"  "360"
			else
				# use conrainer rabbitmq
				test_secret_to_rabbitmq  ${decode_old_tce_secret_user}  "false" "360"
			fi
			
		fi
	done
}


function get_360_sb_parameters()
{
	sb_type=${1}
	sb_tmp_file="/tmp/360_sb.txt"
	kubectl  get  servicebindings.servicecatalog.k8s.io  -ntce | grep "^${sb_type}" | awk '{print $1}' | sort > ${sb_tmp_file}


	cat /dev/null > ${SAVE_OLD_SB_PARAMETERS_FILE}

	while read sb_line; do
		echo "get 360 sb parameters: ${sb_line}"
		echo ${sb_line} >> ${SAVE_OLD_SB_PARAMETERS_FILE}
		sb_parameters_user=$(kubectl  get  servicebindings.servicecatalog.k8s.io -ntce ${sb_line} -o json | jq -r  .spec.parameters.user )
		sb_parameters_pass=$(kubectl  get  servicebindings.servicecatalog.k8s.io -ntce ${sb_line} -o json | jq -r  .spec.parameters.password )

		echo "user:${sb_parameters_user}  pass:${sb_parameters_pass}" >> ${SAVE_OLD_SB_PARAMETERS_FILE}
		sleep 0.5

	done < ${sb_tmp_file}

}


function get_380_tce_secret()
{
	ssm_instance_type=${1}
	secret_tmp_file="/tmp/380_tce_secret.txt"
	kubectl  get  secret  -ntce | grep "^${ssm_instance_type}" |awk '{print $1}' | sort > ${secret_tmp_file}

	cat /dev/null > ${SAVE_NEW_SECRET_DECODE_FILE}

	for secret_line in $(cat ${secret_tmp_file}); do
		echo "get 380 tce secret: ${secret_line}"
		echo ${secret_line} >> ${SAVE_NEW_SECRET_DECODE_FILE}
		new_tce_secret_host=$(kubectl  get  secret  -ntce ${secret_line}  -o json | jq -r .data.host)
		new_tce_secret_user=$(kubectl  get  secret  -ntce ${secret_line}  -o json | jq -r .data.user)
		new_tce_secret_pass=$(kubectl  get  secret  -ntce ${secret_line}  -o json | jq -r .data.pass)
		new_tce_secret_port=$(kubectl  get  secret  -ntce ${secret_line}  -o json | jq -r .data.port)

		decode_new_tce_secret_host=$(echo "${new_tce_secret_host}" | base64 -d)
		decode_new_tce_secret_user=$(echo "${new_tce_secret_user}" | base64 -d)
		decode_new_tce_secret_pass=$(echo "${new_tce_secret_pass}" | base64 -d)
		decode_new_tce_secret_port=$(echo "${new_tce_secret_port}" | base64 -d)
		echo "user:${decode_new_tce_secret_user}  pass:${decode_new_tce_secret_pass}" >> ${SAVE_NEW_SECRET_DECODE_FILE}


		if [[ ${ssm_instance_type} == "dbsql" ]]; then
			test_secret_to_mysql ${decode_new_tce_secret_host} ${decode_new_tce_secret_user} ${decode_new_tce_secret_pass} ${decode_new_tce_secret_port}  "380"

		elif [[ ${ssm_instance_type} == "ckv" ]]; then
			test_secret_to_ckv  ${decode_new_tce_secret_host} ${decode_new_tce_secret_port} ${decode_new_tce_secret_user} ${decode_new_tce_secret_pass}  "380"

		elif [[ ${ssm_instance_type} == "mongodb" ]]; then
			new_tce_secret_dbname=$(kubectl  get  secret  -ntce  ${secret_line} -o json | jq -r .data.db_name)
			decode_new_tce_secret_dbname=$(echo "${new_tce_secret_dbname}" | base64 -d)
			if [[ ! -z ${decode_new_tce_secret_dbname} ]]; then
				test_secret_to_mongodb ${decode_new_tce_secret_user} ${decode_new_tce_secret_pass} ${decode_new_tce_secret_port} ${decode_new_tce_secret_dbname} "380"
			fi

		elif [[ ${ssm_instance_type} == "mq" ]]; then
			new_tce_secret_nodelist=$(kubectl  get  secret  -ntce  ${secret_line}  -o json | jq -r .data.nodeList)
			decode_new_tce_secret_nodelist=$(echo "${new_tce_secret_nodelist}" | base64 -d)
			is_phy_or_conrainer=$(echo ${decode_new_tce_secret_nodelist} | grep  '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*')
			if [[ ! -z ${is_phy_or_conrainer} ]]; then
				# use phy rabbitmq
				test_secret_to_rabbitmq  ${decode_new_tce_secret_user}  "true"  "380"
			else
				# use conrainer rabbitmq
				test_secret_to_rabbitmq  ${decode_new_tce_secret_user}  "false" "380"
			fi
		fi

	done < ${secret_tmp_file}
}


function get_380_sb_parameters()
{
	sb_type=${1}
	sb_tmp_file="/tmp/380_sb.txt"
	kubectl  get  sb  -ntce | grep "^${sb_type}" | awk '{print $1}' | sort > ${sb_tmp_file}


	cat /dev/null > ${SAVE_NEW_SB_PARAMETERS_FILE}

	while read sb_line; do
		echo "get 380 sb parameters: ${sb_line}"
		echo ${sb_line} >> ${SAVE_NEW_SB_PARAMETERS_FILE}
		sb_parameters_user=$(kubectl  get  sb -ntce ${sb_line} -o json | jq -r  .spec.parameters.user )
		sb_parameters_pass=$(kubectl  get  sb -ntce ${sb_line} -o json | jq -r  .spec.parameters.password )

		echo "user:${sb_parameters_user}  pass:${sb_parameters_pass}" >> ${SAVE_NEW_SB_PARAMETERS_FILE}
		sleep 0.5

	done < ${sb_tmp_file}
}



function get_sb_secret_info()
{
	# get old secret user pass
	echo
	echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	get_360_tce_secret  $*
	
	# get old servicebinding parameters
	echo
	echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	get_360_sb_parameters  $*
	
	# get new secret user pass
	echo
	echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	get_380_tce_secret  $*

	# get new secret user pass
	echo
	echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	get_380_sb_parameters  $*
}


function create_support_floder()
{
	floder_name=${1}
	if [[ -d ${SSM_ROOT_PATH}/${floder_name} ]]; then
		cd ${SSM_ROOT_PATH}
		rm -rf ${floder_name}
		mkdir -p ${SSM_ROOT_PATH}/${floder_name}
		cd -
	else
		mkdir -p ${SSM_ROOT_PATH}/${floder_name}
	fi
	SUPPORT_ROOT_PATH=${SSM_ROOT_PATH}/${floder_name}
}


function set_support_env_root_path()
{
	SAVE_OLD_SECRET_DECODE_FILE="${SUPPORT_ROOT_PATH}/360_tce_secret.txt"
	SAVE_OLD_SB_PARAMETERS_FILE="${SUPPORT_ROOT_PATH}/360_sb_parameters.txt"

	SAVE_NEW_SECRET_DECODE_FILE="${SUPPORT_ROOT_PATH}/380_tce_secret.txt"
	SAVE_NEW_SB_PARAMETERS_FILE="${SUPPORT_ROOT_PATH}/380_sb_parameters.txt"
}


function main()
{
	SUPPORT_INSTANCE_TYPE=${1}

	case ${SUPPORT_INSTANCE_TYPE} in

	dbsql)
		echo "get dbsql tce secret ..."
		create_support_floder 	"dbsql"
		set_support_env_root_path
		get_sb_secret_info  "dbsql"
	;;
	credis)
		echo "get credis tce secret ..."
		create_support_floder 	"credis"
		set_support_env_root_path
		get_sb_secret_info  "ckv"
	;;
	mongoDB)
		create_support_floder 	"mongoDB"
		set_support_env_root_path
		get_sb_secret_info  "mongodb"
		echo "get mongoDB tce secret ..."
	;;
	rabbitmq)
		create_support_floder 	"rabbitmq"
		set_support_env_root_path
		get_sb_secret_info  "mq"
		echo "get rabbitmq tce secret ..."
	;;
	*)
		#usage
		echo "please check your cmdline argvs!"
		exit 1
	;;
	esac
}


main $@