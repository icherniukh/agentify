---
name: terminal-tool-bootstrap
description: Use when the user wants to install, configure, migrate, or wire shortcuts/plugins for terminal apps such as yazi, zellij, tmux, fzf, starship, bat, fd, eza, or ripgrep. Handles environment probing, package-manager-aware setup, XDG config placement, plugin-manager bootstrap, and verification.
---

# Terminal Tool Bootstrap

Use this skill for terminal app setup work: first install, config migration, shortcut binding changes, plugin manager bootstrap, or making a new machine match an existing terminal workflow.

## Start with a probe

Resolve and run `scripts/probe_terminal_tools.py` before making changes when local inspection matters. It reports:

- OS, shell, arch, and XDG config root
- available package managers
- installed state and versions for common terminal tools
- expected config paths for `tmux`, `zellij`, and `yazi`
- basic plugin-manager state such as TPM and Yazi plugin directories

If the script cannot be run, reproduce the minimum checks manually with `command -v`, `--version`, and targeted config-path reads.

## Workflow

1. Identify scope: package install, config edit, plugin install, shortcut change, or migration into a repo.
2. Inspect existing state before writing:
   - current package manager
   - whether the target binary already exists
   - whether config files already exist
   - whether the user wants repo-managed dotfiles or direct home-directory edits
3. Prefer the platform's native package manager first. If the package is missing there, use the app's official installer or a language-specific fallback only when justified.
4. Keep config placement predictable:
   - prefer XDG paths when the tool supports them
   - preserve existing layout if the user already has a non-XDG setup
   - patch existing configs minimally instead of replacing them wholesale
5. Treat plugins as optional overhead:
   - only add a plugin manager when the user asked for plugins or the workflow clearly needs one
   - keep plugin lists short and explain why each plugin is being added
   - prefer built-in features before third-party plugins
6. Validate after each change:
   - confirm the binary is installed and callable
   - run the safest available config check, dry-run, or disposable session
   - if validation is interactive-only, document the exact manual check
7. Summarize the result with:
   - installed packages
   - changed files
   - validation run
   - follow-up steps the user still needs to do manually

## Tool-specific guidance

- For `tmux`, default to `~/.tmux.conf` unless the user already uses an XDG layout. Use TPM only when plugins are requested.
- For `zellij`, edit `config.kdl` and `layouts/*.kdl` under the config root. Prefer built-in plugins and layouts before external plugin sources.
- For `yazi`, keep changes split across `yazi.toml`, `keymap.toml`, `theme.toml`, and `init.lua` instead of piling everything into one file.
- For tools like `fzf`, `starship`, `bat`, `fd`, `eza`, and `ripgrep`, config is often shell- or alias-driven. Check shell rc files and environment variables before assuming a standalone config file exists.

Read `references/tool-matrix.md` when you need per-tool config roots, plugin notes, validation patterns, or package-manager cautions.

## Guardrails

- Do not hard-code a package manager without first detecting what is available.
- Do not overwrite an existing config file without reading it and merging intentionally.
- Do not install plugins from untrusted sources without calling that out explicitly.
- Do not assume plugin syntax is stable across tool versions. If a command looks version-sensitive, inspect local `--help` output or browse official docs before applying it.
- Do not leave the user with only home-directory mutations if they asked for a repo-backed setup; stage files in the repo and explain deployment separately.
