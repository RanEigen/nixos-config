# 通用 CLI 与 shell 集成。
{
  lib,
  pkgs,
  userConfig,
  ...
}:
let
  palette = userConfig.preferences.catppuccin.palette;
in
{
  programs = {
    atuin = {
      enable = true;
      enableFishIntegration = false;
      settings = {
        enter_accept = true;
        search.filters = [
          "global"
          "host"
          "session"
          "directory"
        ];
        workspaces = true;
        show_preview = true;
        search_mode = "fuzzy";
        keymap_mode = "auto";
        style = "compact";
        inline_height = 24;
        exit_mode = "return-original";
        history_filter = [ ];
      };
    };
    bat = {
      enable = true;
      config.paging = "never";
    };
    fzf = {
      enable = true;
      enableFishIntegration = false;
      historyWidget.command = ""; # Ctrl-R 交给 atuin。
    };
    zoxide = {
      enable = true;
      enableFishIntegration = false;
    };
    eza = {
      enable = true;
      enableFishIntegration = false;
    };
    zellij = {
      enable = true;
      extraConfig = ''
        show_startup_tips false
      '';
      plugins = with pkgs.zellijPlugins; [
        zjstatus
        vim-zellij-navigator
      ];
      settings = {
        default_layout = "compact";
        simplified_ui = true;
      };
    };
    # 容器内工具可能不存在；type -q 兼容旧 fish（REF:2026-08-18-distrobox-container-fish-unknown-command）。
    fish.interactiveShellInit = lib.mkAfter ''
      if type -q atuin
          atuin init fish | source
      end
      if type -q fzf
          fzf --fish | source
      end
      if type -q zoxide
          zoxide init fish | source
      end
    '';
  };
  home.packages = with pkgs; [
    # 终端媒体与信息
    onefetch
    timg
    ueberzugpp
    vhs
    mediainfo
    # 文本、文件与网络
    fd
    fx
    sd
    curlie
    tree
    moreutils
    pandoc
    unrar
    imagemagick
    tree-sitter
    mcat
    dux-gop
    distrobox
    watchexec

  ];
  xdg.configFile."onefetch/config.yml".source =
    (pkgs.formats.yaml { }).generate "onefetch-config.yml"
      {
        color = {
          title = palette.mauve;
          diagonal = palette.surface0;
          underscores = palette.surface0;
          punctuation = palette.subtext0;
          description = palette.text;
          info = palette.blue;
          hash = palette.pink;
          author = palette.green;
          email = palette.teal;
          branch = palette.peach;
          language = palette.text;
          languages = palette.text;
          license = palette.text;
          commits = palette.yellow;
          performers = palette.text;
          statistics = palette.text;
          style = palette.text;
          all_commits = palette.text;
          block = palette.text;
        };
      };
}
