# Changelog

All notable changes to AudioExtractor will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.5.1] - 2025-03-13

### Fixed
- **视频解析失败** - 修复 FFprobe 输出解析错误
  - 使用 `jsonEncode()` 替代 `toString()` 返回有效的 JSON 格式
  - 确保音轨列表正确显示
- **FFmpeg 退出码 null** - 修复音频提取失败问题
  - 使用 `FFmpegKit.executeWithArguments()` 替代 `executeAsync()`
  - 使用参数数组而不是命令字符串，避免路径解析错误
- **路径包含中文/空格** - 正确处理特殊字符路径
  - FFmpeg Kit 自动处理路径中的空格和中文
  - 无需手动添加引号
- **输出目录初始化失败** - 修复路径展开问题
  - 正确展开 `~` 为实际主目录路径
  - 避免在只读的 "desktop" 路径创建文件

### Added
- **拖拽替换提示** - 拖动新视频时显示确认对话框
  - 防止误操作，询问用户是否替换当前视频
  - 提供清晰的用户反馈
- **点击选择视频** - 占位符支持点击交互
  - 添加文件选择按钮
  - 使用 `file_selector` 插件打开文件选择对话框
  - 提升用户体验，支持拖拽和点击两种方式

### Changed
- **FFmpeg 集成** - 迁移到 `ffmpeg_kit_flutter_new 2.0.0`
  - 使用活跃维护的 fork 替代已废弃的 `ffmpeg_kit_flutter 6.0.3`
  - 完全内置 FFmpeg 库，不依赖外部安装
  - 应用体积约 99MB（Universal Binary）
- **错误处理** - 改进错误日志和用户反馈
  - 显示详细的 FFmpeg 输出日志
  - 提供更明确的错误信息

### Technical
- 新增 `FFmpegKitService` 替代 `FFmpegService`
- 使用 `FFmpegKit.executeWithArguments()` 执行命令
- 正确处理路径中的特殊字符
- 改进输出目录初始化逻辑

### Documentation
- 新增 `FIX_SUMMARY.md` - FFmpeg 依赖修复完整报告
- 新增 `IMPROVEMENTS_SUMMARY.md` - 功能改进说明
- 新增 `FFMPEG_FIX_REPORT.md` - FFmpeg 问题诊断报告
- 新增 `RELEASE_TEST_CHECKLIST.md` - Release 版本测试清单
- 更新 README.md - 添加常见问题解答

---

## [Unreleased]

### Planned
- Windows 平台支持
- Linux 平台支持
- 批量处理功能
- 更多输出格式支持 (AAC, FLAC, OGG)
- 音频预览功能
- 多语言支持

## [2.5.0] - 2026-03-12

### Added
- **视频播放器** - 内置视频播放器，支持拖拽加载视频文件
- **双滑块进度条** - 可视化时间范围选择，带颜色渐变动画（300ms 平滑过渡）
- **键盘快捷键系统** - 完整的快捷键支持
  - 空格：播放/暂停
  - 方向键：快进/快退 5秒
  - Shift + 方向键：单帧前进/后退
  - R 键：从头开始播放
- **高级设置面板** - 支持自定义 FFmpeg 参数
- **输出目录选择器** - 下拉菜单样式，节省标题栏空间
- **质量选择器** - 重新设计为下拉菜单
- **智能文件命名** - 输出文件名自动包含时间范围信息

### Changed
- **UI 优化** - 改进整体布局，提升用户体验
- **应用名称** - 从 "ExtractAudio" 更名为 "AudioExtractor"
- **颜色渐变动画** - 双滑块使用 TweenAnimationBuilder 实现平滑过渡
- **错误处理** - 更清晰的错误提示和用户反馈

### Removed
- **波形可视化** - 移除所有波形相关功能（未提供实际价值）
- **audio_waveforms 依赖** - 移除未使用的第三方库

### Technical
- 使用 `AnimatedBuilder` 实现实时 UI 更新
- 使用 `TweenAnimationBuilder` 实现平滑颜色过渡
- 使用 `ElasticOut` 曲线优化动画效果
- 完整的 Provider 状态管理

### Documentation
- 添加完整的 README.md
- 添加 CONTRIBUTING.md
- 添加 LICENSE（MIT）
- 创建 GitHub 模板和配置
- 添加多个报告文档（FIXES_REPORT.md, PROJECT_STATUS.md 等）

## [2.0.0] - 2026-03-10

### Added
- **视频预览播放器** - 内置视频播放器，可直接预览视频内容
- **可视化时间范围选择** - 双滑块进度条，直观选择提取片段
- **精确时间输入** - 毫秒级精度的手动时间输入（HH:MM:SS.mmm）
- **实时预览** - 拖动滑块时实时预览视频画面
- **智能文件命名** - 输出文件名自动包含时间范围信息
- **拖拽支持** - 直接拖拽视频文件到应用窗口
- **多音轨识别** - 自动检测并显示视频中的所有音轨
- **选择性提取** - 选择需要的音轨进行提取
- **质量预设** - 三种质量预设（高质量/标准/压缩）
- **多音轨保留** - 提取时保留多个音轨结构
- **实时进度** - 显示提取进度和预计剩余时间
- **原质量保持** - 可选择保持原始音频质量

### Technical
- 基于 Flutter 3.11.1+
- 使用 FFmpeg Kit 6.0.3 进行音视频处理
- Provider 状态管理
- desktop_drop 拖拽支持
- video_player 视频播放

### Architecture
- 分层架构（UI层 → 业务逻辑层 → 服务层 → 数据层）
- 完整的错误处理和日志系统
- 模块化组件设计

## [1.0.0] - 2026-02-XX

### Added
- 初始版本发布
- 基础音轨提取功能
- 简单的文件选择
- 固定质量输出
- macOS 平台支持

---

## 版本说明

- **[Unreleased]** - 计划中但尚未发布的版本
- **[X.Y.Z]** - 已发布的版本（X.主版本.Y.次版本.Z.补丁版本）

## 变更类型

- **Added** - 新增功能
- **Changed** - 功能变更
- **Deprecated** - 即将移除的功能
- **Removed** - 已移除的功能
- **Fixed** - Bug 修复
- **Security** - 安全性更新

---

## 链接

- [GitHub Repository](https://github.com/binlly/AudioExtractor)
- [Issue Tracker](https://github.com/binlly/AudioExtractor/issues)
- [Releases](https://github.com/binlly/AudioExtractor/releases)
