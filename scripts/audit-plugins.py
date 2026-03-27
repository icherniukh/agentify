#!/usr/bin/env python3
import json
import os
import sys
from pathlib import Path


def get_dir_size(path="."):
    total = 0
    with os.scandir(path) as it:
        for entry in it:
            if entry.is_file():
                total += entry.stat().st_size
            elif entry.is_dir():
                total += get_dir_size(entry.path)
    return total


def format_size(size_bytes):
    for unit in ["B", "KB", "MB", "GB"]:
        if size_bytes < 1024.0:
            return f"{size_bytes:.1f} {unit}"
        size_bytes /= 1024.0
    return f"{size_bytes:.1f} TB"


def audit_plugins():
    plugins_dir = Path(os.path.expanduser("~/.claude/plugins"))
    settings_path = Path(os.path.expanduser("~/.claude/settings.json"))
    installed_path = plugins_dir / "installed_plugins.json"

    if not plugins_dir.exists():
        print("No plugins directory found.")
        return

    # Read settings
    settings = {}
    if settings_path.exists():
        try:
            with open(settings_path) as f:
                settings = json.load(f)
        except Exception as e:
            print(f"Error reading settings.json: {e}")

    enabled_plugins = settings.get("enabledPlugins", {})

    # Read installed plugins
    installed = {}
    if installed_path.exists():
        try:
            with open(installed_path) as f:
                installed = json.load(f).get("plugins", {})
        except Exception as e:
            print(f"Error reading installed_plugins.json: {e}")

    # Audit Cache Size
    cache_dir = plugins_dir / "cache"
    cache_size = get_dir_size(str(cache_dir)) if cache_dir.exists() else 0

    # Audit Marketplaces Size
    marketplaces_dir = plugins_dir / "marketplaces"
    marketplaces_size = (
        get_dir_size(str(marketplaces_dir)) if marketplaces_dir.exists() else 0
    )

    print("=== Plugin System Health Report ===")
    print(f"Total Cache Size: {format_size(cache_size)}")
    print(f"Total Marketplaces Size: {format_size(marketplaces_size)}")
    print("\n--- User Scope Plugins ---")

    active_user_plugins = []
    disabled_user_plugins = []
    orphaned_user_plugins = []  # In settings but not installed

    # Group by scope
    project_plugins = {}

    for plugin_id, installs in installed.items():
        for install in installs:
            if install.get("scope") == "user":
                is_enabled = enabled_plugins.get(plugin_id)
                info = f"{plugin_id} (Version: {install.get('version')})"
                if is_enabled is True:
                    active_user_plugins.append(info)
                else:
                    disabled_user_plugins.append(info)
            elif install.get("scope") == "project":
                proj_path = install.get("projectPath", "Unknown")
                if proj_path not in project_plugins:
                    project_plugins[proj_path] = []
                project_plugins[proj_path].append(
                    f"{plugin_id} (Version: {install.get('version')})"
                )

    for plugin_id, is_enabled in enabled_plugins.items():
        if is_enabled and plugin_id not in installed:
            orphaned_user_plugins.append(plugin_id)

    print(f"Active (Globally Enabled): {len(active_user_plugins)}")
    for p in active_user_plugins:
        print(f"  ✅ {p}")

    print(f"\nInactive/Disabled (Wasting Space): {len(disabled_user_plugins)}")
    for p in disabled_user_plugins:
        print(f"  ❌ {p}")

    if orphaned_user_plugins:
        print(f"\nOrphaned (Enabled but not installed): {len(orphaned_user_plugins)}")
        for p in orphaned_user_plugins:
            print(f"  ⚠️ {p}")

    print("\n--- Project Scope Plugins ---")
    for proj, plugs in project_plugins.items():
        print(f"\nProject: {proj}")
        for p in plugs:
            # Check if project still exists
            status = "✅" if os.path.exists(proj) else "⚠️ (Project missing)"
            print(f"  {status} {p}")


if __name__ == "__main__":
    audit_plugins()
