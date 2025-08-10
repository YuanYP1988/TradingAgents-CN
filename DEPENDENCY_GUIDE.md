
# 依赖安装指南

## 基本运行（无数据库）
系统可以在没有MongoDB和Redis的情况下正常运行，使用文件缓存。

### 必需依赖
```bash
pip install pandas yfinance requests
```

## 完整功能（包含数据库）
如果需要企业级缓存和数据持久化功能：

### 1. 安装Python包
```bash
pip install pymongo redis
```

### 2. 安装MongoDB（可选）
#### Windows:
1. 下载MongoDB Community Server
2. 安装并启动服务
3. 默认端口：27017

#### 使用Docker:
```bash
docker run -d -p 27017:27017 --name mongodb mongo:4.4
```

### 3. 安装Redis（可选）
#### Windows:
1. 下载Redis for Windows
2. 启动redis-server
3. 默认端口：6379

#### 使用Docker:
```bash
docker run -d -p 6379:6379 --name redis redis:alpine
```

## 配置说明

### 文件缓存模式（默认）
- 缓存存储在本地文件系统
- 性能良好，适合单机使用
- 无需额外服务

### 数据库模式（可选）
- MongoDB：数据持久化
- Redis：高性能缓存
- 适合生产环境和多实例部署

## 运行模式检测
系统会自动检测可用的服务：
1. 如果MongoDB/Redis可用，自动使用数据库缓存
2. 如果不可用，自动降级到文件缓存
3. 功能完全兼容，性能略有差异
