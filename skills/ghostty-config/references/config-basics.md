# Ghostty Config Basics

## Config File Locations

```
macOS:   ~/Library/Application Support/Ghostty/config
Linux:   ~/.config/ghostty/config
Windows: %APPDATA%\ghostty\config
```

Create if missing:
```bash
mkdir -p ~/.config/ghostty && touch ~/.config/ghostty/config
```

## Syntax

```ini
key = value
key = "value with spaces"
key = true
# This is a comment
key = value  # inline comment

# Include other files
config-file = themes/dark.ghostty
config-file = keybinds/custom.ghostty
```

## Common Options

**Font:**
```ini
font-family = JetBrains Mono
font-style = Bold
font-weight = 500
font-size = 14
letter-spacing = 0
```

**Theme/Colors:**
```ini
theme = Catppuccin-Mocha
background = #1e1e2e
foreground = #cdd6f4

# Custom palette (0-15)
palette = 0=#1e1e2e
palette = 1=#f38ba8
```

**Window:**
```ini
window-width = 1200
window-height = 800
window-padding-x = 10
window-padding-y = 10
window-decoration = true
window-theme = dark
```

**Tabs:**
```ini
tab-width = 200
tab-position = bottom  # top, bottom, left, right
```

**Scrollback:**
```ini
scrollback-limit = 10000
scrollback-limit-editor = 0  # no scrollback in editors
```

**Cursor:**
```ini
cursor-style = bar       # bar, block, underline
cursor-style-blink = false
```

**Bell:**
```ini
audible-bell = false
visual-bell = false
```

**Shell/Environment:**
```ini
command = zsh
env = TERM=xterm-256color
env = EDITOR=nvim
```

## Profiles

```ini
[profileDev]
font-size = 14
theme = dark
command = tmux new -A -s main
working-directory = ~/dev

[profilePresent]
font-size = 20
theme = Light
```

Use with keybindings:
```ini
keybind = super+shift+d=new_window:profile=Dev
```

## Validation Commands

```bash
ghostty +show-config --dry-run          # Validate syntax
ghostty +show-config                    # Show effective config
ghostty +show-config --default --docs   # Show defaults with docs
ghostty +list-configs                   # List all options
```
