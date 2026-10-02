# Shell 插件与交互快捷命令；维护入口见 maintenance.nix。
{ pkgs, ... }:
{
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
          if type -q eza; alias ls="eza --icons --git"; end
          if type -q bat; alias cat="bat"; end
          if type -q lazygit; alias lg="lazygit"; end
          if type -q nvim; alias v="nvim"; end
          if type -q kitty; alias ks="kitty --session work"; end
      end
    '';
    shellAbbrs = {
      tg = "topgrade";
      gst = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gpl = "git pull";
      gl = "git log --oneline --graph";
      gd = "git diff";
      ".." = "cd ..";
      "..." = "cd ../..";
      ll = "eza -l --icons=auto --git";
      clip = "wl-copy";
    };
  };
}
