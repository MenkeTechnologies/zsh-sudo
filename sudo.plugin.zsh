#!/usr/bin/env zsh
#{{{                    MARK:Header
#**************************************************************
##### Author: MenkeTechnologies
##### GitHub: https://github.com/MenkeTechnologies
##### Date: Wed Sep 23 16:00:38 EDT 2020
##### Purpose: zsh script to add sudo back to line
##### Notes: 
#}}}***********************************************************
if ! (( $+ZPWR_SUDO_CMD )); then
    export ZPWR_SUDO_CMD='sudo'
fi

sudo-command-line() {
    [[ -z "$BUFFER" ]] && LBUFFER="$(builtin fc -ln -1)"

    if [[ $LBUFFER =~ ([[:space:]]*)sudo([[:space:]]*)((-[ABbEHnPSis]+[[:space:]]+|-[CghpTu][[:space:]]*[[:alpha:]]+[[:space:]]*)*)([[:space:]]*)(.*) ]]; then
        # white space before command
        ZPWR_SUDO_PRECMD_WS="$match[5]"
        # sudo wiith all args
        ZPWR_SUDO_PREV_SUDO_OPTS="sudo$match[2]$match[3]"
        # white space before sudo and cmd
        LBUFFER="$match[1]$match[6]"
    elif [[ $RBUFFER =~ ([[:space:]]*)sudo([[:space:]]*)((-[ABbEHnPSis]+[[:space:]]+|-[CghpTu][[:space:]]*[[:alpha:]]+[[:space:]]*)*)([[:space:]]*)(.*) ]]; then
        ZPWR_SUDO_PRECMD_WS="$match[5]"
        ZPWR_SUDO_PREV_SUDO_OPTS="sudo$match[2]$match[3]"
        RBUFFER="$match[1]$match[6]"
    else
        LBUFFER="$ZPWR_SUDO_CMD $LBUFFER"
    fi

}

zle -N sudo-command-line

