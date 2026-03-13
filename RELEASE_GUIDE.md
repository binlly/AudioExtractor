# AudioExtractor 发布指南

本文档说明如何将 AudioExtractor 发布到 GitHub。

## 📋 发布前检查清单

### 代码检查
- [x] 所有代码已提交
- [x] 编译无错误（`flutter analyze`）
- [x] Release 版本构建成功
- [x] README.md 完整且最新
- [x] CHANGELOG.md 已更新
- [x] LICENSE 文件已添加

### 文档检查
- [x] README.md - 项目介绍、功能特性、使用指南
- [x] CONTRIBUTING.md - 贡献指南
- [x] CHANGELOG.md - 版本历史
- [x] LICENSE - MIT 许可证

### GitHub 配置
- [x] Issue 模板已创建
- [x] PR 模板已创建
- [x] .gitignore 已配置

## 🚀 发布步骤

### 1. 推送代码到 GitHub

```bash
# 推送所有分支
git push -u origin main

# 推送所有标签
git push origin --tags
```

### 2. 在 GitHub 创建 Release

1. 访问 https://github.com/binlly/AudioExtractor
2. 点击 "Releases" → "Create a new release"
3. 填写以下信息：
   - **Tag version**: `v2.5.0`
   - **Release title**: `AudioExtractor v2.5.0 - 重大更新`
   - **Description**:

```markdown
## 🎉 AudioExtractor v2.5.0 - 重大更新

我们很高兴发布 AudioExtractor v2.5.0！这个版本包含了重大改进和新功能。

### ✨ 主要新功能

#### 🎬 视频播放器
- 内置视频播放器，支持拖拽加载
- 可视化双滑块时间范围选择
- 实时预览选中片段
- 平滑的颜色渐变动画效果

#### ⌨️ 键盘快捷键系统
- 空格：播放/暂停
- ← / →：快退/快进 5秒
- Shift + ← / Shift + →：单帧后退/前进
- R：从头开始播放

#### 🎨 UI 优化
- 质量选择器和输出目录改为下拉菜单
- 高级设置面板（支持自定义 FFmpeg 参数）
- 智能文件命名（包含时间范围信息）
- 流畅的动画效果

### 📦 下载

#### macOS
- **AudioExtractor-v2.5.0-macos.dmg** (待上传)
- 系统：macOS 11.0 (Big Sur) 或更高版本
- 架构：x86_64, arm64 (Apple Silicon)

### 📝 更新日志

详见 [CHANGELOG.md](https://github.com/binlly/AudioExtractor/blob/main/CHANGELOG.md)

### 🙏 致谢

感谢所有贡献者和用户的支持！

---

**完整更新日志**: https://github.com/binlly/AudioExtractor/compare/v2.0.0...v2.5.0
```

4. 上传应用文件：
   - 构建 Release 版本
   - 将 `.app` 文件打包为 `.dmg`

### 3. 创建 DMG 安装包（可选）

```bash
# 安装 create-dmg 工具
brew install create-dmg

# 创建 DMG
create-dmg \
  --volname "AudioExtractor" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --app-drop-link 450 185 \
  "AudioExtractor-v2.5.0-macos.dmg" \
  "build/macos/Build/Products/Release/AudioExtractor.app"
```

### 4. 验证 Release

- [ ] 下载并测试安装包
- [ ] 验证所有功能正常工作
- [ ] 检查文档链接有效

## 📊 发布后任务

### GitHub 优化
- [ ] 添加 Topics 到仓库
- [ ] 设置仓库描述
- [ ] 添加网站链接（如果有）
- [ ] 配置 Branch Protection（主要分支）

### 推广
- [ ] 在社交媒体分享
- [ ] 发布到相关社区
- [ ] 更新个人博客

### 后续支持
- [ ] 监控 Issues
- [ ] 回复 PR 和 Discussion
- [ ] 收集用户反馈

## 🔄 持续集成（可选）

可以考虑添加 GitHub Actions：

```yaml
name: Build and Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      - run: flutter pub get
      - run: flutter build macos --release
      - run: |
          create-dmg \
            --volname "AudioExtractor" \
            "AudioExtractor-macos.dmg" \
            "build/macos/Build/Products/Release/AudioExtractor.app"
      - uses: softprops/action-gh-release@v1
        with:
          files: AudioExtractor-macos.dmg
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## 📈 下一步计划

### v2.6
- 改进错误处理
- 批量处理功能
- 更多输出格式

### v3.0 - 跨平台支持
- Windows 支持
- Linux 支持
- 统一安装包

## 📞 联系方式

- **GitHub**: https://github.com/binlly
- **Issues**: https://github.com/binlly/AudioExtractor/issues
- **Discussions**: https://github.com/binlly/AudioExtractor/discussions
