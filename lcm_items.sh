#! /bin/bash
################################################################
#lcm_items.sh   
#    The statistical platform LCM drives to items.ini
#
################################################################

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



git_lcm_temp="git_lcm_temp"
lcm_info_items="lcm_info_items.txt"
git_lcm_temp_txt1="git_lcm_temp1.txt"
git_lcm_temp_txt2="git_lcm_temp2.txt"
git_lcm_temp_txt3="git_lcm_temp3.txt"
special_handle_lcm="special_handle_lcm.txt"
repeat_git_lcm="repeat_git_lcm.txt"



function great_temp_file()
{
    if [ -d $git_lcm_temp ]; then
        rm -rf $git_lcm_temp
    fi
    mkdir  $git_lcm_temp
    
    git log --pretty=format:"%s"  --grep=LCM \
        --oneline  --author=jh.wei > $git_lcm_temp/$git_lcm_temp_txt1
    cat $git_lcm_temp/$git_lcm_temp_txt1 | \
        sed -i 's/\"/@/g' $git_lcm_temp/$git_lcm_temp_txt1
}
 
function rm_temp_file()
{
    if [ -d $git_lcm_temp ]; then 
        rm -rf $git_lcm_temp
    else
        YELLOW "$git_lcm_temp is not exist"
    fi
}
 
function git_lcm_info_handle()
{
    cat $git_lcm_temp/$git_lcm_temp_txt1 | \
        grep -v "update" | grep -E '\-.*>|[\(\)|（）]' > $git_lcm_temp/$git_lcm_temp_txt2

    cat $git_lcm_temp/$git_lcm_temp_txt2 | \
        grep -v "LCM: " | sed -i 's/LCM[ ]*:/LCM: /g' $git_lcm_temp/$git_lcm_temp_txt2

    cat $git_lcm_temp/$git_lcm_temp_txt2 | \
        awk '{ for(i=1;i<=2;i++){$i="" }; print $0 }' > $git_lcm_temp/$git_lcm_temp_txt1
    
    #storge git_log_lcm info 
    cat $git_lcm_temp/$git_lcm_temp_txt1 | \
        grep -v '^[ ]*k' | sed -i 's/[^k]*//' $git_lcm_temp/$git_lcm_temp_txt1
    
    # storge git_log_lcm_drive  
    cat $git_lcm_temp/$git_lcm_temp_txt1 | \
        awk '{print $1}' | sort | uniq > $git_lcm_temp/$git_lcm_temp_txt2
    
}  


function read_lcm_temp_txt()
{
    cat /dev/null > $git_lcm_temp/$repeat_git_lcm
    for  i  in  $(cat $git_lcm_temp/$git_lcm_temp_txt2); do
        num=0
        cat /dev/null > $git_lcm_temp/$git_lcm_temp_txt3
        
        while read LINE; do 
            if [ $i == $(echo $LINE | cut -f1 -d' ') ]; then   
                echo "$LINE" >> $git_lcm_temp/$git_lcm_temp_txt3
                ((num=$num + 1))
            fi    
        done  < $git_lcm_temp/$git_lcm_temp_txt1
        
        if [ $num -gt 1 ]; then 
            check_special_lcm $git_lcm_temp/$git_lcm_temp_txt3
        fi
    done
}

function check_special_lcm()
{
    
    for special_lcm in $(cat $1 | awk '{print $1}' | uniq ); do
        cat /dev/null > $git_lcm_temp/$git_lcm_temp_txt2
        # echo "***$special_lcm"
        cat $1 | while read special_LINE; do
            # echo "$special_LINE"
            if [ $special_lcm == $(echo $special_LINE | cut -f1 -d' ') ]; then
                echo "$special_LINE" >> $git_lcm_temp/$git_lcm_temp_txt2
            fi
        done 
        
        cat $git_lcm_temp/$git_lcm_temp_txt2 | \
            grep "兼容" > $git_lcm_temp/$special_handle_lcm 
         
        if [ -s $git_lcm_temp/$special_handle_lcm ]; then  
            cat $git_lcm_temp/$git_lcm_temp_txt2 | \
                grep -v "兼容" >> $git_lcm_temp/$repeat_git_lcm   
        else
            cat $git_lcm_temp/$git_lcm_temp_txt2 | \
                grep -v -E '[\(\)|（）][[:blank:]]*$' >> $git_lcm_temp/$repeat_git_lcm 
        fi
    done
}

function get_lcm_info_items()
{
    cat $git_lcm_temp/$repeat_git_lcm | while read REPEAT_LINE; do
        while read ALL_LCM_LINE; do
            if [ "$REPEAT_LINE" == "$ALL_LCM_LINE" ]; then 
                # echo "$ALL_LCM_LINE"
   
                local ALL_LCM_LINE_SYMBOL
                ALL_LCM_LINE_SYMBOL=$(regular_handle  "$ALL_LCM_LINE")
                # GREEN  "$ALL_LCM_LINE_SYMBOL"

                sed  -i "/$ALL_LCM_LINE_SYMBOL[[:blank:]]*$/ d" $git_lcm_temp/$git_lcm_temp_txt1 
        
            fi
        done < $git_lcm_temp/$git_lcm_temp_txt1
    done
    cat $git_lcm_temp/$git_lcm_temp_txt1 | sed 's/@/"/g' > $lcm_info_items
}

   
function regular_handle()
{
    # echo  $1
    local lcm_regular_escape
    lcm_regular_escape=$1
    regular=(\\. \\^ \\$ \\? \\+ \\*) 
    
    for ((i = 0; i < ${#regular[@]}; i++)); do
        singl_regular=${regular[i]} 
        
        if [[ ! -z $(echo "$lcm_regular_escape" | grep "$singl_regular" - ) ]]; then
            # echo "$singl_regular"
            case $singl_regular in
                \\^) 
                    lcm_regular_escape=$(echo "${lcm_regular_escape//\^/\\^}") ;;
                \\.) 
                    lcm_regular_escape=$(echo "${lcm_regular_escape//\./\\.}") ;;
                \\*) 
                    lcm_regular_escape=$(echo "${lcm_regular_escape//\*/\\*}") ;;
                \\$) 
                    lcm_regular_escape=$(echo "${lcm_regular_escape//\$/\\$}") ;;
                \\?) 
                    lcm_regular_escape=$(echo "${lcm_regular_escape//\?/\\?}") ;;
                \\+) 
                    lcm_regular_escape=$(echo "${lcm_regular_escape//\+/\\+}") ;;
                 *) ;;
            esac
        fi    
    done
    echo $lcm_regular_escape
}   
      
   
great_temp_file   
git_lcm_info_handle

read_lcm_temp_txt
get_lcm_info_items

rm_temp_file


