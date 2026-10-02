# 无官方主题端口的程序共用此色板；切换 flavor 时同步色值。
rec {
  flavor = "mocha";
  accent = "mauve";
  palette = {
    text = "#cdd6f4";
    crust = "#11111b";
    subtext0 = "#a6adc8";
    mauve = "#cba6f7";
    red = "#f38ba8";
    teal = "#94e2d5";
    sapphire = "#74c7ec";
    blue = "#89b4fa";
    green = "#a6e3a1";
    pink = "#f5c2e7";
    peach = "#fab387";
    yellow = "#f9e2af";
    overlay1 = "#8087a2";
    surface0 = "#313244";
    surface2 = "#585b70";
    shadow = "#000000B3";
  };
  names = {
    fcitx5 = "catppuccin-${flavor}-${accent}";
    gtk = "catppuccin-${flavor}-${accent}-standard";
  };
}
