#!/bin/bash
################################################################
#
# shell_color_show.sh  
#       Show shell color... 
#       
################################################################

GREEN='\e[0;32m'
YELLOW='\e[1;33m'
RED='\e[1;31m'
BLUE='\e[0;34m'
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

BLUE()
{
	echo -e  "${BLUE}$1${END}"
}
