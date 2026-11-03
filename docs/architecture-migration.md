# 架构整理记录（2026-09-30）

本文记录当前仓库结构及文档对齐情况，不替代 `STANDARDS.md`，也不代表系统构建或运行时验收已通过。

## 当前结构

- `flake.nix` 维护 Flake 输入、主机清单和输出；`flake/` 放开发环境与检查。
- `hosts/omen/default.nix` 聚合本机配置；引导、硬件、存储、性能、EC、代理分别由主机领域模块管理。
- `profiles/` 组合基础系统、桌面和开发模块；共享系统配置位于 `modules/`，用户配置位于 `home/`。
- `hosts/omen/storage.nix` 定义本机 Snapper/Btrfs 策略；切换前按 `docs/upgrade-checklist.md` 显式创建快照，不提供重建缩写。
- 小型声明式资产由 `assets/README.md` 登记；个人媒体不纳入 Git 跟踪。

## 本次文档整理

- 修正 `STANDARDS.md` 中 Snapper 和 Limine 实现位置，分别指向 `hosts/omen/storage.nix` 与 `hosts/omen/boot.nix`。
- 将架构审查清单改为当前实现状态与剩余验收要求，避免把待验证内容误写成已完成。
- 补齐 README 所引用的本记录入口。
- 精简 Flake 与 ComfyUI 配置中的历史性长注释；保留职责说明、风险提示和仍有效的事故防再犯规则。

## 架构审查状态

实现状态与验收要求分开记录；代码已拆分不代表构建或运行时验收通过。修改时同步更新对应行，避免 README 和标准文档各自维护一份状态表。

| 项目与当前实现状态 | 尚需验收 |
|---|---|
| OMEN 硬件、引导、功耗与 EC 模块已有主机断言 | 构建并核验危险服务的运行时机型保护 |
| 引导、存储和主机 Home Manager 已归入 `hosts/omen/`；维护文档使用完整命令并列出快照步骤 | 构建并检查快照、引导与托盘行为；确认基础配置不依赖主机存储 |
| GOPROXY、allowUnfree、仓库路径及 stateVersion 已有集中定义 | 检查消费者均引用定义点；保持系统 `25.05`、home `24.05` 不变 |
| CI 已检查提交范围空白；flake checks 已接入架构边界与组合求值 | 确认 CI 执行结果，并区分求值、检查构建和完整系统构建 |
| 大型媒体已从 Git 跟踪中移除，小资产由 `assets/README.md` 登记 | 核对本地媒体备份；不要破坏原文件或 Git 历史 |
| flake 开发环境、检查、Home Manager 接线与 profiles 已拆分；主机入口按职责聚合 | 完成受影响主机求值/构建；新组合单独求值，不从 OMEN 结果推断 |
| README、实际文件路径与架构整理记录已同步 | 继续核对标准中的配置事实与注释；不把未验证项目标为完成 |

## 验证状态

2026-10-02 本地验证：`nix fmt -- --fail-on-change`、`nix flake check --no-write-lock-file`、
`git diff --check` 与 `git diff --cached --check` 均通过；移除暂时不用的 Zotero 后，
`nix build .#nixosConfigurations.omen.config.system.build.toplevel --no-link --no-write-lock-file`
成功。此前首次完整构建因 Zotero 10.0.2 上游补丁匹配失败；移除该包后完整闭包构建通过。
以上是求值与构建验证，不包含机器上的切换、登录、硬件、网络和服务运行时验收。
