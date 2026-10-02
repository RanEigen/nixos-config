# 架构整理记录（2026-09-30）

本文记录当前仓库结构及文档对齐情况，不替代 `STANDARDS.md`，也不代表系统构建或运行时验收已通过。

## 当前结构

- `flake.nix` 维护 Flake 输入、主机清单和输出；`flake/` 放开发环境与检查。
- `hosts/omen/default.nix` 聚合本机配置；引导、硬件、存储、性能、EC、代理分别由主机领域模块管理。
- `profiles/` 组合基础系统、桌面和开发模块；共享系统配置位于 `modules/`，用户配置位于 `home/`。
- `hosts/omen/storage.nix` 定义本机 Snapper/Btrfs 策略，并向通用 `nr` 命令注入快照步骤。
- 小型声明式资产由 `assets/README.md` 登记；个人媒体不纳入 Git 跟踪。

## 本次文档整理

- 修正 `STANDARDS.md` 中 Snapper 和 Limine 实现位置，分别指向 `hosts/omen/storage.nix` 与 `hosts/omen/boot.nix`。
- 将架构审查清单改为当前实现状态与剩余验收要求，避免把待验证内容误写成已完成。
- 补齐 README 所引用的本记录入口。
- 精简 Flake 与 ComfyUI 配置中的历史性长注释；保留职责说明、风险提示和仍有效的事故防再犯规则。

## 验证状态

2026-10-02 本地验证：`nix fmt -- --fail-on-change`、`nix flake check --no-write-lock-file`、
`git diff --check` 与 `git diff --cached --check` 均通过；移除暂时不用的 Zotero 后，
`nix build .#nixosConfigurations.omen.config.system.build.toplevel --no-link --no-write-lock-file`
成功。此前首次完整构建因 Zotero 10.0.2 上游补丁匹配失败；移除该包后完整闭包构建通过。
以上是求值与构建验证，不包含机器上的切换、登录、硬件、网络和服务运行时验收。
