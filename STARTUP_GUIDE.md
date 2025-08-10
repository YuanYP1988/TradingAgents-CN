# TradingAgents-CN 一键启动脚本使用指南

## 📚 概述

本项目提供了多种一键启动脚本，方便用户在不同操作系统和环境下快速启动 TradingAgents-CN 系统。

## 🚀 启动脚本列表

- **`start_web.sh`** - 基于原有脚本增强的 Unix/Linux/macOS 启动脚本
- **`start_web.py`** - Python Web 界面启动脚本
- **`start_web.bat`** - Windows 批处理启动脚本
- **`start_web.ps1`** - Windows PowerShell 启动脚本



## 💻 使用方法

### macOS/Linux 用户

#### 方法一：使用增强的原有脚本
```bash
# 默认启动Web界面（保持向后兼容）
./start_web.sh

# 启动其他模式
./start_web.sh web       # Web界面
./start_web.sh cli       # CLI界面
./start_web.sh direct    # 直接分析
./start_web.sh config    # 配置检查
./start_web.sh examples  # 查看示例
./start_web.sh menu      # 交互菜单

# 跳过某些检查
./start_web.sh --skip-deps     # 跳过依赖检查
./start_web.sh --skip-venv     # 跳过虚拟环境检查
```

### Windows 用户

#### 方法一：双击运行
- 双击 `start_web.bat` 文件

#### 方法二：命令行运行
```cmd
# 批处理文件
start_web.bat
start_web.bat web
start_web.bat cli
start_web.bat config

# PowerShell 脚本
.\start_web.ps1
.\start_web.ps1 web
.\start_web.ps1 cli
.\start_web.ps1 config

# Python 脚本
python start_web.py
```

## 🎯 启动模式说明

| 模式 | 说明 | 适用场景 |
|------|------|----------|
| **web** | Web界面（Streamlit） | 推荐新手使用，图形化界面友好 |
| **cli** | CLI命令行界面 | 高级用户，交互式分析 |
| **analyze/direct** | 直接分析模式 | 快速测试，运行预设分析 |
| **config** | 配置检查 | 检查API密钥和系统配置 |
| **examples** | 查看示例 | 学习如何使用系统 |
| **menu** | 交互菜单 | 选择启动模式 |

## ⚙️ 高级选项

### 跳过检查选项
```bash
# 跳过依赖检查（假设已安装）
./start_web.sh --skip-deps

# 跳过虚拟环境检查
./start_web.sh --skip-venv
```

### 环境要求
- **Python**: 3.10 或更高版本
- **虚拟环境**: 推荐使用（脚本会自动检测和激活）
- **依赖包**: 脚本会自动安装缺失的依赖

## 🔧 故障排除

### 常见问题

1. **权限错误**
   ```bash
   chmod +x start_web.sh
   ```

2. **Python版本问题**
   - 确保安装了 Python 3.10 或更高版本
   - 某些系统需要使用 `python3` 命令

3. **虚拟环境问题**
   ```bash
   # 创建虚拟环境
   python -m venv env
   source env/bin/activate  # macOS/Linux
   # 或
   .\env\Scripts\activate   # Windows
   ```

4. **依赖安装失败**
   ```bash
   # 手动安装
   pip install -e .
   pip install streamlit plotly rich typer
   ```

### 获取帮助
```bash
./start_web.sh --help
```

## 🔄 向后兼容性

- **`start_web.sh`** 保持了原有的默认行为（启动Web界面）
- 所有原有的使用方式仍然有效
- 新增功能通过可选参数提供

## 📝 更新日志

### v1.0 (2025-01-10)
- ✅ 基于原有 `start_web.sh` 进行功能增强
- ✅ 添加多种启动模式支持
- ✅ 改进错误处理和用户体验
- ✅ 保持向后兼容性

## 🤝 贡献

如果您在使用过程中遇到问题或有改进建议，请：
1. 提交 Issue
2. 创建 Pull Request
3. 联系维护团队

---

**享受 TradingAgents-CN 的智能金融分析体验！** 🚀📊💼
