# Art of Command Line Digest

Source basis: the `jlevy/the-art-of-command-line` README. This file is a condensed paraphrase for skill use, not a copy of the upstream text.

Upstream:
- https://github.com/jlevy/the-art-of-command-line

## Operating posture

- Optimize for breadth, specificity, and brevity.
- Default mental model: interactive Bash on Linux.
- Many patterns transfer to macOS and other Unix-like systems, but BSD and GNU flags differ. Call that out when it matters.
- Prefer composable shell commands before reaching for a custom script.

## Documentation and discovery

- Start with local docs:
  - `man <cmd>`
  - `apropos <term>`
  - `help <builtin>`
  - `type <name>`
  - `<cmd> --help`
- If the question is really about shell syntax, remember that builtins and the shell itself have separate help paths.

## Core shell fluency

- Use pipes and redirection when they simplify the job.
- Be careful with quoting, globbing, and whitespace in filenames.
- Know enough shell editing and history to answer quickly:
  - history search
  - word-wise cursor movement
  - job control
- Prefer portable Bash-compatible patterns unless the user asked for shell-specific syntax.

## Finding and reading things

- Use `find` for exact filesystem walks.
- Use `locate` for indexed name lookup when available.
- Use `rg` for recursive content search.
- Use `less`, `head`, `tail`, and follow mode for file and log inspection.
- Use metadata tools like `stat`, `du`, `df`, and detailed `ls` output when ownership, size, or timestamps matter.

## Shaping data

- Reach first for shell-native text tools:
  - `grep`
  - `sort`, `uniq`, `comm`
  - `cut`, `paste`, `join`
  - `wc`
  - `awk`, `sed`
- For structured formats:
  - `jq` for JSON
  - `xmlstarlet` for XML
- Locale affects sorting behavior. For deterministic technical work, bytewise sorting via `LC_ALL=C` is often the right move.

## Process and remote patterns

- Use `xargs` to turn input streams into command arguments, and dry-run first if the expansion could be risky.
- Use `parallel` when the user explicitly needs concurrency and the tool is available.
- Use `pgrep` and `pkill` for process targeting by name.
- Use `ssh`, `ssh-agent`, and `ssh-add` for remote access workflows.

## System debugging

- HTTP and endpoint checks:
  - `curl`
  - `curl -I`
- Resource pressure:
  - `top` or `htop`
  - `iostat`, `vmstat`, `mpstat`
- Network visibility:
  - `ss` or `netstat`
  - `lsof`
  - packet tools like `tcpdump`, `tshark`, or `ngrep` when the problem is on the wire
- Timing and bounding:
  - `time`
  - `timeout`

## Good answer shape for this skill

- Lead with the command or short sequence.
- Add one short explanation of why it works.
- If the command is risky, show the non-destructive version first.
- If platform or package availability matters, say so instead of faking certainty.
