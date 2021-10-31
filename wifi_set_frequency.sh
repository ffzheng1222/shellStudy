#! /system/bin/sh
#################################################################
#
# wifi_set_frequency.sh   
#  	wifi frequency set...
#
#   wifi定频设置
###############################################################



BLUE='\e[0;34m'
YELLOW='\e[1;33m'
RED='\e[1;31m'
END='\e[0m'
RED()
{
	echo -e  "${RED}$1${END}"
}

BLUE()
{
	echo -e  "${BLUE}$1${END}"
}

YELLOW()
{
    echo -e  "${YELLOW}$1${END}"
}

Eecho()
{
    #echo -e  "${Eecho}$1${END}"
}




#android 版本
ANDROID_SDK_VERSION=""

#识别的U盘路径
SDMC_UDISK_PATH=""
#U盘中wifi定频工具压缩包原文件
SRC_RFTESTTOOL_ZIP=""



#wifi定频工具包压缩文件名
RFTESTTOOL_NAME="rftesttool"
#存储于盒子/data路径中的rftesttool工具
DATA_RFTESTTOOL="/data/rftesttool"



SDMC_WIFI_CONFIG="android_sdmc"
####################################################################################
#			sdmc wifi 定频的配置文件默认值
#rftesttool工具中sdmc定频专用压缩tools 
RFTESTTOOL_SDMC_TOOL="sdmc_package_tools.zip"
#rftesttool工具中的使用的wl工具
RFTESTTOOL_WL_TOOL="wl"
#rftesttool工具中的测试apk工具
RFTESTTOOL_APK_TOOL="RFTestTool-user-5.8.apk"
#####################################################################################



#保存被识别的wifi模组
WIFI_MODULE=""
#保存加载的wifi & bt固件
LOAD_WIFI_FW=""
LOAD_BT_FW=""
#保存wifi相关信息的文本文件wifi_module_info.txt
WIFI_MODULE_INFO="/sdcard/wifi_module_info.txt"





#############################################################################
#	根据当前加载的wifi固件精确辨别wifi模组
#	返回值：当前加载的wifi模组名
#############################################################################
function get_wifi_module()
{
	case $1 in

	fw_bcm43436b0.bin)
		echo "6236"
		return 0
		;;

	fw_bcm43455c0_ag.bin)
		echo "6255"
		return 0
		;;

	fw_bcm4356a2_ag.bin)
		echo "6356"
		return 0
		;;
	fw_bcm4359c0_ag.bin)	
		echo "6398"
		return 0
		;;
	*)
		RED "current load wifi fw is not brcm!!!  ($LINENO)"
		exit 1
		;;
	esac
}


#############################################################################
#	根据logcat精确查找当前加载的BT固件
#	返回值：当前加载的bluetooth固件路径
#############################################################################
function get_bt_fw_path()
{
	local SDCARD_BT_LOG="/sdcard/bt_logcat.log"
	logcat -c ; logcat -c
	#close bt service
	service call bluetooth_manager 8 >/dev/null
	sleep 1
	#open bt service
	service call bluetooth_manager 6 >/dev/null

	#此处可能会有问题,隐藏的BUG(logcat中不一定能显示bluetooth加载固件)
	cat /dev/null > ${SDCARD_BT_LOG}
	logcat -v time > ${SDCARD_BT_LOG} &
	sleep 2
	killall logcat
	bluetooth_fw_log=$(cat ${SDCARD_BT_LOG} | grep "Found patchfile")
	#Eecho "${bluetooth_fw_log}  ($LINENO)"

	bluetooth_fw_path=$(echo "${bluetooth_fw_log}" | awk '{print $NF}')
	echo "$bluetooth_fw_path"
}



function md5sum_check_copy()
{
	md_sum1=$(md5sum  $1 | awk '{print $1}')
	md_sum2=$(md5sum  $2 | awk '{print $1}')

	if [[ "${md_sum1}" == "${md_sum2}" ]]; then
		BLUE "md5sum_check_copy: $1 copy success!  ($LINENO)"
	else
		RED "md5sum_check_copy: $1 copy FAILED!!!  ($LINENO)"
		exit 1
	fi
}



#############################################################################
#	检测U盘的插入与否, 并且U盘中是否wifi定频工具
#############################################################################
function check_udisk_wifi_freq_tool()
{
	udisk_name=$(ls /storage/ | grep -v "emulated" | grep -v "self")
	SDMC_UDISK_PATH="/storage/$udisk_name"
	Eecho ${SDMC_UDISK_PATH}

	wifi_freq_tool=$(find ${SDMC_UDISK_PATH} -name "${RFTESTTOOL_NAME}*.zip")
	if [[ ! -z ${wifi_freq_tool} ]]; then
		BLUE "wifi frequency tools: ${wifi_freq_tool}  ($LINENO)"
		SRC_RFTESTTOOL_ZIP=${wifi_freq_tool}
	else
		RED "wifi frequency tools is not exits!!!  ($LINENO)"
		exit 1
	fi


	# SRC_RFTESTTOOL_ZIP存放待解压的wifi定频工具
	# DATA_RFTESTTOOL存放解压之后/data里面的wifi定频工具
	if [[ -d ${DATA_RFTESTTOOL} ]]; then
		BLUE "${DATA_RFTESTTOOL}: wifi frequency tools is exits!  ($LINENO)"
		SRC_RFTESTTOOL_ZIP=""
		echo ""
	elif [[ ! -z ${SRC_RFTESTTOOL_ZIP} ]]; then
		BLUE "${SRC_RFTESTTOOL_ZIP}: wifi frequency tools check success!  ($LINENO)"
	else
		RED "wifi frequency tools check FAILED!!!  ($LINENO)"
		exit 1
	fi
}



#############################################################################
#	解压U盘中的wifi定频工具到/data/rftesttool
#	@参数1：需要解压到的目的地
#	@参数2：DATA_RFTESTTOOL(wifi定频工具包解压后的存放路径)
#############################################################################
function unzip_wifi_freq_tool()
{
	if [[ "${1}" == "data" ]]; then
		unzip -d /${1}/ ${SRC_RFTESTTOOL_ZIP} > /dev/null
		mv /${1}/${RFTESTTOOL_NAME}*  $2
		BLUE "$2 move success!  ($LINENO)"
		echo "unzip_wifi_freq_tool: unzip wifi tools to /${1} success!  ($LINENO)"
		echo ""

	elif [[ "${1}" == "sdcard" ]]; then
		udisk_wifi_freq_tool=$(find ${SDMC_UDISK_PATH} -name "${RFTESTTOOL_NAME}*.zip")
		if [ ! -z ${udisk_wifi_freq_tool} ]; then
			unzip -o ${udisk_wifi_freq_tool} -d "/${1}/" > /dev/null
		fi
	fi
}




function parse_txt()
{
	if [[ ! -z $1 ]]; then
		RFTESTTOOL_WL_TOOL=$(cat $1 | grep "RFTESTTOOL_WL_TOOL" | cut -d '=' -f 2)
		echo "parse_txt: ${1} || ${RFTESTTOOL_WL_TOOL}  ($LINENO)"
		RFTESTTOOL_APK_TOOL=$(cat $1 | grep "RFTESTTOOL_APK_TOOL" | cut -d '=' -f 2)
		echo "parse_txt: ${1} || ${RFTESTTOOL_APK_TOOL}  ($LINENO)"
		RFTESTTOOL_SDMC_TOOL=$(cat $1 | grep "RFTESTTOOL_SDMC_TOOL" | cut -d '=' -f 2)
		echo "parse_txt: ${1} || ${RFTESTTOOL_SDMC_TOOL}  ($LINENO)"
	else
		RED "parse_txt: sdmc wifi frequency config file is not exist!!! ($LINENO)"
		exit 1
	fi
}




#############################################################################
#	解析sdmc wifi定频针对不同android版本的配置文件
#	返回值：当前加载的wifi模组名
#############################################################################
function parse_sdmc_config()
{
	if [[ -d  "${1}/${SDMC_WIFI_CONFIG}" ]]; then
		#不同android版本的wifi 定频配置文件解析
		if [[ ${ANDROID_SDK_VERSION} -eq 25 ]]; then
			sdmc_wifi_conf=$(find $1 -name "sdmc_wifi_frequency_config_N.txt")
			parse_txt $sdmc_wifi_conf
			BLUE "parse_sdmc_config: android 7.0 sdmc wifi frequency config file parse success! ($LINENO)"
			echo ""
		elif [[ ${ANDROID_SDK_VERSION} -eq 26 ]]; then
			sdmc_wifi_conf=$(find $1 -name "sdmc_wifi_frequency_config_O.txt")
			parse_txt $sdmc_wifi_conf
			BLUE "parse_sdmc_config: android 8.0 sdmc wifi frequency config file parse success! ($LINENO)"
			echo ""
		elif [[ ${ANDROID_SDK_VERSION} -eq 27 ]]; then
			sdmc_wifi_conf=$(find $1 -name "sdmc_wifi_frequency_config_O.txt")
			parse_txt $sdmc_wifi_conf
			BLUE "parse_sdmc_config: android 8.1 sdmc wifi frequency config file parse success! ($LINENO)"
			echo ""
		elif [[ ${ANDROID_SDK_VERSION} -eq 28 ]]; then
			sdmc_wifi_conf=$(find $1 -name "sdmc_wifi_frequency_config_P.txt")
			parse_txt $sdmc_wifi_conf
			BLUE "parse_sdmc_config: android 9.0 sdmc wifi frequency config file parse success! ($LINENO)"
			echo ""
		fi
	else
		RED "parse_sdmc_config: ${1}/$SDMC_WIFI_CONFIG file is not exist!!!  ($LINENO)"
		exit 1
	fi
}




#############################################################################
#	拷贝wifi驱动,固件，及相关配置文本
#	@参数1：从/sdcard/wifi_module_info.txt文件读到一个arrary[]
#	(frequency_interface函数传递下来的loading_wifi_info数组)
#		arrary[1]: wifi固件路径
#		arrary[2]: wifi固件名
#		arrary[3]: bt固件路径
#		arrary[4]: bt固件名
#	@参数2：DATA_RFTESTTOOL(wifi定频工具包解压后的存放路径)
#############################################################################
function cp_wifi_context()
{
	copy_wifi_info=($1)
	curr_load_wifi_fw_path="${copy_wifi_info[0]}"
	curr_load_wifi_fw_name="${copy_wifi_info[1]}"

	# 拷贝dhd驱动文件
	if [[ ${ANDROID_SDK_VERSION} -eq 25 ]]; then
		dhd_file=$(find /system/ -name "dhd*")
		Eecho "cp_wifi_context: $dhd_file  ($LINENO)"
		cp $dhd_file "${2}/bcmdhd.ko" ; sync

	elif [[ ${ANDROID_SDK_VERSION} -ge 26 ]]; then
		dhd_file=$(find /vendor/ -name "dhd*")
		Eecho "cp_wifi_context: $dhd_file  ($LINENO)"
		cp $dhd_file "${2}/bcmdhd.ko" ; sync
	fi


	# 拷贝nvram文件
	Eecho "cp_wifi_context: $curr_load_wifi_fw_path  ($LINENO)"
	wifi_fw_temp=${curr_load_wifi_fw_path%/*}
	etc_wifi_path=${wifi_fw_temp##*=}
	Eecho "cp_wifi_context: $etc_wifi_path  ($LINENO)"

	nvram_file=$(find $etc_wifi_path -name "nvram*")
	Eecho "cp_wifi_context: $nvram_file  ($LINENO)"

	if [[ ${ANDROID_SDK_VERSION} -ge 25 ]] && [[ ${ANDROID_SDK_VERSION} -le 27 ]]; then
		cp ${nvram_file}  "${2}/nvram.txt" ; sync

	elif [[ ${ANDROID_SDK_VERSION} -eq 28 ]]; then
		wifi_fw_name_temp=${curr_load_wifi_fw_path##*/}
		curr_wifi_module_name=$(get_wifi_module  "${wifi_fw_name_temp}")
		Eecho "cp_wifi_context: ${curr_wifi_module_name}  ($LINENO)"
		nvram_file_p=$(find ${etc_wifi_path} -name "nvram*" | grep ${curr_wifi_module_name})
		Eecho "cp_wifi_context: ${nvram_file_p}  ($LINENO)"

		nvram_file=${nvram_file_p}
		cp ${nvram_file}  "${2}/" ; sync
	fi


	# 拷贝wifi固件
	if [[ ${ANDROID_SDK_VERSION} -eq 25 ]]; then
		etc_wifi_fw_file=${curr_load_wifi_fw_path##*=}
		cp $etc_wifi_fw_file 	"${2}/fw_bcmdhd_mfg.bin" ; sync

	elif [[ ${ANDROID_SDK_VERSION} -ge 26 ]]; then
		etc_wifi_fw_name=${curr_load_wifi_fw_name##*:}
		prefix_etc_wifi_fw_file=${etc_wifi_fw_name%.*}
		replace_wifi_fw=$(find $2 -name "${prefix_etc_wifi_fw_file}*")
		etc_wifi_fw_file=${replace_wifi_fw}
		Eecho "cp_wifi_context: ${etc_wifi_fw_name}  ($LINENO)"
		Eecho "cp_wifi_context: ${prefix_etc_wifi_fw_file}  ($LINENO)"
		Eecho "cp_wifi_context: ${replace_wifi_fw}  ($LINENO)"
		cp ${etc_wifi_fw_file}	"${2}/fw_bcmdhd_mfg.bin" ; sync

	fi

	# 判断上述文件是否copy成功
	md5sum_check_copy  "${dhd_file}"  	"${2}/bcmdhd.ko"
	md5sum_check_copy  "${nvram_file}"    "${2}/nvram*"
	md5sum_check_copy  "${etc_wifi_fw_file}"  "${2}/fw_bcmdhd_mfg.bin"

	echo "cp_wifi_context: copy wifi files success!  ($LINENO)"
	echo ""
}




#############################################################################
#	拷贝bt固件以及关闭蓝牙apk
#	@参数1：从/sdcard/wifi_module_info.txt文件读到一个arrary[]
#	(frequency_interface函数传递下来的loading_wifi_info数组)
#		arrary[1]: wifi固件路径
#		arrary[2]: wifi固件名
#		arrary[3]: bt固件路径
#		arrary[4]: bt固件名
#	@参数2：DATA_RFTESTTOOL(wifi定频工具包解压后的存放路径)
#############################################################################
function cp_bt_context()
{
	copy_bt_info=($1)
	curr_load_bt_fw_info="${copy_bt_info[2]}"
	Eecho "cp_bt_context: $curr_load_bt_fw_info  ($LINENO)"

	# 拷贝bt固件
	etc_bt_fw_file=${curr_load_bt_fw_info##*:}
	Eecho "cp_bt_context: ${etc_bt_fw_file}  ($LINENO)"
	cp "${etc_bt_fw_file}" 	"${2}/bcmdhd.hcd" ; sync

	# 关闭蓝牙apk
	bluetooth_apk=$(find /system/ -name "Bluetooth.apk")

	if [[ ! -z ${bluetooth_apk} ]]; then
		mv ${bluetooth_apk}	"${bluetooth_apk}_bck"
		BLUE "mv $bluetooth_apk to ${bluetooth_apk}_bck success!  ($LINENO)"
	fi
	
	# 判断上述文件是否copy成功
	md5sum_check_copy  "${etc_bt_fw_file}"  "${2}/bcmdhd.hcd"

	echo "cp_bt_context: copy bt files success!  ($LINENO)"
	echo ""
}




#############################################################################
#	拷贝wifi与BT定频服务及相关tools
#	@参数1：DATA_RFTESTTOOL(wifi定频工具包解压后的存放路径)
#############################################################################
function cp_wifi_bt_freq_service()
{
	cp "${1}/${RFTESTTOOL_WL_TOOL}" "${1}/wl" ; sync
	md5sum_check_copy "${1}/${RFTESTTOOL_WL_TOOL}"  "${1}/wl"

	cp "${1}/$RFTESTTOOL_SDMC_TOOL"  "${1}" ; sync
	#将wifi rftesttool.zip 工具解压到/sdcard中用于md5sum验证
	unzip_wifi_freq_tool "sdcard"

	sdcard_rftesttool=$(find /sdcard/ -name "${RFTESTTOOL_NAME}*")
	echo "cp_wifi_bt_freq_service: ${sdcard_rftesttool}  ($LINENO)"
	if [[ ! -z ${sdcard_rftesttool} ]]; then
		md5sum_check_copy "${1}/${RFTESTTOOL_SDMC_TOOL}"  "${sdcard_rftesttool}/${RFTESTTOOL_SDMC_TOOL}"
		rm -rf ${sdcard_rftesttool}
	fi


	if [[ -f "${1}/${RFTESTTOOL_SDMC_TOOL}" ]]; then
		Eecho "${1}/${RFTESTTOOL_SDMC_TOOL}  ($LINENO)"
		unzip -o "${1}/${RFTESTTOOL_SDMC_TOOL}" -d "/${1}/" > /dev/null

		echo "cp_wifi_bt_freq_service: unzip $RFTESTTOOL_SDMC_TOOL  success!  ($LINENO)"
		echo ""
	fi
}



#############################################################################
#	配置wifi与BT定频服务开机.rc自启动service
#	@参数1：DATA_RFTESTTOOL(wifi定频工具包解压后的存放路径)
#############################################################################
function config_freq_server()
{
	sdmc_wifi_detect_config_rc="${1}/wifi_detect_config.rc"

	# 替换盒子原来的wifi_detect.rc文件
	if [[ -f ${sdmc_wifi_detect_config_rc} ]]; then

		if [[ ${ANDROID_SDK_VERSION} -eq 25 ]]; then
			wifi_detect_rc=$(find /etc/ -name "wifi*.rc")
			cp  ${sdmc_wifi_detect_config_rc}  ${wifi_detect_rc}; sync

		elif [[ ${ANDROID_SDK_VERSION} -ge 26 ]]; then
			wifi_detect_rc=$(find /vendor/etc/ -name "wifi_detect.rc")
			cp  ${sdmc_wifi_detect_config_rc}  ${wifi_detect_rc}; sync

		fi
	fi

	md5sum_check_copy  ${sdmc_wifi_detect_config_rc}  ${wifi_detect_rc}
	echo "config_freq_server: ${sdmc_wifi_detect_config_rc} replace ${wifi_detect_rc} success!  ($LINENO)"
	echo ""
}




#############################################################################
#	不同wifi模组定频需要进行的步骤
#	@参数1：从/sdcard/wifi_module_info.txt文件读到一个arrary[]
#	(frequency_interface函数传递下来的wifi_info数组)
#		arrary[1]: wifi固件路径
#		arrary[2]: wifi固件名
#		arrary[3]: bt固件路径
#		arrary[4]: bt固件名
#############################################################################
function frequency_step()
{
	loading_wifi_info=($1)

	echo ""
	YELLOW "====================================frequency replace start===================================="
	#1. 检测U盘的wifi定频工具
	check_udisk_wifi_freq_tool

	#2. 将定频工具解压到盒子/data/rftesttool
	if [[ ! -d ${DATA_RFTESTTOOL} ]]; then
		RED "frequency_step: ${DATA_RFTESTTOOL} UNKNOW, need to unzip!!!  ($LINENO)"
		unzip_wifi_freq_tool  "data"  "${DATA_RFTESTTOOL}"
	fi

	if [[ -d ${DATA_RFTESTTOOL} ]]; then
		#3. 解析sdmc wifi 定频配置文件
		parse_sdmc_config  "${DATA_RFTESTTOOL}"

		#4. 拷贝wifi驱动,固件，及相关配置文本
		cp_wifi_context "${loading_wifi_info[*]}" "${DATA_RFTESTTOOL}"

		#5. 拷贝BT固件以及关闭蓝牙apk
		cp_bt_context "${loading_wifi_info[*]}" "${DATA_RFTESTTOOL}"

		#6. 拷贝wifi与BT定频服务及相关tools
		cp_wifi_bt_freq_service "${DATA_RFTESTTOOL}"

		#7. 配置wifi与BT定频服务开机自启动service boot
		config_freq_server  "${DATA_RFTESTTOOL}"

		#8. 关闭wifi及装载界面定频apk
		if [[ $(pm install -r ${DATA_RFTESTTOOL}/${RFTESTTOOL_APK_TOOL}) == "Success" ]]; then
			#svc wifi disable ; sync
			sleep 1 ; sync
			BLUE "frequency_step: pm install: ${RFTESTTOOL_APK_TOOL} install success!  ($LINENO)"
		else
			RED "frequency_step: pm install: ${RFTESTTOOL_APK_TOOL} install FAILED!!!  ($LINENO)"
			exit 1
		fi

	else
		RED "frequency_step: ${DATA_RFTESTTOOL} file is not exist!!!  ($LINENO)"
		exit 1
	fi

	#9. 盒子/data/rftesttool权限修改
	chmod  0777  "${DATA_RFTESTTOOL}/"  -R ; sync

	YELLOW "====================================frequency replace end======================================="
	echo ""
}




#############################################################################
#	wifi模组定频通用接口
#	@参数1：从/sdcard/wifi_module_info.txt文件读到一个arrary[]
#	(check_wifi_module_25_to_28函数传递下来的wifi_major_into数组)
#		arrary[1]: wifi固件路径
#		arrary[2]: wifi固件名
#		arrary[3]: bt固件路径
#		arrary[4]: bt固件名
#############################################################################
function frequency_interface()
{
	wifi_info=($1)

	#根据wifi固件名识别wifi模组  LOAD_WIFI_FW:xxx.bin
	brcm_wifi_fw_path="${wifi_info[1]}"
	brcm_wifi_fw_name=${brcm_wifi_fw_path##*:}
	WIFI_MODULE=$(get_wifi_module ${brcm_wifi_fw_name})

	case $WIFI_MODULE in

	6212|6236)
		BLUE "current load wifi module: AP${WIFI_MODULE}  ($LINENO)"
		frequency_step "${wifi_info[*]}"
		exit 0
		;;

	6398)
		BLUE "current load wifi module: AP${WIFI_MODULE}  ($LINENO)"
		#frequency_step "${wifi_info[*]}"
		exit 0
		;;

	6255)
		BLUE "current load wifi module: AP${WIFI_MODULE}  ($LINENO)"
		frequency_step "${wifi_info[*]}"
		exit 0
		;;
	6356)
		BLUE "current load wifi module: AP${WIFI_MODULE}S  ($LINENO)"
		frequency_step "${wifi_info[*]}"
		exit 0
		;;
	*)
		RED "current load wifi module is not brcm!!!  ($LINENO)"
		exit 1
	;;
	esac
}




function check_wifi_module_25_to_28()
{
	YELLOW "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	cat /dev/null > $WIFI_MODULE_INFO

	#检测wifi & bt加载固件路径以及保存相应的信息于/sdcard/wifi_module_info.txt文件中
	svc wifi enable
	sleep 1

	wifi_fw_path=$(dmesg  | grep "fw_path" | head -n 1 | awk '{print $4}')
	echo "wifi_fw_path:${wifi_fw_path}"  | tee -a "/sdcard/wifi_module_info.txt"
	LOAD_WIFI_FW=${wifi_fw_path##*/}
	echo "LOAD_WIFI_FW:${LOAD_WIFI_FW}"  | tee -a "/sdcard/wifi_module_info.txt"

	echo "open/close bluetooth service...  ($LINENO)"

	bt_fw_path=$(get_bt_fw_path)
	if [[ -z $bt_fw_path ]]; then
		RED "load bluetooth firmware FAILED!!!  ($LINENO)"
		exit 1
	fi

	echo "bt_fw_path:${bt_fw_path}"  | tee -a "/sdcard/wifi_module_info.txt"
	LOAD_BT_FW=${bt_fw_path##*/}
	echo "LOAD_BT_FW:${LOAD_BT_FW}"  | tee -a "/sdcard/wifi_module_info.txt"
	YELLOW "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	echo ""


	#将/sdcard/wifi_module_info.txt文件中保存的wifi信息读到wifi_into_line数组中，并向下frequency_interface定频通用接口传递
	wifi_major_into=($(cat $WIFI_MODULE_INFO))
	Eecho "wifi_major_into_num: ${#wifi_major_into[@]}"
	Eecho "WIFI_MODULE_INFO: ${wifi_major_into[*]}"
	Eecho "~~~~~~~~~~~~~~~~~~~~~~~wifi_major_into~~~~~~~~~~~~~~~~~~~~~~~~~~~"

	frequency_interface "${wifi_major_into[*]}"
}



function check_android_version()
{
	android_sdk=$(getprop ro.build.version.sdk)

	ANDROID_SDK_VERSION="${android_sdk}"
	case $android_sdk in

	25)
		BLUE "current software android version is 7.1: ${ANDROID_SDK_VERSION}  ($LINENO)"
		echo ""
		check_wifi_module_25_to_28
		exit 0
		;;

	26)	
		BLUE "current software android version is 8.0: ${ANDROID_SDK_VERSION}  ($LINENO)"
		echo ""
		check_wifi_module_25_to_28
		exit 0
		;;

	27)	
		BLUE "current software android version is 8.1: ${ANDROID_SDK_VERSION}  ($LINENO)"
		echo ""
		check_wifi_module_25_to_28
		exit 0
		;;
	28)	
		BLUE "current software android version is 9.0: ${ANDROID_SDK_VERSION}  ($LINENO)"
		echo ""
		check_wifi_module_25_to_28
		exit 0
		;;
	*)
		RED "current software android version is UNKNOW!!!  ($LINENO)"
		exit 1
	;;
	esac
}




function main()
{
	# 判断蓝牙apk是否被屏蔽
	bluetooth_apk_bck=$(find /system/ -name "Bluetooth.apk_bck")
	if [[ -f $bluetooth_apk_bck ]]; then
		BLUE "$bluetooth_apk_bck is exits!  ($LINENO)"
		echo ""
		bluetooth_apk_path=${bluetooth_apk_bck%/*}
		mv  "${bluetooth_apk_bck}"  "${bluetooth_apk_path}/Bluetooth.apk"
	fi


	#关闭串口
	echo 0 > /proc/sys/kernel/printk


	#Android 版本检测
	check_android_version
}


main $@