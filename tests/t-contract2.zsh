#!/usr/bin/env zunit
#{{{                    MARK:Header
##### Purpose: zsh-sudo — second-tier contract pins.
#####          Cover widget registration, empty-BUFFER history
#####          fallback, plugin-file naming convention, default
#####          ZPWR_SUDO_REGEX matching only "sudo" (not "doas"
#####          by default), and absence of any bindkey side effect.
#}}}***********************************************************

@setup {
    0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
    0="${${(M)0:#/*}:-$PWD/$0}"
    pluginDir="${0:h:A}"
    pluginFile="$pluginDir/sudo.plugin.zsh"
}

@test 'zle -N sudo-command-line registers the widget at source-time' {
    # Pin: without the registration the widget is just a fn and the
    # user's `bindkey '^xs' sudo-command-line` would silently fail.
    grep -qE '^zle -N sudo-command-line' "$pluginFile"
    assert $? equals 0
}

@test 'plugin file is sudo.plugin.zsh (NOT zsh-sudo.plugin.zsh)' {
    # Pin: the entrypoint name is `sudo.plugin.zsh` for oh-my-zsh
    # compat (omz/plugins/sudo). Renaming to match the repo name
    # would break omz auto-load.
    assert "$pluginFile" is_file
}

@test 'plugin does NOT add any bindkey (binding is user choice)' {
    # Pin: zsh-sudo intentionally does NOT bind a key. The README
    # documents that the user picks their own. Adding a bindkey
    # would silently steal a keystroke (typically ESC-ESC or C-x s).
    local matches
    matches=$(grep -c '^bindkey ' "$pluginFile" || true)
    assert "$matches" same_as '0'
}

@test 'BUFFER empty path pulls last command from history via fc -ln -1' {
    # Pin: when buffer is empty, the widget pre-fills LBUFFER with
    # the previous command before sudo-toggling. Removing this would
    # leave the user with an empty `sudo ` line.
    grep -qE 'fc -ln -1' "$pluginFile"
    assert $? equals 0
}

@test 'ZPWR_SUDO_REGEX default is literal sudo (NOT alternation)' {
    # Pin: out of the box, only `sudo` is recognized. Users with
    # doas/run0 override ZPWR_SUDO_REGEX to add alternation. A
    # silent change to default e.g. "sudo|doas" would catch some
    # benign `doas` typos as sudo-prefix removal.
    local out
    out=$(unset ZPWR_SUDO_REGEX; zsh -c "
        source '$pluginFile' 2>/dev/null
        print \"\$ZPWR_SUDO_REGEX\"
    ")
    assert "$out" same_as 'sudo'
}

@test 'ZPWR_SUDO_CMD default is literal sudo (NOT prefixed with full path)' {
    # Pin: out of the box, the prepend is bare `sudo`. Refactor to
    # /usr/bin/sudo would break minimal-PATH environments.
    local out
    out=$(unset ZPWR_SUDO_CMD; zsh -c "
        source '$pluginFile' 2>/dev/null
        print \"\$ZPWR_SUDO_CMD\"
    ")
    assert "$out" same_as 'sudo'
}
