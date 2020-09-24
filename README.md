# zsh-sudo

## Functionality
If sudo is present on current line it will be removed.  If sudo is not present it will be prepeneded to current line.  If current line is empty then previous command line will be prepended with sudo.

## Prepend some other sstring
You can have any string prepended instead of sudo like so:
```sh
export ZPWR_SUDO_REGEX='<mystr>'
export ZPWR_SUDO_CMD='<mystr>'
```
These environment variables should have have the same string.

## Keybinding this ZLE widget.

```sh
bindkey '^N' sudo-command-line
```

# created by MenkeTechnologies

