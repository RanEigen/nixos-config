# Shell 插件与日常工具缩写；系统维护使用完整命令。
{ pkgs, ... }:
{
  # OpenCode 2.1.1 的包内补全经管道生成时被截断为 64 KiB，末尾剩下单独的 c。
  # 直接重定向到普通文件，保留完整补全；上游打包修复后可删除此覆盖。
  xdg.configFile."fish/completions/opencode.fish".source =
    pkgs.runCommand "opencode-fish-completions" { }
      ''
        export HOME="$TMPDIR"
        ${pkgs.lib.getExe pkgs.opencode} --completions fish > "$out"
        ${pkgs.gnugrep}/bin/grep -Fxq '###-end-opencode-completions-###' "$out"
        ${pkgs.fish}/bin/fish --no-config --no-execute "$out"
      '';
  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "transient-fish";
        src = pkgs.fishPlugins.transient-fish;
      }
      {
        name = "done";
        src = pkgs.fishPlugins.done;
      }
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair;
      }
      {
        name = "sponge";
        src = pkgs.fishPlugins.sponge;
      }
      {
        name = "bang-bang";
        src = pkgs.fishPlugins.bang-bang;
      }
      {
        name = "fish-you-should-use";
        src = pkgs.fishPlugins.fish-you-should-use;
      }
      {
        name = "bass";
        src = pkgs.fishPlugins.bass;
      }
      {
        name = "forgit";
        src = pkgs.fishPlugins.forgit;
      }
      {
        name = "git-abbr";
        src = pkgs.fishPlugins.git-abbr;
      }
    ];
    interactiveShellInit = ''
      set fish_greeting ""
      # test 不输出字符串，不能用命令替换判断是否处于容器。
      if not test -e /run/.containerenv; and not set -q CONTAINER_ID
          if type -q fastfetch; and not set -q FASTFETCH_RUN_ONCE
              set -gx FASTFETCH_RUN_ONCE 1
              fastfetch
          end
          set -g __done_min_cmd_duration 10000
          set -g __done_notify_sound 0
      end
    '';
    # 手写缩写仅覆盖日常工具；Git 快捷入口交给保留的插件，不重复定义。
    shellAbbrs = {
      tg = "topgrade";
      ".." = "cd ..";
      "..." = "cd ../..";
      ll = "eza -l --icons=auto --git";
      lg = "lazygit";
      v = "nvim";
      clip = "wl-copy";
    };
  };
}
