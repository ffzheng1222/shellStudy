#!/bin/bash
echo "########################################################"
echo "MT8321 Android N Version Images fast makeimg system"
echo "########################################################"
source build/envsetup.sh
FILE_LOG="build.log"
BUILD_LOG='2>&1 | tee '$FILE_LOG
echo "$BUILD_LOG"
error_info="missing and no known rule to make it"
error=$(cat $FILE_LOG | grep "$error_info" -C +5)


usage()
{
        echo "Usage: (creatimg.sh) [target] "
        echo "target: pl lk k ramdisk boot settings launcher3 systemui"
        echo "example(1): creatimg.sh "
        echo "########################################################"
        exit
}

function make_failed(){
    if [ -n $error ]; then 
    echo "mmm didn't prefect rule, you can try again or used mmma build!"
    fi
}

make_preloader()
{
	mmm vendor/mediatek/proprietary/bootable/bootloader/preloader:pl -j10 $1
}

make_lk()
{
	mmm vendor/mediatek/proprietary/bootable/bootloader/lk:lk -j10 $1
}

make_kernel()
{
	mmm kernel-3.18:kernel -j10 $1
}

make_ramdisk()
{
	make ramdisk-nodeps -j10 $1
}

make_bootimage()
{
	make bootimage-nodeps -j10 $1
}

mmm_settings(){    
    mmm packages/apps/Settings/ $1
}

mmm_launcher3(){
    local error_log failed_info
    error_log=$(cat $FILE_LOG | grep "make failed")
    if [ -n $error_log ]; then 
        failed_info=$(make_failed)
        if [ ! -z $failed_info ]; then 
            mmma packages/apps/Launcher3/ $1
            return 
        fi
    fi
    
    mmm packages/apps/Launcher3/ $1 
}

mmm_systemui(){
    mmm frameworks/base/packages/SystemUI/ $1
}

build()
{
    case $1 in
        pl)
            make_preloader $2
        ;;
        lk)
            make_lk $2
        ;;
        k)
            make_kernel $2
        ;;
        ramdisk)
            make_ramdisk $2
        ;;
        boot)
            make_kernel $2
            make_bootimage $2
        ;;
        settings)
            mmm_settings $2
        ;;
        launcher3)
            mmm_launcher3 $2
        ;;
        systemui)
            mmm_systemui $2
        ;;
        *)
            usage
        ;;
    esac
}

for argv in $*
do
    echo "************************************** build $argv *************************************"
    build $argv $BUILD_LOG
done




