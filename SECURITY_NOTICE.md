# 安全注意事项

## Fork 可见性说明
- 此 fork 是**公开的**，任何人都可以查看源代码
- 不要在此仓库中提交任何敏感信息

## 敏感信息管理

### ❌ 不要提交：
- API 密钥、Token
- 数据库密码
- 私有配置文件
- 客户数据
- 内部文档

### ✅ 安全实践：
1. **使用环境变量**
   ```bash
   # .env.local (不要提交)
   CUSTOM_API_KEY=xxx
   DATABASE_PASSWORD=xxx
   ```

2. **使用 Docker Secrets**
   ```yaml
   # docker-compose.override.yml (已在 .gitignore 中)
   services:
     api:
       environment:
         - API_KEY_FILE=/run/secrets/api_key
   ```

3. **使用配置管理工具**
   - HashiCorp Vault
   - AWS Secrets Manager
   - Azure Key Vault

## 定制代码管理策略

### 选项1：公开 Fork + 私有配置（当前方案）
- 优点：易于同步官方更新
- 缺点：定制代码公开可见
- 适用：无敏感业务逻辑的定制

### 选项2：私有镜像仓库
```bash
# 创建私有仓库并定期同步
git clone --mirror https://github.com/langgenius/dify.git
cd dify.git
git remote add private git@github.com:cydmacro/dify-private.git
git push --mirror private
```

### 选项3：分离架构
- 公开 Fork：仅用于跟踪上游
- 私有仓库：存储定制代码和配置
- CI/CD：合并两者进行构建

## 检查清单
- [ ] 确认 .gitignore 包含所有敏感文件
- [ ] 定期审查提交历史
- [ ] 使用 git-secrets 扫描敏感信息
- [ ] 配置 GitHub Secret Scanning