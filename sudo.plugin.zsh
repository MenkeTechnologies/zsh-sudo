#!/usr/bin/env zsh
#{{{                    MARK:Header
#**************************************************************
##### Author: MenkeTechnologies
##### GitHub: https://github.com/MenkeTechnologies
##### Date: Wed Sep 23 16:00:38 EDT 2020
##### Purpose: zsh script to add sudo back to line
##### Notes: 
#}}}***********************************************************
if [[ -z "$ZPWR_SUDO_CMD" ]]; then
    export ZPWR_SUDO_CMD='sudo -E'
    
fi

sudo-command-line() {
    [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"

    # Save beginning space
    local WHITESPACE=""
    if [[ ${LBUFFER:0:1} == " " ]] ; then 
        WHITESPACE=" "
        LBUFFER="${LBUFFER:1}"
    fi

    if [[ -n $EDITOR && $BUFFER == $EDITOR\ * ]]; then
        if (( ${#LBUFFER} <= ${#EDITOR} )); then
            RBUFFER=" ${BUFFER#$EDITOR }"
            LBUFFER="$ZPWR_SUDO_CMD $EDITOR"
        else
            LBUFFER="sudoedit ${LBUFFER#$EDITOR }"
        fi
    elif [[ $BUFFER == sudoedit\ * ]]; then
        if (( ${#LBUFFER} <= 8 )); then
            RBUFFER=" ${BUFFER#$ZPWR_SUDO_CMD $EDITOR }"
            LBUFFER="$EDITOR"
        else
            LBUFFER="$EDITOR ${LBUFFER#$ZPWR_SUDO_CMD $EDITOR }"
        fi
    elif [[ $BUFFER == 'sudo '* ]]; then
        if (( ${#LBUFFER} <= 4 )); then
            RBUFFER="${BUFFER#$ZPWR_SUDO_CMD }"
            LBUFFER=""
        else
            LBUFFER="${LBUFFER#$ZPWR_SUDO_CMD }"
        fi
    else
        LBUFFER="$ZPWR_SUDO_CMD $LBUFFER"
    fi

    # Preserve beginning space
    LBUFFER="${WHITESPACE}${LBUFFER}"
}

zle -N sudo-command-line

