#! system/bin/sh
#################################################################
#
# wifi_bt_log.sh   
#  	Ready Grab wifi btsnoop log
#
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



ANDROID_SDK_P="28"
ANDROID_SDK_O="27"

#APXXX
RTKXXX_BTSNOOP_FILE="/vendor/etc/bluetooth/rtkbt.conf"
#RTKXXX
APXXX_BTSNOOP_FILE="/system/etc/bluetooth/bt_stack.conf"

BTSNOOP_LOG_SAVE_FILE="btsnoop_log.bz2.gz"


function mount_root()
{
	sdk_version=$(getprop ro.build.version.sdk)

	if [ $sdk_version -eq $ANDROID_SDK_P ]; then
		mount -o remount,rw -t ext4 /dev/root /  && mount -w -o remount /dev/block/vendor /vendor
		BLUE "Android p mount success."
	elif [ $sdk_version -eq $ANDROID_SDK_O ]; then
		mount -o remount,rw /system && mount -o remount,rw /vendor
		BLUE "Android o mount success."
	fi
}


function set_prop()
{
	btsnoop_switch=$(getprop persist.bluetooth.btsnoopenable)
	if [ "$btsnoop_switch" == "true" ]; then
		RED "btsnoopenable has been set to true!!! "
	else
		setprop persist.bluetooth.btsnoopenable true
		curr_btsnoop_switch=$(getprop persist.bluetooth.btsnoopenable)
		if [ "$curr_btsnoop_switch" == "true" ]; then
			BLUE "btsnoopenable set true is success."
		else
			RED "btsnoopenable is set true failed!"
		fi
	fi
}


function config_btsnoop()
{
	##################################
	#APXXX_BTSNOOP_FILE="./bt_stack_back.conf"
	#RTKXXX_BTSNOOP_FILE="./rtkbt_back.conf"

	bcm_wifi_module=$(lsmod | grep -w "dhd")
	if [[ -n $bcm_wifi_module ]]; then
		#current wifi module if APXXX
		cat $APXXX_BTSNOOP_FILE  | grep "TRC.*=2" | sed -i 's/=2/=5/g' $APXXX_BTSNOOP_FILE
		BLUE "$(cat $APXXX_BTSNOOP_FILE | grep TRC) has been fix success."
	else
		#current wifi module if rtkxxx
		cat $RTKXXX_BTSNOOP_FILE | sed -i 's/RtkBtsnoopDump=false/RtkBtsnoopDump=true/1' $RTKXXX_BTSNOOP_FILE
		BLUE "$(cat $RTKXXX_BTSNOOP_FILE | grep RtkBtsnoopDump) has been fix success."
	fi
}


function bt_switch()
{
	#close bt
	service call bluetooth_manager 8
	BLUE "close bt success..."
	sleep 3
	#open bt
	service call bluetooth_manager 6
	BLUE "open bt success..."
}


function get_btsnoop_log()
{
	btsnoop_log_file=$(getprop persist.bluetooth.btsnooppath)
	btsnoop_log_path=${btsnoop_log_file%/*}
	YELLOW "btsnoop log save to $btsnoop_log_path"

	if [[ -n $btsnoop_log_file || -n "$btsnoop_log_path/*.log" ]]; then
		rm -f $btsnoop_log_file "$btsnoop_log_path/*.log"
	fi	

	logcat -c; logcat -c; logcat -v time > ${btsnoop_log_path}/btsnoop_logcat.log &
	bt_switch
	
	echo ""
	YELLOW "Grabbing btsnoop log, Ctrl-C will be save log to /btsnoop_log.bz2.gz !!!"
	echo ""

	while true; do
		trap "tar_btsnoop_log $btsnoop_log_path; exit" INT
	done
}


function tar_btsnoop_log()
{
	if [ -n "/$BTSNOOP_LOG_SAVE_FILE" ]; then
		rm -rf "/$BTSNOOP_LOG_SAVE_FILE"
	fi

	tar -cvf "/$BTSNOOP_LOG_SAVE_FILE" ${1}/*.cfa ${1}/*.log  -C /
	BLUE "tar compression success."
	tar -tvf "/$BTSNOOP_LOG_SAVE_FILE"
	BLUE "tar decompression success."
}


function main()
{
	#YELLOW "########################### mount_root #############################"
	#mount_root
	#YELLOW "#######################################################################"
	
	YELLOW ""
	
	YELLOW "########################### set_prop #############################"
	set_prop
	YELLOW "#######################################################################"
	
	YELLOW ""
	
	YELLOW "################################ config_btsnoop ########################"
	config_btsnoop
	YELLOW "#######################################################################"
	
	YELLOW ""

	YELLOW "############################# get_btsnoop_log ###########################"
	get_btsnoop_log
	YELLOW "#######################################################################"
}

main $@
