# 安装说明

## 系统要求

- Windows 10/11 64-bit
- Antigravity 2.0.0 已安装
- Antigravity 2.0.1 当前需要手动核对安装结构
- PowerShell 5.1+

## 自动安装

```powershell
git clone https://github.com/kakarotto-baroko/antigravity-2.0-zhcn.git
cd antigravity-2.0-zhcn
powershell -ExecutionPolicy Bypass -File scripts/apply.ps1
```

脚本会自动：
1. 检测 Antigravity 安装目录
2. 备份原始文件
3. 应用稳定核心中文翻译
4. 提示重启 Antigravity

默认安装只启用稳定核心汉化，不启用 AI 面板前端补丁，避免版本不匹配时影响启动。

如需启用实验性的 AI 面板汉化：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/apply.ps1 -EnableAiUi
```

该模式会检查 Antigravity 版本和 UI bundle hash。若不匹配，将自动跳过 AI 面板补丁，只应用核心汉化。

AI 面板模式只把 `https://127.0.0.1:<port>/main.js` 重定向到本地 `agy-ui://bundle/main.js`，其余页面和 API 仍由 Antigravity 自带语言服务器提供。

## 版本现状

- `2.0.0`:
  当前脚本链路可以正常应用核心汉化和 AI UI 汉化。
- `2.0.1`:
  本机自动更新后，安装目录结构已变化，`scripts/apply.ps1` 仍会按旧路径 `resources/app/out/nls.messages.json` 检查安装，导致误报未安装。
  AI UI 注入已在本机手动重新挂回，但一键安装脚本仍需继续适配。

## 手动安装

### 1. 备份原始文件

```powershell
$agyPath = "$env:LOCALAPPDATA\Programs\Antigravity\resources\app\out"
Copy-Item "$agyPath\nls.messages.json" "$agyPath\nls.messages.json.bak"
```

### 2. 替换翻译文件

```powershell
Copy-Item "translations\nls.messages.zh-CN.json" "$agyPath\nls.messages.json"
```

### 3. 重启 Antigravity

关闭并重新打开 Antigravity。

## 恢复英文

```powershell
powershell -ExecutionPolicy Bypass -File scripts/apply.ps1 -Restore
```

或手动：

```powershell
$agyPath = "$env:LOCALAPPDATA\Programs\Antigravity\resources\app\out"
Copy-Item "$agyPath\nls.messages.json.bak" "$agyPath\nls.messages.json"
```

## 故障排除

### 应用后界面显示异常
- 确认 Antigravity 版本为 2.0.0
- 检查 `version.json` 中的版本号是否匹配
- 尝试恢复英文后重新应用
- 若卡在进入界面，请先运行默认安装命令，不要加 `-EnableAiUi`
- 若主界面仍是英文，请关闭 Antigravity 后重新运行 `scripts/apply.ps1 -EnableAiUi`，再确认日志中出现 `Serving translated AI UI bundle`
- 若已升级到 `2.0.1`，请优先参考 [HANDOFF.md](/G:/GEMINI-xiangmu/AGY/AGY-汉化/docs/HANDOFF.md) 中的结构差异说明，不要直接假设 `2.0.0` 的安装路径仍然存在

### Antigravity 更新后如何适配

```powershell
powershell -ExecutionPolicy Bypass -File scripts/extract.ps1 -Update
```

该命令会重新提取文本，并生成 `releases/version-update-report.json`。核心翻译通过 `scripts/validate.ps1` 后可继续使用；AI 面板汉化需要确认新版本 UI bundle 后，再更新 `patches/ai-ui-compat.json`。

### 部分文本未汉化
- AI 面板部分文本需要额外的补丁，参见补丁安装说明
- 部分扩展文本需要单独安装扩展翻译
