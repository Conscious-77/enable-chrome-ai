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
