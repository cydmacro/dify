#!/bin/bash

# 设置私有定制仓库的脚本

echo "🔒 设置 Dify 私有定制版本..."

GITHUB_USERNAME="cydmacro"

# 1. 创建私有配置目录
echo "📁 创建私有配置目录..."
mkdir -p ../dify-private-config
cd ../dify-private-config

# 2. 初始化 Git 仓库
echo "🔧 初始化私有仓库..."
git init

# 3. 创建配置结构
echo "📝 创建配置结构..."
cat > README.md << 'EOF'
# Dify 私有配置仓库

此仓库存储 Dify 的私有定制配置。

## 目录结构
- `config/` - 配置文件
- `assets/` - 自定义资源（logo等）
- `patches/` - 代码补丁
- `scripts/` - 部署脚本

## 使用方法
1. 克隆此私有仓库
2. 克隆公开的 Dify fork
3. 运行 `./deploy.sh` 合并配置并部署
EOF

# 4. 创建部署脚本
cat > deploy.sh << 'EOF'
#!/bin/bash

# Dify 私有定制部署脚本

DIFY_DIR="../dify"
CONFIG_DIR="./config"
ASSETS_DIR="./assets"

echo "🚀 开始部署 Dify 定制版本..."

# 1. 检查 Dify 目录
if [ ! -d "$DIFY_DIR" ]; then
    echo "❌ 错误：未找到 Dify 目录"
    echo "请先克隆您的 Dify fork 到 ../dify"
    exit 1
fi

# 2. 复制自定义资源
echo "📦 复制自定义资源..."
if [ -d "$ASSETS_DIR" ]; then
    cp -r $ASSETS_DIR/* $DIFY_DIR/web/public/
fi

# 3. 应用配置
echo "⚙️ 应用配置..."
if [ -d "$CONFIG_DIR" ]; then
    cp $CONFIG_DIR/docker-compose.override.yml $DIFY_DIR/docker/
fi

# 4. 进入 Dify 目录并启动
cd $DIFY_DIR/docker
echo "🐳 启动 Docker 服务..."
docker-compose -f docker-compose.yaml -f docker-compose.override.yml up -d

echo "✅ 部署完成！"
EOF

chmod +x deploy.sh

# 5. 创建目录结构
mkdir -p config assets patches scripts

# 6. 创建 .gitignore
cat > .gitignore << 'EOF'
# 环境变量
.env
*.env

# 临时文件
*.tmp
*.log

# IDE
.vscode/
.idea/
EOF

echo "✅ 私有配置仓库已创建！"
echo ""
echo "下一步："
echo "1. 在 GitHub 创建私有仓库：https://github.com/new"
echo "2. 运行以下命令："
echo "   cd ../dify-private-config"
echo "   git add ."
echo "   git commit -m 'Initial private config'"
echo "   git remote add origin git@github.com:$GITHUB_USERNAME/dify-private-config.git"
echo "   git push -u origin main"