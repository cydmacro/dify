#!/bin/bash

# Dify 安全检查脚本
# 检查是否有敏感信息可能被暴露

echo "🔍 开始安全检查..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查标志
has_issues=false

# 1. 检查环境变量文件
echo -e "\n📋 检查环境变量文件..."
env_files=$(find . -name "*.env" -o -name "*.env.*" | grep -v ".env.example")
if [ -n "$env_files" ]; then
    while IFS= read -r file; do
        if git check-ignore "$file" > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} $file 已被 .gitignore 忽略"
        else
            echo -e "${RED}✗${NC} $file 未被忽略，可能会被提交！"
            has_issues=true
        fi
    done <<< "$env_files"
fi

# 2. 检查 git 状态中的敏感文件
echo -e "\n📝 检查 git 状态..."
sensitive_patterns="\.env|password|secret|token|key|credential"
staged_files=$(git diff --cached --name-only | grep -iE "$sensitive_patterns" || true)
if [ -n "$staged_files" ]; then
    echo -e "${RED}✗ 发现暂存区中的敏感文件：${NC}"
    echo "$staged_files"
    has_issues=true
else
    echo -e "${GREEN}✓${NC} 暂存区无敏感文件"
fi

# 3. 搜索代码中的敏感信息
echo -e "\n🔎 搜索硬编码的敏感信息..."
sensitive_keywords=(
    "xoxb-"  # Slack bot token
    "xoxp-"  # Slack user token
    "github_pat_"  # GitHub personal access token
    "ghp_"  # GitHub personal access token (新格式)
    "sk-"  # OpenAI API key
    "AIza"  # Google API key
    "智谱"
    "百炼"
)

for keyword in "${sensitive_keywords[@]}"; do
    results=$(git grep -i "$keyword" 2>/dev/null | grep -v ".env.example" | grep -v "test" | grep -v "spec" || true)
    if [ -n "$results" ]; then
        echo -e "${RED}✗ 发现可能的敏感信息 '$keyword'：${NC}"
        echo "$results" | head -5
        has_issues=true
    fi
done

# 4. 检查最近的提交
echo -e "\n📜 检查最近的提交..."
recent_commits=$(git log --oneline -n 5 --grep="key\|token\|secret\|password" -i 2>/dev/null || true)
if [ -n "$recent_commits" ]; then
    echo -e "${YELLOW}⚠ 最近提交中包含敏感关键词：${NC}"
    echo "$recent_commits"
fi

# 5. 检查远程仓库
echo -e "\n🌐 检查远程仓库..."
remotes=$(git remote -v)
echo "$remotes"

# 总结
echo -e "\n📊 检查总结："
if [ "$has_issues" = true ]; then
    echo -e "${RED}✗ 发现潜在的安全问题，请检查上述内容${NC}"
    echo -e "\n建议："
    echo "1. 确保所有 .env 文件都在 .gitignore 中"
    echo "2. 使用 git reset 移除暂存区中的敏感文件"
    echo "3. 考虑使用 git filter-branch 清理历史记录"
else
    echo -e "${GREEN}✓ 未发现明显的安全问题${NC}"
    echo -e "\n良好实践："
    echo "1. 继续使用环境变量存储敏感信息"
    echo "2. 定期运行此脚本进行检查"
    echo "3. 提交前使用 git diff 检查内容"
fi

# 额外建议
echo -e "\n💡 额外安全建议："
echo "1. 定期轮换 API 密钥"
echo "2. 使用密钥管理服务（如 AWS Secrets Manager）"
echo "3. 启用 GitHub 的 secret scanning"
echo "4. 使用 pre-commit hooks 自动检查"