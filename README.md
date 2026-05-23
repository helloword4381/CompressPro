# CompressPro 🗜️

> 轻量、高效的开源压缩解压工具 — 基于 7-Zip 引擎，Windows 原生体验

![License: LGPL-2.1](https://img.shields.io/badge/License-LGPL%202.1-blue.svg)
![.NET 8](https://img.shields.io/badge/.NET-8.0-512BD4)
![Windows](https://img.shields.io/badge/Windows-7--11-0078D6)

---

## ✨ 特性

- **全格式支持** — 7z / ZIP / RAR / TAR / GZ / BZ2 / XZ / ISO / CAB / WIM 等 30+ 格式
- **经典 UI** — 类 Bandizip 文件管理器风格，简洁直观
- **右键菜单** — 安装后右键一键解压/压缩
- **高性能** — 原生 7z.dll 引擎，多线程加速
- **安全** — AES-256 加密，支持密码保护的压缩包
- **轻量** — 安装包 < 10MB，无广告，无后台进程

## 📦 截图

*(TODO: 添加截图)*

## 🚀 快速开始

### 下载安装

从 [Releases](https://github.com/compresspro/compresspro/releases) 下载最新安装包，双击安装即可。

或使用 [Scoop](https://scoop.sh):
```bash
scoop bucket add compresspro https://github.com/compresspro/scoop-bucket
scoop install compresspro
```

### 从源码构建

**前置要求:**
- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [7-Zip](https://7-zip.org/) (运行时依赖 7z.dll)
- (可选) [NSIS](https://nsis.sourceforge.io/) — 构建安装包

```bash
# 1. 克隆
git clone https://github.com/compresspro/compresspro.git
cd compresspro

# 2. 恢复依赖
dotnet restore

# 3. 构建
dotnet build -c Release

# 4. (可选) 生成安装包
dotnet build -c Release -p:BuildInstaller=true
```

## 🏗️ 项目结构

```
CompressPro/
├── src/
│   ├── CompressPro.Gui/       ← WPF 主程序
│   │   ├── MainWindow.xaml    ← 主界面
│   │   ├── Services/          ← 7z 引擎封装
│   │   └── Converters/        ← 值转换器
│   └── CompressPro.Core/      ← 核心逻辑
│       ├── ArchiveManager.cs
│       └── Models/
├── installer/
│   └── setup.nsi              ← NSIS 安装脚本
├── external/
│   └── 7z.dll                 ← 7z 引擎 (需自行下载)
└── README.md
```

## 🧩 技术栈

| 层 | 技术 | 说明 |
|----|------|------|
| UI | WPF + ModernWpfUI | Win11 原生风格 |
| 引擎 | 7z.dll (SevenZipSharp) | 30+ 压缩格式 |
| 构建 | .NET 8 SDK | 跨平台 SDK 风格 |
| 安装包 | NSIS | 轻量安装/卸载 |
| 右键菜单 | 注册表 Shell Extension | 无 COM 依赖 |

## 📜 许可证

本项目基于 **LGPL-2.1** 许可证 — 详见 [LICENSE](LICENSE)

7-Zip 引擎部分基于 [7-Zip](https://7-zip.org/) (LGPL-2.1)

## 🤝 贡献

欢迎贡献！请先阅读 [CONTRIBUTING.md](CONTRIBUTING.md)

- 报告 Bug → [Issues](https://github.com/compresspro/compresspro/issues)
- 提交代码 → Pull Requests
- 功能建议 → [Discussions](https://github.com/compresspro/compresspro/discussions)
