# Ghostty Actions Reference

All actions are built-in. No custom functions (unlike WezTerm).

## Window Management

| Action | Description |
|--------|-------------|
| `new_window` | Create new window |
| `close_window` | Close current window |
| `toggle_fullscreen` | Enter/exit fullscreen |
| `toggle_maximize` | Maximize/unmaximize |
| `hide` | Hide window (macOS) |

## Tab Management

| Action | Description |
|--------|-------------|
| `new_tab` | Create new tab |
| `close_tab` | Close current tab |
| `next_tab` / `previous_tab` | Switch tabs |
| `goto_tab N` | Go to tab N (1-9) |
| `move_tab_left` / `move_tab_right` | Reorder tabs |
| `toggle_tab_bar` | Show/hide tab bar |

## Split Management

| Action | Description |
|--------|-------------|
| `split_new` | Split (default: horizontal) |
| `split_new above/below/left/right` | Split in direction |
| `split_new v` / `split_new h` | Vertical / horizontal |
| `split_toggle` | Toggle split direction |
| `split_next` / `split_previous` | Focus next/prev split |
| `split_grid N M` | Create NxM grid |
| `close_split` | Close current split |
| `resize_split:up,N` | Resize split up by N cells (comma separator, not colon) |
| `resize_split:down,N` | Resize split down by N cells |
| `resize_split:left,N` | Resize split left by N cells |
| `resize_split:right,N` | Resize split right by N cells |
| `toggle_split_zoom` | Maximize/restore current split |

## Clipboard

| Action | Description |
|--------|-------------|
| `copy_to_clipboard` | Copy selection |
| `copy_to_clipboard_without_newlines` | Copy without line breaks |
| `paste_from_clipboard` | Paste |
| `paste_from_selection` | Paste primary selection (Linux) |

## Scrolling

| Action | Description |
|--------|-------------|
| `scroll_page_up` / `scroll_page_down` | Full page |
| `scroll_half_page_up` / `scroll_half_page_down` | Half page |
| `scroll_to_top` / `scroll_to_bottom` | Jump to end |
| `scroll_line_up` / `scroll_line_down` | Single line |

## Font / Appearance

| Action | Description |
|--------|-------------|
| `increase_font_size` / `decrease_font_size` | Zoom |
| `reset_font_size` | Reset to default |
| `set_font_size N` | Set specific size |

## System

| Action | Description |
|--------|-------------|
| `reload_config` | Reload config file |
| `inspector` | Open debug panel |
| `reset_terminal` | Reset terminal state |
| `text:<value>` | Send literal text |
| `activate_key_table` / `deactivate_key_table` | Key table mode |
