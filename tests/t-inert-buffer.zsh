#!/usr/bin/env zunit
#{{{                    MARK:Header
#**************************************************************
##### Author: MenkeTechnologies
##### GitHub: https://github.com/MenkeTechnologies
##### Purpose: zsh-sudo — buffer-inertness pins.
#####          The widget rewrites BUFFER/LBUFFER/RBUFFER as INERT
#####          string data via `LBUFFER="$match[1]$match[-1]"`. It
#####          must never glob-expand, command-substitute, or eval
#####          the user's line — the buffer is about to run under
#####          sudo, so any in-widget expansion is a privilege bug.
#####          Also pins multibyte (UTF-8) survival through both the
#####          add and remove branches, where [[:graph:]] regex
#####          classes are a common multibyte-mangling source.
#}}}***********************************************************

@setup {
    0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
    0="${${(M)0:#/*}:-$PWD/$0}"
    pluginDir="${0:h:A}"
    source "$pluginDir/sudo.plugin.zsh"
    unset ZPWR_SUDO_CMD
    unset ZPWR_SUDO_REGEX
    source "$pluginDir/sudo.plugin.zsh"
}

# Remove branch must NOT glob-expand the surviving tail. A naive
# unquoted `LBUFFER=$match[-1]` (or any `eval`) would expand `*.txt`
# against the cwd; the literal glob token must survive byte-for-byte.
@test 'remove-sudo keeps glob token literal (no filename expansion)' {
    BUFFER="sudo /tmp/zsudo_does_not_exist_*.txt"
    LBUFFER="sudo /tmp/zsudo_does_not_exist_*.txt"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "/tmp/zsudo_does_not_exist_*.txt"
}

# Add branch must NOT run command substitution. If the widget ever
# eval'd the buffer, `$(...)` would execute at toggle time — here it
# would create a sentinel file. We assert both: the text is preserved
# literally AND the side-effect file was never created.
@test 'add-sudo does not execute command substitution in buffer' {
    local sentinel="/tmp/zsudo_cmdsubst_sentinel_$$"
    command rm -f "$sentinel"
    BUFFER="echo \$(touch $sentinel)"
    LBUFFER="echo \$(touch $sentinel)"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "sudo echo \$(touch $sentinel)"
    [[ ! -e "$sentinel" ]]
    local existed=$?
    command rm -f "$sentinel"
    assert $existed equals 0
}

# Multibyte command survives the add branch byte-identically. A regex
# or capture that splits on bytes rather than characters would corrupt
# the trailing UTF-8 sequence (é = 0xC3 0xA9).
@test 'add-sudo preserves multibyte UTF-8 command' {
    BUFFER="café --naïve"
    LBUFFER="café --naïve"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "sudo café --naïve"
}

# Multibyte command survives the remove branch byte-identically. The
# remove path runs the regex and re-emits $match[-1]; multibyte tail
# must round-trip with no mojibake.
@test 'remove-sudo preserves multibyte UTF-8 command' {
    BUFFER="sudo café --naïve"
    LBUFFER="sudo café --naïve"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "café --naïve"
}
