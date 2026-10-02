# 疑难杂症：Zed / VSCode 无法补全 NixOS 选项与 nixpkgs（nixd 配置通道 + 相对路径）

- 日期：2026-09-28
- 状态：✅ 已解决
- 影响范围：Zed 与 VSCode 里编辑本仓库 `.nix` 时，`programs.*` / `services.*` 等 NixOS + Home Manager 选项无补全/无 hover；`pkgs.*` 包名补全缺失或落到系统 nixpkgs（非 flake 锁定版本）
- 涉及文件：`home/modules/tools/dev.nix`（VSCode nixd expr）、`home/modules/tools/zed.nix`（新增，Zed 官方 HM 模块）、`home/modules/tools/default.nix`、`home/modules/desktop/packages.nix`
- 关联：nixd 2.9.2、`jnoortheen.nix-ide` 0.5.13、Zed 1.20.1

---

## 症状

- 无论 Zed 还是 VSCode，输入 `services.` / `programs.noctalia.` 等前缀都拿不到 NixOS/HM 选项补全。
- `pkgs.rip` 之类要么无结果，要么补出来的是系统 `<nixpkgs>` 的包而非本 flake 锁定的 nixpkgs。
- nixd 输出日志（VSCode 的 `Nix` 输出通道）里可见：
  `option worker reported: -32001: attrname settings not found in attrset`、
  `options hover: -32001: attrname ... not found in attrset`。

## 环境

- nixd：`nixd, version: 2.9.2`（系统 `modules/nix.nix` 安装，编辑器共用）。
- VSCode：`jnoortheen.nix-ide` 0.5.13，`nix.serverSettings.nixd` 声明三组 expr。
- Zed：手写在 `~/.config/zed/settings.json` 的 `lsp.nixd`，只配了 `options.nixos`。
- 仓库为 git flake，工作树路径 `/home/ran/nixos-config`。

## 排查过程（时间线 + 关键证据）

1. **确认 nixd 版本与行为**：`nixd --help` 有 `--config`、`--nixpkgs-expr`、`--nixos-options-expr`；但用 LSP 客户端实测，`initialize` 的 `initializationOptions` 传什么，nixd 都仍用内置默认：
   ```
   >>> attrset/evalExpr  {"params":"import <nixpkgs> { }"}
   >>> attrset/evalExpr  {"params":"(let pkgs = import <nixpkgs> { }; in ...).options"}
   ```
   nixd 只在收到 `workspace/configuration`（section `"nixd"`）后才改用自定义 expr。
2. **验证 `--config` 也不能用**：`nixd --config '<json>'` 仍然先发默认 expr；当客户端对 `workspace/configuration` 回 `null` 时，nixd 也不回退到 `--config`。→ **nixd ≥2.9 唯一配置通道 = `workspace/configuration`**。
3. **VSCode 扩展确认走该通道**：反编译 `jnoortheen.nix-ide/dist/extension.js.map`，`activate()` 里 `serverOptions` 只有 `command`/`args`，**没有 `options.cwd`**；中间件 `middleware.workspace.configuration` 返回 `nix.serverSettings["nixd"]`。→ 配置本身能送达，但 **nixd 的 cwd = 扩展宿主进程 cwd（通常是 `$HOME`，不是工作区）**。
4. **复现**：用最小 LSP 客户端驱动 nixd。仓库根为 cwd 时三组 expr 正常（`services.`→openssh、`programs.noctalia.`→enable、`pkgs.rip`→ripgrep）；把 nixd 的 cwd 换到 `/home/ran` 后：
   ```
   nixos eval expr: -32001: file '/home/ran/.local/share/Kingsoft/...' has an unsupported type
   nixpkgs entries eval expr: -32001: ... has an unsupported type
   home-manager eval expr: -32001: ... has an unsupported type
   ```
   nixd 把这些错误吞掉、静默回退到内置默认选项（只有 stock NixOS options + 系统 `<nixpkgs>`），所以“看似启动了、实则没加载项目配置”。
5. **Zed 侧**：`~/.config/zed/settings.json` 把配置写在 `lsp.nixd.initialization_options`。step 1/2 已证明该键被 nixd 完全忽略；且它压根没配 `nixpkgs.expr` / `home-manager.expr`。

## 根因分析

- **直接原因**：nixd ≥2.9 只从 LSP `workspace/configuration`（section `"nixd"`）读配置，`initialization_options` 与 `--config` 均无效。
- **Zed**：配置放在 `initialization_options` → 从未生效；且缺 `nixpkgs` / `home-manager` 两组 expr。
- **VSCode**：配置通道正确，但 expr 里用 `builtins.toString ./.`。nixd 用**进程 cwd** 解析相对路径；而 `nix-ide` 扩展 spawn nixd 时未指定 `cwd`，继承扩展宿主（`$HOME`）→ `builtins.getFlake` 找不到 flake → nixd 静默用内置默认。
- **为什么之前没发现**：nixd 对 expr 求值失败**不打到编辑器 UI**，只在 nixd stderr（VSCode 的 `Nix` 输出通道）里报 `-32001: ... unsupported type`；默认回退又能补出一部分系统包，掩盖了“配置没加载”。

## 修复方案

统一原则：**expr 用绝对路径**；**Zed 写 `settings` 而非 `initialization_options`**。

1. `home/modules/tools/dev.nix`：新增 `let flakePath = "${my.homeDirectory}/nixos-config";`，三组 expr（`nixpkgs` / `options.nixos` / `options.home-manager`）一律改用 `builtins.getFlake "${flakePath}"`。
2. 新增 `home/modules/tools/zed.nix`：`programs.zed-editor.enable = true`（官方 HM 模块，自动装包 + 可声明式扩展 `[ "nix" ]`），把同一套 expr 写进 `userSettings.lsp.nixd.settings`。`mutableUserSettings` 默认 `true`，HM 在 activation 用 jq 深合并进既有 `~/.config/zed/settings.json`，保留用户其它设置。
3. `home/modules/tools/default.nix` 引入 `./zed.nix`；`home/modules/desktop/packages.nix` 删除裸 `zed-editor`（STANDARDS §3.1 包唯一性）。
4. 立即生效（未重建前）：手工把 `~/.config/zed/settings.json` 的 `lsp.nixd.initialization_options` 改为 `settings` 并补齐三组 expr。
5. 验证：`nix fmt && nix flake check`，然后 `nr` 切换。VSCode 里 `Ctrl+Shift+P → Developer: Reload Window`（或 `Nix: Restart Language Server`）。

**验证证据**（最小 LSP 客户端，nixd cwd 故意设为 `/home/ran`）：改用绝对路径后
`programs.noctalia.` → `enable`、`services.` → `openssh`、`pkgs.rip` → `ripgrep`，且无 `-32001`。

## 经验教训（防再犯）

- **nixd 配置只认 `workspace/configuration`**：VSCode 写 `nix.serverSettings.nixd`；Zed 写 `lsp.nixd.settings`。`initialization_options` / `--config` 是历史残留，不要再依赖。
- **nixd 的 expr 禁用相对路径**：编辑器不保证把 nixd 的 cwd 设到工作区，统一用 `${my.homeDirectory}/nixos-config` 绝对路径（与 topgrade 的仓库路径假设同源）。
- 排查 nixd 补全问题，第一现场是 VSCode 的 `Nix` 输出通道 / nixd stderr；`-32001: ... unsupported type` 或 `attrname ... not found` = 自定义 expr 没加载。
- 有官方 HM 模块的编辑器走 `programs.<x>`（Zed 之前是裸包，违反 STANDARDS §3.1 判定树 6）。

## 遗留事项（TODO）

- [ ] `formatting.command = [ "nixfmt" ]` 依赖 PATH；仓库外/无 direnv 时可能找不到 nixfmt。可考虑改成 `${pkgs.nixfmt}/bin/nixfmt` 绝对路径（VSCode 与 Zed 两侧同步）。
