# 安装说明

## 系统要求

- Windows 10/11 64-bit
- Antigravity 2.0.0 已安装
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
3. 应用中文翻译
4. 提示重启 Antigravity

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

### 部分文本未汉化
- AI 面板部分文本需要额外的补丁，参见补丁安装说明
- 部分扩展文本需要单独安装扩展翻译
