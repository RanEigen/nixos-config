# Noctalia 回退后主题和壁纸恢复默认（2026-10-25）

## 症状与根因

- 用户反馈原主题丢失；运行时 `noctalia msg color-scheme-get` 返回 `builtin Noctalia`，`wallpaper-get` 返回空路径。
- 历史日志显示 2026-10-22 使用过 Noctalia 5.3.0；故障时运行的是 5.2.1。
- `~/.local/state/noctalia/settings.toml` 保存的 `config_version = 15` 高于当前程序支持的 14。`noctalia config validate` 报 `version 15 is newer than supported version 14`，GUI 覆盖配置未能正常加载。
- 原主题、面板和壁纸选择仍在 settings 文件中，壁纸图片也存在，没有丢失。

## 本次恢复

1. 备份原文件为 `~/.local/state/noctalia/settings.toml.before-theme-recovery-20261025`。
2. 对照锁定输入源码：版本 15 的迁移只涉及 Dock 显示器配置；本机 settings 没有 Dock 配置，因此此次可仅将版本标记改为 14。**这不是通用降级方法**，其他版本或包含相关设置时须重新核对迁移。
3. 执行 `noctalia config validate`，确认无错误后执行 `noctalia msg config-reload`，无需重启桌面。

## 验证结果

- `color-scheme-get`：`wallpaper m3-content`，与保存的主题选择一致。
- `wallpaper-get HDMI-A-1`：恢复为 `~/nixos-config/assets/nixos-wallpaper/upscale_4k_real_00016_.png`；日志确认图片纹理上传成功。
- 保留原 `theme.mode = "auto"`；重载后解析为 light，未擅自切换成其他配色。
- Noctalia 服务 `active/running`，`NRestarts=0`。
- 校验仍有三条已有插件警告：`widget.monitor`、`widget.mpvpaper` 引用了未加载的插件，`plugin_settings."noctalia/mpvpaper"` 也无对应已加载插件。原设置保留在文件及备份中，本次未恢复这些插件。
- 本次修复为本地 GUI 状态调整，未修改 Nix 配置；系统构建不适用。

## 防止复发

更新或回退 Noctalia 时，同时检查实际二进制版本与本地 GUI 配置版本。NixOS 回滚不会同步回滚 home 下的可写 GUI 状态；构建期对声明式配置的校验也不覆盖该状态。切换后执行 `noctalia config validate` 并检查实际主题和壁纸；遇到未来版本配置时先备份、核对迁移，再决定恢复兼容状态或使用支持该版本的程序。
