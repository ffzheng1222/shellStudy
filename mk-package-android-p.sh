#!/bin/bash
# This script use to make package stuff for amlogic s912 platform
# Please run this script on top android directory

set -e

function usage()
{
	echo ""
	echo "please run this script in android top directory"
	echo "Usage:  $0 [product] [sdk_version] [v3]"
	echo "		product menu:"
	echo "			1: ampere     	-----> ampere platform for s905x chip"
	echo "			2: braun      	-----> braun platform for s905d chip"
	echo "			3: curie      	-----> curie platform for s805x chip"
	echo "			4: u221      	-----> u221 platform for s905y2 chip"
	echo "			5: franklin     -----> franklin platform for 905x2 chip"
	echo "			6: faraday     -----> faraday platform for s905y2 chip"	
	echo "		sdk_version menu:"
	echo "			sdk0701"
	echo "			sdk0822"
	echo "			sdk0111"
	echo "			hailstorm"
	echo "		v3 menu:"
	echo "example:"
	echo "	$0 3 sdk0111	-----> make package stuff for curie platform of s805x chip "
	echo "	$0 3 sdk0111 v3	-----> make package stuff for curie platform of s805x chip with secure boot v3"
	echo ""
}

function build_dir()
{
	v_date=`date +%Y%m%d`
	#tony add start
	zip_tmp=$(ls out/target/product/${product} | grep "fastboot-flashall")
	zip_name=${zip_tmp%.*}
	v_date=${zip_name##*-}
	#tony add end
	v_time=`date +%H%M`

	#tony add start
	is_debug_tmp=$(cat out/target/product/${product}/system/build.prop | grep "flavor")
	is_debug=${is_debug_tmp##*-}
	if [[ "${is_debug}" == "eng" ]]; then
		packagedir="${chip}_${sdk_version}_${v_date}_${v_time}_${is_debug}"
	elif [[ "${is_debug}" == "userdebug" ]]; then
		packagedir="${chip}_${sdk_version}_${v_date}_${v_time}_${is_debug}"
	else
		packagedir="${chip}_${sdk_version}_${v_date}_${v_time}"
	fi
	#tony add end
	#packagedir=$chip"_"$sdk_version"_"$v_date"_"$v_time
	mkdir $packagedir
	cd $packagedir
	cp ../patch_list*.txt ./
	mkdir bootloader
	mkdir kernel
	mkdir pkg
	mkdir framework
	mkdir others
	cd bootloader
	mkdir upgrade
	cd ../kernel
	mkdir ramdisk
	mkdir dts
	cd ../others
	mkdir bin
	mkdir meta
	cd ../../
}

function make_package_utils()
{

	if [ "$1"x = "v3x" ]
	then
		# has secure boot v3 
		cd out/target/product/$product/
		OUT_DIR=../../../../$packagedir/
		
		# bootloader start
		cp upgrade/aml_sdc_burn.ini $OUT_DIR/bootloader/upgrade/
		cp upgrade/aml_upgrade_package_enc_avb.conf $OUT_DIR/bootloader/upgrade/
		cp upgrade/logo.img $OUT_DIR/bootloader/upgrade/
		cp dt.img $OUT_DIR/bootloader/upgrade/
		cp upgrade/platform.conf $OUT_DIR/bootloader/upgrade/
		cp bootloader.img.encrypt $OUT_DIR/bootloader/upgrade/bootloader.img
		cp upgrade/u-boot.bin.sd.bin $OUT_DIR/bootloader/upgrade/
		cp upgrade/u-boot.bin.usb.bl2 $OUT_DIR/bootloader/upgrade/
		cp upgrade/u-boot.bin.usb.tpl $OUT_DIR/bootloader/upgrade/
		cp upgrade/special_bootloader.img $OUT_DIR/bootloader/upgrade/
		cp obj/ETC/file_contexts.bin_intermediates/file_contexts.bin $OUT_DIR/bootloader/upgrade/
		cp bl_tmp/*   $OUT_DIR/bootloader/upgrade/

		resize2fs="../../../../device/amlogic/common/recovery/resize2fs_n"
		if [ -f "$resize2fs" ]; then
			cp  ../../../../device/amlogic/common/recovery/resize2fs_n $OUT_DIR/bootloader/upgrade/
			cp  ../../../../device/amlogic/common/recovery/resize2fs_o $OUT_DIR/bootloader/upgrade/
		fi

		# bootloader end
		
		# kernel start
		cp kernel $OUT_DIR/kernel/
		cp dt.img $OUT_DIR/kernel/dts/
		cp $product-kernel/dtbo.img $OUT_DIR/kernel/dts/
		#cp obj/ETC/file_contexts.bin_intermediates/file_contexts.bin root/
		tar -cvjf $OUT_DIR/kernel/ramdisk/root.tar.bz2 root/
		cd recovery
		tar -cvjf ../$OUT_DIR/kernel/ramdisk/root-recovery.tar.bz2 root/
		cd -
		# kernel end
		
		# system start
		tar -cvjf $OUT_DIR/framework/$chip-system.tar.bz2 system/
		tar -cvjf $OUT_DIR/framework/vendor.tar.bz2 vendor/
		tar -cvjf $OUT_DIR/framework/odm.tar.bz2 odm/
		tar -cvjf $OUT_DIR/framework/product.tar.bz2 product/
		# system end
		
		#updater and .xml,.txt file
		cp obj/PACKAGING/target_files_intermediates/$product-target_files-eng.$USER/OTA/bin/updater $OUT_DIR/others/bin
		cp obj/PACKAGING/target_files_intermediates/$product-target_files-eng.$USER/META/* $OUT_DIR/others/meta
		cp obj/PACKAGING/target_files_intermediates/$product-target_files-eng.$USER/OTA/android-info.txt $OUT_DIR/others/
		
		# pkg start
		cp aml_upgrade_package.img $OUT_DIR/pkg/
		cp $product-ota-eng.$USER.zip $OUT_DIR/pkg/
		cp $product-fastboot-flashall-$v_date.zip $OUT_DIR/pkg/
		cp recovery.img.encrypt $OUT_DIR/pkg/recovery.img
		# pkg end

		#vmlinux start
		cp obj/KERNEL_OBJ/vmlinux $OUT_DIR/pkg/
		#vmlinux end
		
		cd ../../../../
		echo -e "\n$packagedir\n"			
	else
		# not v3
		cd out/target/product/$product/
		OUT_DIR=../../../../$packagedir/
		
		# bootloader start
		cp upgrade/aml_sdc_burn.ini $OUT_DIR/bootloader/upgrade/
		cp upgrade/aml_upgrade_package_avb.conf $OUT_DIR/bootloader/upgrade/
		cp upgrade/logo.img $OUT_DIR/bootloader/upgrade/
		cp dt.img $OUT_DIR/bootloader/upgrade/
		cp upgrade/platform.conf $OUT_DIR/bootloader/upgrade/
		cp bootloader.img $OUT_DIR/bootloader/upgrade/
		cp upgrade/u-boot.bin.sd.bin $OUT_DIR/bootloader/upgrade/
		cp upgrade/u-boot.bin.usb.bl2 $OUT_DIR/bootloader/upgrade/
		cp upgrade/u-boot.bin.usb.tpl $OUT_DIR/bootloader/upgrade/
		#cp 2ndbootloader $OUT_DIR/bootloader/upgrade/
		cp obj/ETC/file_contexts.bin_intermediates/file_contexts.bin $OUT_DIR/bootloader/upgrade/
		cp upgrade/special_bootloader.img $OUT_DIR/bootloader/upgrade/

		resize2fs="../../../../device/amlogic/common/recovery/resize2fs_n"
		if [ -f "$resize2fs" ]; then
			cp  ../../../../device/amlogic/common/recovery/resize2fs_n $OUT_DIR/bootloader/upgrade/
			cp  ../../../../device/amlogic/common/recovery/resize2fs_o $OUT_DIR/bootloader/upgrade/
		fi
		# bootloader end
		
		# kernel start
		cp kernel $OUT_DIR/kernel/
		cp dt.img $OUT_DIR/kernel/dts/
		#cp ../../../../device/amlogic/$product-kernel/dtbo.img $OUT_DIR/kernel/dts/
		cp $product-kernel/dtbo.img $OUT_DIR/kernel/dts/
		tar -cvjf $OUT_DIR/kernel/ramdisk/root.tar.bz2 root/
		cd recovery
		tar -cvjf ../$OUT_DIR/kernel/ramdisk/root-recovery.tar.bz2 root/
		cd -
		# kernel end
		
		# system start
		tar -cvjf $OUT_DIR/framework/$chip-system.tar.bz2 system/
		tar -cvjf $OUT_DIR/framework/vendor.tar.bz2 vendor/
		tar -cvjf $OUT_DIR/framework/odm.tar.bz2 odm/
		tar -cvjf $OUT_DIR/framework/product.tar.bz2 product/
		# system end
		
		#updater and .xml,.txt file
		cp obj/PACKAGING/target_files_intermediates/$product-target_files-eng.$USER/OTA/bin/updater $OUT_DIR/others/bin
		cp obj/PACKAGING/target_files_intermediates/$product-target_files-eng.$USER/META/* $OUT_DIR/others/meta
		cp obj/PACKAGING/target_files_intermediates/$product-target_files-eng.$USER/OTA/android-info.txt $OUT_DIR/others/
		
		# pkg start
		cp aml_upgrade_package.img $OUT_DIR/pkg/
		cp $product-ota-eng.$USER.zip $OUT_DIR/pkg/
		cp $product-fastboot-flashall-$v_date.zip $OUT_DIR/pkg/
		cp recovery.img $OUT_DIR/pkg/
		# pkg end
		
		#vmlinux start
		cp obj/KERNEL_OBJ/vmlinux $OUT_DIR/pkg/
		#vmlinux end
		
		cd ../../../../
		echo -e "\n$packagedir\n"		
	fi
}

if [ $# -lt 2 ]; then
	usage
	exit 1
fi

case $1 in
	1)
		chip=s905x
		product=ampere
		;;
	
	2)
		chip=s905d
		product=braun
		;;
		
	3)
		chip=s805x
		product=curie
		;;	
	4)
		chip=s905y2
		product=u221
		;;			
	5)
		chip=s905x2
		product=franklin
		;;
	6)
		chip=s905y2
		product=faraday
		;;
	*)
		usage;
		exit 1
		;;
esac

sdk_version=$2

build_dir
make_package_utils $3

