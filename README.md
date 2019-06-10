# zsh-prompt

<p align="center">
  <img src="./prompt.png" >
</p>

---

### How to install ?
``` bash
mkdir -P $HOME/.zshConfig
cp prompt.zsh $HOME/.zshConfig
```
``` bash
# add this in your .zshrc
if [[ -f $HOME/.zshConfig/prompt.zsh ]]; then
    source $HOME/.zshConfig/prompt.zsh
fi
```
### alias:
``` bash
prompt_font_enable
prompt_font_disable
prompt_git_enable
prompt_git_disable
```
---

### What is this font ?
<a url=https://github.com/powerline/fonts>https://github.com/powerline/fonts</a>