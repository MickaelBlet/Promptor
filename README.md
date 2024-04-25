# Promptor

<p align="center">
  <img src="./images/promptor.drawio.png" >
</p>

## Font
<a url="https://github.com/powerline/fonts">https://github.com/powerline/fonts</a>

## How to install ?
``` bash 
mkdir -p $HOME/.zshrc. d
cp -r promptor $HOME/.zshrc.d
```
``` bash
# add this in your $HOME/.zshrc
source "$HOME/.zshrc.d/promptor/promptor.zsh"
```
## Section
Add section in **promptor_config_prompt** or **promptor_config_rprompt**

{{ **BACKGROUND** **FOREGROUND** **CONTENT** }}

Change color of prompt
<p align="center">
  <img src="./images/promptor.section.drawio.png" >
</p>

## Function
Call functions in **promptor_config_prompt** and **promptor_config_rprompt** with {{ **FUNCTION** }}

~/.zshrc.d/promptor/promptor_functions/example
``` bash
# CONFIG (comment required for configuration)
example.bg="231"
example.fg="232"
example.value="foo bar"

# FUNCTION (comment required for configuration)
echo ${promptor_config[example.bg]} ${promptor_config[example.fg]} "${promptor_config[example.value]}"
```

Create automaticaly the manage function configurations:
- promptor_config_example_bg
- promptor_config_example_fg
- promptor_config_example_value

<p align="center">
  <img src="./images/promptor.function.drawio.png" >
</p>

## Configuration

Default configuration:
``` bash
$ promptor_config_list
git.active             = "true"
git.bg                 = "237"
git.commit.bg          = "226"
git.commit.fg          = "232"
git.fg                 = "231"
git.remote.bg          = "118"
git.remote.fg          = "232"
max_command_title_size = "100"
powerline              = "false"
prompt                 = "{{237 231 %~}}{{git}}{{unwritten}}"
rprompt                = "{{25 231 %n@%m}}{{237 231 %D{%H:%M}}}"
title                  = "%n: %~"
unwritten.bg           = "124"
unwritten.fg           = "231"
```
