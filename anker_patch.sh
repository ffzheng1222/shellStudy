#!/bin/bash

#echo "sdmc patch"

GREEN='\e[0;32m'
YELLOW='\e[1;33m'
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

YELLOW()
{
    echo -e  "${YELLOW}$1${END}"
}

FILENAME=$1
SDMC_PATCH_DIR=$(pwd)
MERLOG_LOG=$(pwd)/merger_patch.log
RECALL_NUM=50
SDMC_SUBMIT_LOG=$(pwd)/sdmc_submit_log.txt
SDMC_SUBMIT_PATH=$(pwd)/sdmc_submit_patch.txt
#echo "FILENAME = $FILENAME"
#由于patch有so,ko,apk这些文件合并时容易出错所以直接拷贝指定的so,ko,apk到patch所指定的目录
function merger_binary()
{
#	echo "$1 == $2 == $3 == $4 == $5"
	grep -w $2 ./$5/$1 | grep "diff --git" > $2.text
	if [ $? -eq 0 ];then
	while read LINE
	do
#		echo "$LINE"
		subString_length=${#2}
		subString_length=$(($subString_length + 1))
#		echo "subString_length ====== $subString_length"
		tail_string=${LINE:0-subString_length:subString_length}
#		echo "tail_string ====== $tail_string"
		if [ $tail_string == .$2 ];then
			file_name=${LINE##*" b/"}
			if  [[ $file_name =~ $2 ]];then #判断$2是否是$file_name子串，用以处理文件路径中包含so,apk,ko等字符而引起的错误操作
				dest_path=$3/$4/$file_name
#				echo ${dest_path%/*}
				mkdir -p ${dest_path%/*}
#				echo "dest_path ====== $dest_path"
				cp ./$5/source_code/$4/$file_name $3/$4/$file_name
			fi
		fi
	done < $2.text
	fi
	
	rm $2.text
}

#判断提交是否成功
function Submit_legality()
{
		
		git status | grep ".rej"
		if [ $? -eq 0 ];then
		{
			return 0;
		}
		else
		{
			return 1;
		}
		fi
		
		git log --stat -1 | grep -q "$1"
		if [ $? -eq 0 ];then
		{
			return 1;
		}
		else
		{
			return 0;
		}
		fi
}

function parse_line()
{
if [ ${1:0:1} = '#' ];then #获取参数1的第一个字符，判断是否是注释 第一个1表示参数，0：1表示取从第零个字符起取1个字符
{
	return
}
fi

OLD_IFS="$IFS" 
IFS="&" 

arr=($1) 
IFS="$OLD_IFS"
i=0
for s in ${arr[@]} 
do	
	i=$(($i + 1))
	if [ $i = '1' ]
	then
		patch_path=$s
		temp=${s:5}
		commit=${s//\-/\ } #将”-“替换成空格，用作提交的注释
#		echo "$commit"
	else
		path=${s%%"|"*}
		patch=${s##*"|"}
		cd $(pwd)/$3/$patch_path
#		pwd
		cp ${patch} $2/$path
		if [ $? -eq 1 ];then
		{
			RED "$3/$patch_path/$patch patch Merge Failure @_@"
			exit
		}
		fi
		
		cd - >> $MERLOG_LOG
		
		cd $2/$path

		git log -$RECALL_NUM | grep "sdmc:$commit" >> $MERLOG_LOG
		if [ $? -eq 0 ];then
		{
			rm ${patch}
			GREEN "$3/$patch_path/$patch patch has been merged T_T"
		}
		else
		{
			patch -p1 < ${patch}  >> $MERLOG_LOG
			rm ${patch}

			#合并so,ko,apk等二进制文件
			cd - >> $MERLOG_LOG
			merger_binary ${patch} so $2 $path $3/$patch_path
			merger_binary ${patch} ko $2 $path $3/$patch_path
			merger_binary ${patch} apk $2 $path $3/$patch_path
			merger_binary ${patch} o $2 $path $3/$patch_path
			merger_binary ${patch} a $2 $path $3/$patch_path
			merger_binary ${patch} hcd $2 $path $3/$patch_path
			merger_binary ${patch} png $2 $path $3/$patch_path
			merger_binary ${patch} bmp $2 $path $3/$patch_path
			merger_binary ${patch} bin $2 $path $3/$patch_path
			merger_binary ${patch} bl2 $2 $path $3/$patch_path
			merger_binary ${patch} tpl $2 $path $3/$patch_path
			merger_binary ${patch} img $2 $path $3/$patch_path
			merger_binary ${patch} sig $2 $path $3/$patch_path
			merger_binary ${patch} elf $2 $path $3/$patch_path
			merger_binary ${patch} ta $2 $path $3/$patch_path
			merger_binary ${patch} k1a $2 $path $3/$patch_path
			merger_binary ${patch} fex $2 $path $3/$patch_path
			merger_binary ${patch} tlv $2 $path $3/$patch_path
			merger_binary ${patch} dat $2 $path $3/$patch_path
			merger_binary ${patch} pk8 $2 $path $3/$patch_path
			merger_binary ${patch} le $2 $path $3/$patch_path

			if [ -d "$3/$patch_path/source_code_bin/" ];then
			{
				cp -rfp $3/$patch_path/source_code_bin/* $2/
			}
			fi

			cd $2/$path
			
			find . -name "*.orig" -exec rm {} \;
			
			Submit_legality $commit
			if [ $? -eq 1 ];then
			{
				GREEN "$3/$patch_path/$patch patch successful merger ^_^"
			}
			else
			{
				RED "$3/$patch_path/$patch patch Merge Failure @_@"
				exit
			}
			fi
							
			git add -A ./
			git commit -m "sdmc:$commit" --no-verify  >> $MERLOG_LOG
			if [ $? -eq 1 ];then
			{
				RED "$3/$patch_path/$patch patch Merge Failure @_@"
				exit
			}
			fi
		}
		fi
		
		cd - >> $MERLOG_LOG
		pwd >> $MERLOG_LOG
#		echo "$patch_path"
		
#		echo "$path/$patch"
	fi
	
done
}

function reparse_line()
{
#if [ ${1:0:1} = '#' ];then #获取参数1的第一个字符，判断是否是注释 第一个1表示参数，0：1表示取从第零个字符起取1个字符
#{
#	return
#}
#fi

OLD_IFS="$IFS" 
IFS="&" 

arr=($1) 
IFS="$OLD_IFS"
i=0
for s in ${arr[@]} 
do	
	i=$(($i + 1))
	
	if [ $i = '1' ]
	then
		patch_path=$s
		temp=${s:5}
		commit=${temp//\-/\ } #将”-“替换成空格，用作提交的注释
#		echo "$commit"
	else
		path=${s%%"|"*}	
		patch=${s##*"|"}
		cd $2/$path
		git log -$RECALL_NUM | grep "sdmc:" >> $MERLOG_LOG
		if [ $? -eq 0 ]; then
		{
			git reset --hard HEAD^ >> $MERLOG_LOG
			echo "reset $3/$patch_path/$patch patch <>_<>"
		}
		else
		{
			echo "$3/$patch_path/$patch patch has been reset O_O"
		}
		fi
	fi
done
}

function reparse_line_one_commit()
{
	cd $2

	repo forall -p -c git log -1 | grep "sdmc:" -B 5 > $SDMC_SUBMIT_LOG
	if [ $? -eq 0 ]; then
	{
		sed -n '/^project/p' $SDMC_SUBMIT_LOG > $SDMC_SUBMIT_PATH
		while read LINE
		do
			echo ${LINE:8:${#LINE}-9}
			repo forall -p ${LINE:8:${#LINE}-9} -c git reset --hard HEAD^
		done < $SDMC_SUBMIT_PATH

		echo "reset $3/$patch_path/$patch patch <>_<>"

		rm $SDMC_SUBMIT_LOG $SDMC_SUBMIT_PATH
	}
	else
	{
		echo "$3/$patch_path/$patch patch has been reset O_O"
	}
	fi
}

function push_patch()
{
if [ ${1:0:1} = '/' ];then #sdk patch 路径必须是相对路径
{
	RED "Parameter Two errors"
	return
}
fi

sdk_patch=${1%"/"*} #截取sdk patch path

touch $MERLOG_LOG
chmod 666 $MERLOG_LOG

common_patch=$sdk_patch/patch_list_com.txt
anker_common_patch=$sdk_patch/patch_list_s905x_Anker_com.txt

if [ "$3" = "" ];then
	if [ -e "$common_patch" ];then
		while read LINE
		do
			parse_line ${LINE:0:${#LINE}-1} $2 $sdk_patch #${LINE:0:${#LINE}-1} 去掉行后面的'/r'换行符
		done < $common_patch

		YELLOW "\ncommon_patch merged done!\n"
	fi
	
	if [ -e "$anker_common_patch" ];then
		while read LINE
		do
			parse_line ${LINE:0:${#LINE}-1} $2 $sdk_patch #${LINE:0:${#LINE}-1} 去掉行后面的'/r'换行符
		done < $anker_common_patch

		YELLOW "\nanker_common_patch merged done!\n"
	fi

	while read LINE
	do
		parse_line ${LINE:0:${#LINE}-1} $2 $sdk_patch #${LINE:0:${#LINE}-1} 去掉行后面的'/r'换行符
	done < $1

	rm $2/vendor/sdmc 2>/dev/null
	if [[ $1 =~ "amlogic" ]]&&[ ! -d "$2/vendor/sdmc" ];then
	    ln -s $PWD/$sdk_patch/../vendor/amlogic $2/vendor/sdmc
	fi

	if [[ $1 =~ "his" ]]&&[ ! -d "$2/vendor/sdmc" ];then
	    mkdir -p $2/vendor
	    ln -s $PWD/$sdk_patch/../vendor/his $2/vendor/sdmc
	fi

	echo "#### push_patch  time : `date`" > $2/${FILENAME##*/}
	echo -e "#### which patch_list : "$SDMC_PATCH_DIR/$1"" >> $2/${FILENAME##*/}
	echo -e "####" >> $2/${FILENAME##*/}
	if [ -e "${FILENAME%/*}/patch_list_com.txt" ];then
		cat ${FILENAME%/*}/patch_list_com.txt >> $2/${FILENAME##*/}
	fi

	if [ -e "${FILENAME%/*}/patch_list_s905x_Anker_com.txt" ];then
		cat ${FILENAME%/*}/patch_list_s905x_Anker_com.txt >> $2/${FILENAME##*/}
	fi

	cat $1 >> $2/${FILENAME##*/}

fi


if [ "$3" = "-r" ];then
	rm $2/vendor/sdmc
	rm $2/${FILENAME##*/}
	tac $1 | while read LINE
	do
		reparse_line ${LINE:0:${#LINE}-1} $2 $sdk_patch #${LINE:0:${#LINE}-1} 去掉行后面的'/r'换行符
	done 

	if [ -e "$anker_common_patch" ];then
		tac $anker_common_patch | while read LINE
		do
			reparse_line ${LINE:0:${#LINE}-1} $2 $sdk_patch #${LINE:0:${#LINE}-1} 去掉行后面的'/r'换行符
		done 
	fi
	
	if [ -e "$common_patch" ];then
		tac $common_patch | while read LINE
		do
			reparse_line ${LINE:0:${#LINE}-1} $2 $sdk_patch #${LINE:0:${#LINE}-1} 去掉行后面的'/r'换行符
		done 
	fi

	reparse_line_one_commit $1 $2 $3

fi


if [ "$3" = "-ro" ];then
	rm $2/vendor/sdmc
	rm $2/${FILENAME##*/}
	tac $1 | while read LINE
	do
	#	echo "$LINE"
		
		reparse_line ${LINE:0:${#LINE}-1} $2 $sdk_patch #${LINE:0:${#LINE}-1} 去掉行后面的'/r'换行符
	#	PATCH_ONE=${LINE#*"&"}
	#	PATCH_TWO=${PATCH_ONE#*"&"}
	#	echo "$PATCH_ONE"
	#	echo "$PATCH_TWO"
	done 
fi

rm $MERLOG_LOG
}

push_patch $FILENAME $2 $3
