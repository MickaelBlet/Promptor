# Promptor

<p align="center">
  <img src="./prompt.png" >
</p>

### How to install ?
``` bash
mkdir -p $HOME/.zshrc.d
cp promptor.zsh $HOME/.zshrc.d
```
``` bash
# add this in your $HOME/.zshrc
for file ($HOME/.zshrc.d/**/*.zsh) source $file
```
### Functions:
``` bash
# ------------------------------------------------------------------------------
# OPTIONS
# ------------------------------------------------------------------------------
promptor_prompt " %~ "
promptor_rprompt " %n@%m "
promptor_title "%~"
promptor_font "true"
promptor_git "true"
promptor_hour "true"
# ------------------------------------------------------------------------------
# COLORS (256)
# ------------------------------------------------------------------------------
# Prompt
promptor_colors_prompt_fg "231"
promptor_colors_prompt_bg "237"
# Lock
promptor_colors_lock_fg "231"
promptor_colors_lock_bg "124"
# RPrompt
promptor_colors_rprompt_fg "231"
promptor_colors_rprompt_bg "25"
# Git
promptor_colors_git_fg "231"
promptor_colors_git_bg "237"
promptor_colors_git_commit_fg "232"
promptor_colors_git_commit_bg "226"
promptor_colors_git_remote_fg "232"
promptor_colors_git_remote_bg "118"
# Hour
promptor_colors_hour_fg "231"
promptor_colors_hour_bg "237"
```
---

### What is this font ?
<a url="https://github.com/powerline/fonts">https://github.com/powerline/fonts</a>
