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

if ! (( $+ZPWR_SUDO_REGEX )); then
    export ZPWR_SUDO_REGEX='sudo'
fi

sudo-command-line() {
    [[ -z "$BUFFER" ]] && LBUFFER="$(builtin fc -ln -1)"

    # notice in this regex how 1 or more required sudo
    if [[ $LBUFFER =~ ^([[:space:]]*)(([\\\"\']*builtin[\\\"\']*[[:space:]]+)*[\\\"\']*command[\\\"\']*)?([[:space:]]*)(([\\\"\']*"$ZPWR_SUDO_REGEX"[\\\"\']*([[:space:]]+)((-[ABbEHnPSis]+[[:space:]]*|-[CghpTu][[:space:]=]+[[:alpha:]]+[[:space:]]+|--)*)*)+([\\\"\']*env[\\\"\']*[[:space:]]+(-[iv]+[[:space:]]*|-[PSu][[:space:]=]+[[:alpha:]]+[[:space:]]+|--)*)*)+(.*)$ ]]; then
        # sudo wiith all args
        # white space before sudo and cmd
        LBUFFER="$match[1]$match[12]"
    # notice in this regex how 1 or more required sudo
    elif [[ $RBUFFER =~ ^([[:space:]]*)(([\\\"\']*builtin[\\\"\']*[[:space:]]+)*[\\\"\']*command[\\\"\']*)?([[:space:]]*)(([\\\"\']*"$ZPWR_SUDO_REGEX"[\\\"\']*([[:space:]]+)((-[ABbEHnPSis]+[[:space:]]*|-[CghpTu][[:space:]=]+[[:alpha:]]+[[:space:]]+|--)*)*)+([\\\"\']*env[\\\"\']*[[:space:]]+(-[iv]+[[:space:]]*|-[PSu][[:space:]=]+[[:alpha:]]+[[:space:]]+|--)*)*)+(.*)$ ]]; then
        RBUFFER="$match[1]$match[12]"
    else
        LBUFFER="$ZPWR_SUDO_CMD $LBUFFER"
    fi


}

zle -N sudo-command-line

