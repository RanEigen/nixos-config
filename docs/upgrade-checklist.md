# 升级体检单（NixOS / Home Manager 大版本升级前逐项核对）

> 目的：防止"构建成功但行为变化"的隐性破坏（构建期拦不住行为变更）。
> 原则：**只记录真实踩过/确证的破坏性变更**（事故驱动，见 STANDARDS 前言）；不预写预言性规则。

## 升级流程（顶部 checklist 逐项执行）

不使用维护缩写或包装函数。以下是 OMEN 的完整流程，使用 `&&` 保证任一步失败就停止；其他主机应按自己的存储方案选择快照步骤。

```bash
cd ~/nixos-config &&
nix flake update nixpkgs &&
nix flake check --no-write-lock-file &&
nix build .#nixosConfigurations.omen.config.system.build.toplevel --no-link --no-write-lock-file &&
sudo snapper -c root create -t single --cleanup-algorithm number -d "before rebuild" &&
sudo snapper -c home create -t single --cleanup-algorithm number -d "before rebuild" &&
nh os switch .#omen
```

Topgrade 不负责 Nix/系统/Home Manager 更新，也不执行 NixOS 重建命令。
只重建、不升级输入时，省略 `nix flake update nixpkgs`；更新全部输入时改用 `nix flake update`。需要格式化时先单独运行 `nix fmt`。
**`nh os switch` 不再有自定义快照前置步骤**，不要跳过上面的两次快照及失败阻断。
失败后保留更新后的 `flake.lock` 供排查；不要用覆盖整个文件的方式丢弃已有修改。
更新前后复核 [维护例外与退出条件](maintenance-exceptions.md)，不要随升级顺便移除尚未验证的硬件补丁。

- [ ] 预构建通过（无新增 warning，STANDARDS §8）
- [ ] 切换后**重启会话**（Umbriel 配置/HM 激活的变更才生效）
- [ ] 更新或回退 Noctalia 后执行 `noctalia config validate`，确认本地 GUI 状态版本受当前程序支持，并核对主题、壁纸；NixOS 回滚不会回滚 home 下的 GUI 状态（[主题恢复记录](troubleshooting/2026-10-25-noctalia-theme-config-version.md)）。
- [ ] 实测：登录/解锁（Noctalia 内置锁屏，PAM 走系统 login 服务）、输入法候选框（fcitx5 双通道）、毛玻璃（blur）、
      护眼（wlsunset 自动开启）
- [ ] 变更合规：STANDARDS §4 IM 双作用域两处同步（input-method.nix + umbriel.nix）

Umbriel 启动、护眼服务与图形授权的部署验收见 [会话维护记录](umbriel-maintenance.md)。

## 历史破坏性变更档案（踩过才记）

### 2026-08：sops-install-secrets 需现场编译 → Go 模块下载失败
- **症状**：新 nixpkgs 下 `sops-install-secrets-go-modules.drv` 构建失败，
  `proxy.golang.org` TLS 握手超时（国内直连不稳定）。
- **原因**：刚更新的 nixpkgs 太新，cache.nixos.org 尚未生成该包缓存 → 现场编译 → 沙箱内 Go 下载不走代理。
- **应对**：等 1-2 天缓存生成后重试；需要回退输入时只撤销本次升级差异，保留升级前已有的 lock 文件修改。
- **教训**：`nix flake update` 后先 `nix build` 预检，别直接 switch。

### 2026-08：HM yazi shellWrapperName 默认值随 stateVersion 变化
- **症状**：`stateVersion < 26.05` 时 HM 默认 `shellWrapperName = "yy"`（弃用警告）。
- **处理**：显式 `shellWrapperName = "y"`（已在 yazi.nix 设置）。
- **核对项**：升级后检查 `nix flake check` 是否出现新弃用警告（STANDARDS §8 零容忍）。

### 2026-08：HM vscode 模块选项路径重命名
- **变更**：`programs.vscode.extensions/userSettings` → `programs.vscode.profiles.default.*`。
- **核对项**：升级后 grep 仓库是否有旧选项名残留。

## 固定护栏（不随版本变化）

- `home.stateVersion` **保持 24.05**（STANDARDS §3：首次使用值，不随 NixOS 版本升）
- `startAsUserService = true` + wantedBy（上游 #3172 竞态修复，**不要动**）
- IM 变量双作用域（STANDARDS §4）：`modules/input-method.nix` + `umbriel.nix` 的 settings.environment。
- nixd 配置共用 `home/modules/tools/nixd.nix`；工作区绝对路径来自 `config/user.nix` 的 `repository`，目标主机来自清单。VSCode 走 `nix.serverSettings.nixd`，Zed 走 `lsp.nixd.settings`（REF:2026-09-28-nixd-editor-completion）。
