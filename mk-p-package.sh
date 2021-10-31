#!/bin/bash
# This script use to make package stuff for amlogic s912 platform
# Please run this script on top android directory

set -e

function usage()
{
	echo ""
	echo "please run this script in android top directory"
	echo "Usage:  $0 [product] [sdk_version]"
	echo "		product menu:"
	echo "			1: p212     	-----> p212 platform for s905x chip"
	echo "			2: p230      	-----> p230 platform for s905d chip"
	echo "			3: p241      	-----> p241 platform for s805x chip"
	echo "			4: ampere      	-----> ampere platform for 905x chip"	
	echo "		sdk_version menu:"
	echo "			sdk0701"
	echo "			sdk0822"
	echo "example:"
	echo "	$0 3 sdk0822	-----> make package stuff for q201 platform of s912 chip "
	echo ""
}

function build_dir()
{
	v_date=`date +%Y%m%d`
	v_time=`date +%H%M`
	packagedir=$chip"_"$sdk_version"_"$v_date"_"$v_time
	mkdir $packagedir
	cd $packagedir
	cp ../patch_list*.txt ./
	mkdir bootloader
	mkdir kernel
	mkdir pkg
	mkdir framework
	cd bootloader
	mkdir upgrade
	cd ../kernel
	mkdir ramdisk
	mkdir dts
	cd ../..
}

function make_package_utils()
{
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
	# bootloader end
	
	# kernel start
	cp kernel $OUT_DIR/kernel/
	cp dt.img $OUT_DIR/kernel/dts/
	cp ../../../../device/amlogic/$product-kernel/dtbo.img $OUT_DIR/kernel/dts/
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
	
	# pkg start
	cp aml_upgrade_package.img $OUT_DIR/pkg/
	cp $product-ota-eng.$USER.zip $OUT_DIR/pkg/
	cp recovery.img $OUT_DIR/pkg/
	# pkg end
	
	cd ../../../../
	echo -e "\n$packagedir\n"
}

if [ $# -ne 2 ]; then
	usage
	exit 1
fi

case $1 in
	1)
		chip=s905x
		product=p212
		;;
	
	2)
		chip=s905d
		product=p230
		;;
		
	3)
		chip=s805x
		product=p241
		;;	
	4)
		chip=s905x
		product=ampere
		;;			
	5)
		chip=s805x
		product=curie
		;;			
	
	*)
		usage;
		exit 1
		;;
esac

sdk_version=$2

build_dir
make_package_utils

