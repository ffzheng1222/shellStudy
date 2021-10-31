#!/bin/sh

scan_dir=$1
commit_note=$2
patch_num=$3
tmp_file=~/tmp/git_modified_files.txt
src_code=$PWD/$commit_note/source_code/

function check_err()
{	
	#echo "$2, ret $1"
	if [ $1 != "0" ] 
	then
		echo "$2 failed, ret $1 path:$PWD"
		exit 1
    	else  
        	return 0  
    	fi 
}

function is_need_to_commit()
{
	cd $1
	ret=`git status | grep 'modified'`
	ret1=`git status | grep 'Untracked files'`
	cd -
	if [ "$ret" != "" ] || [ "$ret1" != "" ] ;then 
		return 1;
	fi
	return 0
}

function gen_git_patch()
{
#	ret3=`git show --stat $PWD | grep '|'`
	ret3=`git show --name-status $PWD`
        echo "$ret3" > $tmp_file
	x=0
        while read LINE
        do
		str_first=${LINE:0:1}
		x=$((x += 1))
		if [ $x -lt 7 ];then
			echo $LINE
			continue
		fi
		case $str_first in
		'A'|'M')
			path=${LINE:2}
#                echo "path:$path"
	                path_dir=`dirname $path`
        	        patch_file="$PWD"/"$path"
 #               echo $patch_file
                	mkdir -p "$src_code"/"$scan_dir"/"$path_dir"
                	cp $patch_file  "$src_code"/"$scan_dir"/"$path_dir"
		;;
		*) continue ;;
		esac
	
        done < $tmp_file
#       rm $tmp_file
}

function git_commit()
{
	is_need_to_commit $1
	if [ $? != "1" ];then
		return 0
	fi
	cd $1
	git add ./ -A
	check_err $? "git add ./ -A"
	git commit -am $commit_note --no-verify
	check_err $? "git commit"
	Tempname=` echo ${1} | sed 's#\/#\\-#g'`
	ret2=${1: -1}
	if [ $ret2 == "/" ];then
		git show > $src_code/../00$patch_num-$Tempname${commit_note:5}.patch
		check_err $? "git show"
	else
		git show > $src_code/../00$patch_num-$Tempname-${commit_note:5}.patch
		check_err $? "git show"
	fi
	gen_git_patch $1
	git reset HEAD~1
	cd -
}

function scan_file_first()
{
        for file in `ls $1`
        do
        #if [ $file = $check_file ] 
        if [ -d $1"/"".git" ];then
                echo $1"/"".git"
#		is_need_to_commit $1
		git_commit $1
#		echo $?
                return
#		break
        fi
        done

        for file in `ls $1`
        do
        if [ -d $1"/"$file ];then
                scan_file_first $1"/"$file
        fi
        done
}


if [ $# != "3" ];then
	echo "help:"
	echo "./sdmc_patch_creat.sh  modify_dir patch_dir num"
	echo "modify_dir:  the dir need to scan and gen the patch"
	echo "patch_dir: the dir use for patch,also the note"
	echo "num:the gen patch num"
else
	#is_need_to_commit $1
	mkdir -p $src_code
	scan_file_first $scan_dir
	#git_commit $scan_dir
fi
