# 维护例外与退出条件

这里只登记临时兼容补丁和主动固定的上游输入，不重复普通软件配置。
更新相关输入时复核；移除补丁应单独提交，完成验证后再删除对应条目。

| 位置 | 保留原因 | 退出条件与验证 |
|---|---|---|
| `flake.nix`：`buildGo125Module` overlay | sops-nix 仍引用旧 builder 名称 | 更新 sops-nix 后，在候选改动中移除别名；主机求值、完整构建及秘密激活均通过后删除。不得仅因 nixpkgs 已移除旧名称就删补丁。 |
| `home/modules/tools/fish.nix`：补全生成覆盖 | 包内补全生成被截断 | 更新对应软件包后，检查上游生成文件完整且通过 `fish --no-config --no-execute`，移除覆盖后再验证交互补全；现有 derivation 已校验结束标记和语法。 |
| `hosts/omen/omen.nix`：`acpi_call` 签名 | 上游安装流程未生成所需模块证书 | 更新 nixpkgs 后检查上游是否已正确生成证书；移除 overlay 后构建本机所用内核，并在启动后验证模块加载及 OMEN 服务。仅求值通过不足以删除。 |
| `flake.nix`：固定 `omen-rs` revision | 机型专属 EC/风扇控制采用显式版本 | 升级时审查上游硬件写入和服务变更，构建后在本机检查服务、功耗及风扇；验证前保持固定，不自动跟随分支。 |

## 用户 profile 软件

- ComfyUI 由用户 `nix profile` 单独管理，不属于仓库声明式配置；profile 可独立升级和回滚。
- 当前包默认使用 `$XDG_DATA_HOME/comfyui`（默认 `~/.local/share/comfyui`），会复用其中的模型、工作流、用户设置和自定义节点。旧 `python-packages` 不会自动加入新包的 Python 环境，自定义节点缺依赖时需按当前 Python 版本处理。

## nix-ld

`modules/nix-compat.nix` 的运行库清单较广，尚无逐程序验证清单。只根据可复现的实际缺库问题增删，不按分类注释推断依赖，也不为单个程序无依据地扩大全局库集。
