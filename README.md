# 🚀 Antigravity 2.0 中文汉化包

[![翻译进度](https://img.shields.io/badge/翻译进度-0%25-red?style=flat-square)](https://github.com/kakarotto-baroko/antigravity-2.0-zhcn)
[![版本](https://img.shields.io/badge/Antigravity-v2.0.0-blue?style=flat-square)](https://github.com/kakarotto-baroko/antigravity-2.0-zhcn)
[![许可证](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

> 将 Google Antigravity 2.0 桌面版 IDE 完整汉化为简体中文。

## 📋 项目概述

Antigravity 2.0 是 Google 推出的新一代 AI 驱动代码编辑器（基于 VS Code/Electron）。本项目旨在为其提供完整的简体中文汉化支持。

### 汉化范围

| 层级 | 内容 | 条目数 | 状态 |
|------|------|--------|------|
| L1 | IDE 核心界面 (NLS) | ~16,567 | 🔴 待翻译 |
| L2 | AI 面板 (jetskiAgent) | 待统计 | 🔴 待翻译 |
| L3 | 内置扩展 | 待统计 | 🔴 待翻译 |
| L4 | 产品配置 | ~50 | 🔴 待翻译 |

### 兼容版本

- Antigravity Desktop: **2.0.0**
- 内部版本: **1.107.0**
- IDE 版本: **1.23.2**
- Electron: **39.2.3**

## ⚡ 快速安装

### 方式一：一键安装（推荐）

```powershell
# 下载最新汉化包
git clone https://github.com/kakarotto-baroko/antigravity-2.0-zhcn.git
cd antigravity-2.0-zhcn

# 应用汉化
powershell -ExecutionPolicy Bypass -File scripts/apply.ps1
```

### 方式二：手动安装

详见 [安装说明](docs/INSTALL.md)

## 🔄 恢复英文

```powershell
powershell -ExecutionPolicy Bypass -File scripts/apply.ps1 -Restore
```

## 📁 项目结构

```
├── scripts/          # 自动化脚本（提取/应用/构建/验证）
├── source/           # 原始英文文本（参考用）
├── translations/     # 中文翻译文件
│   ├── nls.messages.zh-CN.json    # 核心 NLS 翻译
│   ├── extensions/                # 扩展翻译
│   └── jetski/                    # AI 面板翻译
├── patches/          # JS 补丁文件
├── docs/             # 文档
└── version.json      # 版本跟踪
```

## 🤝 参与贡献

欢迎提交翻译！请阅读 [贡献指南](docs/CONTRIBUTING.md)。

### 翻译规范

- 保留技术术语原文（如 Terminal → 终端，Debug → 调试）
- 菜单项保持简洁
- 占位符 `{0}`, `{1}` 等必须保留
- 参考 VS Code 官方中文语言包的翻译风格

## 📄 许可证

本项目基于 [MIT](LICENSE) 许可证开源。

> ⚠️ 本项目为非官方社区汉化，与 Google 无关。Antigravity 是 Google 的商标。
