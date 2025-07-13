# Dify 定制版本维护指南

## 定制内容
- 自定义品牌 Logo
- 移除 "Powered by Dify" 标志（可选）

## 维护流程

### 1. 初始设置
```bash
# Fork 官方仓库后
git remote add upstream git@github.com:langgenius/dify.git
git remote add origin git@github.com:YOUR_USERNAME/dify.git
```

### 2. 定期同步官方更新
```bash
# 运行同步脚本
./sync-upstream.sh
```

### 3. 部署定制版本
```bash
cd docker
docker-compose -f docker-compose.yaml -f docker-compose.override.yml up -d
```

### 4. 备份定制配置
定制配置主要保存在：
- 数据库中（通过管理界面上传的 logo）
- `docker-compose.override.yml`（Docker 配置）
- `custom-assets/` 目录（自定义资源）

### 5. 版本升级注意事项
- 升级前备份数据库
- 检查 API 变更日志
- 测试定制功能是否正常

## 定制配置方式

### 方式1：通过管理界面（推荐）
1. 访问 Dify 管理界面
2. 进入工作空间设置 > 自定义
3. 上传 logo 或切换品牌显示

### 方式2：代码修改
如需更深度定制，可修改以下文件：
- `/web/app/components/custom/custom-web-app-brand/index.tsx`
- `/web/app/components/base/chat/embedded-chatbot/header/index.tsx`
- `/web/app/components/share/text-generation/index.tsx`

## 故障排除
1. Logo 不显示：检查文件格式和大小
2. 配置未生效：清除浏览器缓存，重启容器
3. 同步冲突：手动解决后继续 rebase