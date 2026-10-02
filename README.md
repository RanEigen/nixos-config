# NixOS 配置

单用户 `ran`，当前主机 `omen`（HP OMEN 16-wf0xxx，x86_64-linux）。
架构与维护规则以 [STANDARDS.md](STANDARDS.md) 为准；尚未验证其他真实机器。

## 配置地图

```text
flake.nix                 inputs、主机清单与输出
config/                   用户身份、工作区路径、包策略、主题数据
flake/                    本仓 devShell 与质量检查
profiles/                 base / desktop / development 配置组合
modules/                  系统领域配置与 Home Manager 接线
home/                     用户应用、shell 与主题
hosts/omen/               硬件、引导、存储、性能、显示器
  proxy/                  dae + Clash + 可独立移除的 fcclient 集成
assets/                   受版本管理的小资产，以及被忽略的本地媒体
scripts/                  仓库架构检查
docs/                     操作、迁移、升级与事故记录
```

- 主机选择 profiles；profiles 组合系统和用户模块，不反向引用主机。
- `base` 不启用桌面、Btrfs 快照、Limine 或私有代理。
- `config/user.nix` 管理用户身份、仓库绝对路径与 allowUnfree；`config/theme.nix` 管理配色。
- `stateVersion` 保持系统 `25.05`、home `24.05`，不随版本升级。
- 新机器从最小入口和目标机生成的硬件配置开始，不复制 OMEN 的 EC、PCI 和显示器设置。

## 日常操作

```bash
nr                  # 本机快照成功后，构建并切换；不更新输入
nr -u               # 更新输入并重建
nr -U nixpkgs       # 仅更新指定输入并重建
nr -n               # nh 干跑；前置快照仍会执行

tg                  # topgrade 升级入口
clean-system        # nh 清理，保留至少 15 代 / 14 天
nh os rollback      # 系统回滚
```

`nr` 的通用逻辑在 `home/modules/tools/maintenance.nix`；OMEN 的快照步骤由
`hosts/omen/storage.nix` 注入，不要求其他主机使用同一磁盘方案。

## 验证

```bash
nix fmt
nix flake check --no-write-lock-file
git diff --check
git diff --cached --check
nix build .#nixosConfigurations.omen.config.system.build.toplevel --no-link
```

- `flake check` 包含格式、deadnix/statix、架构边界及两个组合的求值检查：最小 base、移除 fcclient 后的 OMEN。
- `--no-build` 仅验证求值；组合检查不启动虚拟机或验证真实硬件。
- 完整系统构建不代表运行正常。切换后仍需核验登录、输入法、网络、快照及受影响服务。
- CI 检查 PR/push 的提交差异，不以干净工作区的空 diff 代替检查。

## 代理与闭源软件隔离

两个客户端均保留，详情见 [代理管理](docs/proxy.md)。

- `hosts/omen/proxy/settings.nix`：后端地址、端口、接口的唯一定义点。
- `dae.nix`：透明代理及防火墙，不直接依赖某个客户端。
- `clash.nix`：Clash 包、核心直连规则与托盘项。
- `fcclient.nix`：仅包含私有客户端直连规则、会话变量和托盘项；不安装其私有包或创建提权入口。

以后移除 `proxy/default.nix` 中 `./fcclient.nix` 的导入，即可解除仓库侧集成。
**仓库外安装的私有包、运行中进程、GUI 状态与旧系统代际不会因此自动删除**，清理步骤见文档。

## 本地媒体

`assets/wallpapers/`、`assets/VideoWallpapers/`、`assets/nixos-wallpaper/` 保留原位置，
已取消 Git 跟踪并忽略。它们不进入 flake 源，也不会随 clone 自动恢复；请单独备份。
受版本管理的小资产用途见 [assets/README.md](assets/README.md)。

架构整理范围与验证状态见 [架构整理记录](docs/architecture-migration.md)。
