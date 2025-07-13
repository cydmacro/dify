#!/bin/bash

# Dify 快速部署脚本（公开版本）
# 此脚本用于快速部署 Dify，但需要用户手动配置私有设置

set -e  # 遇到错误立即退出

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}🚀 Dify 快速部署脚本（公开版本）${NC}"
echo "================================"

# 获取 GitHub 用户名
echo -e "\n${BLUE}请输入您的 GitHub 用户名：${NC} \c"
read -r GITHUB_USER

if [ -z "$GITHUB_USER" ]; then
    echo -e "${RED}❌ GitHub 用户名不能为空${NC}"
    exit 1
fi

# 配置变量
DEPLOY_DIR="$HOME/dify-deployment"
DATA_DIR="/data/dify"

# 1. 检查依赖
echo -e "\n${YELLOW}1. 检查依赖...${NC}"
command -v docker >/dev/null 2>&1 || { echo -e "${RED}❌ 需要安装 Docker${NC}"; exit 1; }
command -v docker-compose >/dev/null 2>&1 || { echo -e "${RED}❌ 需要安装 Docker Compose${NC}"; exit 1; }
command -v git >/dev/null 2>&1 || { echo -e "${RED}❌ 需要安装 Git${NC}"; exit 1; }
echo -e "${GREEN}✓ 依赖检查通过${NC}"

# 2. 创建目录
echo -e "\n${YELLOW}2. 创建目录...${NC}"
mkdir -p $DEPLOY_DIR
sudo mkdir -p $DATA_DIR/{postgres,redis,storage,weaviate,qdrant,pgvector,sandbox,minio}
sudo chown -R $USER:$USER $DATA_DIR
echo -e "${GREEN}✓ 目录创建完成${NC}"

# 3. 克隆仓库
echo -e "\n${YELLOW}3. 克隆仓库...${NC}"
cd $DEPLOY_DIR

# 克隆 Dify Fork
if [ ! -d "dify" ]; then
    echo "克隆 Dify 仓库..."
    git clone git@github.com:$GITHUB_USER/dify.git || {
        echo -e "${YELLOW}⚠️  使用 HTTPS 方式重试...${NC}"
        git clone https://github.com/$GITHUB_USER/dify.git
    }
    cd dify
    git remote add upstream https://github.com/langgenius/dify.git
    
    # 检查是否有 custom-branding 分支
    if git ls-remote --heads origin custom-branding | grep -q custom-branding; then
        git checkout custom-branding
    else
        echo -e "${YELLOW}未找到 custom-branding 分支，使用 main 分支${NC}"
    fi
    cd ..
else
    echo "Dify 仓库已存在，跳过克隆"
fi

# 4. 创建基础配置
echo -e "\n${YELLOW}4. 创建基础配置...${NC}"
mkdir -p $DEPLOY_DIR/config

# 创建 docker-compose.override.yml
cat > $DEPLOY_DIR/config/docker-compose.override.yml << 'EOF'
# Dify 数据持久化配置
version: '3.8'

services:
  # PostgreSQL 数据持久化
  db:
    volumes:
      - /data/dify/postgres:/var/lib/postgresql/data

  # Redis 数据持久化
  redis:
    volumes:
      - /data/dify/redis:/data

  # API 服务 - 文件存储
  api:
    volumes:
      - /data/dify/storage:/app/api/storage

  # Worker 服务 - 共享存储
  worker:
    volumes:
      - /data/dify/storage:/app/api/storage

  # 向量数据库持久化配置
  weaviate:
    volumes:
      - /data/dify/weaviate:/var/lib/weaviate

  qdrant:
    volumes:
      - /data/dify/qdrant:/qdrant/storage

  pgvector:
    volumes:
      - /data/dify/pgvector:/var/lib/postgresql/data

  # Sandbox 数据持久化
  sandbox:
    volumes:
      - /data/dify/sandbox:/dependencies

  # MinIO 对象存储
  minio:
    volumes:
      - /data/dify/minio:/data
EOF

echo -e "${GREEN}✓ 配置创建完成${NC}"

# 5. 部署应用
echo -e "\n${YELLOW}5. 部署 Dify...${NC}"
cd $DEPLOY_DIR/dify/docker

# 检查是否有 .env 文件
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}复制环境变量模板...${NC}"
    cp .env.example .env
    echo -e "${YELLOW}⚠️  请编辑 .env 文件配置您的 API 密钥${NC}"
fi

# 拉取镜像
echo "拉取 Docker 镜像..."
docker-compose pull

# 停止旧容器（如果存在）
docker-compose down 2>/dev/null || true

# 启动服务
echo "启动服务..."
docker-compose -f docker-compose.yaml -f "$DEPLOY_DIR/config/docker-compose.override.yml" up -d

# 6. 等待服务启动
echo -e "\n${YELLOW}6. 等待服务启动...${NC}"
sleep 30

# 7. 检查状态
echo -e "\n${YELLOW}7. 检查服务状态...${NC}"
docker-compose ps

# 8. 显示访问信息
echo -e "\n${GREEN}✅ 部署完成！${NC}"
echo "================================"
echo -e "${GREEN}访问地址：${NC}"
echo -e "  Web 界面: http://$(curl -s ifconfig.me 2>/dev/null || echo 'your-server-ip')"
echo -e "  API 文档: http://$(curl -s ifconfig.me 2>/dev/null || echo 'your-server-ip')/api"
echo -e "\n${GREEN}重要文件位置：${NC}"
echo -e "  数据目录: $DATA_DIR"
echo -e "  配置文件: $DEPLOY_DIR/dify/docker/.env"
echo -e "  覆盖配置: $DEPLOY_DIR/config/docker-compose.override.yml"
echo "================================"

# 9. 提示后续步骤
echo -e "\n${YELLOW}后续步骤：${NC}"
echo "1. 编辑环境变量: nano $DEPLOY_DIR/dify/docker/.env"
echo "2. 查看日志: cd $DEPLOY_DIR/dify/docker && docker-compose logs -f"
echo "3. 停止服务: cd $DEPLOY_DIR/dify/docker && docker-compose down"
echo "4. 重启服务: cd $DEPLOY_DIR/dify/docker && docker-compose up -d"
echo ""
echo -e "${BLUE}提示：如需使用私有配置（自定义 logo 等），请克隆您的私有配置仓库${NC}"