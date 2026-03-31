---
name: ghostty-config
description: Use when configuring Ghostty, creating or looking up keybindings, setting up profiles, applying themes, working with splits, looking up available actions, or troubleshooting terminal config.
---

# Ghostty Configuration

Simple `key = value` config format. No Lua, no complex syntax.

## Config File Location

Check in this priority order — read the first one that exists:

1. `/Users/ivan/Library/Application Support/com.mitchellh.ghostty/config` ← **active config (ivan's machine)**
2. `~/.config/ghostty.toml` — secondary (duplicate, may be stale)
3. `~/Library/Application Support/Ghostty/config` — generic macOS default
4. `~/.config/ghostty/config` — Linux default

The defaults reference (read-only, all built-in keybinds) is at:
`/Users/ivan/.config/ghostty/defaults`

## Quick Reference

```ini
# Font
font-family = JetBrains Mono
font-size = 14

# Theme
theme = Catppuccin-Mocha

# Keybinding
keybind = ctrl+shift+c=copy_to_clipboard

# Include other files
config-file = keybinds/custom.ghostty

# Profile
[profileDev]
working-directory = ~/dev
font-size = 14
```

**Hot reload**: `Cmd+Shift+,` (macOS) / `Ctrl+Shift+,` (Linux). No restart needed.

**Validate**: `ghostty +show-config --dry-run`

## Keybinding Syntax

```
keybind = modifiers+key = action
```

Modifiers: `ctrl`, `shift`, `alt`, `super` (Cmd on macOS)

Multi-key sequences via key tables:
```ini
keybind = ctrl+b=activate_key_table tmux
keybind = tmux/c=new_tab
keybind = tmux/v=split_new v
keybind = tmux/escape=deactivate_key_table
```

**Avoid rebinding**: Ctrl+C, Ctrl+Z, Ctrl+D, Ctrl+\ (terminal signals)

## Reference Files

Detailed reference material in `references/`:

- **config-basics.md** — Full config syntax, options, profiles, validation commands
- **keybinding-system.md** — Keybinding syntax, flags, key tables, platform notes
- **actions-reference.md** — All available actions (window, tab, split, clipboard, font)
- **common-patterns.md** — Dev workstation, tmux replacement, presentation mode, Neovim integration, organized config structure
