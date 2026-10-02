# 配置资产

| 文件 | 用途 | 引用方 |
|---|---|---|
| `nixos-logo.png` | 终端和启动器图标 | `home/modules/tools/fastfetch.nix`、`home/modules/desktop/noctalia.nix` |
| `fonts.conf` | 字体回退与渲染 | `home/modules/theme/appearance.nix` |
| `scripts/toggle-wlsunset` | 护眼切换 | `home/modules/desktop/umbriel.nix` |

新增受版本管理的资产时登记用途和引用方；不在此保存秘密。

## 仅本地保留

下列目录已被 Git 忽略，文件仍在原位置，供 GUI 选择；不进入 flake 源，也不随 clone 恢复：

- `wallpapers/`
- `VideoWallpapers/`
- `nixos-wallpaper/`
- `VideoWallpaper/`（兼容旧目录名）

这些媒体需要单独备份。以后若需可复现部署大资产，应改用固定版本输入或带哈希下载。
