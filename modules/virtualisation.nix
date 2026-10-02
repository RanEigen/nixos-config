# 容器与 AppImage；包由官方模块安装。
{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.fuse-overlayfs ];
  # AppImage
  programs.appimage = {
    enable = true;
    binfmt = true; # 允许直接执行
  };
  programs.fuse.userAllowOther = true; # AppImage/容器用户态挂载需要

  # Podman 为 distrobox 提供 rootless 容器。
  # 不开 dockerSocket：rootful 兼容 socket（/run/podman/podman.sock）≈ root；distrobox 用 rootless 即可
  virtualisation.podman.enable = true;

  virtualisation.containers = {
    enable = true;
    containersConf.settings = {
      engine = {
        env = [ "CONTAINERS_REGISTRIES_CONF=/etc/containers/registries.conf" ];
      };
    };
    registries.settings = {
      registry = [
        {
          location = "docker.io";
          # 配置国内可用的 mirror
          mirror = [
            { location = "docker.1ms.run"; }
            { location = "docker.xuanyuan.me"; }
            { location = "hub.rat.dev"; }
          ];
        }
      ];
    };
  };
}
