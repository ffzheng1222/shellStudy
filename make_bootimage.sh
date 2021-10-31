#!/bin/bash

function check_err()
{
    #echo "$2, ret $1"
    if [ $1 != "0" ]
    then
        cd -
        echo "$2 failed, ret $1 path:$PWD  LINENO:$3"
        exit 1
    else
        return 0
    fi
}

function usage() {
	cat << EOF
Usage: $(basename $0) --help

    All-in-one command to compile a module:

    $(basename $0)
        -p soc                  \\
        -a arch

    Environment Variables:
        soc: platform soc
        arch: arm or arm64 bit,default is base on .config
EOF
	exit 1
}

function env_setup()
{
	if [ -z "${local_soc}" ]; then
		echo "pls select a soc"
		usage
	fi

	if [ -z ${ANDROID_BUILD_TOP} ];then
		echo "pls select a luncher at first!"
		exit 1
	fi

	if [ -z ${local_arch} ];then
		arch=$(grep -nrs CONFIG_64BIT ${ANDROID_BUILD_TOP}/out/target/product/${TARGET_PRODUCT}/obj/KERNEL_OBJ/.config)
		if [  -z ${arch} ];then
			KERNEL_ARCH=arm
		else
			KERNEL_ARCH=arm64
		fi
	else
		KERNEL_ARCH=${local_arch}
	fi

	MAKE=make
	BOARD_BOOTIMG_HEADER_VERSION=1
	BOARD_KERNEL_OFFSET=0x1080000
	BOARD_MKBOOTIMG_ARGS="--kernel_offset ${BOARD_KERNEL_OFFSET} --header_version ${BOARD_BOOTIMG_HEADER_VERSION}"
	BOARD_KERNEL_CMDLINE="--cmdline androidboot.dtbo_idx=0 --cmdline buildvariant=userdebug --cmdline root=/dev/mmcblk0p18"
	BOARD_AML_VENDOR_PATH=${ANDROID_BUILD_TOP}/vendor/amlogic/common/

	ANDROID_PRODUCT_OUT=out/target/product/${TARGET_PRODUCT}
	INSTALLED_KERNEL_TARGET=${ANDROID_PRODUCT_OUT}/kernel
	KERNEL_ROOTDIR=${ANDROID_BUILD_TOP}/common
	KERNEL_OBJ=${ANDROID_BUILD_TOP}/${ANDROID_PRODUCT_OUT}/obj/KERNEL_OBJ
	KERNEL_DEVICETREE_DIR=${KERNEL_ROOTDIR}/arch/${KERNEL_ARCH}/boot/dts/amlogic/

	PRODUCT_OUT=${ANDROID_PRODUCT_OUT}
	DTBTOOL=${BOARD_AML_VENDOR_PATH}/tools/dtbTool

	TARGET_FIRMWARE_DTSI=firmware_system.dtsi

	if [ ${KERNEL_ARCH} == "arm" ];then
		ARCH=arm
		KERNEL_TARGET=uImage
		CROSS_COMPILE=/opt/gcc-linaro-6.3.1-2017.02-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
		TARGET_PARTITION_DTSI=partition_mbox_normal_P_32.dtsi
		
	else
		ARCH=arm64
		KERNEL_TARGET=Image.gz
		CROSS_COMPILE=/opt/gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-
		TARGET_PARTITION_DTSI=partition_mbox_normal_P_32.dtsi
	fi

	 case ${local_soc} in
		s905x2)
			KERNEL_DEVICETREE="g12a_s905x2_u212_1g g12a_s905x2_u212 g12a_s905x2_u212_4g"
		;;
		s905x)
			KERNEL_DEVICETREE="gxl_p212_1g gxl_p212_1.5g gxl_p212_2g"
		;;
		s805x)
		;;
		s905d)
		;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 2
		;;
	esac

    echo "build tool info:"
    echo "version		: v1.0"
    echo "Author		: yangyufeng"
    echo "email 		: yangyufeng@mail.sdmc.com"
	echo "product  soc	: ${local_soc}"
	echo "product arch	: ${ARCH}"
}

function make_bootimage()
{
	${MAKE} -j24 -C ${KERNEL_ROOTDIR} O=${KERNEL_OBJ} ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules ${KERNEL_TARGET}
	rm -rf ${INSTALLED_KERNEL_TARGET}
	cp ${KERNEL_OBJ}/arch/${ARCH}/boot/${KERNEL_TARGET} ${INSTALLED_KERNEL_TARGET}
	${ANDROID_BUILD_TOP}/out/host/linux-x86/bin/mkbootfs ${PRODUCT_OUT}/root | \
	${ANDROID_BUILD_TOP}/out/host/linux-x86/bin/minigzip > ${PRODUCT_OUT}/ramdisk.img
	${ANDROID_BUILD_TOP}/out/host/linux-x86/bin/mkbootimg  --kernel ${KERNEL_OBJ}/arch/${ARCH}/boot/${KERNEL_TARGET} \
		--base 0x0 \
		--kernel_offset 0x1080000 \
		${BOARD_KERNEL_CMDLINE} \
		--ramdisk ${PRODUCT_OUT}/ramdisk.img \
		${BOARD_MKBOOTIMG_ARGS} \
		--output ${PRODUCT_OUT}/boot.img

	ls -l ${PRODUCT_OUT}/boot.img
	echo "Done building boot.img, md5sum:"
	md5sum ${PRODUCT_OUT}/boot.img
}

function make_dtbimage()
{
	for aDts in ${KERNEL_DEVICETREE};do
		path=`echo ${aDts} | sed 's/[[:space:]]//g'` #去除所有空格
		sed -i "s/^#include \"partition_.*/#include \"${TARGET_PARTITION_DTSI}\"/" ${KERNEL_DEVICETREE_DIR}/${aDts}.dts;
		sed -i "s/^#include \"firmware_.*/#include \"${TARGET_FIRMWARE_DTSI}\"/" ${KERNEL_DEVICETREE_DIR}/${TARGET_PARTITION_DTSI};

		if [ -f "${KERNEL_DEVICETREE_DIR}/${aDts}.dtd" ]; then
			${MAKE} -C ${KERNEL_ROOTDIR} O=${KERNEL_OBJ} ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} ${aDts}.dts;
		fi;

		echo "${MAKE} -C ${KERNEL_ROOTDIR} O=${KERNEL_OBJ} ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} ${aDts}.dtb;"
		${MAKE} -C ${KERNEL_ROOTDIR} O=${KERNEL_OBJ} ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} ${aDts}.dtb;
	done

	${DTBTOOL} -o ${PRODUCT_OUT}/dtb.img -p ${KERNEL_OBJ}/scripts/dtc/ ${KERNEL_OBJ}/arch/${ARCH}/boot/dts/amlogic/

	ls -l ${PRODUCT_OUT}/dtb.img
	echo "Done building dtb.img, md5sum:"
	md5sum ${PRODUCT_OUT}/dtb.img
}

function parase_opts()
{
	while getopts "p:o:a:m:" opt; do
		case $opt in
			p) readonly local_soc="$OPTARG" ;;
			a) readonly local_arch="$OPTARG" ;;
			\?)
				echo "Invalid option: -$OPTARG" >&2
				exit 2
			;;
		esac
	done
}

function main()
{
	parase_opts $@
	env_setup
	make_dtbimage
	make_bootimage
}

main $@ # parse all paras to function

