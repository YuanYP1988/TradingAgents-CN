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
        else
            echo -e "${RED}❌ 虚拟环境目录存在但无法激活${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}⚠️  未找到虚拟环境目录${NC}"
        echo -e "${YELLOW}⚠️  No virtual environment directory found${NC}"
        echo "建议创建虚拟环境 Recommended to create virtual environment:"
        echo "   python -m venv env"
        echo "   source env/bin/activate"
        echo ""
        echo -e "${BLUE}是否继续使用系统Python？ Continue with system Python? (y/n)${NC}"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}👋 已取消启动${NC}"
            exit 0
        fi
    fi
}

# 安装项目依赖
install_project() {
    echo -e "${BLUE}📦 检查项目安装状态...${NC}"
    
    # 检查项目是否已安装
    if ! $PYTHON_CMD -c "import tradingagents" 2>/dev/null; then
        echo -e "${BLUE}📦 安装项目到当前环境...${NC}"
        $PYTHON_CMD -m pip install -e . || {
            echo -e "${RED}❌ 项目安装失败${NC}"
            exit 1
        }
        echo -e "${GREEN}✅ 项目安装成功${NC}"
    else
        echo -e "${GREEN}✅ 项目已安装${NC}"
    fi
    
    # 检查关键依赖
    echo -e "${BLUE}🔍 检查关键依赖...${NC}"
    required_packages=("streamlit" "plotly" "rich")
    missing_packages=()
    
    for package in "${required_packages[@]}"; do
        if ! $PYTHON_CMD -c "import $package" &> /dev/null; then
            missing_packages+=("$package")
        fi
    done
    
    if [ ${#missing_packages[@]} -gt 0 ]; then
        echo -e "${YELLOW}📦 安装缺失的关键依赖: ${missing_packages[*]}${NC}"
        $PYTHON_CMD -m pip install "${missing_packages[@]}" || {
            echo -e "${RED}❌ 依赖安装失败${NC}"
            exit 1
        }
        echo -e "${GREEN}✅ 关键依赖安装完成${NC}"
    else
        echo -e "${GREEN}✅ 所有关键依赖已安装${NC}"
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
    echo "  -h, --help        显示此帮助信息"
    echo ""
    echo "示例 Examples:"
    echo "  $0                # 启动Web界面 (默认)"
    echo "  $0 web            # 启动Web界面"
    echo "  $0 cli            # 启动CLI界面"
    echo "  $0 menu           # 显示交互菜单"
    echo "  $0 config         # 检查配置"
}

# 主函数
main() {
    local skip_deps=false
    local skip_venv=false
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
    fi
    
    # 项目安装检查
    if [ "$skip_deps" = false ]; then
        install_project
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

# 捕获中断信号
trap 'echo -e "\n${GREEN}👋 再见！Goodbye!${NC}"; exit 0' INT TERM

# 如果没有参数，保持原来的行为（启动Web界面）
if [ $# -eq 0 ]; then
    echo "🚀 启动TradingAgents-CN Web应用..."
    echo ""
fi

# 执行主函数
main "$@"

# 保持原来的交互式退出方式
echo ""
echo "按任意键退出... Press any key to exit..."
read -n 1
