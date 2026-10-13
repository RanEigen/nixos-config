{
  imports = [
    ./umbriel.nix # 合成器、键位与窗口规则
    ./kitty.nix # 终端
    ./fcitx5.nix # 输入法
    ./noctalia.nix # 桌面壳与锁屏
    ./wlsunset.nix # 会话护眼服务
    ./xdg.nix # 用户目录与默认应用
    ./mpv.nix # 视频播放
    ./satty.nix # 截图标注
    ./comfyui.nix # 壁纸 AI 放大（CUDA）
    ./qq.nix # QQ 与 Wayland 参数
    ./packages.nix # 其他应用与会话工具
  ];
}
