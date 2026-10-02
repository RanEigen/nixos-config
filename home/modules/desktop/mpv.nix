{
  programs.mpv = {
    enable = true;
    config = {
      "gpu-api" = "vulkan";
      hwdec = "auto-safe";
    };
  };
}
