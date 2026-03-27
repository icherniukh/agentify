# Tool Matrix

Use this reference when the task is app-specific. Keep changes minimal and verify the local install before assuming a command or config format.

## tmux

- Config roots:
  - `~/.tmux.conf`
  - `~/.config/tmux/tmux.conf` in XDG-style setups
- Common support paths:
  - `~/.tmux/`
  - `~/.tmux/plugins/tpm`
- Shortcut changes:
  - add or edit `bind-key` lines in the main config
  - if changing the prefix, update any dependent bindings in the same pass
- Plugins:
  - common manager: TPM
  - plugin declarations live in the main config as `set -g @plugin 'owner/repo'`
  - non-interactive install path is usually `~/.tmux/plugins/tpm/bin/install_plugins`
- Validation:
  - check install with `tmux -V`
  - safest automated smoke test is a disposable server using the target config, then `kill-server`
- Packaging notes:
  - package name is usually `tmux`
  - available on most package managers

## zellij

- Config roots:
  - `~/.config/zellij/config.kdl`
  - `~/.config/zellij/layouts/`
- Shortcut changes:
  - keybinds live in `config.kdl`
  - layouts belong in separate `.kdl` files under `layouts/`
- Plugins:
  - prefer built-in plugins first
  - external plugin workflows are more version-sensitive than `tmux` and should be checked locally before use
- Validation:
  - check install with `zellij --version`
  - there is no universally reliable noninteractive config checker across releases; if needed, launch a disposable session and document the manual smoke test
- Packaging notes:
  - package name is usually `zellij`
  - distro availability varies more than `tmux`; package-manager fallback decisions may be needed

## yazi

- Config roots:
  - `~/.config/yazi/yazi.toml`
  - `~/.config/yazi/keymap.toml`
  - `~/.config/yazi/theme.toml`
  - `~/.config/yazi/init.lua`
  - `~/.config/yazi/plugins/`
- Shortcut changes:
  - use `keymap.toml` for bindings
  - keep file-manager behavior in `yazi.toml`
  - keep Lua hooks and plugin code in `init.lua`
- Plugins:
  - recent Yazi releases use built-in package management via the `ya` helper
  - package subcommands have changed over time; inspect `ya --help` before scripting plugin installs
  - keep plugin count small and note why each one is worth the overhead
- Validation:
  - check install with `yazi --version`
  - inspect helper availability with `ya --help`
  - config verification is usually by launch-time smoke test
- Packaging notes:
  - package name is usually `yazi`
  - available on Homebrew and many modern Linux package managers; older distros may need a fallback

## fzf

- Config is often shell integration, not a standalone app config
- Check:
  - shell rc files for keybindings and completion setup
  - whether the install already provides integration scripts
- Validation:
  - `fzf --version`
  - open a shell and confirm keybindings if the task changed shell integration

## starship

- Config root:
  - `~/.config/starship.toml`
- Shell integration:
  - usually enabled from `.zshrc`, `.bashrc`, or another shell rc file
- Validation:
  - `starship --version`
  - open a new shell or source the rc file

## bat

- Config root:
  - usually `~/.config/bat/config`
- Theme changes may require a cache rebuild depending on how themes are installed
- Validation:
  - `bat --version`
  - run a small file through `bat`

## fd

- Often no dedicated config file; aliases and shell functions are common
- Validation:
  - `fd --version`

## eza

- Often configured through aliases, shell functions, or env vars
- Validation:
  - `eza --version`

## ripgrep

- Config roots:
  - `~/.ripgreprc`
  - or a custom file pointed to by `RIPGREP_CONFIG_PATH`
- Validation:
  - `rg --version`
  - run a simple search that depends on the new flags

## Packaging strategy

- Prefer the first supported system package manager already present on the machine.
- If multiple package managers are installed, prefer the one already used for adjacent tools unless the user asked otherwise.
- Only use curl-pipe installers or language-specific fallbacks when the package is unavailable or badly outdated in the primary package manager.
- For any exact install command that may have changed recently, verify with local help output or official docs before executing it.
