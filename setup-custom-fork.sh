#!/bin/bash

# 设置定制版 Dify 的 Git 配置脚本

echo "🔧 开始配置 Dify 定制版本..."

# 请在这里替换为您的 GitHub 用户名
GITHUB_USERNAME="cydmacro"

# 1. 备份当前 remote 配置
echo "📋 当前 remote 配置："
git remote -v

# 2. 添加 upstream（官方仓库）
echo -e "\n📌 设置 upstream remote..."
if ! git remote get-url upstream >/dev/null 2>&1; then
    git remote add upstream https://github.com/langgenius/dify.git
    echo "✅ 已添加 upstream"
else
    echo "ℹ️  upstream 已存在"
fi

# 3. 添加 origin（您的 fork）
echo -e "\n🔗 设置 origin remote..."
git remote remove origin 2>/dev/null || true
git remote add origin git@github.com:${GITHUB_USERNAME}/dify.git
echo "✅ 已设置 origin 为您的 fork"

# 4. 显示新的 remote 配置
echo -e "\n📋 新的 remote 配置："
git remote -v

# 5. 获取最新代码
echo -e "\n📥 获取代码..."
git fetch --all

# 6. 创建定制分支
echo -e "\n🌿 创建定制分支..."
git checkout -b custom-branding || git checkout custom-branding

echo -e "\n✨ 配置完成！"
echo "下一步："
echo "1. 确保您已经在 GitHub 上 fork 了 Dify 仓库"
echo "2. 运行: git push -u origin custom-branding"
echo "3. 使用 ./sync-upstream.sh 定期同步官方更新"
