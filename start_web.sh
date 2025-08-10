#!/bin/bash
# TradingAgents-CN 一键启动脚本 (基于原start_web.sh扩展)
# One-click startup script for TradingAgents-CN (Extended from original start_web.sh)

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 打印横幅
print_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    TradingAgents-CN                          ║"
    echo "║               多智能体金融交易分析系统                        ║"
    echo "║          Multi-Agent Financial Trading Analysis System       ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║  🚀 一键启动脚本 | One-Click Startup Script                  ║"
    echo "║  🤖 支持多种LLM | Multiple LLM Support                      ║"
    echo "║  📊 实时数据分析 | Real-time Data Analysis                   ║"
    echo "║  💼 智能投资建议 | Intelligent Investment Advice             ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# 检查Python版本
check_python() {
    if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
        echo -e "${RED}❌ 错误：未找到Python命令${NC}"
        echo -e "${RED}❌ Error: Python command not found${NC}"
        exit 1
    fi
    
    # 优先使用python3，如果没有则使用python
    if command -v python3 &> /dev/null; then
        PYTHON_CMD="python3"
    else
        PYTHON_CMD="python"
    fi
    
    # 检查Python版本
    python_version=$($PYTHON_CMD -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    required_version="3.10"
    
    if [ "$(printf '%s\n' "$required_version" "$python_version" | sort -V | head -n1)" != "$required_version" ]; then
        echo -e "${RED}❌ 错误：需要Python 3.10或更高版本，当前版本：$python_version${NC}"
        echo -e "${RED}❌ Error: Python 3.10 or higher required, current: $python_version${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Python版本检查通过: $python_version (使用命令: $PYTHON_CMD)${NC}"
}

# 显示环境检测摘要
show_environment_summary() {
    echo -e "${BLUE}🔍 环境检测摘要${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    
    # 检测Python环境
    local python_path=$(which $PYTHON_CMD)
    local python_version=$($PYTHON_CMD -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')")
    
    echo -e "${BLUE}   Python: ${NC}$python_version ($python_path)"
    
    # 检测虚拟环境状态
    if [[ "$VIRTUAL_ENV" != "" ]]; then
        echo -e "${BLUE}   环境类型: ${GREEN}虚拟环境${NC} ($(basename $VIRTUAL_ENV))"
        echo -e "${BLUE}   策略: ${GREEN}已安装则直接运行，未安装则安装依赖${NC}"
    else
        echo -e "${BLUE}   环境类型: ${YELLOW}系统环境${NC}"
        echo -e "${BLUE}   策略: ${YELLOW}强制执行 pip install -e . 安装依赖${NC}"
    fi
    
    # 检查项目安装状态
    if $PYTHON_CMD -c "import tradingagents" 2>/dev/null; then
        echo -e "${BLUE}   项目状态: ${GREEN}已安装${NC}"
    else
        echo -e "${BLUE}   项目状态: ${YELLOW}未安装${NC}"
    fi
    
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo ""
}

# 检查并激活虚拟环境
activate_venv() {
    if [[ "$VIRTUAL_ENV" != "" ]]; then
        echo -e "${GREEN}✅ 虚拟环境已激活: $(basename $VIRTUAL_ENV)${NC}"
        return 0
    fi
    
    echo -e "${BLUE}🔍 检查虚拟环境...${NC}"
    
    # 检查是否存在虚拟环境目录
    if [ -d "env" ]; then
        echo -e "${BLUE}📁 发现虚拟环境目录: env${NC}"
        if [ -f "env/bin/activate" ]; then
            echo -e "${BLUE}🔧 激活虚拟环境...${NC}"
            source env/bin/activate
            echo -e "${GREEN}✅ 虚拟环境已激活${NC}"
                        
            # 显示当前pip版本
            pip_version=$($PYTHON_CMD -m pip --version)
            echo -e "${BLUE}   当前pip版本: ${pip_version}${NC}"

        else
            echo -e "${RED}❌ 虚拟环境目录存在但无法激活${NC}"
            exit 1
        fi
    elif [ -d "venv" ]; then
        echo -e "${BLUE}📁 发现虚拟环境目录: venv${NC}"
        if [ -f "venv/bin/activate" ]; then
            echo -e "${BLUE}🔧 激活虚拟环境...${NC}"
            source venv/bin/activate
            echo -e "${GREEN}✅ 虚拟环境已激活${NC}"
            # 显示当前pip版本
            pip_version=$($PYTHON_CMD -m pip --version)
            echo -e "${BLUE}   当前pip版本: ${pip_version}${NC}"
        else
            echo -e "${RED}❌ 虚拟环境目录存在但无法激活${NC}"
            exit 1
        fi
    elif [ -d ".venv" ]; then
        echo -e "${BLUE}📁 发现虚拟环境目录: .venv${NC}"
        if [ -f ".venv/bin/activate" ]; then
            echo -e "${BLUE}🔧 激活虚拟环境...${NC}"
            source .venv/bin/activate
            echo -e "${GREEN}✅ 虚拟环境已激活${NC}"
            # 显示当前pip版本
            pip_version=$($PYTHON_CMD -m pip --version)
            echo -e "${BLUE}   当前pip版本: ${pip_version}${NC}"
        else
            echo -e "${RED}❌ 虚拟环境目录存在但无法激活${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}⚠️  未找到虚拟环境目录${NC}"
        echo -e "${YELLOW}⚠️  No virtual environment directory found${NC}"
        echo -e "${BLUE}🔧 正在创建虚拟环境...${NC}"
        echo -e "${BLUE}🔧 Creating virtual environment...${NC}"
        
        # 创建虚拟环境
        $PYTHON_CMD -m venv env || {
            echo -e "${RED}❌ 虚拟环境创建失败${NC}"
            echo -e "${RED}❌ Failed to create virtual environment${NC}"
            exit 1
        }
        
        echo -e "${GREEN}✅ 虚拟环境创建成功${NC}"
        echo -e "${GREEN}✅ Virtual environment created successfully${NC}"
        
        # 激活虚拟环境
        if [ -f "env/bin/activate" ]; then
            echo -e "${BLUE}🔧 激活虚拟环境...${NC}"
            source env/bin/activate
            echo -e "${GREEN}✅ 虚拟环境已激活${NC}"
            # 显示当前pip版本
            pip_version=$($PYTHON_CMD -m pip --version)
            echo -e "${BLUE}   当前pip版本: ${pip_version}${NC}"
        else
            echo -e "${RED}❌ 虚拟环境创建成功但无法激活${NC}"
            exit 1
        fi
    fi
}

# 安装项目依赖
install_project() {
    local skip_update=${1:-false}
    echo -e "${BLUE}📦 检查项目安装状态...${NC}"
    
    # 检测当前Python环境类型
    local env_type="system"
    local needs_install=false
    
    if [[ "$VIRTUAL_ENV" != "" ]]; then
        env_type="virtual"
        echo -e "${GREEN}🔍 检测到虚拟环境: $VIRTUAL_ENV${NC}"
    else
        env_type="system"
        echo -e "${YELLOW}🔍 检测到系统Python环境（无虚拟环境）${NC}"
        needs_install=true
    fi
    
    # 显示当前环境信息
    echo -e "${BLUE}🔍 当前环境信息:${NC}"
    echo -e "${BLUE}   环境类型: $env_type${NC}"
    echo -e "${BLUE}   Python路径: $(which $PYTHON_CMD)${NC}"
    echo -e "${BLUE}   Pip路径: $(which pip)${NC}"
    echo -e "${BLUE}   虚拟环境: ${VIRTUAL_ENV:-未激活}${NC}"
    
    # 检查项目是否已安装
    local project_installed=false
    if $PYTHON_CMD -c "import tradingagents" 2>/dev/null; then
        project_installed=true
        echo -e "${GREEN}✅ 项目已安装在当前环境中${NC}"
    else
        echo -e "${YELLOW}⚠️  项目未安装在当前环境中${NC}"
        needs_install=true
    fi
    
    # 根据环境状态决定处理策略
    if [ "$env_type" = "system" ]; then
        echo -e "${BLUE}🎯 系统环境处理策略：${NC}"
        echo -e "${CYAN}   由于未检测到虚拟环境，将强制安装/更新项目依赖${NC}"
        needs_install=true
    elif [ "$env_type" = "virtual" ]; then
        echo -e "${BLUE}🎯 虚拟环境处理策略：${NC}"
        if [ "$project_installed" = "true" ]; then
            echo -e "${CYAN}   项目已安装，将跳过依赖安装（可选择更新）${NC}"
            needs_install=false
        else
            echo -e "${CYAN}   项目未安装，将安装项目依赖${NC}"
            needs_install=true
        fi
    fi
    
    # 显示即将安装的依赖信息
    if [ "$needs_install" = "true" ] && [ -f "requirements.txt" ]; then
        echo -e "${BLUE}📋 项目依赖信息:${NC}"
        echo -e "${CYAN}   正在读取 requirements.txt...${NC}"
        
        # 统计依赖数量
        local deps_count=$(grep -v "^#" requirements.txt | grep -v "^$" | wc -l | tr -d ' ')
        echo -e "${CYAN}   发现 ${deps_count} 个依赖包${NC}"
        
        # 显示主要依赖（前10个）
        echo -e "${BLUE}   主要依赖包:${NC}"
        grep -v "^#" requirements.txt | grep -v "^$" | head -10 | while read line; do
            echo -e "${CYAN}     • $line${NC}"
        done
        
        if [ "$deps_count" -gt 10 ]; then
            echo -e "${CYAN}     ... 还有 $((deps_count - 10)) 个其他依赖包${NC}"
        fi
        echo ""
    fi
    
    # 执行安装策略
    if [ "$needs_install" = "true" ]; then
        echo -e "${BLUE}📦 开始安装项目依赖...${NC}"
        echo -e "${CYAN}   正在读取 requirements.txt 和项目配置...${NC}"
        echo -e "${CYAN}   这可能需要几分钟时间，请耐心等待...${NC}"
        
        if [ "$env_type" = "system" ]; then
            echo -e "${YELLOW}   💡 系统环境安装可能需要 3-10 分钟（取决于网络速度）${NC}"
        else
            echo -e "${YELLOW}   💡 虚拟环境安装可能需要 2-8 分钟（取决于网络速度）${NC}"
        fi
        echo ""
        
        # 记录开始时间
        local start_time=$(date +%s)
        
        # 使用简化安装，先安装requirements.txt再安装项目
        echo -e "${BLUE}🚀 开始安装依赖包...${NC}"
        
        # 先安装requirements.txt中的依赖
        if [ -f "requirements.txt" ]; then
            echo -e "${CYAN}   第1步: 安装requirements.txt中的依赖包...${NC}"
            if ! $PYTHON_CMD -m pip install -r requirements.txt; then
                echo -e "${YELLOW}⚠️  requirements.txt安装失败，继续尝试项目安装...${NC}"
            else
                echo -e "${GREEN}   ✅ requirements.txt依赖安装成功${NC}"
            fi
            echo ""
        fi
        
        # 再安装项目本身
        echo -e "${CYAN}   第2步: 以开发模式安装项目...${NC}"
        if $PYTHON_CMD -m pip install -e .; then
            # 计算安装时间
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            local minutes=$((duration / 60))
            local seconds=$((duration % 60))
            
            echo ""
            echo -e "${GREEN}✅ 项目安装成功${NC}"
            echo -e "${GREEN}   安装耗时: ${minutes}分${seconds}秒${NC}"
        else
            echo -e "${RED}❌ 项目安装失败${NC}"
            echo -e "${RED}   建议检查网络连接或尝试使用镜像源${NC}"
            echo -e "${YELLOW}   💡 可以尝试: pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -e .${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✅ 项目已安装${NC}"
        
        # 只有在虚拟环境中且未跳过更新时，才检测并安装依赖
        if [ "$env_type" = "virtual" ] && [ "$skip_update" = "false" ]; then
            echo -e "${BLUE}🔄 自动检测虚拟环境依赖状态...${NC}"
            
            # 检测项目是否完整安装（检查setup.py/pyproject.toml中的依赖）
            local deps_missing=false
            echo -e "${CYAN}   正在检查项目依赖完整性...${NC}"
            
            # 尝试导入项目并检查关键功能模块
            if ! $PYTHON_CMD -c "
import sys
try:
    # 检查项目主模块
    import tradingagents
    
    # 检查关键依赖
    import streamlit
    import plotly
    import rich
    from dotenv import load_dotenv
    import pandas as pd
    
    # 检查项目是否以开发模式安装
    import pkg_resources
    try:
        dist = pkg_resources.get_distribution('tradingagents')
        print('项目已正确安装，版本:', dist.version)
    except pkg_resources.DistributionNotFound:
        print('项目未以开发模式安装')
        sys.exit(1)
        
except ImportError as e:
    print(f'依赖检查失败: {e}')
    sys.exit(1)
" 2>/dev/null; then
                deps_missing=true
                echo -e "${YELLOW}   ⚠️  检测到依赖缺失或项目未完整安装${NC}"
            else
                echo -e "${GREEN}   ✅ 项目依赖完整，无需重新安装${NC}"
            fi
            
            # 如果检测到依赖缺失，自动安装
            if [ "$deps_missing" = "true" ]; then
                echo -e "${BLUE}🔧 自动安装缺失的项目依赖...${NC}"
                echo -e "${CYAN}   正在以开发模式重新安装项目...${NC}"
                echo -e "${CYAN}   这将确保所有依赖正确安装${NC}"
                echo ""
                
                # 记录开始时间
                local update_start_time=$(date +%s)
                
                # 自动安装项目依赖
                echo -e "${BLUE}🚀 开始安装依赖包...${NC}"
                
                # 先安装requirements.txt中的依赖
                if [ -f "requirements.txt" ]; then
                    echo -e "${CYAN}   第1步: 安装requirements.txt中的依赖包...${NC}"
                    if ! $PYTHON_CMD -m pip install -r requirements.txt; then
                        echo -e "${YELLOW}⚠️  requirements.txt安装失败，继续尝试项目安装...${NC}"
                    else
                        echo -e "${GREEN}   ✅ requirements.txt依赖安装成功${NC}"
                    fi
                    echo ""
                fi
                
                # 再安装项目本身
                echo -e "${CYAN}   第2步: 以开发模式安装项目...${NC}"
                if $PYTHON_CMD -m pip install -e .; then
                    # 计算安装时间
                    local update_end_time=$(date +%s)
                    local update_duration=$((update_end_time - update_start_time))
                    local update_minutes=$((update_duration / 60))
                    local update_seconds=$((update_duration % 60))
                    
                    echo ""
                    echo -e "${GREEN}✅ 项目依赖安装完成${NC}"
                    echo -e "${GREEN}   安装耗时: ${update_minutes}分${update_seconds}秒${NC}"
                else
                    echo ""
                    echo -e "${YELLOW}⚠️  依赖安装失败，继续检查关键依赖${NC}"
                fi
            fi
        elif [ "$env_type" = "system" ]; then
            echo -e "${BLUE}⏭️  系统环境已完成依赖安装，跳过更新选项${NC}"
        else
            echo -e "${BLUE}⏭️  跳过依赖更新（使用 --skip-update 选项）${NC}"
        fi
    fi
    
    # 检查关键依赖
    echo -e "${BLUE}🔍 检查关键依赖...${NC}"
    required_packages=("streamlit" "plotly" "rich" "python-dotenv")
    missing_packages=()
    
    for package in "${required_packages[@]}"; do
        echo -n "   检查 $package ... "
        # 对于python-dotenv，检查dotenv模块
        if [ "$package" = "python-dotenv" ]; then
            if ! $PYTHON_CMD -c "import dotenv" &> /dev/null; then
                echo -e "${RED}❌${NC}"
                missing_packages+=("$package")
            else
                echo -e "${GREEN}✅${NC}"
            fi
        else
            if ! $PYTHON_CMD -c "import $package" &> /dev/null; then
                echo -e "${RED}❌${NC}"
                missing_packages+=("$package")
            else
                echo -e "${GREEN}✅${NC}"
            fi
        fi
    done
    
    if [ ${#missing_packages[@]} -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}📦 发现缺失的关键依赖包: ${missing_packages[*]}${NC}"
        echo -e "${CYAN}   正在安装缺失的依赖包...${NC}"
        echo -e "${CYAN}   安装包数量: ${#missing_packages[@]}${NC}"
        echo ""
        
        # 逐个安装并显示进度
        local count=0
        local total=${#missing_packages[@]}
        local install_start_time=$(date +%s)
        
        for package in "${missing_packages[@]}"; do
            count=$((count + 1))
            local pkg_start_time=$(date +%s)
            
            echo -e "${BLUE}   [$count/$total] 正在安装 $package...${NC}"
            
            if $PYTHON_CMD -m pip install "$package"; then
                local pkg_end_time=$(date +%s)
                local pkg_duration=$((pkg_end_time - pkg_start_time))
                echo -e "${GREEN}   ✅ $package 安装成功 (耗时: ${pkg_duration}秒)${NC}"
            else
                echo -e "${RED}   ❌ $package 安装失败${NC}"
                echo -e "${RED}❌ 依赖安装失败${NC}"
                exit 1
            fi
            echo ""
        done
        
        local install_end_time=$(date +%s)
        local install_duration=$((install_end_time - install_start_time))
        local install_minutes=$((install_duration / 60))
        local install_seconds=$((install_duration % 60))
        
        echo -e "${GREEN}✅ 所有关键依赖安装完成${NC}"
        echo -e "${GREEN}   总安装耗时: ${install_minutes}分${install_seconds}秒${NC}"
    else
        echo -e "${GREEN}✅ 所有关键依赖已安装${NC}"
    fi
    
    # 额外检查：验证项目核心模块是否可以正常导入
    echo -e "${BLUE}🔍 验证核心模块导入...${NC}"
    if ! $PYTHON_CMD -c "
try:
    import tradingagents
    import streamlit
    import plotly
    import rich
    from dotenv import load_dotenv
    print('✅ 所有核心模块导入成功')
except ImportError as e:
    print(f'❌ 模块导入失败: {e}')
    exit(1)
" 2>/dev/null; then
        echo -e "${RED}❌ 核心模块验证失败，可能需要重新安装依赖${NC}"
        echo -e "${YELLOW}🔄 尝试强制重新安装项目...${NC}"
        echo -e "${CYAN}   正在强制重新安装项目包和依赖...${NC}"
        echo -e "${CYAN}   这个过程会重新下载和安装所有依赖，请稍等...${NC}"
        echo ""
        
        # 先强制重新安装requirements.txt中的依赖
        if [ -f "requirements.txt" ]; then
            echo -e "${CYAN}   第1步: 强制重新安装requirements.txt中的依赖包...${NC}"
            if ! $PYTHON_CMD -m pip install -r requirements.txt --force-reinstall; then
                echo -e "${YELLOW}⚠️  requirements.txt强制重新安装失败，继续尝试项目安装...${NC}"
            else
                echo -e "${GREEN}   ✅ requirements.txt依赖强制重新安装成功${NC}"
            fi
            echo ""
        fi
        
        # 再强制重新安装项目本身
        echo -e "${CYAN}   第2步: 强制重新安装项目...${NC}"
        if $PYTHON_CMD -m pip install -e . --force-reinstall --no-deps; then
            echo ""
            echo -e "${GREEN}✅ 项目强制重新安装成功${NC}"
        else
            echo ""
            echo -e "${RED}❌ 强制重新安装失败${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✅ 核心模块验证通过${NC}"
    fi
}

# 启动Web界面
start_web() {
    echo -e "${BLUE}🌐 启动TradingAgents-CN Web应用...${NC}"
    echo -e "${BLUE}🌐 Starting TradingAgents-CN Web application...${NC}"
    echo ""
    
    if [ -f "start_web.py" ]; then
        $PYTHON_CMD start_web.py
    else
        echo -e "${RED}❌ 找不到start_web.py文件${NC}"
        echo -e "${RED}❌ start_web.py file not found${NC}"
        exit 1
    fi
}

# 启动CLI界面
start_cli() {
    echo -e "${BLUE}💻 启动CLI命令行界面...${NC}"
    echo -e "${BLUE}💻 Starting CLI command line interface...${NC}"
    $PYTHON_CMD -m cli.main analyze
}

# 直接分析模式
start_direct() {
    echo -e "${BLUE}🔍 启动直接分析模式...${NC}"
    echo -e "${BLUE}🔍 Starting direct analysis mode...${NC}"
    if [ -f "main.py" ]; then
        $PYTHON_CMD main.py
    else
        echo -e "${RED}❌ 找不到main.py文件${NC}"
        exit 1
    fi
}

# 配置检查
check_config() {
    echo -e "${BLUE}🔧 检查系统配置...${NC}"
    echo -e "${BLUE}🔧 Checking system configuration...${NC}"
    $PYTHON_CMD -m cli.main config
}

# 显示示例
show_examples() {
    echo -e "${BLUE}📚 显示示例程序...${NC}"
    echo -e "${BLUE}📚 Showing example programs...${NC}"
    $PYTHON_CMD -m cli.main examples
}

# 交互模式菜单
interactive_menu() {
    echo "请选择启动模式 Please select startup mode:"
    echo "1. 🌐 Web界面 (推荐新手) | Web Interface (Recommended for beginners)"
    echo "2. 💻 CLI命令行界面 | CLI Command Line Interface"
    echo "3. 🔍 直接分析模式 | Direct Analysis Mode"
    echo "4. 🔧 配置检查 | Configuration Check"
    echo "5. 📚 查看示例 | View Examples"
    echo "6. ❌ 退出 | Exit"
    echo ""
    
    while true; do
        echo -n "请输入选择 (1-6) Please enter your choice (1-6): "
        read -r choice
        
        case $choice in
            1)
                start_web
                break
                ;;
            2)
                start_cli
                break
                ;;
            3)
                start_direct
                break
                ;;
            4)
                check_config
                break
                ;;
            5)
                show_examples
                break
                ;;
            6)
                echo -e "${GREEN}👋 再见！Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ 无效选择，请输入1-6 Invalid choice, please enter 1-6${NC}"
                ;;
        esac
    done
}

# 显示帮助信息
show_help() {
    echo "用法 Usage: $0 [选项] [模式]"
    echo ""
    echo "模式 Modes:"
    echo "  web        启动Web界面 (默认)"
    echo "  cli        启动CLI命令行界面"
    echo "  direct     直接分析模式"
    echo "  config     配置检查模式"
    echo "  examples   查看示例程序"
    echo "  menu       显示交互菜单"
    echo ""
    echo "选项 Options:"
    echo "  --skip-deps       跳过依赖检查"
    echo "  --skip-venv       跳过虚拟环境检查"
    echo "  --skip-update     跳过依赖更新（仅检查关键依赖）"
    echo "  -h, --help        显示此帮助信息"
    echo ""
    echo "示例 Examples:"
    echo "  $0                      # 完整启动（包含依赖更新确认）"
    echo "  $0 --skip-update        # 快速启动（推荐日常使用）"
    echo "  $0 --skip-deps          # 最快启动（跳过所有依赖检查）"
    echo "  $0 web                  # 启动Web界面"
    echo "  $0 cli                  # 启动CLI界面"
    echo "  $0 menu                 # 显示交互菜单"
    echo "  $0 config               # 检查配置"
    echo ""
    echo "环境检测策略 Environment Detection Strategy:"
    echo "  🔍 自动检测Python环境类型："
    echo "    • 虚拟环境: 已安装项目→直接运行，未安装→安装依赖"
    echo "    • 系统环境: 自动执行 pip install -e . 安装所有依赖"
    echo "  💡 推荐使用虚拟环境以避免系统包冲突"
    echo ""
    echo "故障排除 Troubleshooting:"
    echo "  如果启动时卡在依赖更新步骤："
    echo "    1. 按 Ctrl+C 中断当前进程"
    echo "    2. 使用: $0 --skip-update"
    echo "  如果依赖有问题，请手动运行: pip install -r requirements.txt && pip install -e ."
    echo "  首次使用建议运行完整安装: $0 (选择 y 进行依赖更新)"
    echo "  系统环境用户建议创建虚拟环境: python -m venv env && source env/bin/activate"
    echo ""
    echo "新功能特性 New Features:"
    echo "  ✨ 详细的安装进度显示，包含时间统计"
    echo "  📊 依赖包信息预览和安装状态实时显示"
    echo "  ⏱️  安装时间估算和实际耗时统计"
    echo "  🔍 逐个依赖包的安装进度和状态"
    echo "  📋 安装前显示即将安装的依赖包列表"
}

# 主函数
main() {
    local skip_deps=false
    local skip_venv=false
    local skip_update=false
    local mode="web"  # 默认启动Web界面，保持向后兼容
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-deps)
                skip_deps=true
                shift
                ;;
            --skip-venv)
                skip_venv=true
                shift
                ;;
            --skip-update)
                skip_update=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            web|cli|direct|config|examples|menu)
                mode="$1"
                shift
                ;;
            *)
                echo -e "${RED}❌ 未知参数: $1${NC}"
                echo "使用 $0 --help 查看帮助信息"
                exit 1
                ;;
        esac
    done
    
    # 显示横幅
    print_banner
    
    # 检查Python
    check_python
    
    # 虚拟环境检查和激活
    if [ "$skip_venv" = false ]; then
        activate_venv
        
        # 确保虚拟环境状态正确传递
        if [[ "$VIRTUAL_ENV" == "" ]] && [ -f "env/bin/activate" ]; then
            echo -e "${BLUE}🔧 确保虚拟环境激活状态...${NC}"
            source env/bin/activate
        fi
    fi
    
    # 显示环境检测摘要
    show_environment_summary
    
    # 项目安装检查
    if [ "$skip_deps" = false ]; then
        install_project "$skip_update"
    fi
    
    echo ""
    
    # 根据模式启动
    case $mode in
        web)
            start_web
            ;;
        cli)
            start_cli
            ;;
        direct)
            start_direct
            ;;
        config)
            check_config
            ;;
        examples)
            show_examples
            ;;
        menu)
            interactive_menu
            ;;
        *)
            echo -e "${RED}❌ 未知模式: $mode${NC}"
            exit 1
            ;;
    esac
}

# 捕获中断信号并要求确认
safe_exit() {
    echo ""
    echo -e "${YELLOW}⚠️  检测到退出信号 (Ctrl+C)${NC}"
    echo -n -e "${CYAN}确认要退出应用吗？输入 '${YELLOW}yes${CYAN}' 确认退出: ${NC}"
    read -r confirm
    
    if [ "$confirm" = "yes" ] || [ "$confirm" = "YES" ] || [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        echo -e "${GREEN}✅ 正在安全退出应用...${NC}"
        echo -e "${GREEN}👋 再见！应用已关闭。Goodbye!${NC}"
        exit 0
    else
        echo -e "${BLUE}✅ 继续运行应用...${NC}"
        echo -e "${BLUE}💡 要退出，请输入 'quit' 或使用 Ctrl+C 并确认${NC}"
        echo ""
    fi
}

trap 'safe_exit' INT TERM

# 如果没有参数，保持原来的行为（启动Web界面）
if [ $# -eq 0 ]; then
    echo "🚀 启动TradingAgents-CN Web应用..."
    echo ""
fi

# 执行主函数
main "$@"

# 安全退出方式
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  💡 应用已启动完成！Web界面正在后台运行                        ║${NC}"
echo -e "${BLUE}║  🌐 访问地址: http://localhost:8501                           ║${NC}"
echo -e "${BLUE}║                                                                ║${NC}"
echo -e "${BLUE}║  ⚠️  要安全退出应用，请输入: ${YELLOW}quit${BLUE} 然后按回车                    ║${NC}"
echo -e "${BLUE}║  🔒 这样可以避免意外关闭正在运行的分析任务                     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

while true; do
    echo -n -e "${CYAN}请输入 '${YELLOW}quit${CYAN}' 退出应用 (输入其他内容将被忽略): ${NC}"
    read user_input
    
    if [ "$user_input" = "quit" ] || [ "$user_input" = "QUIT" ]; then
        echo -e "${GREEN}✅ 正在安全退出应用...${NC}"
        echo -e "${GREEN}👋 再见！应用已关闭。Goodbye!${NC}"
        break
    else
        echo -e "${YELLOW}⚠️  输入无效。要退出，请输入 'quit'${NC}"
        echo ""
    fi
done
