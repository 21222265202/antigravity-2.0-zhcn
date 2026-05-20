# 🚀 Antigravity 2.0 中文汉化包

[![翻译进度](https://img.shields.io/badge/核心NLS-98.7%25-brightgreen?style=flat-square)](https://github.com/kakarotto-baroko/antigravity-2.0-zhcn)
[![版本](https://img.shields.io/badge/Antigravity-v2.0.0%20%2F%202.0.1-blue?style=flat-square)](https://github.com/kakarotto-baroko/antigravity-2.0-zhcn)
[![许可证](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

> 将 Google Antigravity 2.0 桌面版 IDE 完整汉化为简体中文。

## 📋 项目概述

Antigravity 2.0 是 Google 推出的新一代 AI 驱动代码编辑器（基于 VS Code/Electron）。本项目旨在为其提供完整的简体中文汉化支持。

### 汉化范围

| 层级 | 内容 | 条目数 | 状态 |
|------|------|--------|------|
| L1 | IDE 核心界面 (NLS) | 16,567 | 🟢 98.7% 已覆盖 |
| L2 | AI 面板 / Hub UI | 持续补齐中 | 🟡 已接管主界面 bundle，设置中心已补一轮 |
| L3 | 内置扩展 | 5 个内置扩展 | 🟢 已有首轮汉化 |
| L4 | 产品配置 | ~50 | 🟢 已有首轮汉化 |

### 兼容版本

- Antigravity Desktop: **2.0.0 / 2.0.1**
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

默认安装只启用稳定核心汉化。实验性的 AI 面板汉化需要显式启用，且会进行版本/hash 校验：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/apply.ps1 -EnableAiUi
```

AI 面板模式仅替换主界面的 `/main.js` 前端 bundle，其余本地服务请求保持原样。

## 📌 当前进度

- 核心 NLS 校验通过: 16,567 条消息，已翻译 16,352 条，覆盖率 98.7%。
- AI UI 已从“卡死在进入界面”修复为“定向替换 `/main.js`”，并在本机验证可正常进入主界面。
- 设置中心已补一轮，覆盖 `外观 / 权限 / 浏览器 / 模型 / 自定义 / 应用 / 账户 / 快捷键` 等主要导航与设置项。
- 2026-05-20 本机自动更新到 `2.0.1` 后，已重新将 `agy-ui` 注入挂回当前 `app.asar`，主日志再次出现 `Serving translated AI UI bundle`。

## ⚠️ 已知事项

- `scripts/apply.ps1` 当前仍按 `2.0.0` 的安装结构检查 `resources/app/out/nls.messages.json`。在已自动升级到 `2.0.1` 的机器上，这个检查会误报“Antigravity installation not found”。
- `2.0.1` 安装包结构与 `2.0.0` 不同，核心 NLS / product / extension 的自动应用逻辑需要单独适配后，才能恢复一键安装的完整能力。
- AI UI 翻译目前是词典替换方案，覆盖已经明显提升，但仍可能残留零散英文描述文案，需要继续迭代。

## 📚 交接文档

- 项目变更记录: [docs/CHANGELOG.md](/G:/GEMINI-xiangmu/AGY/AGY-汉化/docs/CHANGELOG.md)
- 安装与版本说明: [docs/INSTALL.md](/G:/GEMINI-xiangmu/AGY/AGY-汉化/docs/INSTALL.md)
- GitHub 接手说明: [docs/HANDOFF.md](/G:/GEMINI-xiangmu/AGY/AGY-汉化/docs/HANDOFF.md)

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
