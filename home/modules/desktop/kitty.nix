# 终端外观与工作会话；模糊由合成器规则提供。
{ my, ... }:
let
  palette = my.catppuccin.palette;
in
{
  programs.kitty = {
    enable = true;
    font = {
      name = my.fonts.terminal;
      size = 11.5;
    };
    settings = {
      background_opacity = "0.8";
      dynamic_background_opacity = "yes";
      hide_window_decorations = "yes";
      window_padding_width = "12";
      cursor_shape = "beam";
      cursor_blink_interval = "0.5";
      copy_on_select = "clipboard";
      scrollback_lines = "10000";
      tab_bar_style = "powerline";
      tab_bar_min_tabs = "2";
      active_tab_foreground = palette.crust;
      active_tab_background = palette.mauve;
      inactive_tab_foreground = palette.text;
      inactive_tab_background = palette.surface0;
      tab_bar_background = palette.crust;
      disable_ligatures = "never";
    };
    keybindings = {
      "ctrl+shift+t" = "new_tab_with_cwd";
      "ctrl+shift+enter" = "new_window_with_cwd";
      "ctrl+shift+h" = "previous_window";
      "ctrl+shift+l" = "next_window";
    };
  };
  # 工作会话按需通过 kitty --session work 启动，不额外注册快捷入口。
  xdg.configFile."kitty/work".text = ''
    new_tab work
    launch --cwd=~ fish
    launch --cwd=~ --location=vsplit btop
    launch --cwd=~ --location=hsplit fish
    layout splits
  '';
}
