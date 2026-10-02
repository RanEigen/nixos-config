# 会话归档：niri → Umbriel 合成器迁移（2026-09-27）

> 本文件为一次性会话工作总结与存档，非 STANDARDS 规则。
> 前置：niri（滚动平铺 Wayland 合成器）→ Umbriel（noctalia-dev 同团队，wlroots + umbrielfx）。

---

## 1. 目标

- Umbriel 转正为唯一合成器，niri 全链路退役，配置复杂度下降。
- 保持原有观感/键位/输入法/输出形态，Noctalia 桌面壳无缝对接。

## 2. 关键决策与实现

### 官方 flake 模块（非 nixpkgs 模块）
- `flake.nix` 新增 `inputs.umbriel`（`github:noctalia-dev/umbriel`，nixpkgs follows）。
- NixOS 侧 `inputs.umbriel.nixosModules.default`（`disabledModules` 剔除 nixpkgs 的
  `programs.umbriel`，保证 schema 与所装二进制同源）；HM 侧 `inputs.umbriel.homeModules.default`
  （提供 `programs.umbriel.settings` → `config.toml`，TOML 由 `pkgs.formats.toml` 生成）。
- 包唯一性（§3.1）：包由 NixOS 侧装入 `environment.systemPackages`（greeter 列会话需要），
  HM 侧 `programs.umbriel.package = null` 避免重复安装。

### 机器剖面：`[include.optional]`
- `umbriel.nix` 主配置 `include.optional.files = [ "machine.toml" ]`；
  `hosts/omen/hm.nix` 生成 `~/.config/umbriel/machine.toml`（eDP-1 关 / HDMI-A-1 主屏 + GSK_RENDERER）。
- 其他机器无此文件 → optional 忽略，默认自动布局。比 niri 的 `_children` 追加更干净。

### 瘦身点
- 规则：niri 每组浮动应用 5 行 KDL 嵌套 → Umbriel 用正则 alternation 合并为一条
  `match.app_id = "^(a|b|c)$"`（`umbriel-rules.nix` 178 行）。
- 键位：丢中文 `hotkey-overlay-title`（Umbriel cheatsheet 自动生成），`umbriel-binds.nix` 107 行。
- 删 niri 特有包袱：`dbus-update-activation-environment`、GNOME tracker `set-environment`、
  NVIDIA `debug.wait-for-frame-completion`、`screenshot-path`。

### 缺口用 Noctalia 官方工具补
- `Mod+Tab` → `noctalia msg window-switcher`；截图 → `noctalia msg screenshot-region`；
  音量/亮度 → `noctalia msg volume-*/brightness-*`（带 OSD，niri 原本无 OSD）。

## 3. 功能缺口（不可替代）

| 缺口 | 影响 |
|---|---|
| 无窗口级屏幕捕获排除（niri `block-out-from = "screen-capture"`） | KeePassXC / GNOME Secrets / 微信在共享/录屏时可见 |
| 无自定义中文 hotkey 标题 | `Mod+F1` cheatsheet 为自动生成 |
| 截图音效 | 原 `screenshot-sound.sh` 依赖 niri 信号，Noctalia 无 hook，未移植 |
| kitty `background_blur`（ext-background-effects） | Umbriel 无此协议，模糊改由 `umbriel-rules.nix` 的 kitty 规则负责 |

## 4. 变更清单

- 删：`home/modules/desktop/niri*.nix`（4 文件）、`home/source/niri/`（6 脚本）、
  `misc.nix` 的 `niri-portals.conf`、`env.nix` 的 `XDG_CURRENT_DESKTOP = "Niri"`。
- 增：`umbriel.nix` / `umbriel-binds.nix` / `umbriel-rules.nix`、
  `assets/scripts/toggle-wlsunset`（自 niri 复用；后随资产归集迁入 `assets/`）、本归档。
- 改：`modules/desktop.nix`（`umbriel.enable` 唯一）、`hosts/omen/hm.nix`（输出段重写为
  machine.toml）、`desktop/packages.nix`（删 grim/slurp/brightnessctl/playerctl/swayidle）。
- `~/.config/niri` 残留由用户手动 `rm -rf ~/.config/niri` 清理（一次性清理不入库，避免放置无用脚本）。

## 5. 验证

- `nix flake check`（treefmt + deadnix/statix）all passed。
- `umbriel config validate` → `config: ok`（含 machine.toml include；故意插错键可报错，证明 include 生效）。
- `system.build.toplevel` 完整构建成功；greeter 会话列表仅 `umbriel`。

## 6. 回滚

- `git checkout v1.0.x`（转正前的已验证 tag）→ `sudo nixos-rebuild switch`。
- 或手工：`modules/desktop.nix` 恢复 `niri.enable = true`，恢复 niri 四文件与
  `home/source/niri/`（git 历史均有），`env.nix` 改回 `XDG_CURRENT_DESKTOP`。
