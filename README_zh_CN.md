# Aegisub_Ruby_Kara
源：[RubyTools](https://github.com/qwe7989199/RubyTools) 和 [Set Karaoke Style](https://github.com/MichiyamaKaren/aegisub-set-karaoke-style)

一键为日文字幕添加假名标注并生成卡拉OK格式字幕。

**不能精确到假名每个音节都对上时间轴。**

[英文说明(English Ver)](README.md)

## 用法  
- Clone 本仓库
- 解压 ***automation*** 文件夹和 ***libcurl.dll*** 到 Aegisub 根目录
- 启动你的 Aegisub 并检查自动化菜单  
  - 在选择行上运行 "Ruby_Kara" 即可
  
## 注意事项
### RubyTools需要的依赖 
 - luajit-request  
  https://github.com/LPGhatguy/luajit-request   
  **注意：** 你需要自行寻找64位版本的 **_libcurl.dll_** 来在对应版本的 Aegisub 中使用本工具。  
 - json (v2版)  
  https://github.com/rxi/json.lua
 - utf8.lua  
  https://github.com/Stepets/utf8.lua

### Set Karaoke Style参数说明
 - Advance time：默认情况下上下两行歌词形成连续交替出现的序列，对于这样的序列的首行歌词，使字幕出现时间提前于歌曲播放到这行歌词的时间。
 - Seperation threshold：当前后两行歌词相隔时间超过这个阈值时，下一行歌词不在紧随上一行歌词出现，而是开启一个新的序列。

### 使用注意事项
 - 需要在打好k值的字幕文件上运行（如果你不知道k值：[卡拉OK计时](https://aegi.vmoe.info/docs/3.2/Karaoke_Timing_Tutorial/)）
 - k值建议：
   - 标点符号前后打k值，**包括空格**。
   - 需要假名标注的词语单独作为一块打k值。
 - 卡拉OK样式：
   - 需要自己预设字幕样式和模板行，注意根据实际情况更改字体颜色、大小和存留时间。
   - 样式和模板参考：
  ```
  [Styles]
  Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
  Style: K1,Noto Serif JP Black,110,&H00FFFFFF,&H00FF0000,&H00000000,&H80000000,0,0,0,0,100,100,0,0,1,4,0,1,120,30,220,1
  Style: K2,Noto Serif JP Black,110,&H00FFFFFF,&H00FF0000,&H00000000,&H80000000,0,0,0,0,100,100,0,0,1,4,0,3,30,120,40,1

  [Events]
  Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
  Comment: 0,0:00:00.00,0:00:00.00,K1,,0,0,0,code syl all,fxgroup.kara=syl.inline_fx==""
  Comment: 1,0:00:00.00,0:00:00.00,K1,overlay,0,0,0,template syl noblank all fxgroup kara,!retime("line",-100,0)!{\pos($center,$middle)\an5\shad0\1c&H2F1CD8&\3c&HFFFFFF&\clip(!$sleft-3!,0,!$sleft-3!,1080)\t($sstart,$send,\clip(!$sleft-3!,0,!$sright+3!,1080))\bord5}
  Comment: 0,0:00:00.00,0:00:00.00,K1,,0,0,0,template syl all fxgroup kara,!retime("line",-100,0)!{\pos($center,$middle)\an5}
  Comment: 1,0:00:18.65,0:00:20.65,K1,overlay,0,0,0,template furi all,!retime("line",-100,0)!{\pos($center,!$middle+10!)\an5\shad0\1c&H2F1CD8&\3c&HFFFFFF&\clip(!$sleft-3!,0,!$sleft-3!,1080)\t($sstart,$send,\clip(!$sleft-3!,0,!$sright+3!,1080))\bord5}
  Comment: 0,0:00:00.00,0:00:00.00,K1,,0,0,0,template furi all,!retime("line",-100,0)!{\pos($center,!$middle+10!)\an5}
  Comment: 0,0:00:00.00,0:00:00.00,K1,music,0,0,0,template fx no_k,!retime("line",-100,0)!{\pos($center,!$middle!)\an5\1c&H505050&\3c&HFFFFFFF&}
``` 

- 仓库里的 ***Setsuna Yuki - CHASE!.ass*** 文件可直接运行该脚本。此文件可作为示例，以便查看最终效果。