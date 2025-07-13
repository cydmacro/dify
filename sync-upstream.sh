#!/bin/bash

# 同步 Dify 官方更新的脚本

echo "🔄 开始同步官方 Dify 更新..."

# 1. 获取最新的官方代码
echo "📥 获取官方最新代码..."
git fetch upstream

# 2. 切换到主分支
echo "🔀 切换到 main 分支..."
git checkout main

# 3. 合并官方更新
echo "🔗 合并官方更新..."
git merge upstream/main

# 4. 推送到您的仓库
echo "📤 推送到您的仓库..."
git push origin main

# 5. 更新定制分支
echo "🎨 更新定制分支..."
git checkout custom-branding

# 6. 变基到最新的 main
echo "♻️  变基定制分支..."
git rebase main

# 7. 如果有冲突，提示用户解决
if [ $? -ne 0 ]; then
    echo "❗ 检测到冲突，请手动解决后执行："
    echo "   git rebase --continue"
    echo "   git push -f origin custom-branding"
else
    echo "✅ 变基成功！推送更新..."
    git push -f origin custom-branding
    echo "🎉 同步完成！"
fi