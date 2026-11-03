# root / TTY 排障工具；会话与字体依赖由 desktop profile 选择。
{ pkgs, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      wget
      git # root 救援需要；用户 Git 配置由 HM 管理。
      traceroute
      vim
      stress-ng
      perf
      numactl
      fio
      iotop
      nmon
      sysstat
      iperf3

      # 获取源码、查看文件

      curl
      ripgrep
      jq

      # 解压源码和二进制安装包
      gnutar
      gzip
      bzip2
      xz
      unzip
      zip
      p7zip
      dpkg
      rpm
      cpio

      # ELF 检查、修改和调试
      file
      binutils
      patchelf
      strace
      gdb

      # 救援脚本运行时；开发工具链由 development profile 接入。
      python3

    ];
  };
}
