#! /bin/bash
#################################################################
#
# sdk_check_aml_media_audio.sh
#
#	基于SDK检测原厂patch关于media及audio
#	一些二进制文件(.so .ta .bin)的修改
#
#	usage: sdk_check_media_audio_so.sh <SDK_CODE_PATH> <SDK_OUT_PATH>
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


SDK_MEDIA_AUDIO_MANIFEST="${ROOT_DIR}/${PROJECT_NAME}/sdk_media_audio.txt"
SDK_MEDIA_AUDIO_MANIFEST_DEFAULT="./sdk_media_audio.txt"



function md5sum_check_save()
{
	md5sum "${1}" >> ${SDK_MEDIA_AUDIO_MANIFEST}
}


function libamnuplay_module()
{
	BLUE "md5sum libamnuplay_module start ..."

	libamnuplayer_so=$(find ${SDK_OUT_PATH}/system/lib/ -name  "libamnuplayer.so")
	md5sum_check_save 	${libamnuplayer_so}

	libamffmpeg_so=$(find ${SDK_OUT_PATH}/system/lib/ -name  "libamffmpeg.so")
	md5sum_check_save 	${libamffmpeg_so}

	libamffmpegadapter_so=$(find ${SDK_OUT_PATH}/system/lib/ -name  "libamffmpegadapter.so")
	md5sum_check_save 	${libamffmpegadapter_so}

	libavenhancements_so=$(find ${SDK_OUT_PATH}/system/lib/ -name  "libavenhancements.so")
	md5sum_check_save 	${libavenhancements_so}
}



function omx_moudle()
{
	BLUE "md5sum omx_moudle start ..."

	omx_so_arrays=($(ls ${SDK_CODE_PATH}/vendor/amlogic/common/prebuilt/libstagefrighthw/lib))

	for ((i = 0; i < ${#omx_so_arrays[@]}; i++)); do

		omx_so_name=$(find ${SDK_OUT_PATH}/vendor/lib/ -name  "${omx_so_arrays[i]}")
		if [ ! -z ${omx_so_name} ]; then
			md5sum_check_save 	${omx_so_name}
		fi
	done
}


function drm_module()
{
	BLUE "md5sum drm_module start ..."

	#widevine
	libwvhidl_so=$(find ${SDK_OUT_PATH}/vendor/lib/ -name  "libwvhidl.so")
	md5sum_check_save 	${libwvhidl_so}

	liboemcrypto_so=$(find ${SDK_OUT_PATH}/vendor/lib/ -name  "liboemcrypto.so")
	md5sum_check_save 	${liboemcrypto_so}

	widevine_ta=$(find ${SDK_OUT_PATH}/vendor/lib/ -name  "e043cde0-61d0-11e5-9c260002a5d5c51b.ta")
	md5sum_check_save 	${widevine_ta}


	#playready
	libplayready_so=$(find ${SDK_OUT_PATH}/vendor/lib/ -name  "libplayready.so")
	md5sum_check_save 	${libplayready_so}

	libplayreadymediadrmplugin_so=$(find ${SDK_OUT_PATH}/vendor/lib/ -name  "libplayreadymediadrmplugin.so")
	md5sum_check_save 	${libplayreadymediadrmplugin_so}

	playready_ta=$(find ${SDK_OUT_PATH}/vendor/lib/ -name  "9a04f079-9840-4286-ab92e65be0885f95.ta")
	md5sum_check_save 	${playready_ta}


	#secmem
	libsecmem_so=$(find ${SDK_OUT_PATH}/vendor/lib/ -name  "libsecmem.so")
	md5sum_check_save 	${libsecmem_so}

	secmem_ta=$(find ${SDK_OUT_PATH}/vendor/lib/ -name  "2c1a33c0-44cc-11e5-bc3b0002a5d5c51b.ta")
	md5sum_check_save 	${secmem_ta}

}


function media_ko_module()
{
	BLUE "md5sum media_ko_module start ..."

	media_ko_arrays=($(ls ${SDK_OUT_PATH}/vendor/lib/modules | grep "amvdec"))

	for ((i = 0; i < ${#media_ko_arrays[@]}; i++)); do
		media_ko_name=$(find ${SDK_OUT_PATH}/vendor/lib/modules -name  "${media_ko_arrays[i]}")
		md5sum_check_save 	${media_ko_name}
	done
}


function h264_fw_module()
{
	BLUE "md5sum h264_fw_module start ..."

	h264_fw_arrays=($(ls ${SDK_CODE_PATH}/hardware/amlogic/media_modules/firmware))

	for ((i = 0; i < ${#h264_fw_arrays[@]}; i++)); do
		h264_fw_name=$(find ${SDK_OUT_PATH}/vendor/lib/ -name  "${h264_fw_arrays[i]}")
		md5sum_check_save 	${h264_fw_name}
	done
}


function audio_so_module()
{
	BLUE "md5sum audio_so_module start ..."

	libHwAudio_dcvdec_so=$(find ${SDK_OUT_PATH}/vendor/lib/ -name  "libHwAudio_dcvdec.so")
	md5sum_check_save 	${libHwAudio_dcvdec_so}

	audio_primary_amlogic_so=$(find ${SDK_OUT_PATH}/vendor/lib/ -name  "audio.primary.amlogic.so")
	md5sum_check_save 	${audio_primary_amlogic_so}

}


function tdk_bl32_module()
{
	BLUE "md5sum tdk_bl32_module start ..."

	tdk_bl32_arrays=($(find ${SDK_CODE_PATH}/vendor/amlogic/common/tdk/ -name "bl32*" | grep -E "g12a|gx"))

	for ((i = 0; i < ${#tdk_bl32_arrays[@]}; i++)); do
		tdk_bl32_name="${tdk_bl32_arrays[i]}"
		md5sum_check_save 	${tdk_bl32_name}
	done
}


function kernel_di_module()
{
	BLUE "md5sum kernel_di_module start ..."

	kernel_di_ko=$(find ${SDK_OUT_PATH}/obj/KERNEL_OBJ/ -name "di.o")
	md5sum_check_save 	${kernel_di_ko}
}


function framwork_media_audio_module()
{
	BLUE "md5sum framwork_media_audio_module start ..."

	framwork_media_arrays=($(find ${SDK_OUT_PATH}/system/lib/ -name "libmedia*"))

	for ((i = 0; i < ${#framwork_media_arrays[@]}; i++)); do
		framwork_media_name="${framwork_media_arrays[i]}"
		md5sum_check_save 	${framwork_media_name}
	done

	framwork_audio_arrays=($(find ${SDK_OUT_PATH}/system/lib/ -name "libaudio*"))

	for ((i = 0; i < ${#framwork_audio_arrays[@]}; i++)); do
		framwork_audio_name="${framwork_audio_arrays[i]}"
		md5sum_check_save 	${framwork_audio_name}
	done
}


#############################################################################
#扫描SDK out以及源码关于音视频相关的so
#	@参数1：SDK路径
#	@参数2：SDK编译完成后软件路径
#############################################################################
function scanso_tools()
{
	###############################################################
	#
	#主要检测以下模块
	#
	###############################################################

	#(1). libamnuplay.so模块
	echo "libamnuplay_module: -------------------------------------------------------------------------"	>> ${SDK_MEDIA_AUDIO_MANIFEST}
	libamnuplay_module
	echo ""	>> ${SDK_MEDIA_AUDIO_MANIFEST}


	#(2). OMX模块
	echo "omx_moudle: -------------------------------------------------------------------------"	>> ${SDK_MEDIA_AUDIO_MANIFEST}
	omx_moudle
	echo ""	>> ${SDK_MEDIA_AUDIO_MANIFEST}


	#(3). DRM_module模块
	echo "drm_module: -------------------------------------------------------------------------"	>> ${SDK_MEDIA_AUDIO_MANIFEST}
	drm_module
	echo ""	>> ${SDK_MEDIA_AUDIO_MANIFEST}


	#(4). media驱动ko模块
	echo "media_ko_module: -------------------------------------------------------------------------"	>> ${SDK_MEDIA_AUDIO_MANIFEST}
	media_ko_module
	echo ""	>> ${SDK_MEDIA_AUDIO_MANIFEST}


	#(5). h264解码库模块
	echo "h264_fw_module: -------------------------------------------------------------------------"	>> ${SDK_MEDIA_AUDIO_MANIFEST}
	h264_fw_module
	echo ""	>> ${SDK_MEDIA_AUDIO_MANIFEST}


	#(6). audio模块
	echo "audio_so_module: -------------------------------------------------------------------------" 	>> ${SDK_MEDIA_AUDIO_MANIFEST}
	audio_so_module
	echo ""	>> ${SDK_MEDIA_AUDIO_MANIFEST}


	#(7). tdk模块
	echo "tdk_bl32_module: -------------------------------------------------------------------------"	>> ${SDK_MEDIA_AUDIO_MANIFEST}
	tdk_bl32_module
	echo ""	>> ${SDK_MEDIA_AUDIO_MANIFEST}


	#(8). kernel di模块
	echo "kernel_di_module: -------------------------------------------------------------------------"	>> ${SDK_MEDIA_AUDIO_MANIFEST}
	kernel_di_module
	echo ""	>> ${SDK_MEDIA_AUDIO_MANIFEST}


	#(9). framwork模块
	echo "framwork_media_audio_module: -------------------------------------------------------------------------"	>> ${SDK_MEDIA_AUDIO_MANIFEST}
	framwork_media_audio_module
	echo ""	>> ${SDK_MEDIA_AUDIO_MANIFEST}

}



function main()
{
	#${1}:	SDK code
	#${2}:	SDK out product

	SDK_CODE_PATH=${1}
	SDK_OUT_PATH=${2}


	if [[ ! -z $(echo ${ROOT_DIR}) ]]; then
		if [ -f ${SDK_MEDIA_AUDIO_MANIFEST} ]; then
			rm -f ${SDK_MEDIA_AUDIO_MANIFEST}
		else
			touch ${SDK_MEDIA_AUDIO_MANIFEST}
		fi
	else
		if [ -f ${SDK_MEDIA_AUDIO_MANIFEST_DEFAULT} ]; then
			rm -f ${SDK_MEDIA_AUDIO_MANIFEST_DEFAULT}
		else
			touch ${SDK_MEDIA_AUDIO_MANIFEST_DEFAULT}
		fi
		SDK_MEDIA_AUDIO_MANIFEST=${SDK_MEDIA_AUDIO_MANIFEST_DEFAULT}
	fi



	if [[ -z ${SDK_CODE_PATH} ]] || [[ -z ${SDK_OUT_PATH} ]]; then
		echo "Miss SDK parameters failed!!! ($LINENO)"
		exit 1
	fi

	scanso_tools

}


main $@

