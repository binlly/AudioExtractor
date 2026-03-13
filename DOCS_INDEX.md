# AudioExtractor 文档索引

本目录包含 AudioExtractor 项目的所有文档。

---

## 📚 核心文档

### 用户文档

| 文档 | 说明 | 适用对象 |
|------|------|----------|
| [README.md](README.md) | 项目介绍、功能说明、快速开始 | 所有用户 |
| [CHANGELOG.md](CHANGELOG.md) | 版本历史记录 | 所有用户 |
| [RELEASE_NOTES_2.5.1.md](RELEASE_NOTES_2.5.1.md) | 版本 2.5.1 发布说明 | 用户 |

### 开发文档

| 文档 | 说明 | 适用对象 |
|------|------|----------|
| [CONTRIBUTING.md](CONTRIBUTING.md) | 贡献指南 | 开发者 |
| [TESTING_CHECKLIST.md](TESTING_CHECKLIST.md) | 测试清单 | 开发者、QA |
| [PROJECT_STATUS.md](PROJECT_STATUS.md) | 项目状态跟踪 | 开发者 |

---

## 🔧 技术文档

### 版本 2.5.1 相关

| 文档 | 说明 | 内容 |
|------|------|------|
| [VERSION_2.5.1.md](VERSION_2.5.1.md) | 完整版本说明 | 所有修复、新功能、技术细节 |
| [FIX_SUMMARY.md](FIX_SUMMARY.md) | FFmpeg 修复报告 | 双击运行崩溃问题的完整诊断和修复 |
| [IMPROVEMENTS_SUMMARY.md](IMPROVEMENTS_SUMMARY.md) | 功能改进说明 | 拖拽替换、点击选择等功能实现 |
| [FFMPEG_FIX_REPORT.md](FFMPEG_FIX_REPORT.md) | FFmpeg 问题诊断 | 退出码 null 问题的分析和解决 |
| [RELEASE_TEST_CHECKLIST.md](RELEASE_TEST_CHECKLIST.md) | Release 测试清单 | 双击运行测试验证步骤 |

### 设计文档

| 文档 | 说明 |
|------|------|
| [docs/plans/2026-03-11-video-preview-ui-redesign.md](docs/plans/2026-03-11-video-preview-ui-redesign.md) | 视频预览 UI 设计文档 |
| [docs/plans/2026-03-11-video-audio-extractor-design.md](docs/plans/2026-03-11-video-audio-extractor-design.md) | 音视频提取器架构设计 |

---

## 🎯 快速导航

### 我想了解...

#### 作为用户

- **如何使用** → [README.md](README.md) - 快速开始
- **新功能** → [RELEASE_NOTES_2.5.1.md](RELEASE_NOTES_2.5.1.md) - 版本 2.5.1 新特性
- **遇到问题** → [README.md#常见问题](README.md#-常见问题) - FAQ
- **版本历史** → [CHANGELOG.md](CHANGELOG.md) - 变更日志

#### 作为开发者

- **项目结构** → [README.md#项目结构](README.md#-项目结构) - 代码组织
- **如何贡献** → [CONTRIBUTING.md](CONTRIBUTING.md) - 贡献指南
- **测试验证** → [TESTING_CHECKLIST.md](TESTING_CHECKLIST.md) - 测试清单
- **技术实现** → [VERSION_2.5.1.md](VERSION_2.5.1.md) - 技术细节

#### 版本 2.5.1 特定

- **修复了什么** → [FIX_SUMMARY.md](FIX_SUMMARY.md) - 修复摘要
- **新功能** → [IMPROVEMENTS_SUMMARY.md](IMPROVEMENTS_SUMMARY.md) - 功能改进
- **技术细节** → [VERSION_2.5.1.md](VERSION_2.5.1.md) - 完整说明
- **如何测试** → [RELEASE_TEST_CHECKLIST.md](RELEASE_TEST_CHECKLIST.md) - 测试步骤

---

## 📊 版本 2.5.1 总览

### 主要修复

1. ✅ 视频解析失败 - 使用 `jsonEncode()` 修复
2. ✅ 音频提取失败 - 使用 `executeWithArguments()` 修复
3. ✅ 中文文件名 - FFmpeg Kit 自动处理
4. ✅ 路径初始化 - 正确展开 `~` 路径
5. ✅ 双击运行崩溃 - 使用内置 FFmpeg

### 新增功能

1. 🆕 拖拽替换提示 - 显示确认对话框
2. 🆕 点击选择视频 - 文件选择器集成

### 架构变更

- 🔄 迁移到 `ffmpeg_kit_flutter_new 2.0.0`
- 🔄 内置 FFmpeg 库（99MB）
- 🔄 完全独立，不依赖外部安装

---

## 🔗 相关链接

- **GitHub 仓库** - https://github.com/binlly/AudioExtractor
- **问题追踪** - https://github.com/binlly/AudioExtractor/issues
- **发布页面** - https://github.com/binlly/AudioExtractor/releases

---

## 📝 文档维护

### 文档更新记录

| 日期 | 文档 | 更新内容 |
|------|------|----------|
| 2025-03-13 | 所有文档 | 版本 2.5.1 发布 |
| 2025-03-13 | CHANGELOG.md | 添加版本 2.5.1 变更 |
| 2025-03-13 | README.md | 更新功能说明和 FAQ |
| 2025-03-13 | VERSION_2.5.1.md | 创建详细版本说明 |
| 2025-03-13 | FIX_SUMMARY.md | FFmpeg 修复完整报告 |

### 文档规范

- 使用 Markdown 格式
- 遵循 Keep a Changelog 格式
- 提供中英文双语支持（计划中）
- 包含代码示例和截图（计划中）

---

## 💡 反馈

如果您发现文档问题或有改进建议，请：

1. 提交 [GitHub Issue](https://github.com/binlly/AudioExtractor/issues)
2. 发起 Pull Request
3. 联系维护者

---

**AudioExtractor Documentation**
*Last updated: 2025-03-13*
*Version: 2.5.1*
