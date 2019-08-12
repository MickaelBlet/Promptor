# zsh-prompt

<p align="center">
  <img src="./prompt.png" >
</p>

---

### How to install ?
``` bash
mkdir -p $HOME/.zshConfig
cp prompt.zsh $HOME/.zshConfig
```
``` bash
# add this in your $HOME/.zshrc
if [[ -f $HOME/.zshConfig/prompt.zsh ]]; then
    source $HOME/.zshConfig/prompt.zsh
fi
```
### Alias:
``` bash
prompt_font_enable
prompt_font_disable
prompt_git_enable
prompt_git_disable
```
---

### What is this font ?
<a url="https://github.com/powerline/fonts">https://github.com/powerline/fonts</a>

### What is this terminal ?
<a url="https://github.com/zeit/hyper">https://github.com/zeit/hyper</a>
