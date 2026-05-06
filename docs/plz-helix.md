# `plz` From Helix

This is the first minimal version of the Helix-to-LLM workflow.

## What `plz` Does

[`scripts/plz`](/Users/ivan/proj/ccconfig/scripts/plz) reads selected text from `stdin`, combines it with a natural-language instruction, sends both to an LLM CLI, and writes only the result to `stdout`.

That means Helix can use it with `:pipe` to replace the current selection.

Examples:

```bash
echo 'def f(): pass' | scripts/plz "refactor this function into one dictionary"
echo 'some vague paragraph' | scripts/plz --engine claude "rewrite this to be sharper"
```

By default `plz` uses Codex. Override with:

```bash
PLZ_ENGINE=claude scripts/plz "rewrite this"
```

The current Codex default model is `gpt-5.4-mini`.
Override it later with:

```bash
PLZ_CODEX_MODEL=gpt-5.4 scripts/plz "rewrite this"
```

## Helix Replace-Selection Workflow

Helix supports piping each selection through a shell command and replacing it with the output.

The basic manual command is:

```text
:pipe scripts/plz "refactor this function into one dictionary"
```

That is the simplest usable version.

## Helix Keybinding Example

Add something like this to `~/.config/helix/config.toml` if you want a fixed shortcut:

```toml
[keys.select]
space.p = ":pipe scripts/plz \"refactor this function into one dictionary\""
```

That is only useful for a fixed instruction. For freeform prompts, keep using `:pipe`.

## Global `plz`

The repo-managed install path is:

```bash
scripts/link-user-bin.sh --apply
```

That links:

- [`scripts/plz`](/Users/ivan/proj/ccconfig/scripts/plz)

into:

- `~/.local/bin/plz`

`~/.local/bin` is already on your PATH on this machine.

If you want a shell alias instead, you can still do:

```bash
alias plz='/Users/ivan/proj/ccconfig/scripts/plz'
```

Then Helix commands become:

```text
:pipe plz "refactor this function into one dictionary"
```

## Useful Variants

Replace current selection:

```text
:pipe plz "rewrite this to be more concise"
```

Explain selection in a scratch buffer:

```text
:append-output plz "explain what this code is doing"
```

Send selection to Claude instead of Codex:

```text
:pipe PLZ_ENGINE=claude plz "rewrite this to be less repetitive"
```

## Next Step

The minimal version assumes:

- you type the prompt in Helix command mode
- the result either replaces the selection or is appended nearby
- there is no popup, side pane, or iterative UI yet

Follow-up research is tracked in `bd` as `ccconfig-03o`.
