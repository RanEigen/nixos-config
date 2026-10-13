# Umbriel 会话配置维护（2026-10-07）

本次为配置审查与维护，不是已发生事故的归档。依据 `STANDARDS.md` §0、§2、§3.1、§7、§10；保留官方 flake 模块和主机 `machine.toml`，不切换合成器版本。

## 逐项处理

| 项目 | 处理与边界 |
|---|---|
| Noctalia 启动 | 保留 `programs.noctalia.systemd.enable`，删除 Umbriel 中重复的 autostart。上游合成器发布会话环境后启动 `umbriel-session.target`，该 target 拉起 `graphical-session.target`。 |
| 护眼启动 | `home/modules/desktop/wlsunset.nix` 使用官方 `services.wlsunset`；移除旧脚本、目录部署与重复装包。保留原配置经纬度 36.5 / 128.0 和日夜色温 6500 / 5000 K，不代表已核验用户所在地。经纬度模式不能同时设置 `duration`，故不迁移旧脚本中的 `-d 1800`。 |
| 配置校验 | `checks.umbriel-config` 使用 NixOS 所装 Umbriel 校验生成的主配置和 `machine.toml`。额外向主机 include 注入未知表，确认校验失败，避免 optional include 被漏检。检查只用声明式输入，不读取运行中的用户配置。 |
| 图标同源 | `QS_ICON_THEME` 引用 `config.gtk.iconTheme.name`，仍为 Papirus-Dark。 |
| root 图形授权 | 仓库未发现必须依赖此权限的消费者；删除默认 `xhost +si:localuser:root` 和 xhost 装包。当前会话已有授权不会因改配置立即消失，重新登录后须验证；本轮未改活动会话授权。 |
| 窗口规则 | 修正模糊“零额外消耗”注释；保留现有匹配规则和顺序。部分应用当前不在 PATH 中，但不足以确认用户不再使用，本轮不猜测删除。清理旧规则需先确认应用和自定义 app-id 已退役。 |

键位、输入法双作用域变量、窗口外观、显示器、stateVersion、磁盘事实和 Home Manager 启动修复保持不变。ComfyUI 仅补齐原有改动的格式，不改变其逻辑。

## 构建期验收

已执行：

- `nix fmt`，并通过 flake 中的 treefmt 检查。
- `nix flake check --no-write-lock-file`：所有检查通过，实际构建 checks；包含 deadnix、statix、架构检查、最小 base 与移除 fcclient 的组合求值，以及 Umbriel 配置正反向测试。
- `git diff --check`、`git diff --cached --check`。
- `nix build .#nixosConfigurations.omen.config.system.build.toplevel --no-link --no-write-lock-file`：完整系统构建通过（本轮构建使用 `--offline`，所需系统依赖已在本机）。
- 比对修改前后求值：合成器和 Portal 包、主机 include、磁盘事实、stateVersion、输入法变量、Home Manager 服务启动设置未变。生成的 wlsunset unit 随 `graphical-session.target` 启停，并要求 `WAYLAND_DISPLAY`。
- 新系统闭包不再包含 Tela 或 xhost，包含 wlsunset。

**尚未执行系统切换和新会话运行时验收；不能据此宣称护眼、桌面启动或授权撤销已生效。** 未提交或打 tag。

## 部署与运行时验收

先运行 `nr`（不加 `-u`，不再次更新输入），成功后注销并重新登录。保留旧代际，不运行清除旧代际命令。

```bash
umbriel config validate
systemctl --user is-active graphical-session.target noctalia.service wlsunset.service
systemctl --user show noctalia.service wlsunset.service -p MainPID -p NRestarts -p ActiveState
journalctl --user -b -u noctalia.service -u wlsunset.service --no-pager -n 80
```

核验：桌面壳正常、没有第二个非服务管理的 Noctalia 进程、无重启循环，中文输入正常，Papirus-Dark 图标正常，护眼实际有效。HDR 等输出条件可能限制 gamma 控制，须看 wlsunset 日志及实际显示，不能仅以服务 active 判定功能正常。

护眼手动开关只操作服务，不再调用旧脚本：

```bash
systemctl --user stop wlsunset.service   # 本会话关闭
systemctl --user start wlsunset.service  # 本会话开启
```

新会话默认自动启动。不使用 `disable` 或修改 HM 生成文件冒充持久配置；长期关闭应声明 `services.wlsunset.enable = false`。

检查授权可以临时使用 xhost 工具，不需要重新加入常驻系统包：

```bash
nix shell nixpkgs#xhost -c xhost
```

确认输出不再包含 `SI:localuser:root`。若仅想撤销当前旧会话的授权，可执行 `nix shell nixpkgs#xhost -c xhost -si:localuser:root`；这会影响依赖该授权的 root X11 程序，先关闭这类程序。不要改为全局 `xhost +`。

旧的 `~/.config/umbriel/scripts/toggle-wlsunset` 原先由 HM 管理，切换后应撤去该受管链接；若发现用户自行复制的普通文件，先确认来源，不自动删除。
