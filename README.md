<div align="center">

```
 ███████╗███████╗██╗  ██╗      ███████╗██╗   ██╗██████╗  ██████╗
 ╚══███╔╝██╔════╝██║  ██║      ██╔════╝██║   ██║██╔══██╗██╔═══██╗
   ███╔╝ ███████╗███████║█████╗███████╗██║   ██║██║  ██║██║   ██║
  ███╔╝  ╚════██║██╔══██║╚════╝╚════██║██║   ██║██║  ██║██║   ██║
 ███████╗███████║██║  ██║      ███████║╚██████╔╝██████╔╝╚██████╔╝
 ╚══════╝╚══════╝╚═╝  ╚═╝      ╚══════╝ ╚═════╝ ╚═════╝  ╚═════╝
```

**`[ ELEVATE YOUR COMMAND LINE // JACK INTO ROOT ]`**

[![License](https://img.shields.io/badge/LICENSE-OPEN__SOURCE-ff00ff?style=flat-square&labelColor=0d0d0d)](.)
[![Shell](https://img.shields.io/badge/SHELL-ZSH-00ffff?style=flat-square&labelColor=0d0d0d)](.)
[![Status](https://img.shields.io/badge/STATUS-ONLINE-39ff14?style=flat-square&labelColor=0d0d0d)](.)

---

```
> INITIALIZING NEURAL LINK...
> SUDO MODULE LOADED
> AWAITING INPUT_
```

</div>

## `// WHAT IS THIS`

A ZSH widget that toggles `sudo` on your current command line with a single keybind. No retyping. No arrow keys. Just pure privilege escalation at the speed of thought.

- **`sudo` not on the line?** &mdash; it gets prepended
- **`sudo` already there?** &mdash; it gets stripped (along with `builtin`, `command`, `env`, and all their args)
- **Empty line?** &mdash; pulls your last command back from history and slaps `sudo` on it

> _"The street finds its own uses for things."_ &mdash; William Gibson

---

## `// INSTALL`

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

## `// KEYBIND`

Wire up the ZLE widget to whatever key combo jacks you in fastest:

```zsh
bindkey '^N' sudo-command-line
```

---

## `// CONFIG`

Override the default `sudo` string by exporting these before the plugin loads:

```zsh
export ZPWR_SUDO_REGEX='doas'
export ZPWR_SUDO_CMD='doas'
```

> Both variables should contain the same string. `ZPWR_SUDO_CMD` is what gets prepended; `ZPWR_SUDO_REGEX` is what the parser hunts for when stripping.

---

## `// HOW IT WORKS`

```
┌──────────────────────────────────────────────────────────┐
│  INPUT STATE              ACTION             OUTPUT       │
├──────────────────────────────────────────────────────────┤
│  $ apt update       ──►  prepend sudo  ──►  $ sudo apt update  │
│  $ sudo apt update  ──►  strip sudo   ──►  $ apt update        │
│  $ (empty)          ──►  recall + sudo ──►  $ sudo <last cmd>  │
└──────────────────────────────────────────────────────────┘
```

The regex engine handles edge cases like quoted commands, `builtin`/`command` prefixes, `env` with flags, variable assignments before `sudo`, and stacked sudo options (`-u root -E`, etc).

---

<div align="center">

```
 ╔══════════════════════════════════════════╗
 ║  CREATED BY >> MenkeTechnologies        ║
 ║  https://github.com/MenkeTechnologies   ║
 ╚══════════════════════════════════════════╝
```

**`[ END OF LINE ]`**

</div>
