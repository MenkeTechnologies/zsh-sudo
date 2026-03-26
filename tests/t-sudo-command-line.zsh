#!/usr/bin/env zunit
#{{{                    MARK:Header
#**************************************************************
##### Author: MenkeTechnologies
##### GitHub: https://github.com/MenkeTechnologies
##### Date: Tue Feb 25 19:37:50 EST 2020
##### Purpose: zsh script to test sudo-command-line widget
##### Notes:
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

# Basic: add sudo to a plain command
@test 'add sudo to plain command' {
    BUFFER="ls -la"
    LBUFFER="ls -la"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "sudo ls -la"
}

# Basic: remove sudo from command
@test 'remove sudo from command' {
    BUFFER="sudo ls -la"
    LBUFFER="sudo ls -la"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls -la"
}

# Toggle sudo off then on (round-trip)
@test 'toggle sudo off then on' {
    BUFFER="sudo cat /etc/hosts"
    LBUFFER="sudo cat /etc/hosts"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "cat /etc/hosts"
    BUFFER="cat /etc/hosts"
    sudo-command-line
    assert "$LBUFFER" same_as "sudo cat /etc/hosts"
}

# Remove sudo with -i flag
@test 'remove sudo with -i flag' {
    BUFFER="sudo -i ls"
    LBUFFER="sudo -i ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Remove sudo with -s flag
@test 'remove sudo with -s flag' {
    BUFFER="sudo -s ls"
    LBUFFER="sudo -s ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Remove sudo with -E flag (preserve env)
@test 'remove sudo with -E flag' {
    BUFFER="sudo -E ls"
    LBUFFER="sudo -E ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Remove sudo with -H flag
@test 'remove sudo with -H flag' {
    BUFFER="sudo -H ls"
    LBUFFER="sudo -H ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Remove sudo with combined flags
@test 'remove sudo with combined flags -EH' {
    BUFFER="sudo -EH ls"
    LBUFFER="sudo -EH ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Remove sudo with -u user flag
@test 'remove sudo with -u user' {
    BUFFER="sudo -u root ls"
    LBUFFER="sudo -u root ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Sudo with env vars before sudo
@test 'remove sudo with env vars prefix' {
    BUFFER="FOO=bar sudo ls"
    LBUFFER="FOO=bar sudo ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Sudo with 'command' prefix
@test 'remove sudo with command prefix' {
    BUFFER="command sudo ls"
    LBUFFER="command sudo ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Sudo with 'builtin command' prefix
@test 'remove sudo with builtin command prefix' {
    BUFFER="builtin command sudo ls"
    LBUFFER="builtin command sudo ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Sudo with env command after sudo
@test 'remove sudo env command' {
    BUFFER="sudo env ls"
    LBUFFER="sudo env ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Leading whitespace preserved when removing sudo
@test 'preserve leading whitespace when removing sudo' {
    BUFFER="  sudo ls"
    LBUFFER="  sudo ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "  ls"
}

# Add sudo to command with arguments and pipes
@test 'add sudo to command with pipes' {
    BUFFER="cat /etc/shadow | grep root"
    LBUFFER="cat /etc/shadow | grep root"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "sudo cat /etc/shadow | grep root"
}

# RBUFFER: remove sudo from RBUFFER when LBUFFER empty
@test 'remove sudo from RBUFFER' {
    BUFFER="sudo ls -la"
    LBUFFER=""
    RBUFFER="sudo ls -la"
    sudo-command-line
    assert "$RBUFFER" same_as "ls -la"
}

# Add sudo when RBUFFER has no sudo
@test 'add sudo when cursor at start' {
    BUFFER="ls -la"
    LBUFFER=""
    RBUFFER="ls -la"
    sudo-command-line
    assert "$LBUFFER" same_as "sudo "
}

# Custom ZPWR_SUDO_CMD
@test 'custom ZPWR_SUDO_CMD' {
    ZPWR_SUDO_CMD="doas"
    ZPWR_SUDO_REGEX="sudo"
    BUFFER="ls -la"
    LBUFFER="ls -la"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "doas ls -la"
    ZPWR_SUDO_CMD="sudo"
}

# Custom ZPWR_SUDO_REGEX matches doas
@test 'custom ZPWR_SUDO_REGEX removes doas' {
    ZPWR_SUDO_CMD="doas"
    ZPWR_SUDO_REGEX="doas"
    BUFFER="doas ls -la"
    LBUFFER="doas ls -la"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls -la"
    ZPWR_SUDO_CMD="sudo"
    ZPWR_SUDO_REGEX="sudo"
}

# Double sudo gets removed
@test 'remove double sudo' {
    BUFFER="sudo sudo ls"
    LBUFFER="sudo sudo ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Empty buffer (would pull from history - just verify no crash)
@test 'empty buffer does not crash' {
    LBUFFER=""
    RBUFFER=""
    BUFFER=""
    run sudo-command-line
    assert $state equals 0
}

# Sudo with -- separator
@test 'remove sudo with -- separator' {
    BUFFER="sudo -- ls"
    LBUFFER="sudo -- ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Sudo with -n (non-interactive) flag
@test 'remove sudo with -n flag' {
    BUFFER="sudo -n ls"
    LBUFFER="sudo -n ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Add sudo to single command no args
@test 'add sudo to single command' {
    BUFFER="reboot"
    LBUFFER="reboot"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "sudo reboot"
}

# Env vars after sudo with env
@test 'remove sudo env with vars' {
    BUFFER="sudo env FOO=bar ls"
    LBUFFER="sudo env FOO=bar ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Sudo with -b (background) flag
@test 'remove sudo with -b flag' {
    BUFFER="sudo -b ls"
    LBUFFER="sudo -b ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Sudo with -P (preserve group) flag
@test 'remove sudo with -P flag' {
    BUFFER="sudo -P ls"
    LBUFFER="sudo -P ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Sudo with env -i flag
@test 'remove sudo env -i' {
    BUFFER="sudo env -i ls"
    LBUFFER="sudo env -i ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# RBUFFER with sudo flags
@test 'remove sudo with flags from RBUFFER' {
    BUFFER="sudo -E ls -la"
    LBUFFER=""
    RBUFFER="sudo -E ls -la"
    sudo-command-line
    assert "$RBUFFER" same_as "ls -la"
}

# Quoted sudo
@test 'remove quoted sudo' {
    BUFFER="'sudo' ls"
    LBUFFER="'sudo' ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Double-quoted sudo
@test 'remove double-quoted sudo' {
    BUFFER='"sudo" ls'
    LBUFFER='"sudo" ls'
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Default ZPWR_SUDO_CMD value
@test 'default ZPWR_SUDO_CMD is sudo' {
    assert "$ZPWR_SUDO_CMD" same_as "sudo"
}

# Default ZPWR_SUDO_REGEX value
@test 'default ZPWR_SUDO_REGEX is sudo' {
    assert "$ZPWR_SUDO_REGEX" same_as "sudo"
}

# --- Sudo flag coverage (flags without args: -[ABbEHnPSis]) ---

# Remove sudo with -A (askpass) flag
@test 'remove sudo with -A flag' {
    BUFFER="sudo -A ls"
    LBUFFER="sudo -A ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Remove sudo with -B flag
@test 'remove sudo with -B flag' {
    BUFFER="sudo -B ls"
    LBUFFER="sudo -B ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Remove sudo with -S (stdin) flag
@test 'remove sudo with -S flag' {
    BUFFER="sudo -S ls"
    LBUFFER="sudo -S ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Remove sudo with many combined no-arg flags
@test 'remove sudo with -ABnEHSis flags' {
    BUFFER="sudo -ABnEHSis ls"
    LBUFFER="sudo -ABnEHSis ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Remove sudo with multiple separate flag groups
@test 'remove sudo with multiple flag groups' {
    BUFFER="sudo -En -s ls"
    LBUFFER="sudo -En -s ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# --- Sudo flags with arguments: -[CghpTu] ---

# Remove sudo with -C (close from fd) flag
@test 'remove sudo with -C fd' {
    BUFFER="sudo -C 3 ls"
    LBUFFER="sudo -C 3 ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Remove sudo with -g (group) flag
@test 'remove sudo with -g group' {
    BUFFER="sudo -g wheel ls"
    LBUFFER="sudo -g wheel ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Remove sudo with -h (host) flag
@test 'remove sudo with -h host' {
    BUFFER="sudo -h localhost ls"
    LBUFFER="sudo -h localhost ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Remove sudo with -p (prompt) flag
@test 'remove sudo with -p prompt' {
    BUFFER="sudo -p Password: ls"
    LBUFFER="sudo -p Password: ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Remove sudo with -T (timeout) flag
@test 'remove sudo with -T timeout' {
    BUFFER="sudo -T 30 ls"
    LBUFFER="sudo -T 30 ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Remove sudo with -u= equals syntax
@test 'remove sudo with -u=root' {
    BUFFER="sudo -u=root ls"
    LBUFFER="sudo -u=root ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Remove sudo with -g= equals syntax
@test 'remove sudo with -g=wheel' {
    BUFFER="sudo -g=wheel ls"
    LBUFFER="sudo -g=wheel ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Mixed no-arg and arg flags
@test 'remove sudo with -E -u root combined' {
    BUFFER="sudo -E -u root ls"
    LBUFFER="sudo -E -u root ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# --- Multiple env vars ---

# Multiple env vars before sudo
@test 'remove sudo with multiple env vars prefix' {
    BUFFER="FOO=bar BAZ=qux sudo ls"
    LBUFFER="FOO=bar BAZ=qux sudo ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Multiple env vars after sudo env
@test 'remove sudo env with multiple vars' {
    BUFFER="sudo env FOO=bar BAZ=qux ls"
    LBUFFER="sudo env FOO=bar BAZ=qux ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# --- Quoted variants ---

# Backslash-quoted sudo
@test 'remove backslash-quoted sudo' {
    BUFFER='\\sudo ls'
    LBUFFER='\\sudo ls'
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Quoted command keyword
@test 'remove sudo with quoted command' {
    BUFFER="'command' sudo ls"
    LBUFFER="'command' sudo ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Double-quoted command keyword
@test 'remove sudo with double-quoted command' {
    BUFFER='"command" sudo ls'
    LBUFFER='"command" sudo ls'
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Quoted builtin keyword
@test 'remove sudo with quoted builtin' {
    BUFFER="'builtin' command sudo ls"
    LBUFFER="'builtin' command sudo ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Quoted env keyword
@test 'remove sudo with quoted env' {
    BUFFER="sudo 'env' ls"
    LBUFFER="sudo 'env' ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Double-quoted env keyword
@test 'remove sudo with double-quoted env' {
    BUFFER='sudo "env" ls'
    LBUFFER='sudo "env" ls'
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# --- env flag coverage ---

# env with -v flag
@test 'remove sudo env -v' {
    BUFFER="sudo env -v ls"
    LBUFFER="sudo env -v ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# env with -iv combined flags
@test 'remove sudo env -iv' {
    BUFFER="sudo env -iv ls"
    LBUFFER="sudo env -iv ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# env with -P flag (alternate PATH)
@test 'remove sudo env -P path' {
    BUFFER="sudo env -P /usr/bin ls"
    LBUFFER="sudo env -P /usr/bin ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# env with -S flag (split string)
@test 'remove sudo env -S string' {
    BUFFER="sudo env -S VAR=val ls"
    LBUFFER="sudo env -S VAR=val ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# env with -u flag (unset var)
@test 'remove sudo env -u var' {
    BUFFER="sudo env -u HOME ls"
    LBUFFER="sudo env -u HOME ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# env with -- separator
@test 'remove sudo env -- command' {
    BUFFER="sudo env -- ls"
    LBUFFER="sudo env -- ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# --- Whitespace variations ---

# Tab as leading whitespace
@test 'preserve tab leading whitespace' {
    BUFFER="	sudo ls"
    LBUFFER="	sudo ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "	ls"
}

# Multiple spaces between sudo and command
@test 'remove sudo with extra spaces before command' {
    BUFFER="sudo  ls"
    LBUFFER="sudo  ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# --- Cursor position edge cases ---

# Cursor in middle, sudo in LBUFFER
@test 'remove sudo with cursor in middle' {
    BUFFER="sudo ls -la /tmp"
    LBUFFER="sudo ls"
    RBUFFER=" -la /tmp"
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# LBUFFER non-empty but no sudo, RBUFFER has sudo
@test 'LBUFFER no match falls through to RBUFFER' {
    BUFFER="echo sudo ls"
    LBUFFER="echo "
    RBUFFER="sudo ls"
    sudo-command-line
    assert "$RBUFFER" same_as "ls"
}

# Both LBUFFER and RBUFFER have no sudo
@test 'add sudo when neither buffer has sudo' {
    BUFFER="echo hello"
    LBUFFER="echo"
    RBUFFER=" hello"
    sudo-command-line
    assert "$LBUFFER" same_as "sudo echo"
}

# --- Triple sudo ---

@test 'remove triple sudo' {
    BUFFER="sudo sudo sudo ls"
    LBUFFER="sudo sudo sudo ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# --- Complex real-world combinations ---

# Full complex: env vars + command + sudo + flags + env + env vars + command
@test 'remove complex sudo with all prefixes' {
    BUFFER="FOO=bar command sudo -E env -i BAZ=qux ls"
    LBUFFER="FOO=bar command sudo -E env -i BAZ=qux ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# sudo with -u and -E combined with env
@test 'remove sudo -u root -E env command' {
    BUFFER="sudo -u root -E env ls"
    LBUFFER="sudo -u root -E env ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
}

# Command with path
@test 'add sudo to absolute path command' {
    BUFFER="/usr/bin/ls -la"
    LBUFFER="/usr/bin/ls -la"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "sudo /usr/bin/ls -la"
}

# Long command with many arguments
@test 'add sudo to long command' {
    BUFFER="find / -name test -type f -exec rm {} +"
    LBUFFER="find / -name test -type f -exec rm {} +"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "sudo find / -name test -type f -exec rm {} +"
}

# Command that starts with 'sudo' as substring (should NOT strip)
@test 'do not strip sudoers as sudo' {
    BUFFER="sudoers ls"
    LBUFFER="sudoers ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "sudo sudoers ls"
}

# sudo followed by command with equals sign (not env var pattern)
@test 'remove sudo before command with redirect' {
    BUFFER="sudo tee /etc/file"
    LBUFFER="sudo tee /etc/file"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "tee /etc/file"
}

# --- RBUFFER complex cases ---

# RBUFFER: command prefix + sudo with flags
@test 'remove command sudo from RBUFFER' {
    BUFFER="command sudo -E ls"
    LBUFFER=""
    RBUFFER="command sudo -E ls"
    sudo-command-line
    assert "$RBUFFER" same_as "ls"
}

# RBUFFER: env vars + sudo
@test 'remove env var sudo from RBUFFER' {
    BUFFER="FOO=bar sudo ls"
    LBUFFER=""
    RBUFFER="FOO=bar sudo ls"
    sudo-command-line
    assert "$RBUFFER" same_as "ls"
}

# RBUFFER: sudo env with vars
@test 'remove sudo env vars from RBUFFER' {
    BUFFER="sudo env FOO=bar ls"
    LBUFFER=""
    RBUFFER="sudo env FOO=bar ls"
    sudo-command-line
    assert "$RBUFFER" same_as "ls"
}

# RBUFFER: leading whitespace preserved
@test 'RBUFFER preserve leading whitespace' {
    BUFFER="  sudo ls"
    LBUFFER=""
    RBUFFER="  sudo ls"
    sudo-command-line
    assert "$RBUFFER" same_as "  ls"
}

# --- Custom ZPWR_SUDO_REGEX edge cases ---

# Custom regex that is a regex pattern
@test 'custom ZPWR_SUDO_REGEX as alternation' {
    ZPWR_SUDO_CMD="sudo"
    ZPWR_SUDO_REGEX="sudo|doas"
    BUFFER="doas ls"
    LBUFFER="doas ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "ls"
    ZPWR_SUDO_CMD="sudo"
    ZPWR_SUDO_REGEX="sudo"
}

# Custom regex: add sudo when no match
@test 'custom ZPWR_SUDO_REGEX add when no match' {
    ZPWR_SUDO_CMD="doas"
    ZPWR_SUDO_REGEX="doas"
    BUFFER="ls"
    LBUFFER="ls"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "doas ls"
    ZPWR_SUDO_CMD="sudo"
    ZPWR_SUDO_REGEX="sudo"
}

# Custom regex round-trip
@test 'custom ZPWR_SUDO round-trip' {
    ZPWR_SUDO_CMD="doas"
    ZPWR_SUDO_REGEX="doas"
    BUFFER="ls -la"
    LBUFFER="ls -la"
    RBUFFER=""
    sudo-command-line
    assert "$LBUFFER" same_as "doas ls -la"
    BUFFER="doas ls -la"
    LBUFFER="doas ls -la"
    sudo-command-line
    assert "$LBUFFER" same_as "ls -la"
    ZPWR_SUDO_CMD="sudo"
    ZPWR_SUDO_REGEX="sudo"
}

# --- ZPWR_SUDO_CMD/REGEX not set before source ---

@test 'ZPWR_SUDO_CMD defaults when unset' {
    unset ZPWR_SUDO_CMD
    unset ZPWR_SUDO_REGEX
    source "$pluginDir/sudo.plugin.zsh"
    assert "$ZPWR_SUDO_CMD" same_as "sudo"
    assert "$ZPWR_SUDO_REGEX" same_as "sudo"
}

@test 'ZPWR_SUDO_CMD preserved when pre-set' {
    ZPWR_SUDO_CMD="doas"
    ZPWR_SUDO_REGEX="doas"
    source "$pluginDir/sudo.plugin.zsh"
    assert "$ZPWR_SUDO_CMD" same_as "doas"
    assert "$ZPWR_SUDO_REGEX" same_as "doas"
    ZPWR_SUDO_CMD="sudo"
    ZPWR_SUDO_REGEX="sudo"
}
