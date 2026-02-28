# Enable Chrome AI

该仓库已整理为“代码与资源分层”结构，源码位于 `source/` 目录。

## 目录结构

- `source/`：核心源码、运行脚本、打包脚本与单一应用图标
- `LICENSE`：开源许可

## 快速开始

```bash
cd source
uv sync
uv run main.py
```

## 打包 macOS App

```bash
cd source
./build-macos-self-contained-app.sh
```
