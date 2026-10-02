# STANDARDS —— NixOS 架构与维护标准

> 本仓库修改的权威依据。规则必须对应真实事故、已知风险或仓库审查发现的问题；
> 不为尚不存在的需求建设框架，不把个人习惯写成 NixOS 的普遍技术结论。
>
> 当前：单主机 `omen`（HP OMEN 16-wf0xxx，x86_64-linux）、单用户 `ran`。
> 技术栈保持 Flakes + flake-parts + home-manager + sops-nix，主机由 `hosts` 清单驱动。
> 目标：**modules/home 提供领域配置，profiles 组合配置，hosts 选择组合并描述机器。**
> “共享”指不依赖某台机器的身份、硬件与私有后端，不表示支持任意操作系统或 CPU 架构。
>
> **必须/禁止**为硬性要求；**建议**允许有依据的例外。安全、配置归属与单一来源优先于文件长度。
> 本标准描述目标约束，**不表示现有实现已全部符合**；已知差距见 §11。新增及修改配置不得扩大差距。
> 事故档案：`docs/troubleshooting/`；架构迁移不冒充事故，不虚构 REF。

---

## 0. 底线（安全、单一来源与边界）

1. **秘密永不落明文**：token/密码只进 `secrets/secrets.yaml`（sops 加密），git 只存密文，`/nix/store` 不允许出现明文秘密。
2. **唯一来源 = 一个语义值一个定义点，多个消费者引用**：同一代理地址/端口、镜像策略、allowUnfree 策略、密码哈希及分区事实不得靠重复字面量保持一致。不同作用域允许分别输出配置，不允许分别维护同一策略值。实现方式：
   - **用户身份与共享偏好** → 通过 `my` 注入 NixOS/HM（NixOS `specialArgs`、HM `extraSpecialArgs`）。当前保留 `flake.nix` 中的定义；仅在职责需要时提取数据文件，不引入全能常量框架。
   - **主机事实** → `hosts` 清单或 `hosts/<machine>/`：hostname、hostId、目标 system、引导方式、硬件地址、磁盘布局、私有后端及端口。共享层只消费传入的数据，不硬编码主机标识。只在主机内部使用的值不提升为全局常量。
   - **stateVersion 分开管理**：`systemStateVersion` 属于每台机器，`homeStateVersion` 属于该用户环境的初始化历史；二者不是同一个值，不得为了去重合并。OMEN 当前系统 `25.05`、home `24.05`，结构迁移必须保持不变，禁止随发行版升级。
   - **镜像源/GOPROXY 等网络环境项** → 对应领域模块中的常量；daemon 与客户端引用同一值。`allowUnfree` 在系统、devShell、用户配置中的多个输出引用同一策略。
   - **仓库运行时路径** → 一处定义，编辑器补全、升级工具、重建命令共同引用；不得分别拼接 `${homeDirectory}/nixos-config`。不要把可写工作区路径替换为只读 Store 路径。
   - **配色** → flavor/accent 只在 `my.catppuccin` 定义一次；静态端口由 `modules/theme.nix`（NixOS）与 `home/modules/theme/`（HM，`catppuccin.nix`/`appearance.nix` 两层）统一启用 `catppuccin/nix`，程序配色一律走其模块接口（`catppuccin.<程序>`），禁止在各程序配置里手写 hex/调色板；派生主题名（fcitx5/GTK）只在 `my.catppuccin.names` 定义。**无 catppuccin 端口的资产**（umbriel 焦点边框/fastfetch/GTK 主题包）统一引用 `my.catppuccin.palette`（Mocha hex 色板，同源派生，换 flavor 时手动同步）。桌面壳 Noctalia 走 `programs.noctalia.settings.theme`：`source = "wallpaper"`（壳层动态取色，保留）固定 `mode = "dark"`，但 `templates.builtin_ids = []`——**模板写回一律禁用**（kitty/gtk/qt/starship 由 catppuccin/nix 与 HM 声明式管理，写回会与之打架，与已废除的 DMS 写回 hack 同构）。锁屏 = Noctalia 内置（PAM 认证走系统 `login` 服务，无需额外配置，2026-09-26）。**中文字体**：`lxgw-neoxihei` 为中文 UI 首选（fontconfig 回退链 + satty 标注字体，family = LXGW Neo XiHei），Noto Sans CJK SC 降为缺字兜底。
   - **禁止**：消费者再次硬编码已有来源的地址/用户名；用 `lib.mkForce` 掩盖本仓重复定义冲突；用 `builtins.getEnv` 读取环境决定系统配置。必须覆盖上游默认值时允许 `mkForce`，但须说明原因（如 §4 输入法修复）。构建依赖必须来自已声明的源码或 Flake 输入。
3. **不手改生成文件**：`hosts/<machine>/hardware-configuration.nix` 排除自动格式化与源码 lint，但仍必须参加主机求值和构建；变更硬件后重新生成并复核差异，不能以“生成文件”为由跳过配置验证。
4. **事故说明分层**：模块文件内保留「事故根因 → 防再犯规则」（1-2 句）；完整排查过程、环境、恢复流程移入 `docs/troubleshooting/` 对应文件。模块内不重复完整事故链。
5. **机器耦合红线**：依赖固定设备、本机私有服务、外部未声明二进制的配置，以及其进程匹配、地址、端口、路由和托盘固定项，必须放在 `hosts/<machine>/` 或显式接入的独立 flake；不得回流 `modules/`、共享 `home/` 或 profiles，注释也不得把某台机器的限制描述为通用前提。**闭源/商业属性本身不是机器耦合**：Chrome、办公软件等用户偏好可放 home，由主机所选组合启用。

---

## 1. 架构（主机驱动，显式组合）

- 入口保持 `flake-parts.lib.mkFlake { inherit inputs; }`，由 `hosts` 清单生成 `nixosConfigurations`；保留 `#omen`。当前只支持 `x86_64-linux`，不得宣称已验证其他平台。
- `flake.nix` 负责 inputs、主机清单与输出接线，不承载桌面设置、硬件调优或大量 HM 配置。开发环境与检查可提取到 `flake/devshell.nix`、`flake/checks.nix`；HM 接线移入独立集成模块。仅在实际提取时创建文件。
- **目标组合链**：`flake → hosts/<machine>/default.nix → configuration.nix → profiles + 主机领域模块`。主机选择 profiles；profiles 导入所需系统模块，并通过 HM 集成导入对应用户模块。
- **profiles 是普通 NixOS 模块，不是新框架**：基础 `base`、桌面 `desktop`、开发 `development` 按实际职责提取。导入即选择，优先复用官方选项，不生成自定义 enable 开关矩阵。各 profile 的前置依赖必须明确，不依赖 imports 的书写顺序。
- **最小基础不能隐含完整桌面或存储方案**：Limine/EFI、Zen 内核、Btrfs 挂载点、Snapper 配置、私有代理、GPU/EC 调优由主机显式选择。通用实现可提取复用，但不能在基础入口中无条件启用。
- **加一台机器**：添加主机清单条目，创建最小入口，在目标机器生成硬件配置，再选择需要的 profiles 和硬件模块。**禁止复制整套 OMEN 剖面后仅改主机名**；不得继承其 EC 写入、PCI 地址、输出布局或私有代理。
- 不因整理目录迁移 flake 框架；不引 flake-modules-core/digga，不改为手写裸 outputs，不使用 `mkFlake { inherit self; }`。未出现真实重复前，不建设通用主机构造框架。

---

## 2. 目录、职责与依赖方向

| 路径 | 职责 | 不得承担 |
|---|---|---|
| `flake.nix` / `flake/` | 输入、输出、主机清单、仓库开发与检查 | 桌面细节、硬件调优 |
| `profiles/` | 组合系统与用户领域模块 | 固定机器事实、重新定义工具配置 |
| `modules/` | NixOS 系统领域配置与集成 | 反向导入 hosts、默认启用所有能力 |
| `home/` | 用户身份、应用配置、会话工具 | 固定硬件、私有后端、隐含磁盘布局 |
| `hosts/<machine>/` | 主机组合、硬件、存储、引导、私有服务、主机 home | 为其他机器提供隐式基础配置 |
| `assets/` | 配置需要的小型静态资产 | 个人媒体库、秘密 |
| `docs/` | 使用、迁移、事故及升级文档 | 代替实际配置或自动检查 |

- **依赖单向**：主机选择 profiles，profiles 组合 modules/home；共享模块不得导入 `hosts/`，不得按 `hostname == "omen"` 在共享层分支实现主机特例。共享数据通过显式参数传递，不扫描宿主机环境。
- 一目录一领域、一文件一关注点；`default.nix` 仅做 imports，每项带职责注释。主机服务参数写在 `configuration.nix` 或对应领域文件，不写在聚合入口。
- 新增配置优先放入现有对应领域；只有出现独立职责才新建文件。新增模块必须有显式导入路径，禁止自动扫描目录导入，禁止预留空壳。
- `home/home.nix` 作为最小用户入口，不无条件拉入完整 GUI 和开发工具；这些由选中的 profiles 接入。主机 home 经 `hosts/<machine>/hm.nix` 聚合，显示器/锁屏、性能命令、私有代理按职责分开。
- 合成器共享配置使用 `home/modules/desktop/umbriel*.nix` 的官方 HM `settings`，TOML 由生成器产生，禁止手写 `config.toml`。显示器形态由主机 home 生成 `umbriel/machine.toml`，运行时 `umbriel config validate` 兜底。
- 图形程序的 GUI 状态与声明式配置必须明确各自所有权；提升 GUI 设置到 Nix 后，按程序安全流程清理对应覆盖项，不保留相互竞争的写入者（见现有 Noctalia 迁移说明）。
- 真实事故记录进 `docs/troubleshooting/`（有事故才写，不预写）。

### 注释精简原则

- **定位注释**（default.nix imports 行）：一行说明该 import 的职责（做什么），不含历史背景、迁移说明。
- **配置注释**（config 块内）：保留事故防再犯规则（§0.4）和唯一来源说明；删除已迁移/已移出的历史说明、emoji 标记（🔴🎯📝）可选用于高危项。
- **历史背景**：移入 `docs/troubleshooting/` 或 git commit message，模块文件不保留。
- **事故引用格式**：模块内防再犯规则须包含 `REF:YYYY-MM-DD-关键词`（如 `REF:2026-08-21-fcitx5-gtk`），全局搜索该 ID 可直达 `docs/troubleshooting/` 对应文件。示例：`# GTK_IM_MODULE 必须 mkForce "" (REF:2026-08-21-fcitx5-gtk)`。🔴 **REF 仅用于已有对应事故档（`docs/troubleshooting/` 含该 ID）的规则**；普通迁移/上游改名/环境常量只写解释、不加 `REF:`，避免悬空指针（2026-09 体检：曾有多处 REF 无档）。
- **事故文件命名**：`docs/troubleshooting/` 下文件名**必须**包含对应 REF ID（如 `2026-08-21-fcitx5-gtk.md`），终端 `ls docs/troubleshooting/ | grep ID` 或编辑器 `Ctrl+P` 输入 ID 即可秒开。

### 文件规模与拆分标准

1. **职责优先，行数是审查信号而非硬门禁**。主体文件建议 40–200 行，配置密集的单工具文件可到约 300 行；超过时先检查是否存在多个变化原因，不为达标机械拆分。
2. 聚合入口、单一服务等小文件允许少于 40 行；不同程序不因文件短就合并为 `misc.nix`。同一工具或同一协作流程的紧密相关配置可以放在一起。
3. 规则表、键位表、主题等纯数据无硬行数上限，但必须分段；数据条目多不能成为混入其他职责的理由。
4. 目录应浅且可预测，每目录建议不超过 16 个直接文件；超过时按领域分组。不再使用含糊的“全仓目录 ≤2 层”，也不新增只有转发作用的聚合层。
5. 按变化原因拆分：编辑器配置与 Git 工作流分开、存储与音频分开、主机显示器与性能命令分开。禁止为“将来可能复用”预建目录、空模块或开关矩阵。
6. 架构边界由代码审查及显式架构检查验证；`nix fmt`、deadnix、statix 不证明职责划分正确。

---

## 3. home-manager

- `useGlobalPkgs = true`、`useUserPackages = true`；`extraSpecialArgs = { inherit my; }`（身份/每机常量注入，见 §0.2）。
- 主机专属 home（依赖某机 CLI/输出形态，如 fish perf-*、umbriel 输出段）由 `hosts/<machine>/hm.nix` 聚合，经
  `home-manager.users.<name>.imports = [ ./hm.nix ]` 引入；共享 home 层禁止引用机器专属二进制或私有托盘标识。
- 重建命令的通用逻辑不得强制依赖 Snapper、固定快照名或 Btrfs；已启用快照保护的主机负责接入本机步骤，快照失败应明确报错，不静默绕过保护。
- `startAsUserService = true` + `systemd.user.services.home-manager.wantedBy = [ "default.target" ]`——上游 #3172 开机竞态的唯一修复，**不要动**。
- `home.stateVersion` 保持首次使用值，不随 NixOS 版本升。
- 有官方模块 → `programs.<x>.enable`；纯安装 → `home.packages`；配置文件 → `xdg.configFile`（禁止 `home.file` 指向 `~/.config`）。

### 3.1 包与配置落点（判定树，2026-09 起）

**安装跟「谁需要它」走，配置跟「哪个程序」走。** 按顺序判定，第一个命中即定：

1. 秘密 → `secrets/secrets.yaml`（§6）。
2. 机器专属（硬件/私有后端/主机端口/输出形态）→ `hosts/<machine>/`（§0.5）；不按软件是否闭源判断归属。
3. 特定项目工具链（编译器/LSP/语言运行时）→ 项目 devShell/direnv，不因属于 CLI 就提升为全局工具。
4. 需要 root / boot / PAM / greeter / 系统 daemon 或系统级集成 → 优先使用 `modules/<领域>.nix` 的官方 `programs./services.`；无模块且确需全局 PATH 的二进制放 `environment.systemPackages`。
5. 字体 → 系统 `fonts.packages`；主题包随对应主题模块管理，不把普通主题包装入字体列表。
6. 仅用户会话：有官方 HM 模块 → `programs.<x>`（自动装包）；纯安装 → `home.packages`。不能仅因存在 NixOS 模块，就把纯用户工具提升为系统服务。
   - GUI 应用与桌面会话工具 → `home/modules/desktop/packages.nix`；
   - 无专属领域的通用 CLI → `home/modules/tools/shell-utils.nix`；
   - 有明确领域的 CLI → 该领域文件（监控 `monitoring.nix`、开发 `dev.nix`）；
   - **程序专属依赖随程序文件**（如 yazi 预览依赖在 `yazi.nix`）。
7. 跨项目使用的编辑器辅助工具可以随编辑器模块安装；必须区分它们与第 3 项的项目版本化工具链，不用“开发工具”作为全局安装所有运行时的理由。
8. 配置所需的小型静态资产 → `assets/`（登记见 `assets/README.md`）；个人媒体库按 §3.2 管理。

**配置文件落点优先级**（从高到低）：
官方模块 `settings` > `xdg.configFile` + `pkgs.formats` 生成器 > `xdg.configFile.text` >
`xdg.configFile.source`（`assets/` 静态资产）> 必要的 `home.activation`。
运行时写回配置必须先明确所有权，不能以 activation 或 `force = true` 掩盖竞争；确需接管已有文件时，先确认备份与覆盖范围。禁止把无关程序配置堆进同一个「杂项」文件。

**包所有权**：同一最终使用环境内，避免在系统包、home 包和自动装包的官方模块中重复安装同一工具；必须同时安装时说明作用域理由。独立项目 devShell 可以声明与系统相同的工具以保持自足，不受“全仓只能声明一次”限制。依赖应就近归属，版本与策略保持单一来源；nix-ld 的运行库依赖不等同于重复安装 CLI。

### 3.2 静态资产与媒体库

- `assets/` 只保留声明式配置实际需要的 logo、字体配置、小脚本等；新增时在 `assets/README.md` 登记用途和引用方，移除引用时检查是否仍需保留资产。
- 日常 GUI 切换的图片/视频壁纸属于用户数据，放用户媒体目录，不把个人媒体库作为 flake 源的一部分。
- 必须可复现部署的大资产使用独立固定版本输入或带哈希的下载；禁止运行时下载未固定内容冒充声明式部署。不得为迁移资产擅自重写 Git 历史或删除用户原文件。
- 审查新增二进制资产时说明必要性、体积及分发方式；不用无依据的统一大小阈值代替判断。

---

## 4. 输入法环境变量（双作用域是官方写法，不是重复）

- fcitx 官方 wiki《Setup Fcitx 5》：IM 变量（`XMODIFIERS`/`QT_IM_MODULE`/`SDL_IM_MODULE`）应在**登录会话环境**设置。
  Umbriel 的 `[environment]` 会自动发布到 systemd user manager（覆盖合成器 spawn 与 systemd user 服务）；
  系统会话作用域仍保留以覆盖 greeter/登录 shell 等非合成器场景。两处保留，缺一不可。
- 落点固定：
  1. **系统会话作用域** → `modules/locale.nix` 的 `environment.sessionVariables`（统一收 XMODIFIERS / QT_IM_MODULE / SDL_IM_MODULE / GLFW_IM_MODULE）。
  2. **合成器作用域** → `home/modules/desktop/umbriel.nix` 的 `settings.environment`（2026-09-27 niri→umbriel 迁移）。
  3. `home.sessionVariables` **不重复** IM 变量（与 /etc/profile 作用域重叠），只留用户专属变量。
- 🔴 **GTK 输入法只有一条正路（2026-08-21 事故教训）**：Wayland 原生 GTK3/4 走合成器
  text-input-v3，因此 **GTK3/GTK4 任何形式都不设 im-module**——既不放
  `GTK_IM_MODULE` 环境变量，也**不放 `gtk3/gtk4.extraConfig` 的 `gtk-im-module`**
  （settings.ini 该键对 Wayland 与 X11 同时生效，写了就回退内嵌候选框=原皮），
  还要**主动覆盖官方模块的自动注入**：NixOS fcitx5 模块在其 `environment.variables`
  里写死 `GTK_IM_MODULE = "fcitx"`（经 /etc/profile→set-environment 喂给所有会话，
  仓库内 grep 不到）——必须 `environment.variables.GTK_IM_MODULE = lib.mkForce ""`
  （GTK 空串=未设）才真正关掉。GTK2（仅 X11/XWayland）保留 `gtk-im-module=fcitx`；
  XWayland GTK3 由 GTK3 内建 XIM 兜底（XMODIFIERS 已设）。完整事故链见
  docs/troubleshooting/2026-08-21-fcitx5-gtk-im-module-original-skin.md。
- 🔴 **Qt 输入法双通道（2026-08-21 DMS Spotlight 原皮真根因）**：Qt6 Wayland 应用
  （quickshell 等 systemd user 服务启动的）只继承会话环境（niri 时代 environment 块喂不到
  systemd 服务；Umbriel 会发布到 systemd user manager，但系统层仍保留以覆盖 greeter/登录
  shell）——因此 `QT_IM_MODULES = "wayland;fcitx"`（Qt 6.7+ 官方变量，合成器 text-input-v3
  优先 → classicui 主题生效）放在系统层 `modules/locale.nix`；`QT_IM_MODULE = "fcitx"`
  仅兜底 Qt4/5。缺 `QT_IM_MODULES` 时 Qt6 强制走 fcitx-qt 应用内嵌候选框=原皮（本次事故）。
  umbriel.nix 的 `settings.environment.QT_IM_MODULES` 保留为合成器 spawn 层。
- 改动 IM 变量时两处同步改（§10 checklist 第 5 项兜底）。

---

## 5. 磁盘

- fileSystems 当前由 `hosts/<machine>/hardware-configuration.nix` 管理（by-uuid）；磁盘事实只声明一处，不在存储模块重复声明。
- Snapper 配置及挂载点由主机 `storage.nix` 管理；基础 profile 不假定 `/`、`/home` 都是 Btrfs。下述 Snapper/Btrfs 要求仅适用于选择相应方案的主机，启用时必须验证目标文件系统与布局。
- disko 是可选目标，不作为架构整理的前置条件。接入已有磁盘时先核对分区、子卷及挂载声明，备份并验证恢复流程，再按官方非破坏性路径评估接入。**`--mode format,mount` 含格式化，禁止作为保留现有数据的“采纳”命令**；仅在明确授权重装/重分区并确认备份后使用（既有磁盘声明不匹配曾导致紧急模式）。
- ⚠️ `.snapshots` 禁止声明为"不挂载"子卷（snapper 会报 IO Error）。
- 🔴 `.snapshots` 必须是真正的 btrfs 子卷（2026-08-29 实测：普通空目录同样报
  `IO Error (.snapshots is not a btrfs subvolume)`，timeline/快照全部静默失败）。修复前逐一核实挂载、现有子卷和数据；仅在确认路径是空的普通目录后移除并分别创建子卷，禁止用递归删除清理已有快照。
- **快照保留策略底线**：snapper TIMELINE_LIMIT_* 必须设置（当前：hourly=5, daily=7, weekly=4, monthly=3, yearly=1）。不设保留策略 → btrfs 元数据膨胀 → 空间满后 IO 性能骤降 + metadata 错误（btrfs 活坑）。OMEN 实现在 `hosts/omen/storage.nix`。
- **快照访问权限**：重要子卷（/、/home）的 snapper 配置必须设 `ALLOW_GROUPS = "wheel"`——普通用户无需 sudo 即可只读访问 `.snapshots`，符合直觉。
- **静默损坏检测**：使用 Btrfs 的主机必须开启 `services.btrfs.autoScrub`（SSD 每月一次，HDD 每季度一次）；scrub 用于检测校验错误，能否修复取决于是否存在可用冗余，不能代替备份。
- **快照 ≠ 备份**：快照用于本地回滚（后悔药），物理损坏/文件系统崩溃会连带快照消失。核心数据（secrets 私钥、Documents、代码）必须有脱离快照的异地备份（Restic/Borg/U盘/Bitwarden）。secrets 物理私钥必须在外部安全介质保留副本。
- **Nix Store 血栓预防**：高频试验大型包（CUDA/LLM/桌面组件）会导致 Store 膨胀到 100GB+，挤压快照空间引发 Metadata 错误。必须启用 `nix.gc` 自动清理（保留 7-14 天）+ `nix.optimise.automatic = true` 硬链接去重。配置见 `modules/nix.nix`。

---

## 6. 秘密（sops-nix）

- 默认文件 `secrets/secrets.yaml`；密码用 `neededForUsers = true` + `hashedPasswordFile`，不设明文密码。
- 🔴 **私钥必须放 `/` 下**（如 `/var/lib/sops-nix/keys.txt`）：2026-08-17 放 `/home` → 开机时 `/home` 尚未挂载 → shadow 锁死。禁止放任何独立子卷。
- 本机方案 = 既有盘手动拷贝私钥（`/var/lib/...` 与 `~/.config/sops/age/...` 同一私钥两份）；`generateKey` 仅全新装机自动生成。两者互斥。
- 改密码：`mkpasswd -s` → `sops secrets/secrets.yaml` 更新 → rebuild 验证。
- 多机：新机的 age 公钥加进 `.sops.yaml` 的 `keys` 与 `creation_rules.key_groups` 后
  `sops updatekeys secrets/secrets.yaml`；同一 secrets.yaml 多机共用（密码/私钥策略不变）。

---

## 7. 质量门禁（静态、求值构建、运行时分层）

### 7.1 静态检查

- 本地：`nix fmt` → `nix flake check` → `git diff --check` 与 `git diff --cached --check`，分别覆盖未暂存和已暂存改动。
- CI：格式检查使用 `nix fmt -- --fail-on-change`，运行 deadnix/statix；空白检查必须覆盖提交差异，不能只对刚 checkout 的干净工作区运行 `git diff --check`。
- PR 以目标分支与 PR head 的 merge-base 为起点检查差异；push 检查事件 before/after 范围。checkout 必须获取所需提交；初始 push 的全零 before 使用明确的空树基线，基线不可用时不得静默检查空差异。
- 架构检查优先覆盖已经发现的问题：REF 对应文件存在、共享层无已知主机私有标识、聚合入口只做 imports。先用小脚本接入 `checks`，不得将单纯 grep 当作完整语义证明；自动化未覆盖的归属、策略重复、依赖方向仍须人工审查。
- `hardware-configuration.nix` 仅豁免格式化和源码 lint；不得排除主机求值。

### 7.2 求值与构建

- 每个主机必须进入求值检查；`nix flake check --no-build` 只能报告求值结果，不能报告格式/lint derivation 已执行或构建成功。
- 普通 `nix flake check` 构建暴露在 `checks` 中的检查项，**不自动构建所有 NixOS 系统闭包**。PR 至少完成静态检查与全部主机求值；配置部署前必须构建受影响主机，例如 `nix build .#nixosConfigurations.omen.config.system.build.toplevel --no-link`。
- 硬件、内核、引导、磁盘、秘密及模块接线变更不得仅凭 lint 合入已验证版本。完整系统构建可本地或 CI 执行，但必须记录命令、目标与结果；因资源限制未运行时明确写“未验证”。
- CI 逐步增加关键生成配置校验和主机构建，不以建立复杂测试平台阻塞当前整改，不要求接入新的外部服务。

### 7.3 硬件防误用断言

- 固定 GPU 总线、EC 写入、机型特定功耗等危险模块必须有断言防误导入；断言置于实际配置所在模块，不能只依赖目录名或顶层入口。
- `message` 必须说明修复路径，例如“移除 hosts/omen/hardware.nix，并使用目标机硬件配置”；不得引导使用者仅改主机名绕过检查。
- 示例（模块参数需包含 `config`）：
  ```nix
  assertions = [{
    assertion = config.networking.hostName == "omen";
    message = "此模块仅用于已核验的 OMEN；请移除本模块并配置目标机硬件，不要仅改主机名。";
  }];
  ```
- 主机名断言只验证配置归属，不证明真实硬件兼容。危险硬件服务还需确认其运行时机型保护；不得在 Nix 求值期读取宿主机 `/sys` 来冒充目标硬件验证。

### 7.4 运行时验收与封闭求值

- 切换后检查受影响的系统服务（`systemctl status`）或用户服务（`systemctl --user status`）及日志，不能仅凭 rebuild 返回成功。桌面、输入法、网络、快照按改动范围验证。
- 禁止根据未声明的宿主机文件是否存在来决定构建配置。`builtins.pathExists` 并非在纯求值中恒为 false；仅允许用于已声明输入内有明确用途的路径判断，不用于静默跳过缺失的必需模块或依赖。

---

## 8. 零容忍

- rebuild/check 的 warning、error、deprecation 当场处理，不允许带病提交。
- 升级 NixOS/HM 大版本前读 release notes，逐条核对仓库受影响项。
- **启动项生存位**：Bootloader 必须保留足够的可回滚代际（OMEN 当前 Limine 菜单保留 `maxGenerations = 3`，受 ESP 容量限制，实现在 `hosts/omen/boot.nix`；其他主机按自身引导方案选择，系统代际档案由 `/nix/var/nix/profiles/system` 保留）。手动 `nix-collect-garbage -d` 会绕过代际保留——禁止在系统微小不稳定时执行，那是自毁长城。
- **驱动更新离线兜底**：涉及核心驱动（Wi-Fi/GPU）的更新，必须在网络环境良好的情况下进行，并确保本地有上一版本的生成记录（可 `nixos-rebuild switch --rollback` 回退）。

---

## 9. 版本

- `nixos-rebuild switch` 验证成功后 `git tag vX.Y.Z`（tag 指向已验证提交）。
- `main` 唯一长期分支，验证后才提交；应急回滚 = `git checkout vX.Y.Z` → rebuild → 回 main。

---

## 10. 提交 checklist

按改动范围执行；纯文档改动可注明 Nix 构建与运行时检查不适用，不得将未执行的检查标为通过。

- [ ] `nix fmt` 通过；CI 使用非改写检查模式
- [ ] `nix flake check` 通过，并明确是否实际构建了 checks
- [ ] 未暂存、已暂存及 CI 提交范围的空白检查符合 §7.1
- [ ] 无明文秘密进 git（diff 复查 + `secrets/` 仅密文）
- [ ] 注释/表述与改动同步（含本文件；双作用域变量两处同步）；所有新增 REF 可定位
- [ ] 配置归属、单一来源、包所有权正确；未给基础入口增加隐含桌面/存储/私有服务依赖
- [ ] 硬件专属模块有防误用断言；结构迁移未修改 stateVersion、磁盘事实和秘密路径
- [ ] 受影响主机构建成功；切换后无新增 warning，保留回滚位
- [ ] **关键服务状态核验**：按作用域使用 `systemctl status` / `systemctl --user status`，检查无自动重启循环，并验证受影响功能
- [ ] **运行时状态改动**：删除 abbr/通用变量/迁移文件等声明式管不到的运行时状态后，须 `abbr --erase`/清 `fish_variables` + 新 shell 验证——配置删了 ≠ 状态没了（REF:2026-09-09-fish-abbr-universal-residue）
- [ ] 静态资产已登记；个人媒体未继续进入 flake 源

---

## 11. 渐进迁移与验收

下表记录架构审查项目的当前实现状态。代码已拆分不等于构建或运行时验收通过；README 不得提前宣称全面合规。

| 顺序 | 项目与当前实现状态 | 验收要求 |
|---|---|---|
| 1 | OMEN 硬件、引导、功耗与 EC 模块已有主机断言 | 构建并核验危险服务的运行时机型保护 |
| 2 | 引导、存储和主机 Home Manager 已归入 `hosts/omen/`；快照步骤由主机模块注入 | 构建并检查快照、引导与托盘行为；确认通用重建入口不依赖主机存储 |
| 3 | 代理后端、GOPROXY、allowUnfree、仓库路径及 stateVersion 已有集中定义 | 检查消费者均引用定义点；保持系统 `25.05`、home `24.05` 不变 |
| 4 | CI 已检查提交范围空白；flake checks 已接入架构边界与组合求值 | 确认 CI 执行结果，并区分求值、检查构建和完整系统构建 |
| 5 | 大型媒体已从 Git 跟踪中移除，小资产由 `assets/README.md` 登记 | 核对本地媒体备份；不要破坏原文件或 Git 历史 |
| 6 | flake 开发环境、检查、Home Manager 接线与 profiles 已拆分；主机入口按职责聚合 | 完成受影响主机求值/构建；新组合单独求值，不从 OMEN 结果推断 |
| 7 | 本轮同步 README、实际文件路径与架构整理记录 | 继续核对标准中的配置事实与注释；不把未验证项目标为完成 |

迁移纪律：

- 每次只迁移一个职责，先搬移与接线，后做行为调整；不把内核升级、桌面迁移、分区操作混进架构整理。
- 保留 `#omen`、现有 stateVersion、磁盘 UUID、秘密解密路径和已验证的 HM 启动修复。
- 移除旧导入前确认新入口覆盖全部消费者；不要通过重复导入、`mkForce` 或静默条件导入掩盖迁移错误。
- 结构迁移前后对比关键求值配置；涉及系统行为时完成构建与运行时验收。新增主机或精简组合必须单独求值，不能用 OMEN 通过推断其他组合可用。
- 修改标准不代表完成自动化；记录未验证范围和剩余差距。仅在出现实际复用需求时继续抽象，不要求一次性创建全部目标目录。

---

## 🎯 [OMEN] 本机硬件要点（仅 omen 剖面；事故背书见 troubleshooting）

- **功耗墙解锁走 omen-rs**（`services.omen` flake module；参数位于 `hosts/omen/omen.nix`）：
  开机 `omen unlock` + omend hold 看门狗，EC 0xBA 写后读回验证）：
  底层通道仍是 `ec_sys` 写 EC 寄存器 `0xBA=5`（write_support=1 必须）；TLP 的 PL 配置（键名须 `PL1_LIMIT_ON_AC`，
  本机仍写不进）、WMAA 固件假 PASS（内核日志 `WMAA/WHCM aborts`）、RAPL 被 EC 实际供电覆盖——全是死路（2026-08-23 事故）。
- **AC 下 CPU 调速器用 `powersave` + EPP `balance_performance`**（`hosts/omen/performance.nix`）：
  `performance` governor 在 intel_pstate 下锁最高频（min=max）→ CPU VRM 电感高频开关 →
  登录桌面后"嗞嗞"线圈啸叫（2026-08-25 实测）；powersave 才是动态调频，重载时 HWP 仍睿频到
  5.2GHz，PL1/PL2 解锁与 scx_lavd 均不受影响，性能无损。
- 改功耗/风扇相关配置 → 对照 `docs/troubleshooting/2026-08-23-omen-ec-power-limit-2.5ghz-lock.md`。

## 文档锚点（有疑问先查这里）

- flake-parts：<https://flake.parts/getting-started>
- home-manager 手册：<https://nix-community.github.io/home-manager/>
- disko：<https://github.com/nix-community/disko>
- sops-nix：<https://github.com/Mic92/sops-nix>
- umbriel 文档：<https://docs.noctalia.dev/umbriel/>（configuration/keybinds/actions/window-rules）
- fcitx wiki：<https://fcitx-im.org/wiki/Setup_Fcitx_5>
- nixpkgs release notes：<https://nixos.org/manual/nixos/stable/release-notes.html>
