# 桌面音频、可移动介质、固件与密钥环。
{
  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    udisks2.enable = true;
    gvfs.enable = true;
    fwupd.enable = true;
    gnome.gnome-keyring.enable = true;
  };
}
