---
name: github-sync
description: |
  GitHub 仓库同步与管理工具。用于安全地管理多个 GitHub 仓库配置、
  执行 git clone/pull/push 等操作，支持 Personal Access Token 认证。
  
  适用场景：
  - 用户提到"同步 GitHub 仓库"、"从 GitHub 拉代码"、"push 到 GitHub"
  - 需要管理多个 GitHub 仓库的凭证和配置
  - 需要安全地存储和复用 GitHub Token
  
  密钥存储：Token 和仓库 URL 保存在工作区的 .github-config.json 文件中，
  用户可选择加密存储。
---

# GitHub 同步 Skill

## 配置管理

### 配置文件位置

配置文件存储在工作区根目录：
- `.github-config.json` - 主配置文件（包含加密后的 Token）
- `.github-config.json.key` - 加密密钥（如启用加密）

### 配置结构

```json
{
  "version": "1.0",
  "encrypted": false,
  "default_repo": "my-project",
  "repositories": {
    "my-project": {
      "name": "my-project",
      "full_name": "username/my-project",
      "clone_url": "https://github.com/username/my-project.git",
      "token_reference": "token_1",
      "local_path": "my-project",
      "default_branch": "main"
    }
  },
  "tokens": {
    "token_1": {
      "name": "personal_token",
      "type": "personal_access",
      "value": "ghp_xxxxxxxxxxxx",
      "scopes": ["repo"],
      "created_at": "2026-03-27T00:00:00Z"
    }
  }
}
```

## 核心操作

### 1. 添加仓库配置

当用户提供 GitHub 仓库 URL 和 Token 时：

1. **验证 Token 有效性**
   ```bash
   curl -H "Authorization: token <TOKEN>" https://api.github.com/user
   ```

2. **获取仓库信息**
   ```bash
   curl -H "Authorization: token <TOKEN>" https://api.github.com/repos/{owner}/{repo}
   ```

3. **安全存储配置**
   - 询问用户是否加密存储 Token
   - 将配置写入 `.github-config.json`
   - 默认使用本地路径名（仓库名）

### 2. Clone 仓库

执行 clone 操作：

```bash
# 构建带 Token 的 URL
https://<TOKEN>@github.com/<owner>/<repo>.git

# 执行 clone
git clone https://<TOKEN>@github.com/<owner>/<repo>.git <local-path>
```

### 3. Pull 更新

在已有仓库目录执行：

```bash
cd <local-path>
git pull origin <branch>
```

### 4. Push 推送

执行 push 操作：

```bash
cd <local-path>
git add .
git commit -m "<message>"
git push origin <branch>
```

## 使用流程

### 首次使用

1. **配置仓库**
   - 用户提供 GitHub 仓库 URL
   - 提供 Personal Access Token
   - 可选：指定本地路径名

2. **安全确认**
   - 询问是否加密存储 Token
   - 确认存储位置（工作区根目录）

### 日常使用

1. **同步仓库**
   - 选择已配置的仓库
   - 执行 pull 获取最新代码

2. **推送修改**
   - 添加/修改文件
   - 提交并推送

## 安全注意事项

1. **Token 安全**
   - 使用 Personal Access Token 而非密码
   - Token 最小权限原则（仅 repo 权限）
   - 可选加密存储

2. **配置文件保护**
   - `.github-config.json` 包含敏感信息
   - 建议添加到 `.gitignore`
   - 定期备份配置

3. **URL 安全**
   - 构建带 Token 的 URL 时确保 Token 正确编码
   - 避免在日志中打印完整 URL（含 Token）

## 错误处理

### 常见错误

1. **Token 无效**
   - 验证 Token 是否过期
   - 检查 Token 权限是否包含 repo

2. **仓库不存在/无权限**
   - 确认仓库 URL 正确
   - 确认 Token 有访问权限

3. **本地路径冲突**
   - 检查本地目录是否已存在
   - 选择不同的本地路径名

4. **网络/认证失败**
   - 检查网络连接
   - 重新验证 Token

## 扩展功能

### 多仓库管理
- 支持配置多个仓库
- 快速切换不同项目
- 批量同步多个仓库

### 分支管理
- 列出远程分支
- 切换/创建本地分支
- 推送特定分支

### 高级配置
- 自定义 Git 配置（用户名、邮箱）
- SSH 密钥认证（替代 Token）
- 代理设置
