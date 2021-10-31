#!/bin/bash
#auto_pack.sh	自动打包工具(包括OTA)

GREEN='\e[0;32m'
RED='\e[1;31m'
END='\e[0m'
RED()
{
	echo -e  "${RED}$1${END}"
}

GREEN()
{
	echo -e  "${GREEN}$1${END}"
}

SCRIPT_PATH=`which $0`
SCRIPT_PATH=${SCRIPT_PATH%/*}/config.ini
ISCOMPRESS=0

if [ $# != 2 -a $# != 0 ];then
	RED "usage：pack [project] [packname] or pack"
	exit
fi

#if [ ! -e .git ];then
#	RED "Error exec path!!!"
#	exit
#fi
if [ ! -e out ];then
	RED "No out dir!!!"
	exit
fi

if [ -e "$SCRIPT_PATH" ];then
	ISCOMPRESS=`awk -F"=" '{if(/^iscompress/)print $2}' "$SCRIPT_PATH"`
fi

OUT=./out/target/product/
PACK_PROJECT=`ls $OUT`

function showRocoProjectMenu(){
	i=1
    echo "=========================================================="
	for subproject in $PACK_PROJECT
	do
		if [ -d $OUT/$subproject ];then
			GREEN "$i.$subproject"
			i=$(($i+1))
		fi
	done
    echo "=========================================================="
}

function choosePackProject(){
	echo "What project do you want pack?:"
	read choose
	j=1
	for subproject in $PACK_PROJECT
	do
		
		if [ -d $OUT/$subproject ];then
			if [ "$choose" == "$j" ];then
				packproject=$subproject
			fi
			j=$(($j+1))
		fi
	done
	if [ -z "$packproject" ];then
		RED "Invialed input......."
		exit 1
	fi
}

function readDefaultPackName(){
    echo "Select:"
	read choose
	q=1
	for subproject in $DISPLAY $VERSION
	do
		if [ "$choose" == "$q" ];then
			TARGET=$subproject
			echo "$TARGET"
		fi
		q=$(($q+1))
	done

	if [ -z "$TARGET" ];then
		RED "Invialed input......."
	fi
}

function inputYourPackName(){
	echo "Input your pack name:"
	DISPLAY=`awk -F"=" '{if(/^ro.build.display.id/)print $2}' "out/target/product/$packproject/system/build.prop" `
	VERSION=`awk -F"=" '{if(/^ro.custom.build.version/)print $2}' "out/target/product/$packproject/system/build.prop" `

	echo "Do you want get default name?(y/n):"
	read cmd
	if [ $cmd = "y" ];then
        echo "=========================================================="
		k=1
		for subproject in $DISPLAY $VERSION
		do
			GREEN "$k.$subproject"
			k=$(($k+1))
		done

        echo "=========================================================="
		readDefaultPackName
	else
		GREEN "Input your pack name:"
		read packname
		TARGET=$packname
	fi
	#read packname
}

if [ $# == 0 ];then
    showRocoProjectMenu
    choosePackProject
    inputYourPackName
else
    packproject=$1
    TARGET=$2
fi

PROJECT=$packproject
HOMEDIR=$PWD/../
ROMDIR=$PWD/../ROM
OUTDIR=out/target/product/$PROJECT

if [ ! -e "$OUTDIR" ];then
	RED "$OUTDIR not found!!!"
	exit
fi

if [ ! -e "$OUTDIR"/*_Android_scatter.txt ];then
	RED "No found  Android_scatter.txt file in  "$OUTDIR" !!!"
	exit
fi

DESDIR=$HOMEDIR/$TARGET
if [ -e "mediatek/cgen/APDB_MT6582_S01_ALPS.JB5.TABLET.MP_" ];then
	Mode_databse1=mediatek/cgen/APDB_*
	Mode_databse2=mediatek/config/out/$PROJECT/modem/BPLGUInfoCustomAppSrcP*
elif [ -e "out/target/product/$PROJECT/obj/CODEGEN/" ];then
	Mode_databse1=out/target/product/$PROJECT/obj/CODEGEN/cgen/APDB_*
	Mode_databse2=out/target/product/$PROJECT/obj/CUSTGEN/config/modem/BPLGUInfoCustomAppSrcP*
elif [ -e "out/target/product/$PROJECT/obj/CGEN/" ];then
	Mode_databse1=out/target/product/$PROJECT/obj/CGEN/APDB_*
	Mode_databse2=out/target/product/$PROJECT/system/etc/mddb/BPLGUInfoCustomAppSrcP*
    # for android N, the file move to vendor
    if [ ! -e "out/target/product/$PROJECT/system/etc/mddb/" ]; then
        Mode_databse2=out/target/product/$PROJECT/system/vendor/etc/mddb/BPLGUInfoCustomAppSrcP*
        if [ ! $(ls $Mode_databse2 2>/dev/null) ]; then 
            Mode_databse2=out/target/product/$PROJECT/vendor/etc/mddb/BPLGUInfoCustomAppSrcP*
        fi
        if ls $Mode_databse2 > /dev/null 2>&1; then
            GREEN "etc/mddb/BPLG OK"
        else
            # for 8785, we use MDDB file 
            RED "You are using 8785 "
            Mode_databse2=out/target/product/$PROJECT/system/vendor/etc/mddb/MDDB*
        fi
    fi
fi	
	
DATABASEDIR=$HOMEDIR/$TARGET/DB
mkdir -p $DATABASEDIR
cp $Mode_databse1 $DATABASEDIR
cp $Mode_databse2 $DATABASEDIR

cd $OUTDIR
ALLFILE=`awk '/file_name/{T=$2;next}{if(/is_download/){if(/true/)print T;}}' *_Android_scatter.txt`

for i in $ALLFILE
do
	cp $i $DESDIR
	GREEN "copy $i "
done

for i in `ls`
do
    ISVERIFIED=`echo $i | grep   "verified" | wc -l`
    if [  $ISVERIFIED = 1 ];then
        cp $i $DESDIR
        GREEN "copy $i"
    fi
done
cp *_Android_scatter.txt $DESDIR
#sed -i '0,/is_download/{s/true/false/}' $DESDIR/*_Android_scatter.txt 
cp items*.ini $DESDIR
cd ->/dev/null
rm $DATABASEDIR/*_ENUM

if [ ! -e "$ROMDIR"/$TARGET ];then
	mkdir -p "$ROMDIR"/$TARGET
fi

if [ "$ISCOMPRESS" == 1 ];then
    GREEN "================>>begin compressing"
    cd "$HOMEDIR"
    tar czvfh $TARGET.tar.gz $TARGET
    GREEN "================>>Compressed OK!"
    mv $TARGET.tar.gz "$ROMDIR"/ -f
    cd ->/dev/null
fi

cd "$HOMEDIR"
mv $TARGET "$ROMDIR"/ -f
cd ->/dev/null

#==========================================================================
#@zf add part
FOTA_OTA="target_files-package.zip"
#---查找最近一次的编译命令,看是否编译OTA包
#IS_BUILD_OTA=$(history | grep make | egrep 'make\s+-j' | tail -1 | grep ota)

CUSTOM_OTA=$(ls -R $OUTDIR/obj/PACKAGING/ | grep "^full_mt8321.*\.zip")
CUSTOM_OTA_FILE_PATH=
if [ ! -z $CUSTOM_OTA ]; then
	CUSTOM_OTA_FILE_PATH=$(find $OUTDIR -name $CUSTOM_OTA)
	#---取得grep搜索文件的路径
	#CUSTOM_OTA_DIR_PATH=${CUSTOM_OTA_FILE_PATH%/*}
fi

ROM_OTA="OTA"

if [ -d $ROMDIR/$TARGET/$ROM_OTA ]; then 
	rm -rf $ROMDIR/$TARGET/$ROM_OTA
fi

function clean_verified(){
	local temp_verified_list=`find $ROMDIR -name *verified*`

	for temp_verified in $temp_verified_list; do
		rm -rf $temp_verified   
	done
	if [ -z $(find $ROMDIR -name *verified*) ]; then
		RED "verified file clean seccuss!"
	fi
}

function cp_ota(){	
	if [ -f $OUTDIR/$FOTA_OTA ]; then
		mkdir $ROMDIR/$TARGET/$ROM_OTA
		cp -raf $OUTDIR/$FOTA_OTA  $ROMDIR/$TARGET/$ROM_OTA
        RED "OTA copy complete!"                
	fi
	if [[ ! -f $OUTDIR/$FOTA_OTA && -f $CUSTOM_OTA_FILE_PATH ]]; then 
		mkdir $ROMDIR/$TARGET/$ROM_OTA
		cp -raf $CUSTOM_OTA_FILE_PATH  $ROMDIR/$TARGET/$ROM_OTA	
        RED "OTA copy complete!" 
    fi
}

function ota_continue(){
	read -p "Do you want to clean verified file?(y/n): " answer
	if [ "y" = $answer ]; then 
		clean_verified
	fi

	read -p "Do you want to cp OTA pack?(y/n): " my_choose
	if [ "y" = $my_choose ]; then 
		cp_ota
	fi
}


if [[ ! -f $OUTDIR/$FOTA_OTA && ! -f $CUSTOM_OTA_FILE_PATH ]]; then
	exit 1
else
	ota_continue
fi 



