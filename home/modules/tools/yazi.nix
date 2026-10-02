{ pkgs, ... }:

{
  # HM 提供 y 包装函数，避免手写同名 fish 函数。
  programs.yazi = {
    enable = true;
    # 显式采用新默认 "y"（stateVersion < 26.05 时 HM 默认是 legacy "yy"，会产生弃用警告）
    shellWrapperName = "y";

    # 主配置：显示隐藏文件、自然排序、目录置顶
    # 非空 settings 才会生成 yazi.toml。
    settings = {
      manager = {
        show_hidden = true;
        sort_by = "natural";
        sort_dir_first = true;
      };
    };
  };

  # yazi 专属预览依赖（仅为本程序存在；通用 CLI 如 fd/ripgrep/jq 在 shell-utils.nix，
  # zoxide 由 programs.zoxide 提供，禁止在此重复声明）
  home.packages = with pkgs; [
    ffmpegthumbnailer # 视频缩略图
    poppler-utils # PDF 预览 (pdftoppm)
    unar # 压缩包内容预览
    chafa # 备用图像渲染器
  ];
}
