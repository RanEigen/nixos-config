# 终端系统信息；颜色与全局主题同源。
{ userConfig, ... }:
let
  palette = userConfig.preferences.catppuccin.palette;
  entry = type: key: keyColor: { inherit type key keyColor; };
in
{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "kitty-direct";
        source = toString ../../../assets/nixos-logo.png;
        width = 34;
        padding = {
          top = 3;
          left = 1;
          right = 1;
        };
      };
      display = {
        separator = " ";
        color = {
          title = palette.text;
          output = palette.text;
        };
      };
      modules = [
        "break"
        (entry "os" "OS" palette.green)
        (entry "kernel" " ├  KER " palette.green)
        ((entry "packages" " ├  PAK " palette.green) // { format = "{all}"; })
        (
          (entry "command" " ├  AGE " palette.green)
          // {
            text = "birth_install=$(stat -c %W / 2>/dev/null || stat -f %B /); current=$(date +%s); days_difference=$(( (current - birth_install) / 86400 )); echo $days_difference days";
          }
        )
        (entry "title" " └  USR " palette.green)
        "break"
        (entry "wm" "WM" palette.sapphire)
        (entry "de" " ├  DES " palette.sapphire)
        (entry "shell" " ├  SHE " palette.sapphire)
        (entry "terminal" " ├  TER " palette.sapphire)
        (entry "terminalfont" " └  TFO " palette.sapphire)
        "break"
        (entry "host" "PC " palette.teal)
        ((entry "cpu" " ├  CPU " palette.teal) // { format = "{1} @ {7}"; })
        (entry "memory" " ├  MEM " palette.teal)
        (entry "swap" " ├  SWP " palette.teal)
        (entry "gpu" " ├  GPU " palette.teal)
        ((entry "monitor" " ├  MON " palette.teal) // { format = "{width}x{height}@{refresh-rate}"; })
        ((entry "disk" " └  DIS " palette.teal) // { format = "{1}"; })
        "break"
        "colors"
      ];
    };
  };
}
