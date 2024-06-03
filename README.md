# Promptor

Customize your zsh prompt with powerline or nerd font.  
Full examples at [examples.md](docs/examples.md).

<p align="center">
  <img src="./images/promptor.drawio.png" >
</p>

## Fonts

<a url="https://www.nerdfonts.com/">https://www.nerdfonts.com/</a>  
<a url="https://github.com/powerline/fonts">https://github.com/powerline/fonts</a>

## How to install ?

``` bash
mkdir -p $HOME/.zshrc.d
cp -r promptor $HOME/.zshrc.d
```

``` bash
# add this in your $HOME/.zshrc
source "$HOME/.zshrc.d/promptor/promptor.zsh"
```

## Glyphs

<p align="center">
    <img src="./images/glyphs.drawio.png" >
</p>

## Colors

<p align="center">
    <img src="./images/colors.drawio.png" >
</p>

## Section

Add section in **promptor_config::prompt** or **promptor_config::rprompt**.  
The sections are separate by `[<glyph>]`, the **Glyph** can be set by `name` or `unicode` character.

A **section** can be contain a `{{`[Function](#function)`}}` or 3 Arguments (`background`, `foreground`, `content`).

### Examples:

Full examples at [examples.md](docs/examples.md).

#### Change colors of prompt

```bash
promptor_config::prompt '[left_half_circle_thick]248 231 %~ [left_hard_divider] {{unwritten}} [left_hard_divider] {{exit_code}} [left_hard_divider]'
```

<p align="center">
  <img src="./images/example_change_color.drawio.png" >
</p>

#### Bullet prompt

```bash
promptor_config::prompt '[\ue0b6]237 231 %~[\ue0b4][\ue0b6]{{unwritten}}[\ue0b4][\ue0b6]{{exit_code}}[\ue0b4]'
```

<p align="center">
  <img src="./images/example_bullet.drawio.png" >
</p>

## Function
Call functions in **promptor_config::prompt** and **promptor_config::rprompt** with `{{<function_name>}}`  
Function can be take an arguments (`{{<function_name> <arguments...>}}`).

### Git
With `git` or `git_async` functions you can show a color status.  
You can change or disable color piority sequence with: `promptor_config::git.color.sequence`  
You can change or disable information piority sequence with: `promptor_config::git.information.sequence`

<p align="center">
  <img src="./images/git.drawio.png" >
</p>

### Custion function
~/.zshrc.d/promptor/functions/example
``` bash
# default configuration
promptor_config[example.bg]=231
promptor_config[example.fg]=232
promptor_config[example.value]="foobar"

# must be prefix by promptor_function_
promptor_function_example() {
    # the function must be print at least 3 arguments
    echo "${promptor_config[example.bg]}"    # BACKGROUND
    echo "${promptor_config[example.fg]}"    # FOREGROUND
    echo "${promptor_config[example.value]}" # CONTENT
}
```

Create automaticaly the manage function configurations:
- promptor_config::example.bg
- promptor_config::example.fg
- promptor_config::example.value

<p align="center">
  <img src="./images/function.drawio.png" >
</p>

### Custion async function
~/.zshrc.d/promptor/functions/example_async
``` bash
# default configuration
promptor_config[example.bg]=231
promptor_config[example.fg]=232
promptor_config[example.value]="foobar"

# call by end of __my_example_slow_function (not required)
__my_example_callback() {
    local answer="$1"
    promptor_reload_prompt_from_function example_async "$answer"
}

# slow example function
__my_example_slow_function() {
    sleep 1
    echo "${promptor_config[example.bg]}"    # BACKGROUND
    echo "${promptor_config[example.fg]}"    # FOREGROUND
    echo "${promptor_config[example.value]}" # CONTENT
}

# must be prefix by promptor_worker_
promptor_worker_example_async() {
    promptor_create_worker_callback example_async __my_example_callback
    promptor_launch_worker_job example_async __my_example_slow_function "$@"
}

# execute before callback (not required)
# must be prefix by promptor_function_
promptor_function_example_async() {
    # the function must be print at least 3 arguments
    echo "${promptor_config[example.bg]}"    # BACKGROUND
    echo "${promptor_config[example.fg]}"    # FOREGROUND
    echo "..."                               # CONTENT
}
```

## Configuration

You can edit the configuration file `~/.zshrc.d/promptor/promptor.conf`.  
Use the `promptor_reload` function for take your change(s).

Default configuration:
``` bash
$ promptor_config_list
example.bg                                = "231"
example.fg                                = "232"
example.value                             = "foobar"
exit_code.bg                              = "125"
exit_code.fg                              = "231"
git                                       = "true"
git.async.wait.bg                         = "238"
git.async.wait.character                  = "\uf250" ()
git.async.wait.fg                         = "231"
git.character.added                       = "A"
git.character.branch                      = "\u26d5" (⛕)
git.character.dirty                       = "M"
git.character.hash                        = "\u2d4c" (ⵌ)
git.character.separator                   = "\u2502" (│)
git.character.separator.prompt            = "\u2503" (┃)
git.character.separator.rprompt           = "\u2503" (┃)
git.character.stash                       = "S"
git.character.tag                         = "\uf02b" ()
git.character.untracked                   = "U"
git.character.upstream.left               = "\u2b63" (⭣)
git.character.upstream.right              = "\u2b61" (⭡)
git.color.added.bg                        = "207"
git.color.added.fg                        = "232"
git.color.bg                              = "240"
git.color.conflict.bg                     = "124"
git.color.conflict.fg                     = "231"
git.color.detached.bg                     = "97"
git.color.detached.fg                     = "231"
git.color.dirty.bg                        = "226"
git.color.dirty.fg                        = "232"
git.color.fg                              = "231"
git.color.remote.bg                       = "118"
git.color.remote.fg                       = "232"
git.color.sequence                        = "conflict dirty added untracked detached remote"
git.color.untracked.bg                    = "214"
git.color.untracked.fg                    = "232"
git.compress.sparse.state                 = "true"
git.describe.style                        = "tag"
git.hide_if_pwd_ignored                   = "false"
git.information.sequence                  = "dirty added untracked stash upstream"
git.omit.sparse.state                     = "true"
git.powerline.character.added             = "A"
git.powerline.character.branch            = "\ue0a0" ()
git.powerline.character.dirty             = "M"
git.powerline.character.hash              = "\u2d4c" (ⵌ)
git.powerline.character.separator         = "\u2502" (│)
git.powerline.character.separator.prompt  = "\ue0b1" ()
git.powerline.character.separator.rprompt = "\ue0b3" ()
git.powerline.character.stash             = "S"
git.powerline.character.tag               = "\uf02b" ()
git.powerline.character.untracked         = "U"
git.powerline.character.upstream.left     = "\u2b63" (⭣)
git.powerline.character.upstream.right    = "\u2b61" (⭡)
powerline                                 = "true"
prompt                                    = "[left_half_circle_thick]237 231 %~ [left_hard_divider] {{unwritten}} [left_hard_divider] {{exit_code}} [left_hard_divider]"
rprompt                                   = "[right_hard_divider] {{git_async}} [right_hard_divider] 25 231 %n@%m [right_hard_divider] 237 231 %D{%H:%M}[right_half_circle_thick]"
title                                     = "%n: %~"
title.command.max_size                    = "100"
unwritten.bg                              = "124"
unwritten.fg                              = "231"
```
