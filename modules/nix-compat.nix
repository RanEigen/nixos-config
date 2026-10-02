# nix-ld 为仓库外二进制提供运行库，不向全局安装对应 CLI。
{ pkgs, ... }:
{
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # 基础库
      stdenv.cc.cc
      openssl
      zlib
      fuse3
      icu
      libuuid
      xz
      gettext
      libxml2
      # GTK / Electron
      glib
      nss
      nspr
      atk
      at-spi2-atk
      at-spi2-core
      dbus
      dconf
      expat
      fontconfig
      freetype
      gdk-pixbuf
      gtk3
      pango
      cairo
      libdrm
      mesa
      # X11 / Wayland
      libx11
      libice
      libsm
      libxcursor
      libxdamage
      libxext
      libxfixes
      libxi
      libxrandr
      libxrender
      libxtst
      libxcb
      libxcomposite
      libxscrnsaver
      libxinerama
      wayland
      libxkbcommon
      # 音视频
      alsa-lib
      libpulseaudio
      libvorbis
      libogg
      libopus
      libvpx
      ffmpeg
      # 网络与运行时
      curl
      libidn2
      libssh2
      nghttp2
      rtmpdump
      python3
      systemd
    ];
  };
}
