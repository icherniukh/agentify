#!/usr/bin/env python3
"""Probe local terminal-tool setup for bootstrap and config tasks."""

from __future__ import annotations

import json
import os
import platform
import shutil
import subprocess
from pathlib import Path


PACKAGE_MANAGERS = [
    "brew",
    "apt",
    "apt-get",
    "dnf",
    "yum",
    "pacman",
    "zypper",
    "apk",
    "nix",
    "cargo",
    "pipx",
]


TOOLS = {
    "tmux": {
        "commands": ["tmux"],
        "version": ["tmux", "-V"],
    },
    "zellij": {
        "commands": ["zellij"],
        "version": ["zellij", "--version"],
    },
    "yazi": {
        "commands": ["yazi", "ya"],
        "version": ["yazi", "--version"],
    },
    "fzf": {
        "commands": ["fzf"],
        "version": ["fzf", "--version"],
    },
    "starship": {
        "commands": ["starship"],
        "version": ["starship", "--version"],
    },
    "bat": {
        "commands": ["bat"],
        "version": ["bat", "--version"],
    },
    "fd": {
        "commands": ["fd", "fdfind"],
        "version": ["fd", "--version"],
    },
    "eza": {
        "commands": ["eza", "exa"],
        "version": ["eza", "--version"],
    },
    "rg": {
        "commands": ["rg"],
        "version": ["rg", "--version"],
    },
}


def run_command(argv: list[str]) -> str | None:
    try:
        completed = subprocess.run(
            argv,
            capture_output=True,
            text=True,
            timeout=3,
            check=False,
        )
    except (OSError, subprocess.SubprocessError):
        return None

    output = (completed.stdout or completed.stderr).strip()
    if not output:
        return None
    return output.splitlines()[0]


def existing_paths(paths: list[Path]) -> list[str]:
    return [str(path) for path in paths if path.exists()]


def detect_tool(spec: dict[str, list[str]]) -> dict[str, object]:
    commands = spec["commands"]
    resolved = {}
    for command in commands:
        path = shutil.which(command)
        if path:
            resolved[command] = path

    version = None
    version_argv = spec.get("version")
    if version_argv:
        version_executable = version_argv[0]
        if shutil.which(version_executable):
            version = run_command(version_argv)
        elif resolved:
            fallback = next(iter(resolved))
            version = run_command([fallback] + version_argv[1:])

    return {
        "installed": bool(resolved),
        "commands": resolved,
        "version": version,
    }


def nonempty_strings(items: list[str]) -> list[str]:
    return [item for item in items if item]


def main() -> None:
    home = Path.home()
    xdg_config = Path(os.environ.get("XDG_CONFIG_HOME", home / ".config")).expanduser()

    tmux_config_paths = [
        home / ".tmux.conf",
        xdg_config / "tmux" / "tmux.conf",
    ]
    zellij_config_paths = [
        xdg_config / "zellij" / "config.kdl",
    ]
    yazi_config_paths = [
        xdg_config / "yazi" / "yazi.toml",
        xdg_config / "yazi" / "keymap.toml",
        xdg_config / "yazi" / "theme.toml",
        xdg_config / "yazi" / "init.lua",
    ]

    ripgrep_expected = nonempty_strings(
        [
            str(home / ".ripgreprc"),
            os.environ.get("RIPGREP_CONFIG_PATH", ""),
        ]
    )
    ripgrep_existing = existing_paths([home / ".ripgreprc"])
    if os.environ.get("RIPGREP_CONFIG_PATH"):
        env_path = Path(os.environ["RIPGREP_CONFIG_PATH"]).expanduser()
        if env_path.exists():
            ripgrep_existing.append(str(env_path))

    result = {
        "system": {
            "os": platform.system(),
            "release": platform.release(),
            "arch": platform.machine(),
            "shell": os.environ.get("SHELL"),
            "xdg_config_home": str(xdg_config),
            "home": str(home),
        },
        "package_managers": {
            manager: shutil.which(manager)
            for manager in PACKAGE_MANAGERS
            if shutil.which(manager)
        },
        "tools": {},
        "configs": {
            "tmux": {
                "expected_files": [str(path) for path in tmux_config_paths],
                "existing_files": existing_paths(tmux_config_paths),
                "plugin_paths": existing_paths([home / ".tmux" / "plugins" / "tpm"]),
            },
            "zellij": {
                "expected_files": [str(path) for path in zellij_config_paths],
                "existing_files": existing_paths(zellij_config_paths),
                "layout_dirs": existing_paths([xdg_config / "zellij" / "layouts"]),
            },
            "yazi": {
                "expected_files": [str(path) for path in yazi_config_paths],
                "existing_files": existing_paths(yazi_config_paths),
                "plugin_dirs": existing_paths([xdg_config / "yazi" / "plugins"]),
            },
            "starship": {
                "expected_files": [str(xdg_config / "starship.toml")],
                "existing_files": existing_paths([xdg_config / "starship.toml"]),
            },
            "bat": {
                "expected_files": [str(xdg_config / "bat" / "config")],
                "existing_files": existing_paths([xdg_config / "bat" / "config"]),
            },
            "ripgrep": {
                "expected_files": ripgrep_expected,
                "existing_files": ripgrep_existing,
            },
        },
    }

    for name, spec in TOOLS.items():
        result["tools"][name] = detect_tool(spec)

    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
