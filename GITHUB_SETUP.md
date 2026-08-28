# 🚀 GitHub Actions 构建设置指南

## 📋 步骤1：配置 GitHub 认证

### 方法1：使用 GitHub CLI（推荐）
```bash
# 安装 GitHub CLI
pkg install gh

# 登录 GitHub
gh auth login

# 选择 HTTPS 协议
# 选择 GitHub.com
# 选择浏览器认证（推荐）
```

### 方法2：使用 Personal Access Token
1. 访问 https://github.com/settings/tokens
2. 点击 "Generate new token"
3. 选择 "repo" 权限
4. 复制生成的 token
5. 配置 Git：
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your-email@example.com"
   
   # 设置远程仓库 URL（包含 token）
   git remote set-url origin https://<your-token>@github.com/Youzix-Star/Neko.git
   ```

## 📋 步骤2：推送代码到 GitHub

```bash
cd md2-termux-app

# 推送到 GitHub
git push -u origin master
```

## 📋 步骤3：触发 GitHub Actions 构建

### 自动触发
- 推送代码到 `main` 或 `master` 分支时自动触发
- 创建 Pull Request 时自动触发

### 手动触发
1. 访问 https://github.com/Youzix-Star/Neko/actions
2. 点击 "Build Android APK"
3. 点击 "Run workflow"

## 📋 步骤4：下载构建的 APK

### 从 Actions 页面下载
1. 访问 https://github.com/Youzix-Star/Neko/actions
2. 点击最新的构建工作流
3. 在 "Artifacts" 部分下载：
   - `debug-apk`: 调试版本 APK
   - `release-apk`: 发布版本 APK

### 从 Releases 页面下载
1. 访问 https://github.com/Youzix-Star/Neko/releases
2. 下载最新版本的 APK

## 📋 步骤5：安装到手机

### 方法1：使用 ADB
```bash
# 连接手机（开启USB调试）
adb install -r app-debug.apk
```

### 方法2：手动安装
1. 将 APK 文件传输到手机
2. 在文件管理器中点击安装
3. 允许安装未知来源应用

## 🔧 构建配置

### GitHub Actions 工作流程
- **触发条件**：push 到 main/master 分支
- **构建环境**：Ubuntu + JDK 17
- **构建产物**：Debug 和 Release APK
- **保留时间**：7天

### 构建产物
1. **Debug APK**: `app/build/outputs/apk/debug/app-debug.apk`
   - 包含调试信息
   - 可以直接安装
   - 适合开发测试

2. **Release APK**: `app/build/outputs/apk/release/app-release-unsigned.apk`
   - 未签名版本
   - 需要签名后才能安装
   - 适合发布

## 🎯 快速开始

### 1. 配置认证
```bash
# 安装 GitHub CLI
pkg install gh

# 登录
gh auth login
```

### 2. 推送代码
```bash
cd md2-termux-app
git push -u origin master
```

### 3. 等待构建
- 访问 https://github.com/Youzix-Star/Neko/actions
- 等待构建完成（通常2-5分钟）

### 4. 下载 APK
- 在 Actions 页面下载 artifact
- 或者在 Releases 页面下载

### 5. 安装到手机
- 使用 ADB 安装
- 或者手动传输安装

## 🐛 常见问题

### Q: 推送失败怎么办？
A: 检查 GitHub 认证配置，确保有推送权限。

### Q: 构建失败怎么办？
A: 检查 GitHub Actions 日志，查看具体错误信息。

### Q: 如何查看构建日志？
A: 访问 GitHub Actions 页面，点击具体的构建工作流查看日志。

### Q: 如何手动触发构建？
A: 在 GitHub Actions 页面点击 "Run workflow"。

## 📚 相关资源

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Android 构建指南](https://developer.android.com/build)
- [Gradle 文档](https://gradle.org/documentation/)

## 🎉 开始构建！

现在您可以：
1. 配置 GitHub 认证
2. 推送代码到 GitHub
3. 等待 GitHub Actions 构建
4. 下载 APK 并安装到手机

**开始您的 Android 开发之旅吧！** 🚀
