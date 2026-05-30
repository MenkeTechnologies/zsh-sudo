#!/usr/bin/env zunit
#{{{                    MARK:Header
##### Purpose: zsh-sudo — fourth-tier contracts.
#####          Pins for cursor-split preservation: the widget treats
#####          LBUFFER and RBUFFER independently, and the cursor (the
#####          implicit split point between them) is invariant under
#####          the "add sudo" branch — sudo prepends to LBUFFER and
#####          leaves RBUFFER untouched, so the cursor moves with the
#####          insertion point as expected by ZLE semantics.
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

@test 'add-sudo branch leaves RBUFFER untouched (cursor-split preservation)' {
    # Pin: when no sudo is present, the widget prepends to LBUFFER.
    # RBUFFER must not be perturbed — that is the slice to the right
    # of the cursor and changing it would shift the user's caret.
    BUFFER="ls -la"
    LBUFFER="ls"
    RBUFFER=" -la"
    sudo-command-line
    assert "$LBUFFER" same_as "sudo ls"
    assert "$RBUFFER" same_as " -la"
}

@test 'remove-sudo via LBUFFER match leaves RBUFFER untouched' {
    # Pin: the LBUFFER-side regex strips sudo from LBUFFER only. RBUFFER
    # remains the post-cursor slice unchanged.
    BUFFER="sudo ls -la"
    LBUFFER="sudo ls"
    RBUFFER=" -la"
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
    assert "$RBUFFER" same_as " -la"
}

@test 'remove-sudo via RBUFFER match leaves LBUFFER untouched' {
    # Pin: when LBUFFER does NOT match the sudo regex but RBUFFER does,
    # the widget strips sudo from RBUFFER. LBUFFER (everything before
    # the cursor) is preserved.
    BUFFER="echo: sudo ls"
    LBUFFER="echo: "
    RBUFFER="sudo ls"
    sudo-command-line
    assert "$LBUFFER" same_as "echo: "
    assert "$RBUFFER" same_as "ls"
}

@test 'env-var prefix is removed along with sudo (KEY=val sudo cmd shape)' {
    # Pin: LBUFFER `FOO=bar sudo ls` should strip back to `ls`. The
    # leading-env-vars segment of the regex captures the assignment
    # prefix and the match[-1] terminal grabs the trailing command,
    # so both head and tail collapse to just the command.
    BUFFER="FOO=bar sudo ls"
    LBUFFER="FOO=bar sudo ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

@test 'custom ZPWR_SUDO_CMD prepends the user-overridden prefix' {
    # Pin: when ZPWR_SUDO_CMD is overridden (e.g. to "doas" or
    # "sudo -E"), the add-sudo branch must use the new value, not
    # the hardcoded "sudo " literal. Pin the override path end-to-end.
    ZPWR_SUDO_CMD="doas"
    BUFFER="reboot"
    LBUFFER="reboot"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "doas reboot"
    ZPWR_SUDO_CMD="sudo"
}
