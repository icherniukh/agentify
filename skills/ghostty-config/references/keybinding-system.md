# Ghostty Keybinding System

## Syntax

```
keybind = [flags] modifiers+key = action
```

**Modifiers:** `ctrl`, `shift`, `alt`, `super` (`super` = Cmd on macOS, Win on Windows)

```ini
keybind = ctrl+shift+c=copy_to_clipboard
keybind = ctrl+shift+v=paste_from_clipboard
keybind = super+enter=new_window
```

## Flags

Flags modify keybinding behavior:

- `noreport` — Don't report to shell integration
- `global` — Work globally (outside terminal focus)
- `application` — Only when app has keyboard focus

## Key Tables (Multi-Key Sequences)

Vim/tmux-like prefix sequences:

```ini
# Define prefix
keybind = ctrl+b=activate_key_table tmux

# Table entries
keybind = tmux/c=new_tab
keybind = tmux/v=split_new v
keybind = tmux/%=split_new h
keybind = tmux/h=split_previous
keybind = tmux/l=split_next
keybind = tmux/x=close_split
keybind = tmux/escape=deactivate_key_table
```

## Platform Notes

| Platform | `super` key | `alt` key | Notes |
|----------|-------------|-----------|-------|
| macOS | Command | Option | System handles `super+c/v` |
| Linux | Mod4/Win | Alt | `paste_from_selection` available |
| Windows | Win | Alt | Standard behavior |

## Avoiding Conflicts

Terminal signals — do NOT rebind:
- `Ctrl+C` (interrupt), `Ctrl+Z` (suspend), `Ctrl+D` (EOF), `Ctrl+\` (quit)

Use `Ctrl+Shift+*` or `Super+*` for Ghostty actions instead.

For Vim/Neovim users: avoid `Ctrl+[hjkl]` and `Ctrl+W` — use `Super+*` for Ghostty.
