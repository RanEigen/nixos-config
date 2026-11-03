# NixOS 配置

单用户 `ran`，当前主机 `omen`（HP OMEN 16-wf0xxx，x86_64-linux）。
架构与维护规则以 [STANDARDS.md](STANDARDS.md) 为准；尚未验证其他真实机器。

## 按需求找配置

| 想修改 | 从这里开始 |
|---|---|
| 当前主机启用了哪些功能 | `hosts/omen/configuration.nix`、`hosts/omen/default.nix` |
| 系统服务、网络、软件包 | `modules/`；组合入口见 `profiles/` |
| 桌面应用、Shell、编辑器、主题 | `home/modules/desktop/`、`home/modules/tools/`、`home/modules/theme/` |
| OMEN 硬件、引导、存储、性能 | `hosts/omen/` |
| 用户身份、地理位置等共享偏好、主题数据 | `config/` |
| 升级与切换 | [升级流程](docs/upgrade-checklist.md) |
| 代理使用、排障记录 | [代理说明](docs/proxy.md)、`docs/troubleshooting/` |

主机显式选择 profiles；profiles 组合系统和用户模块。共享层不依赖具体主机。新机器应使用目标机硬件配置，不复制 OMEN 的 EC、PCI 或显示器设置。架构约定见 [STANDARDS.md](STANDARDS.md)，迁移记录见[架构整理记录](docs/architecture-migration.md)。

- 依赖具体型号、PCI/USB 标识、磁盘布局、固件或显示器接口 → `hosts/<machine>/`。
- 不依赖机型的系统能力 → `modules/`，由主机选择的 `profiles/` 启用。
- 应用配置和用户偏好 → `home/`；跨系统与 Home Manager 共用的用户数据（如所在地）→ `config/user.nix`。
- `hardware-configuration.nix` 由目标机生成；不能用 OMEN 的 UUID 或设备配置作为新机器模板。

## 日常操作

```bash
nix flake update nixpkgs  # 更新指定输入；省略输入名则更新全部
topgrade                 # 非 Nix 更新
nh os rollback           # 系统回滚
```

重建与升级使用[完整操作流程](docs/upgrade-checklist.md)，不提供包装函数或维护缩写。**直接运行 `nh os switch` 不会自动创建 Snapper 快照**；OMEN 切换前必须显式创建 `/` 和 `/home` 快照，任一步失败即停止。临时补丁的复核条件见[维护例外清单](docs/maintenance-exceptions.md)。

手写 Fish 缩写仅有 `..`、`...`、`ll`、`lg`、`v`、`y`、`clip`、`tg`，插件及约束见 `home/modules/tools/fish.nix` 和 [维护标准](STANDARDS.md)。Nix 生态工具的系统/devShell 归属按对应模块维护。

## 验证

```bash
nix fmt
nix flake check --no-write-lock-file
git diff --check
git diff --cached --check
nix build .#nixosConfigurations.omen.config.system.build.toplevel --no-link
```

- `flake check` 包含格式、lint、架构边界及配置组合检查；`--no-build` 不代表检查 derivation 已构建。
- 完整系统构建不代表运行正常；切换后按改动范围核验服务和功能。详细验证边界见 [STANDARDS.md](STANDARDS.md)。

## 代理

当前由 GUI 管理 Clash 订阅与代理启停；仓库不配置 dae 或系统级透明代理。TUN 能力须在本机验证，详见[代理说明](docs/proxy.md)。

## 双显卡

OMEN 保留 Intel + NVIDIA PRIME offload 配置，不全局强制应用选择 NVIDIA。
需要独显渲染时使用 `nvidia-offload <程序>`；CUDA 应用的设备选择由应用自身管理。
这不表示单个应用会自动合并两张 GPU 的算力。

运行时需确认两张 GPU 均被 PCI 枚举、存在各自的 DRM 节点。目前检查仅发现 NVIDIA、未发现配置中的 Intel `00:02.0`，
因此双显卡运行验收尚未完成；即使固件界面显示 Hybrid，也需要进一步核对该设置的实际生效状态。

## 本地媒体

`assets/wallpapers/`、`assets/VideoWallpapers/`、`assets/nixos-wallpaper/` 保留原位置，
已取消 Git 跟踪并忽略。它们不进入 flake 源，也不会随 clone 自动恢复；请单独备份。
受版本管理的小资产用途见 [assets/README.md](assets/README.md)。
