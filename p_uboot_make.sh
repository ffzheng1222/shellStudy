#! /bin/bash


CUR_PATH=$(pwd)
BOOTLOADER_PATH="$CUR_PATH/bootloader/uboot-repo"
LAUNCH_ITEM="$TARGET_PRODUCT"
AVB2="avb2"

MAKE_USERDEBUG=""

function usage()
{
	echo "please run this script in android top directory"
	echo "Usage:	p_uboot_make.sh [opts]"
	echo "	p_uboot_make.sh s805x [avb2]	-----> compile s805x uboot"
	echo "	p_uboot_make.sh s905x [avb2]	-----> compile s905x uboot"
	echo "	p_uboot_make.sh s905x2 [avb2]	-----> compile s905x2 uboot"
}


function mk_android_p_uboot()
{
	if [ ! -z $4 ]; then
		choose_open_avb2="--${4}"
		echo "note: open $choose_open_avb2......"
	else
		choose_open_avb2=""
	fi
	

	is_source_launch=$(export | grep TARGET)
	MAKE_USERDEBUG=$(echo $TARGET_BUILD_VARIANT)
	
	if [[ "${MAKE_USERDEBUG}" == "user" ]]; then
		is_make_userdebug=""
	else
		is_make_userdebug="--${MAKE_USERDEBUG}"
	fi

	if [[ -z $is_source_launch ]]; then
		echo "error: SDK don't source build environment !!!"
		exit 1
	fi

	#Enter the bootloader root directory
	cd $BOOTLOADER_PATH

	if [[ "${3}" == "franklin" ]] || [[ "${3}" == "faraday" ]]; then
		u_boot_device="g12a"
	else
		u_boot_device="gx"
	fi

	echo
	echo "compile $1 uboot: $2 : $3"
	echo "./mk ${2} --bl32  ../../vendor/amlogic/common/tdk/secureos/${u_boot_device}/bl32.img --systemroot $choose_open_avb2 ${is_make_userdebug}"
	echo
	
	./mk ${2} --bl32  ../../vendor/amlogic/common/tdk/secureos/${u_boot_device}/bl32.img --systemroot $choose_open_avb2 ${is_make_userdebug}
	
	cp build/u-boot.bin ../../device/amlogic/${3}/bootloader.img
	cp build/u-boot.bin.sd.bin ../../device/amlogic/${3}/upgrade/
	cp build/u-boot.bin.usb.* ../../device/amlogic/${3}/upgrade/
	cd -
}


function comp_s805x_uboot()
{
	mk_android_p_uboot "$1" "gxl_p241_v1" "$LAUNCH_ITEM" "$2"
}

function comp_s905x_uboot()
{
	mk_android_p_uboot "$1" "gxl_p212_v1" "$LAUNCH_ITEM" "$2"
}


function comp_s905x2_uboot()
{
	mk_android_p_uboot "$1" "g12a_u212_v1" "$LAUNCH_ITEM" "$2"
}

function comp_s905y2_uboot()
{
	mk_android_p_uboot "$1" "g12a_u221_v1" "$LAUNCH_ITEM" "$2"
}


function ask_avb2_make()
{
	read -p "Do you want to choose make avb2? (y/n): " answer
	
	if [ "y" = $answer ]; then 
		add_avb2="$AVB2"
	else
		add_avb2=""
	fi
	echo $add_avb2
}


function check_mk_argvs()
{

	if [[ $# -eq 2 && $2 -eq "avb2" ]]; then
		add_avb2_make="$2"
	else
		add_avb2_make=$(ask_avb2_make)
	fi


	case $1 in

	s805x|S805X)
		comp_s805x_uboot $1 $add_avb2_make
		exit 0
		;;

	s905x|S905X)	
		comp_s905x_uboot $1 $add_avb2_make
		exit 0
		;;

	s905x2|S905X2)	
		comp_s905x2_uboot $1 $add_avb2_make
		exit 0
		;;
	s905x2|S905X2)	
		comp_s905x2_uboot $1 $add_avb2_make
		exit 0
		;;
	s905y2|S905Y2)	
		comp_s905y2_uboot $1 $add_avb2_make
		exit 0
		;;
	*)
		usage
		exit 1
	;;
	esac
}


function handle_argvs()
{
	case $# in
	
	1)
		check_mk_argvs $1
	;;

	2)
		check_mk_argvs $1 $2
	;;

	*)
		usage
		exit 1
	;;
	esac
	
}


function main()
{
	handle_argvs $*
}

main $@




