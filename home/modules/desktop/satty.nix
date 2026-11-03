# 截图标注与剪贴板交互。
{ my, ... }:
{
  programs.satty = {
    enable = true;
    settings = {
      general = {
        "copy-command" = "wl-copy";
        "focus-toggles-toolbars" = true;
        "initial-tool" = "brush";
        "zoom-factor" = 1.1;
        "actions-on-right-click" = [ "save-to-clipboard" ];
      };
      font = {
        family = my.fonts.screenshot;
        style = "Regular";
        fallback = [
          my.fonts.interface
          "Noto Sans CJK SC"
          "Noto Sans CJK JP"
          "Noto Sans CJK TC"
          "Noto Sans CJK KR"
        ];
      };
    };
  };
}
