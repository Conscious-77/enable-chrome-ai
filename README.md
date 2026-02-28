# Enable Chrome AI

一个用于启用 Chrome 内置 AI 能力的小工具仓库，包含源码与 macOS App 打包脚本。

## 用户怎么用

### 方式一：直接运行源码

```bash
cd source
uv sync
uv run main.py
```

运行过程中会询问是否先关闭 Chrome；脚本会按你的选择执行并在结束后输出结果。

### 方式二：构建 macOS 一键 App

```bash
cd source
./build-macos-self-contained-app.sh
```

构建完成后会在 `~/Applications` 生成 `Enable Chrome AI.app`。

### 方式三：直接下载 App（推荐普通用户）

1. 打开仓库的 Release 页面下载 `Enable Chrome AI.app.zip`：  
   <https://github.com/Conscious-77/enable-chrome-ai/releases/latest>
2. 解压后将 `Enable Chrome AI.app` 拖到“应用程序”目录。
3. 双击运行，按提示选择是否先关闭 Chrome。

App 版说明：

- 不需要单独安装 Python（自包含打包）。
- 首次运行未签名应用时，可能需要“右键 -> 打开”确认一次。
- 可能会弹出“控制 Terminal”的系统授权，请点“允许”（用于在 Terminal 中执行脚本）。
- 建议使用拥有 Chrome 用户配置写权限的同一 macOS 用户运行。

## 使用条件（网络 / 账号 / Chrome）

由于该工具是为 `Gemini in Chrome` 侧边栏能力做本地配置修复，最终是否可用仍取决于 Google 服务侧条件与灰度策略。

- **网络与地区（重要）**：必须使用美国网络环境。若使用代理/🪜，请确认出口节点 `location` 为 `United States`，否则即使本地配置正确也可能不显示 Gemini in Chrome。
- **账号与年龄**：需登录 Chrome 账号，通常要求 18 岁及以上。
- **系统与浏览器**：建议使用 macOS / Windows + 最新版 Chrome。
- **语言设置**：Chrome 语言建议设为 `English (United States)`。可仅针对 Chrome 修改：`Chrome 右上角 ⋮ -> Settings -> Languages -> Preferred languages -> Add languages -> English (United States) -> Move to top`，然后重启 Chrome。
- **企业账号**：工作/学校账号可能需要管理员开启相关能力。
- **灰度发布**：即使满足条件，也可能因 Google 分批放量而暂时不可见。

说明：本项目主要修改本地 `Local State` 配置（如 `variations_country`、`is_glic_eligible`），不保证绕过服务端资格校验。

## 源码说明

仓库采用“根目录文档 + `source/` 实现代码”结构：

- `source/main.py`：核心逻辑，负责定位 Chrome 配置、打补丁、可选关闭并重启 Chrome
- `source/build-macos-self-contained-app.sh`：构建自包含 macOS `.app` 的脚本
- `source/build-macos-app.sh`：轻量启动器 `.app` 打包脚本
- `source/Chrome with Gemini.sh`：命令行一键启动脚本
- `source/README.md` / `source/README.zh.md`：更详细的中英文使用说明
- `LICENSE`：开源许可证

## 参考来源

- 原始项目：<https://github.com/lcandy2/enable-chrome-ai/?tab=readme-ov-file>
- Google 帮助（Use Gemini in Chrome）：<https://support.google.com/gemini/answer/16283624>
- Google Chrome Enterprise 文档（Gemini in Chrome）：<https://support.google.com/chrome/a/answer/16291696>
