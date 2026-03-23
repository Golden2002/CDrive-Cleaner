# Windows C盘清理工具 (Clean-CDrive)

一个安全、灵活的 Windows 系统清理工具，支持多种清理级别和交互式选择。

项目文件结构
CDrive-Cleaner\
├── README.md              # 中/英文用户指南
├── Clean-CDrive2.ps1      # 主脚本 (推荐)
├── Clean-CDrive.ps1       # 旧版脚本
└── Dism++10.1.1001.1/    # 额外工具(可选)

## 功能特点

- 🗂️ **多级清理** - 4个清理级别，满足不同需求
- 🔒 **安全优先** - 自动跳过危险项，支持确认后再清理
- 🎯 **交互选择** - 可自主选择要清理的项目
- ⚡ **快速清理** - 清理常见缓存，释放大量空间
- 📊 **预览功能** - 清理前显示预计释放空间

## 清理级别

| 级别 | 说明 | 释放空间(约) |
|------|------|-------------|
| Level 1 | 临时文件 | 0-1 GB |
| Level 2 | 常用缓存 (默认) | 1-5 GB |
| Level 3 | 深度清理 (可交互选择) | 5-20 GB |
| Level 4 | 完整清理 | 10-50 GB |

## 快速开始

### 1. 检测可释放空间

```powershell
.\Clean-CDrive2.ps1 -Level 0
```

### 2. 预览清理计划

```powershell
.\Clean-CDrive2.ps1 -Level 2 -Preview
```

### 3. 执行清理

```powershell
# Level 2 (推荐，自动跳过危险项)
.\Clean-CDrive2.ps1 -Level 2 -Confirm

# Level 3 (会提示危险项，按 y 继续)
.\Clean-CDrive2.ps1 -Level 3
```

## 支持的清理项

### Level 1 - 最小清理
- Windows 临时文件
- 用户临时文件夹

### Level 2 - 普通清理
- npm 缓存
- pip 缓存
- OfficePLUS 缓存
- GitHub Desktop 缓存

### Level 3 - 深度清理 (可选)
- JetBrains IDE 缓存
- VS Code 缓存
- Chrome/Edge/Firefox 浏览器缓存
- Python 缓存
- 钉钉缓存

### ⚠️ 危险项 (需确认)
- QQ/微信聊天记录 (建议备份)
- 钉钉 (需重新登录)

## 使用示例

### 场景1: 日常清理

```powershell
# 释放约 2-5 GB 空间
.\Clean-CDrive2.ps1 -Level 2 -Confirm
```

### 场景2: 深度清理

```powershell
# 交互式选择要清理的项目
.\Clean-CDrive2.ps1 -Level 3
# 输入 'd' 仅清理默认项目(安全)
# 输入 'a' 清理所有可选项目
# 输入 'y' 确认危险项清理
```

### 场景3: 释放大量空间

```powershell
# 预览 Level 4 可释放空间
.\Clean-CDrive2.ps1 -Level 4 -Preview
```

## 文件说明

| 文件 | 说明 |
|------|------|
| `Clean-CDrive2.ps1` | **主脚本** (推荐使用) |
| `Clean-CDrive.ps1` | 旧版脚本 (保留兼容) |
| `Dism++10.1.1002.1/` | 额外系统清理工具 (可选，非核心组件) |

---

## Dism++ 系统清理工具 (可选)

本项目中包含的 `Dism++` 文件夹是一个功能强大的第三方系统优化工具。

### 官方信息

| 项目 | 信息 |
|------|------|
| **官方仓库** | [Chuyu-Team/Dism-Multi-language](https://github.com/Chuyu-Team/Dism-Multi-language) |
| **官方网站** | [https://www.chuyu.me/](https://www.chuyu.me/) |
| **开源许可** | MIT License |
| **GitHub Star** | 19.2k |
| **当前版本** | 10.1.1002.2 (2023年3月) |

> ⚠️ 注意：本项目包含的 Dism++ 版本为 10.1.1001，官方最新版本为 10.1.1002.2

### 功能特点

- Windows 系统映像管理工具
- 无需安装，Dism API 的 GUI 实现
- 支持系统垃圾清理、优化设置
- 开源免费，无广告

### 安全建议

1. **推荐使用官方最新版本**：可从 GitHub Release 页面下载最新版本
2. **如需使用 Dism++**：
   - 只使用「空间回收」等基础清理功能
   - 避免在「优化」功能中随意修改系统设置
   - 使用后建议重启电脑

### 获取官方版本

如需使用官方最新版本，请访问：
- GitHub: https://github.com/Chuyu-Team/Dism-Multi-language/releases
- 官网下载: https://www.chuyu.me/

---

## 环境要求

- Windows 10/11
- PowerShell 5.0+

## 常见问题

### Q: 清理安全吗?
> 是的。Level 1-2 是安全的系统缓存。Level 3-4 包含应用缓存，清理后应用可能需要重新登录或加载稍慢，但不会丢失重要数据。

### Q: 为什么会清理失败?
> 部分文件被占用时清理会失败，可关闭相关应用后重试。

### Q: 如何恢复误删的文件?
> 大部分清理项会先进入回收站，可在回收站中恢复。

## 注意事项

1. ⚠️ 清理 QQ/微信 前建议备份聊天记录
2. ⚠️ 清理钉钉后需要重新登录
3. 建议清理前关闭正在使用的浏览器和开发工具

## 定时自动清理 (适合长时间待机)

如果你希望电脑在长时间运行过程中自动清理缓存，保持健康状态，可以通过以下方式实现定时自动清理：

### 方法一：Windows 任务计划程序 (推荐)

1. **打开任务计划程序**
   - 按 `Win + R`，输入 `taskschd.msc`，回车

2. **创建基本任务**
   - 点击右侧「创建基本任务...」
   - 名称填写：`C盘自动清理`
   - 触发器选择：「每天」或「每周」

3. **设置操作**
   - 操作选择：「启动程序」
   - 程序或脚本填写：
     ```powershell
     powershell.exe
     ```
   - 添加参数填写：
     ```
     -ExecutionPolicy Bypass -File "D:\c盘清理\Clean-CDrive2.ps1" -Level 2 -Confirm
     ```
   - (请根据脚本实际路径修改 `D:\c盘清理\` 部分)

4. **完成设置**
   - 点击「完成」即可

### 方法二：创建批处理文件 (简化版)

1. 在脚本同目录下新建一个 `.bat` 文件，例如 `auto-cleanup.bat`

2. 写入以下内容：
   ```batch
   @echo off
   powershell -ExecutionPolicy Bypass -File "%~dp0Clean-CDrive2.ps1" -Level 2 -Confirm
   ```

3. 将此批处理文件添加到「任务计划程序」中

### 方法三：开机启动 (简单粗暴)

如果你希望每次开机时自动清理一次：

1. 按 `Win + R`，输入 `shell:startup`，回车

2. 在打开的文件夹中创建一个快捷方式
   - 目标填写：
     ```powershell
     powershell.exe -ExecutionPolicy Bypass -File "D:\c盘清理\Clean-CDrive2.ps1" -Level 2 -Confirm
     ```

3. 每次开机登录后会自动运行清理

### ⏰ 推荐清理频率

| 使用场景 | 建议频率 |
|---------|---------|
| 日常办公 | 每天 1 次 或 每周 2-3 次 |
| 开发/设计 | 每周 1 次 |
| 轻度使用 | 每周 1 次 |

### ⚠️ 定时清理注意事项

1. **推荐使用 Level 2**：自动清理时只清理安全项，避免误删重要数据
2. **避开工作时间**：建议设置在午休或下班后运行
3. **先测试**：建议先手动运行一次确认无误后再设置定时任务
4. **查看日志**：可在脚本目录下查看清理日志（如果需要可添加日志功能）

---

# Windows C Drive Cleanup Tool

A safe and flexible Windows system cleanup tool with multiple cleanup levels and interactive selection.

## Features

- **Multi-level Cleanup** - 4 cleanup levels for different needs
- **Safety First** - Auto-skip dangerous items, confirm before cleanup
- **Interactive Selection** - Choose which items to clean
- **Preview** - Show estimated space before cleanup

## Quick Start

```powershell
# Check available space
.\Clean-CDrive2.ps1 -Level 0

# Preview cleanup plan
.\Clean-CDrive2.ps1 -Level 2 -Preview

# Execute cleanup (recommended)
.\Clean-CDrive2.ps1 -Level 2 -Confirm
```

## Cleanup Levels

| Level   | Description                | Est. Space |
| ------- | -------------------------- | ---------- |
| Level 1 | Temp files only            | 0-1 GB     |
| Level 2 | Common cache (default)     | 1-5 GB     |
| Level 3 | Deep cleanup (interactive) | 5-20 GB    |
| Level 4 | Full cleanup               | 10-50 GB   |

## Supported Items

### Level 1 - Minimal

- Windows Temp
- User Temp

### Level 2 - Normal

- npm Cache
- pip Cache
- OfficePLUS Cache
- GitHub Desktop Cache

### Level 3 - Deep (Optional)

- JetBrains IDE Cache
- VS Code Cache
- Browser Cache (Chrome/Edge/Firefox)
- Python Cache
- DingTalk Cache

### ⚠️ Dangerous (Require Confirmation)

- QQ/WeChat chat records (backup recommended)
- DingTalk (re-login required)

## Requirements

- Windows 10/11
- PowerShell 5.0+

## License

MIT License

---

## License

MIT License - 可自由使用和修改
