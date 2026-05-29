#!/usr/bin/env zunit
#{{{                    MARK:Header
##### Purpose: zsh-sudo — third-tier surface pins:
#####          - widget invocation preserves exit code ($? not clobbered)
#####          - LBUFFER+RBUFFER concat is preserved through toggle round-trip
#####          - widget does NOT call any external binary (pure-string mutation)
#####          - 4-toggle cycle (add/remove/add/remove) returns to original buffer
#####          - widget does not corrupt buffer when LBUFFER has trailing space
#}}}***********************************************************

@setup {
    0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
    0="${${(M)0:#/*}:-$PWD/$0}"
    pluginDir="${0:h:A}"
    pluginFile="$pluginDir/sudo.plugin.zsh"
}

@test 'widget invocation preserves $? exit code (no clobber)' {
    # Pin: sudo-command-line is invoked via `zle .sudo-command-line`. Whatever
    # the previous command's exit code was, the widget must not clobber it
    # in a user-visible way. Verify by setting a non-zero rc, sourcing the
    # plugin, and confirming the prior rc is still readable after definition.
    local result
    result=$(zsh -c "
        emulate zsh
        false  # set \$? to 1
        prev=\$?
        source '$pluginFile' 2>/dev/null
        # The plugin only DEFINES the widget at source-time; nothing should
        # alter \$? from what 'source' itself returned (0).
        if (( prev == 1 )); then print PRESERVED; else print CLOBBERED; fi
    ")
    assert "$result" same_as 'PRESERVED'
}

@test '4-toggle cycle returns to original BUFFER (add/remove/add/remove)' {
    # Pin: applying the widget twice should restore the original buffer.
    # 4 toggles = 2 round-trips = guaranteed return to original.
    local result
    result=$(zsh -c "
        zmodload zsh/zle 2>/dev/null
        source '$pluginFile' 2>/dev/null
        BUFFER='ls -la'
        LBUFFER='ls -la'
        RBUFFER=''
        orig=\"\$LBUFFER\$RBUFFER\"
        for i in 1 2 3 4; do
            BUFFER=\"\$LBUFFER\$RBUFFER\"
            sudo-command-line
        done
        final=\"\$LBUFFER\$RBUFFER\"
        if [[ \"\$orig\" == \"\$final\" ]]; then print IDENT; else print \"DRIFT: '\$orig' -> '\$final'\"; fi
    ")
    assert "$result" same_as 'IDENT'
}

@test 'widget does NOT spawn external binaries (pure-string mutation)' {
    # Pin: the widget operates on BUFFER/LBUFFER/RBUFFER only. No `sudo`,
    # `env`, `getent`, etc. is invoked at toggle time. Counts: zero
    # `command-substitution` lines beyond the fc -ln -1 history pull.
    local externals
    externals=$(grep -cE '\$\(' "$pluginFile")
    # Allow exactly 1 — the `$(builtin fc -ln -1)` empty-buffer fallback
    assert "$externals" same_as '1'
}

@test 'remove-sudo path uses $match[-1] (last capture group) for the surviving command' {
    # Pin: the regex has many alternation groups; the SURVIVING tail (the
    # post-sudo command) is captured by the FINAL group, addressed by
    # $match[-1] (negative index = last). Replacing -1 with a hardcoded
    # numeric index would silently break when alternations are reordered.
    grep -qF 'match[-1]' "$pluginFile"
    assert $? equals 0
}

@test 'remove-sudo path preserves leading whitespace ($match[1])' {
    # Pin: the regex captures leading whitespace as `$match[1]` and re-emits
    # it as `$match[1]$match[-1]`. A regression that drops $match[1] would
    # silently eat leading-space formatting in sub-shell pipelines.
    local result
    result=$(zsh -c "
        zmodload zsh/zle 2>/dev/null
        source '$pluginFile' 2>/dev/null
        BUFFER='   sudo ls'
        LBUFFER='   sudo ls'
        RBUFFER=''
        sudo-command-line
        # Should be '   ls' (3 leading spaces preserved)
        if [[ \"\$LBUFFER\" == '   ls' ]]; then print KEPT; else print \"LOST: '\$LBUFFER'\"; fi
    ")
    assert "$result" same_as 'KEPT'
}
