```
 ███████╗███████╗██╗  ██╗      ███████╗██╗   ██╗██████╗  ██████╗
 ╚══███╔╝██╔════╝██║  ██║      ██╔════╝██║   ██║██╔══██╗██╔═══██╗
   ███╔╝ ███████╗███████║█████╗███████╗██║   ██║██║  ██║██║   ██║
  ███╔╝  ╚════██║██╔══██║╚════╝╚════██║██║   ██║██║  ██║██║   ██║
 ███████╗███████║██║  ██║      ███████║╚██████╔╝██████╔╝╚██████╔╝
 ╚══════╝╚══════╝╚═╝  ╚═╝      ╚══════╝ ╚═════╝ ╚═════╝  ╚═════╝
```

[![CI](https://github.com/MenkeTechnologies/zsh-sudo/actions/workflows/ci.yml/badge.svg)](https://github.com/MenkeTechnologies/zsh-sudo/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![zsh](https://img.shields.io/badge/zsh-plugin-cyan.svg)](https://github.com/MenkeTechnologies/zpwr)

### `[ONE KEYBIND TO TOGGLE sudo ON THE CURRENT COMMAND LINE]`

> *"One keypress — your last command, with sudo."*

### [`strykelang`](https://github.com/MenkeTechnologies/strykelang) &middot; [`zshrs`](https://github.com/MenkeTechnologies/zshrs) · [`MenkeTechnologiesMeta`](https://github.com/MenkeTechnologies/MenkeTechnologiesMeta) · [`zsh-sed-sub`](https://github.com/MenkeTechnologies/zsh-sed-sub) · [`zsh-git-acp`](https://github.com/MenkeTechnologies/zsh-git-acp) · [`zsh-more-completions`](https://github.com/MenkeTechnologies/zsh-more-completions) · [`zpwr`](https://github.com/MenkeTechnologies/zpwr)

---

## Table of Contents

- [\[0x00\] `// WHAT IS THIS`](#0x00-what-is-this)
- [\[0x01\] `// INSTALL`](#0x01-install)
- [\[0x02\] `// KEYBIND`](#0x02-keybind)
- [\[0x03\] `// CONFIG`](#0x03-config)
- [\[0x04\] `// HOW IT WORKS`](#0x04-how-it-works)

---

## [0x00] `// WHAT IS THIS`

A ZSH widget that toggles `sudo` on your current command line with a single keybind. No retyping. No arrow keys. Just pure privilege escalation at the speed of thought.

- **`sudo` not on the line?** &mdash; it gets prepended
- **`sudo` already there?** &mdash; it gets stripped (along with `builtin`, `command`, `env`, and all their args)
- **Empty line?** &mdash; pulls your last command back from history and slaps `sudo` on it

> _"The street finds its own uses for things."_ &mdash; William Gibson

---

## [0x01] `// INSTALL`

### Zinit

```zsh
zinit light MenkeTechnologies/zsh-sudo
```

### Oh-My-Zsh

```zsh
git clone https://github.com/MenkeTechnologies/zsh-sudo \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-sudo
```

Then add `zsh-sudo` to your plugins array in `~/.zshrc`.

### Manual

```zsh
source /path/to/sudo.plugin.zsh
```

---

## [0x02] `// KEYBIND`

Wire up the ZLE widget to whatever key combo jacks you in fastest:

```zsh
bindkey '^N' sudo-command-line
```

---

## [0x03] `// CONFIG`

Override the default `sudo` string by exporting these before the plugin loads:

```zsh
export ZPWR_SUDO_REGEX='doas'
export ZPWR_SUDO_CMD='doas'
```

> Both variables should contain the same string. `ZPWR_SUDO_CMD` is what gets prepended; `ZPWR_SUDO_REGEX` is what the parser hunts for when stripping.

---

## [0x04] `// HOW IT WORKS`

```
┌────────────────────────────────────────────────────────────────┐
│  INPUT STATE              ACTION             OUTPUT            │
├────────────────────────────────────────────────────────────────┤
│  $ apt update       ──►  prepend sudo  ──►  $ sudo apt update  │
│  $ sudo apt update  ──►  strip sudo   ──►  $ apt update        │
│  $ (empty)          ──►  recall + sudo ──►  $ sudo <last cmd>  │
└────────────────────────────────────────────────────────────────┘
```

The regex engine handles edge cases like quoted commands, `builtin`/`command` prefixes, `env` with flags, variable assignments before `sudo`, and stacked sudo options (`-u root -E`, etc).

---

