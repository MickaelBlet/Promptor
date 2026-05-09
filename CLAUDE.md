# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Promptor is a zsh prompt customization framework that supports powerline and nerd fonts. It provides a dynamic, extensible prompt system with support for synchronous and asynchronous functions, custom glyphs, and configurable color schemes.

## Installation

```bash
mkdir -p $HOME/.zshrc.d
cp -r promptor $HOME/.zshrc.d
```

Add to `$HOME/.zshrc`:
```bash
source "$HOME/.zshrc.d/promptor/promptor.conf"
```

## Testing Changes

After making changes to the code:

1. **Reload configuration**: Run `promptor_reload` in an active zsh session
2. **List configuration**: Run `promptor_config_list` to view all settings
3. **Live preview**: Run `promptor_preview` to interactively edit and preview prompts
4. **Test in new shell**: Open a new zsh terminal to test from a clean state

### Live Preview Tool

The `promptor_preview` function provides an interactive editor for customizing prompts:

```bash
# Start with current configuration
promptor_preview

# Start with custom strings
promptor_preview '[left_half_circle_thick]237 231 %~' '[right_hard_divider] 25 231 %n'
```

Features:
- **Text Mode**: Edit PROMPT and RPROMPT interactively with `vared`
- **Section Builder** (`__promptor_preview_section_builder`): Visual piece-by-piece construction
  - Parse existing prompt into editable sections
  - Add sections: Glyphs, colored text (bg/fg/content), functions, custom text
  - Edit/delete/move/reorder sections
  - Assemble sections into final prompt string
  - Guided menus for beginners
- Load from 4 built-in templates:
  - Default (powerline with git_async)
  - Minimal (no decorations)
  - Bullet style (rounded separators)
  - Simple arrows (basic prompt)
- Reset to default configuration from `promptor_config[default.*]`
- See rendered output before saving
- Save to config or cancel/revert changes

## Architecture

### Core Components

The system follows a load → parse → compile → render pipeline:

1. **promptor.zsh** (entry point in promptor/promptor.zsh:26-103)
   - Sources all modules in specific order
   - Registers zsh hooks (precmd, preexec)
   - Initializes configuration and functions

2. **Configuration System** (promptor/src/configuration.zsh)
   - `promptor_config` associative array stores all settings
   - Dynamically creates `promptor_config::<key>()` functions for each setting
   - Auto-saves to `promptor.conf` file
   - Maintains default values with `default.*` keys

3. **Compilation System** (promptor/src/compile.zsh)
   - Parses prompt/rprompt strings into executable action arrays
   - Converts `[glyph_name]` to Unicode characters
   - Converts `{{function_name}}` to function calls
   - Distinguishes left/right powerline characters for proper rendering
   - Outputs: `__promptor_prompt_actions`, `__promptor_rprompt_actions`, `__promptor_prompt_workers`, `__promptor_rprompt_workers`

4. **Rendering System** (promptor/src/prints.zsh)
   - Executes compiled action arrays to build PROMPT and RPROMPT
   - Handles color codes (256-color palette via ANSI escape sequences)
   - Manages powerline character placement and transitions

5. **Function Loader** (promptor/src/functions.zsh)
   - Loads all files from `promptor/functions/` directory
   - Renames `promptor_function_*` to `__promptor_function_*` (private)
   - Renames `promptor_worker_*` to `__promptor_worker_*` (async workers)
   - Creates default fallback functions for workers

6. **Async Worker System** (promptor/src/worker.zsh)
   - Uses external async.zsh library for non-blocking operations
   - Each worker runs in separate process with callback
   - Common pattern: display cached result immediately, update when worker completes
   - Example: `git_async` shows previous git status with wait indicator while computing new status

### Key Design Patterns

**Prompt String Format:**
```
[glyph]bg fg content [glyph] {{function}} [glyph]
```
- `[glyph]`: Named glyph or Unicode character (e.g., `[left_hard_divider]` or `[\ue0b0]`)
- `bg fg content`: Background color, foreground color (256-color), and text
- `{{function}}`: Calls `__promptor_function_<name>` or async `__promptor_worker_<name>`

**Function Output Protocol:**
Functions must output exactly 3 lines:
```bash
echo "$background_color"  # Line 1: 256-color code
echo "$foreground_color"  # Line 2: 256-color code
echo "$content"           # Line 3: Text to display
```

**Async Function Pattern:**
```bash
promptor_worker_<name>() {
    promptor_create_worker_callback <name> <optional_callback>
    promptor_launch_worker_job <name> <job_function> "$@"
}

promptor_function_<name>() {
    # Display immediately (cached or placeholder)
    echo "$bg" "$fg" "..."
}
```

**Configuration Functions:**
The system auto-generates helper functions for every config key:
- `promptor_config::git.color.bg "240"` - Set value directly
- `promptor_config::git.color.bg` - Interactive prompt with vared

### Directory Structure

```
promptor/
├── promptor.zsh           # Main entry point
├── promptor.conf          # Auto-generated config file (not in git)
├── lib/
│   └── async.zsh          # Third-party async library
├── src/
│   ├── configuration.zsh  # Config loading/saving
│   ├── compile.zsh        # Prompt string parser
│   ├── prints.zsh         # ANSI rendering engine
│   ├── functions.zsh      # Function loader
│   ├── worker.zsh         # Async worker management
│   ├── colors.zsh         # Color definitions
│   ├── glyphs.zsh         # Glyph name mappings
│   └── widgets.zsh        # Zsh widget bindings
└── functions/             # Prompt function plugins
    ├── git                # Synchronous git info
    ├── git_async          # Async git with placeholder
    ├── exit_code          # Last command exit code
    ├── unwritten          # Shell change indicator
    ├── echo               # Simple text display
    ├── example            # Sync function template
    └── example_async      # Async function template
```

## User-Facing Tools

### Section Builder (`promptor_preview` with [b] or [r] option)

For users unfamiliar with prompt syntax, the section builder provides:
- Visual, step-by-step prompt construction
- Guided menus for each section type
- Live preview of assembled string
- Edit/delete/move operations on sections
- No need to understand full syntax upfront

Implementation notes:
- Parses existing prompt string into sections array
- Each section is a complete unit (glyph, text segment, or function)
- Reassembles with space separation
- Returns assembled string or original on cancel

## Common Development Tasks

### Adding a New Prompt Function

1. Create file in `promptor/functions/<name>`
2. Define config defaults at top
3. Implement `promptor_function_<name>()` returning 3 lines (bg, fg, content)
4. Test with `promptor_reload` and add to prompt string

### Adding Async Function

1. Follow sync function steps above
2. Add `promptor_worker_<name>()` that calls the actual work function
3. Optional: Add callback with `promptor_create_worker_callback`
4. The sync function serves as placeholder while worker runs

### Modifying Compilation Logic

The compilation system in `promptor/src/compile.zsh:26-226` is critical:
- `__promptor_precompile_prompts()` runs once per prompt string change
- `__promptor_split_prompt()` tokenizes by brackets
- `__promptor_parse_prompt()` converts tokens to eval-able strings
- Changes here affect all prompt rendering

### Color System

Colors use 256-color palette (0-255). Common patterns:
- -1 disables color (transparent)
- Background set via `\033[48;5;<n>m`
- Foreground set via `\033[38;5;<n>m`
- Reset via `\033[0m`

Powerline glyphs are direction-aware:
- Left characters: `__promptor_left_characters` (e.g., \ue0b2)
- Right characters: `__promptor_right_characters` (e.g., \ue0b0)

## Debugging

- Configuration changes: `promptor_config_list | grep <pattern>`
- View compiled actions: `echo $__promptor_prompt_actions`
- Check function exists: `typeset -f __promptor_function_<name>`
- Test git function: `__promptor_function_git` (after sourcing)
- Async workers: Check `async_job` callbacks in worker.zsh
- Preview function: `promptor_preview` - Interactive live editor

### How promptor_preview Works

The preview function (promptor/promptor.zsh:74-470):
1. Backs up current `promptor_config[prompt]` and `promptor_config[rprompt]`
2. Enters interactive loop with menu
3. On each edit:
   - Updates config temporarily
   - Calls `__promptor_precompile_prompts` to parse strings
   - Calls `__promptor_print_prompts` to render ANSI output
   - Displays result with `print -P`
4. Templates: Pre-defined prompt strings for quick loading
5. **Section Builder** (`__promptor_preview_section_builder` at promptor.zsh:74-270):
   - Parses prompt string into array of sections
   - Interactive menu for add/edit/delete/move operations
   - Guided section creation (glyph/text/function/custom)
   - Reassembles sections into final string
   - Returns new string or original on cancel
6. Help mode: Dynamically lists available functions from `__promptor_function_*`
7. On save: Calls `__promptor_update_config_file` to persist
8. On cancel: Restores backup and recompiles

See [docs/preview-guide.md](docs/preview-guide.md) for comprehensive usage guide.

This is useful for testing prompt modifications without manually editing config files.

## Important Notes

- Never modify `promptor.conf` directly in code (it's auto-generated)
- All internal functions are prefixed with `__promptor_`
- The compilation phase happens before rendering, so prompt strings are pre-parsed
- Async workers use separate processes, avoid shared state
- Zsh version compatibility: Uses `is-at-least 5.8` checks for function copying
- The hooks `__promptor_precmd` and `__promptor_preexec` control the render cycle
