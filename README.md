# Aegisub_Ruby_Kara
Source: [RubyTools](https://github.com/qwe7989199/RubyTools) and [Set Karaoke Style](https://github.com/MichiyamaKaren/aegisub-set-karaoke-style)

One-click tool to add ruby annotations to Japanese subtitles and generate karaoke-style subtitles.

**Note: It cannot precisely align every syllable with the timeline.**

[Chinese(中文说明)](README_zh_CN.md)

## Usage
- Clone this repository.
- Extract the ***automation*** folder and ***libcurl.dll*** to the Aegisub root directory.
- Launch Aegisub and check the Automation menu.
  - Run "Ruby_Kara" on the selected lines.

## Important Notes
### Dependencies for RubyTools
- luajit-request
  https://github.com/LPGhatguy/luajit-request
  **Note:** You need to find a 64-bit version of **_libcurl.dll_** on your own to use this tool with the corresponding version of Aegisub.
- json (v2 edition)
  https://github.com/rxi/json.lua
- utf8.lua
  https://github.com/Stepets/utf8.lua

### Set Karaoke Style Parameters
- Advance time: By default, lyrics in the upper and lower lines form a continuous alternating sequence. For the first line of lyrics in such a sequence, this parameter advances the subtitle appearance time before the song reaches that line.
- Separation threshold: When the time gap between the current and the next line of lyrics exceeds this threshold, the next line of lyrics does not follow immediately but begins a new sequence.

### Usage Guidelines
- Run this tool on subtitles with accurate k-values (if you are unsure about k-values, see [Karaoke Timing Tutorial](https://aegisub.org/docs/latest/karaoke_timing_tutorial/)).
- K-value recommendations:
  - Add k-values before and after punctuation marks.
  - Words that require ruby annotation should have their own k-values.
- Karaoke style:
  - You need to predefine your subtitle style and template lines. Adjust the font color, size, and duration according to your specific requirements.
  - Style and template reference:
  ```
  [Styles]
  Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
  Style: K1, Noto Serif JP Black, 110, &H00FFFFFF, &H00FF0000, &H00000000, &H80000000, 0, 0, 0, 0, 100, 100, 0, 0, 1, 4, 0, 1, 120, 30, 220, 1
  Style: K2, Noto Serif JP Black, 110, &H00FFFFFF, &H00FF0000, &H00000000, &H80000000, 0, 0, 0, 0, 100, 100, 0, 0, 1, 4, 0, 3, 30, 120, 40, 1

  [Events]
  Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
  Comment: 0, 0:00:00.00, 0:00:00.00, K1, , 0, 0, 0, code syl all, fxgroup.kara=syl.inline_fx==""
  Comment: 1, 0:00:00.00, 0:00:00.00, K1, overlay, 0, 0, 0, template syl noblank all fxgroup kara,!retime("line", -100, 0)!{\pos($center, $middle)\an5\shad0\1c&H2F1CD8&\3c&HFFFFFF&\clip(!$sleft-3!, 0, !$sleft-3!, 1080)\t($sstart, $send, \clip(!$sleft-3!, 0, !$sright+3!, 1080))\bord5}
  Comment: 0, 0:00:00.00, 0:00:00.00, K1, , 0, 0, 0, template syl all fxgroup kara,!retime("line", -100, 0)!{\pos($center, $middle)\an5}
  Comment: 1, 0:00:18.65, 0:00:20.65, K1, overlay, 0, 0, 0, template furi all,!retime("line", -100, 0)!{\pos($center, !$middle+10!)\an5\shad0\1c&H2F1CD8&\3c&HFFFFFF&\clip(!$sleft-3!, 0, !$sleft-3!, 1080)\t($sstart, $send, \clip(!$sleft-3!, 0, !$sright+3!, 1080))\bord5}
  Comment: 0, 0:00:00.00, 0:00:00.00, K1, , 0, 0, 0, template furi all,!retime("line", -100, 0)!{\pos($center, !$middle+10!)\an5}
  Comment: 0, 0:00:00.00, 0:00:00.00, K1, music, 0, 0, 0, template fx no_k,!retime("line", -100, 0)!{\pos($center, !$middle!)\an5\1c&H505050&\3c&HFFFFFFF&}
  ```

- The ***Setsuna Yuki - CHASE!.ass*** file in the repository can be directly used with this script. This file serves as an example to view the final result.