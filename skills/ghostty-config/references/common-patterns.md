# Common Ghostty Patterns

## Developer Workstation

```ini
font-family = JetBrains Mono Nerd Font
font-size = 13
theme = Catppuccin-Mocha
scrollback-limit = 50000
scrollback-limit-editor = 0
cursor-style = block
audible-bell = false
visual-bell = false

keybind = super+enter=new_window
keybind = super+shift+enter=new_window:profile=dev

[profileDev]
working-directory = ~/dev
font-size = 14
```

## Tmux Replacement

Native splits without tmux overhead:

```ini
keybind = ctrl+b=activate_key_table tmux
keybind = tmux/"=split_new v
keybind = tmux/%=split_new h
keybind = tmux/h=split_previous
keybind = tmux/l=split_next
keybind = tmux/x=close_split
keybind = tmux/c=new_tab
keybind = tmux/n=new_window
keybind = tmux/escape=deactivate_key_table
```

## Presentation Mode

```ini
[profilePresent]
font-size = 20
theme = Light
background-opacity = 1.0
cursor-style-blink = false
window-padding-x = 20
window-padding-y = 20

# Quick toggle
keybind = super+shift+p=new_window:profile=Present
```

## Neovim Integration

```ini
scrollback-limit-editor = 0
cursor-style = block
confirm-close-surfaces = false

# Use Super for Ghostty — Ctrl reserved for Neovim
keybind = super+t=new_tab
keybind = super+w=close_tab
keybind = super+1=goto_tab 1
keybind = super+2=goto_tab 2
# Don't bind ctrl+[hjkl] or ctrl+w
```

## Tab Navigation

```ini
keybind = alt+1=goto_tab 1
keybind = alt+2=goto_tab 2
keybind = alt+3=goto_tab 3
keybind = alt+4=goto_tab 4
keybind = alt+5=goto_tab 5
```

## Organized Config Structure

```
~/.config/ghostty/
├── config                    # Main entry point
├── themes/
│   └── catppuccin.ghostty
├── keybinds/
│   ├── splits.ghostty
│   └── tabs.ghostty
└── profiles/
    ├── dev.ghostty
    └── work.ghostty
```

Main config includes:
```ini
font-family = JetBrains Mono
font-size = 13
config-file = keybinds/splits.ghostty
config-file = keybinds/tabs.ghostty
config-file = profiles/dev.ghostty
```

## Anti-Patterns

- **Don't rebind Ctrl+C/Z/D** — these are terminal signals, not keybindings
- **Don't try Lua functions** — Ghostty has no scripting; use `text:` action or shell scripts
- **Don't ignore app conflicts** — Vim, tmux, Emacs have their own bindings; use prefix keys or Super
- **Do comment your keybindings** — custom bindings are easy to forget
