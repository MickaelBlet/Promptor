# Examples

## Git async on left

```bash
promptor_config::prompt '[left_half_circle_thick]237 231 %~ [left_hard_divider] {{unwritten}} [left_hard_divider] {{exit_code}} [left_hard_divider] {{git_async}} [left_hard_divider]'
promptor_config::rprompt '[right_hard_divider] 25 231 %n@%m [right_hard_divider] 237 231 %D{%H:%M}[right_half_circle_thick]'
```

<p align="center">
  <img src="images/left_git.drawio.png" >
</p>

## Bullets

```bash
promptor_config::prompt '[left_half_circle_thick]237 231 %~[right_half_circle_thick][left_half_circle_thick]{{unwritten}}[right_half_circle_thick][left_half_circle_thick]{{exit_code}}[right_half_circle_thick]'
promptor_config::rprompt '[left_half_circle_thick]{{git_async}}[right_half_circle_thick][left_half_circle_thick]25 231 %n@%m[right_half_circle_thick][left_half_circle_thick]237 231 %D{%H:%M}[right_half_circle_thick]'
```

<p align="center">
  <img src="images/bullets.drawio.png" >
</p>

## Multiline

```bash
promptor_config::prompt '[left_half_circle_thick]240 231 %D{%H:%M} [left_hard_divider] {{git_async}} [left_hard_divider] 237 231 %~[right_half_circle_thick][\n][left_half_circle_thick]25 231 %n@%m [left_hard_divider] {{unwritten}} [left_hard_divider] {{exit_code}} [left_hard_divider]'
promptor_config::rprompt ''
```

<p align="center">
  <img src="images/multiline.drawio.png" >
</p>

## Multiline2

```bash
promptor_config::prompt '[left_half_circle_thick]39 232 %D{%H:%M:%S} [left_hard_divider] 204 232 %1d [left_hard_divider] {{unwritten}} [left_hard_divider] {{exit_code}} [left_hard_divider] {{git_async}}[right_half_circle_thick][\n]-1 2 \ue285'
promptor_config::rprompt ''
```

<p align="center">
  <img src="images/multiline2.drawio.png" >
</p>

## Multiline3

```bash
promptor_config::prompt '[left_half_circle_thick]39 232 %D{%H:%M:%S} [left_hard_divider][left_hard_divider_inverse] 204 232 %1d [left_hard_divider] {{unwritten}} [left_hard_divider] {{exit_code}} [left_hard_divider][left_hard_divider_inverse] {{git_async}}[right_half_circle_thick][\n]-1 2 \ue285'
promptor_config::rprompt ''
```
<p align="center">
  <img src="images/multiline3.drawio.png" >
</p>