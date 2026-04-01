---
name: oss-manager
description: 管理阿里云 OSS 对象存储的工具。支持列出文件、上传下载、同步目录、删除文件等操作。当用户提到"OSS"、"阿里云"、"对象存储"、"上传文件到OSS"、"查看OSS文件"、"ossutil"等时使用此 skill。
---

# OSS Manager

用于管理阿里云 OSS 对象存储的实用工具集。

## 前置要求

- 已安装 `ossutil` 工具（版本 1.7+）
- 已配置 `~/.ossutilconfig` 文件（包含 AK/SK 和 Bucket 信息）

## 可用操作

### 1. 列出 OSS 文件

列出指定 Bucket 或前缀下的文件列表。

```bash
ossutil ls oss://<bucket>/<prefix>/
```

**参数:**
- `bucket` - Bucket 名称（如 `liutaoxie`）
- `prefix` - 可选，目录前缀（如 `openclaw/`）
- `recursive` - 可选，是否递归列出子目录

**示例:**
```bash
# 列出根目录
ossutil ls oss://liutaoxie/

# 列出 openclaw 目录
ossutil ls oss://liutaoxie/openclaw/

# 递归列出
ossutil ls oss://liutaoxie/openclaw/ --recursive
```

### 2. 上传文件/目录

将本地文件或目录上传到 OSS。

```bash
ossutil cp -r <local-path> oss://<bucket>/<remote-path>
```

**参数:**
- `local-path` - 本地文件或目录路径
- `bucket` - Bucket 名称
- `remote-path` - 目标路径（如 `backup/files/`）
- `recursive` - 上传目录时需要加 `-r`

**示例:**
```bash
# 上传单个文件
ossutil cp ./report.pdf oss://liutaoxie/files/

# 上传目录
ossutil cp -r ./my-project oss://liutaoxie/software/my-project/
```

### 3. 下载文件/目录

从 OSS 下载文件或目录到本地。

```bash
ossutil cp -r oss://<bucket>/<remote-path> <local-path>
```

**参数:**
- `bucket` - Bucket 名称
- `remote-path` - OSS 上的文件或目录路径
- `local-path` - 本地目标路径
- `recursive` - 下载目录时需要加 `-r`

**示例:**
```bash
# 下载单个文件
ossutil cp oss://liutaoxie/files/report.pdf ./downloads/

# 下载目录
ossutil cp -r oss://liutaoxie/software/my-project ./my-project-backup/
```

### 4. 同步目录

将本地目录与 OSS 目录进行双向或单向同步。

```bash
# 本地同步到 OSS（上传增量）
ossutil sync <local-dir> oss://<bucket>/<remote-dir>

# OSS 同步到本地（下载增量）
ossutil sync oss://<bucket>/<remote-dir> <local-dir>
```

**参数:**
- `local-dir` - 本地目录路径
- `bucket` - Bucket 名称
- `remote-dir` - OSS 上的目录路径

**示例:**
```bash
# 增量上传到 OSS
ossutil sync ./workspace oss://liutaoxie/workspace/

# 从 OSS 增量下载
ossutil sync oss://liutaoxie/workspace/ ./workspace-backup/
```

### 5. 删除文件/目录

删除 OSS 上的文件或目录。

```bash
ossutil rm oss://<bucket>/<path> [--recursive] [--force]
```

**参数:**
- `bucket` - Bucket 名称
- `path` - 要删除的文件或目录路径
- `recursive` - 递归删除目录
- `force` - 强制删除，不提示确认

**示例:**
```bash
# 删除单个文件
ossutil rm oss://liutaoxie/files/old-report.pdf

# 删除整个目录（递归）
ossutil rm oss://liutaoxie/software/old-project/ --recursive --force
```

### 6. 检查 Bucket 配额

查看 Bucket 的基本信息和存储用量。

```bash
ossutil bucket-stat oss://<bucket>
```

**示例:**
```bash
ossutil bucket-stat oss://liutaoxie
```

## 快捷别名（推荐配置）

为方便使用，建议在 `~/.bash_aliases` 或 `~/.bashrc` 中添加以下别名：

```bash
# OSS 快捷命令
alias oss-ls='ossutil ls'
alias oss-push='ossutil cp -r'
alias oss-pull='ossutil cp -r'
alias oss-sync='ossutil sync'
alias oss-rm='ossutil rm --recursive --force'
```

## 使用建议

1. **上传前检查**: 大文件上传前建议先用 `ls` 检查目标目录结构
2. **增量同步**: 定期同步使用 `sync` 而不是 `cp`，可以节省流量和时间
3. **递归删除小心**: `rm --recursive` 会删除整个目录树，使用前三思
4. **备份配置**: `~/.ossutilconfig` 包含密钥，建议定期备份但注意保密

## 故障排除

### 连接超时

```bash
# 增加超时时间
export OSSUTIL_CONNECT_TIMEOUT=300
export OSSUTIL_READ_WRITE_TIMEOUT=300
```

### 权限错误

- 检查 `~/.ossutilconfig` 中的 AK/SK 是否正确
- 确认 AK 对应的子账号有 OSS 访问权限

### 文件不存在

- OSS 路径必须以 `oss://` 开头
- 检查 Bucket 名称拼写
- 目录路径末尾加 `/` 表示目录，不加表示文件
