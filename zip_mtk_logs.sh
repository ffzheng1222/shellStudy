#! /bin/bash
################################################################
#
#mtk_logs_extrack.sh.sh   
#   Extrack GMS log to mtk.
#       
################################################################

LOGS_PATH="logs_mtk"
GMS_PATH=~/GMS/android8/
TOOLRESULT=""
CLEAN_EXIS_FILE=""

SHELL_PATH=$(echo $PATH | egrep -o '[^:]+shell')

#show shell color
. $SHELL_PATH/shell_color_show.sh


function is_clean_file() {
    read -p "Do you want to clean $1 file?(y/n): " answer
    if [ "y" = $answer ]; then 
        rm -rf ~/$LOGS_PATH/${1}
        CLEAN_EXIS_FILE="yes"
    fi
}

function is_item_tool() {
    local items_tool_arr

    items_tool_arr=($(find ${GMS_PATH} -maxdepth 2 | cut -d8 -f2 | egrep  'r|R' | grep -v 'media' | cut -d/ -f3))
    
    if [[ ! "${items_tool_arr[*]}" =~ ${1} ]]; then 
        RED "error: gms items tools exist!"
        exit 1
    fi
    TOOLRESULT=${1}
}


function parse_arguments() {

     gmslogs=($*)
     
     gms_item=${gmslogs[0]}
     item_tool=${gmslogs[1]}
  
     if [[ "$#" -gt 2 ]]; then 
        for ((i = 2; i < ${#gmslogs[@]}; i++)); do
	    
            logfile=${gmslogs[i]}          
  
            if GREEN $logfile | egrep '^[0-9._]+$'  ; then

                extrack_args=($gms_item $item_tool $logfile)

                do_extrack_logs "${extrack_args[*]}"

            else
                RED "error: ${gmslogs[i]} Unknown file name grade!"
                continue
            fi
            
            if [[ ! $? ]]; then
                RED "fail: ${gmslogs[i]} extrack failed!"
                continue
            fi
        done
    
    else    
        GREEN "Usage: mtk_logs_extrack.sh [GMS item][GMS tool version][log file name]"
        exit 1  
    fi
}


function do_extrack_logs() { 
    cd ~/$LOGS_PATH
 
    extrack_arr=(${1})
    
    extrack_gms_item=${extrack_arr[0]}
    extrack_item_tool=${extrack_arr[1]}
    extrack_file_name=${extrack_arr[2]}
    
    is_item_tool $extrack_item_tool
    
  
    #create logs Folder
    if [ -d $extrack_file_name ]; then
    
        is_clean_file $extrack_file_name   
	
    	if [ ! $CLEAN_EXIS_FILE ]; then
       	    YELLOW "warning: Don't rm $extrack_file_name file!"
            exit 1
    	else
            mkdir -p ~/$LOGS_PATH/$extrack_file_name
    	fi 
    else 
        mkdir -p ~/$LOGS_PATH/$extrack_file_name
    fi
    
    
    #zip log.zip and copy result.zip 
    cp  -raf ${GMS_PATH}$extrack_gms_item/$TOOLRESULT/android-${extrack_gms_item}/results/$extrack_file_name.zip \
        ./$extrack_file_name/
    
    mv  ./$extrack_file_name/${extrack_file_name}.zip  \
        ./$extrack_file_name/results.zip
    
    
    zip -r  ./$extrack_file_name/${extrack_file_name}_log.zip  \
        ${GMS_PATH}$extrack_gms_item/$TOOLRESULT/android-${extrack_gms_item}/logs/$extrack_file_name/
        
    mv  ./$extrack_file_name/${extrack_file_name}_log.zip  \
        ./$extrack_file_name/logs.zip
    
    cd - 1> /dev/null   

    GREEN "==========zip log success!================="
    
    return $?
}

function main() {
    parse_arguments $*
}

main $@
