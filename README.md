# BrewUI 🍺

> **BrewUI** 是一款专门为 macOS 打造的原生 **SwiftUI Desktop Application**，旨在为 Homebrew 命令行工具（Formulae）和 Mac 桌面应用（Casks）提供现代化、高性能、可视化的一站式图形管理界面。

![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![macOS](https://img.shields.io/badge/macOS-14.0%2B-blue.svg)
![Homebrew](https://img.shields.io/badge/Homebrew-CLI-yellow.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

---

## 🌟 核心功能亮点 (Features)

- **📊 仪表盘与数据概览 (Dashboard)**：实时展示已安装的 Formulae (命令行工具)、Casks (Mac 桌面应用)、待升级软件包数量，以及 Homebrew 环境健康诊断指标。
- **📦 软件包可视化管理 (Package Management)**：
  - 高性能列表，支持快速搜索、筛选（直接安装包 vs 依赖包、待升级包）。
  - 右侧抽屉 Inspector 展示软件包主页、授权协议、安装版本与依赖关系树。
- **⬆️ 版本升级中心 (Updates)**：直观对比已安装版本与最新可用版本，支持针对单个软件包升级或一键 **Upgrade All** 批量升级。
- **🔍 探索与一键安装 (Search & Discover)**：在线检索 Homebrew 官方注册表，支持一键点击安装新的 CLI 工具或 Mac 应用程序。
- **🩺 系统维护与医生 (Doctor & Cleanup)**：可视化运行 `brew doctor` 诊断坏死 Tap 和权限问题，一键运行 `brew cleanup` 释放旧版本缓存与磁盘空间。
- **💻 实时终端日志控制台 (Terminal Console Drawer)**：底部内置黑客风控制台，实时流式输出 `brew` 命令的 stdout/stderr 运行日志，支持自动滚动、一键复制与清空。
- **🌐 多语言与偏好设置 (Localization & Settings)**：
  - **默认语言**：简体中文 (Chinese)。
  - **语言切换**：设置页面提供 **简体中文** 与 **English** 一键切换（状态自动持久化保存）。
  - **路径自动识别**：自动兼容 Apple Silicon (`/opt/homebrew/bin/brew`) 与 Intel Mac (`/usr/local/bin/brew`)，并支持自定义路径。

---

## 🛠 构建与安装 (Build & Install)

### 前置要求
- macOS 14.0 或更高版本
- Xcode 15+ / Swift 6.0+
- 已安装 [Homebrew](https://brew.sh)

### 命令行编译与安装

克隆仓库并运行编译脚本：
```bash
git clone https://github.com/shitouuuuu/BrewUI.git
cd BrewUI
./build_app.sh
```

`build_app.sh` 会自动完成 release 模式编译，并将打包好的 `BrewUI.app` 安装至系统的 `/Applications` (应用程序) 目录。

### 运行方式
- **Launchpad / Spotlight**：按 `Cmd + Space` 搜索 `BrewUI` 回车。
- **终端**：`open /Applications/BrewUI.app`

---

## 📄 开源协议 (License)

本项目采用 [MIT License](LICENSE) 开源协议。
