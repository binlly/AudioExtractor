# 视频音轨提取应用 - 设计文档

**日期**: 2026-03-11
**项目**: ExtractAudio Core
**平台**: Flutter macOS

## 1. 概述

### 1.1 目标
开发一个 macOS 原生应用，支持从视频文件中提取音轨并保存为 MP3 文件，保留多音轨结构。

### 1.2 核心功能
- 拖拽视频文件进行解析
- 自动检测并显示所有音轨信息
- 支持多音轨选择提取
- 三种质量预设（高质量/标准/压缩）
- 指定输出目录
- 实时进度显示
- 保持原有音频质量

### 1.3 技术栈
- **框架**: Flutter 3.11.1+
- **平台**: macOS 11+ (Big Sur)
- **音视频处理**: FFmpeg Kit 6.0.3
- **状态管理**: Provider 6.1.1
- **UI风格**: macOS 原生风格

## 2. 系统架构

### 2.1 分层架构

```
┌─────────────────────────────────────────┐
│           UI Layer (Flutter)            │
│  - DragTarget (拖拽区域)                 │
│  - ListView (音轨列表)                   │
│  - Controls (配置和控制按钮)             │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│      Business Logic Layer (Dart)        │
│  - VideoAnalyzer (解析视频)             │
│  - AudioExtractor (管理提取任务)        │
│  - QualityManager (质量预设)            │
│  - ProgressTracker (进度追踪)           │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         FFmpeg Layer                    │
│  - ffmpeg_kit_flutter (执行音频提取)    │
│  - Stream callbacks (进度回调)          │
│  - Async task management (异步任务)     │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Data Layer                      │
│  - AudioTrack (音轨模型)                │
│  - ExtractionSettings (配置模型)        │
│  - OutputManager (输出管理)             │
└─────────────────────────────────────────┘
```

### 2.2 项目结构

```
lib/
├── main.dart                          # 应用入口
├── models/
│   ├── audio_track.dart               # 音轨数据模型
│   ├── extraction_settings.dart       # 提取配置模型
│   └── quality_preset.dart            # 质量预设枚举
├── services/
│   ├── ffmpeg_service.dart            # FFmpeg 封装
│   ├── video_analyzer.dart            # 视频分析服务
│   ├── audio_extractor.dart           # 音频提取服务
│   ├── quality_manager.dart           # 质量预设管理
│   └── output_manager.dart            # 输出目录管理
├── providers/
│   └── extraction_provider.dart       # 状态管理 Provider
├── ui/
│   ├── pages/
│   │   └── home_page.dart             # 主页面
│   └── widgets/
│       ├── drop_zone.dart             # 拖拽区域组件
│       ├── track_list_item.dart       # 音轨列表项
│       ├── quality_selector.dart      # 质量选择器
│       ├── output_directory_picker.dart # 输出目录选择器
│       └── extraction_progress.dart   # 提取进度组件
└── utils/
    ├── file_utils.dart                # 文件工具函数
    └── ffmpeg_command_builder.dart    # FFmpeg 命令构建器
```

## 3. 数据模型

### 3.1 AudioTrack 音轨模型

```dart
class AudioTrack {
  final int index;              // 音轨索引（从0开始）
  final String? language;        // 语言代码（如 "eng", "chi"）
  final String codec;            // 编码格式（如 "aac", "ac3"）
  final int sampleRate;          // 采样率（Hz）
  final int channels;            // 声道数（1=单声道, 2=立体声）
  final Duration duration;       // 时长
  final bool isSelected;         // 是否选中提取（UI状态）

  AudioTrack copyWith({bool? isSelected});
}
```

### 3.2 ExtractionSettings 提取配置

```dart
class ExtractionSettings {
  final QualityPreset preset;           // 质量预设
  final int? customBitrate;             // 自定义比特率（kbps）
  final int? customSampleRate;          // 自定义采样率（Hz）
  final String outputDirectory;         // 输出目录路径
}
```

### 3.3 QualityPreset 质量预设

```dart
enum QualityPreset {
  highQuality,   // 320kbps, 保持原采样率
  standard,      // 192kbps, 44.1kHz
  compressed,    // 128kbps, 44.1kHz
  custom         // 自定义参数
}
```

### 3.4 质量预设参数

| 预设 | 比特率 | 采样率 | 适用场景 |
|------|--------|--------|----------|
| 高质量 | 320kbps | 原采样率 | 音乐、高保真音频 |
| 标准 | 192kbps | 44.1kHz | 一般视频、播客 |
| 压缩 | 128kbps | 44.1kHz | 节省空间、语音 |

## 4. UI 设计

### 4.1 主界面布局（垂直流式）

```
┌─────────────────────────────────────┐
│  [图标] 拖拽视频文件到这里           │  ← DropZone
│  或点击选择文件                      │
└─────────────────────────────────────┘
         ↓ (分析后显示)
┌─────────────────────────────────────┐
│ 音轨信息                             │
│ ☑ 音轨 1: 英语 (AAC, 48000Hz, 立体声)│  ← TrackList
│ ☑ 音轨 2: 中文 (AAC, 48000Hz, 立体声)│
│ ☐ 音轨 3: 评论 (AAC, 44100Hz, 单声道)│
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│ 音频质量                             │
│ ⦿ 高质量 (320kbps)                  │  ← QualitySelector
│ ○ 标准 (192kbps)                     │
│ ○ 压缩 (128kbps)                     │
┘                                      │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│ 输出目录: ~/Downloads/ExtractAudio   │  ← OutputDirectoryPicker
│ [更改] [打开]                        │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│          [开始提取]                  │  ← ActionButton
│  ████████░░░░░░░░ 60%               │  ← ProgressIndicator
└─────────────────────────────────────┘
```

### 4.2 交互状态流转

```
[空闲] → 拖入文件 → [分析中] → [已分析] → 点击开始 → [提取中] → [完成]
                      ↓                       ↓
                   错误提示               取消操作
```

### 4.3 视觉反馈

- **拖拽区域**：
  - 未拖入：虚线边框 + 灰色背景
  - 悬停：蓝色高亮边框
  - 已选择：显示文件信息卡片

- **音轨列表**：
  - 悬停高亮
  - 复选框状态清晰
  - 编码信息图标化

- **进度条**：
  - 实时百分比
  - 预计剩余时间
  - 当前阶段提示（分析/提取/完成）

## 5. 核心服务

### 5.1 VideoAnalyzer - 视频分析服务

**职责**：解析视频文件，提取音轨元数据

**方法**：
```dart
class VideoAnalyzer {
  Future<List<AudioTrack>> analyze(String videoPath) async {
    // 1. 使用 FFprobe 获取媒体信息
    // 2. 解析音频流
    // 3. 构建 AudioTrack 列表
    // 4. 返回结果
  }
}
```

**FFmpeg 命令**：
```bash
ffprobe -i input.mp4 -show_streams -select_streams a -of json
```

### 5.2 AudioExtractor - 音频提取服务

**职责**：执行音频提取任务

**方法**：
```dart
class AudioExtractor {
  Future<void> extract(
    String videoPath,
    List<int> selectedTrackIndices,
    ExtractionSettings settings,
    Function(double) onProgress,
  ) async {
    // 1. 构建 FFmpeg 命令
    // 2. 执行异步提取
    // 3. 回调进度更新
    // 4. 完成后返回
  }

  Future<void> cancel() async {
    // 取消当前任务
  }
}
```

**FFmpeg 命令模板**：
```bash
ffmpeg -i input.mp4 \
  -map 0:a:0 -map 0:a:1 -map 0:a:2 \
  -c:a:0 mp3 -b:a:0 320k \
  -c:a:1 mp3 -b:a:1 320k \
  -c:a:2 mp3 -b:a:2 320k \
  -ar 48000 \
  output.mp3
```

**命令构建逻辑**：
1. 根据选中的音轨动态添加 `-map 0:a:X`
2. 为每个音轨单独设置编码参数
3. 应用质量预设的比特率和采样率
4. 输出到指定目录

### 5.3 QualityManager - 质量预设管理

**职责**：管理质量预设参数

```dart
class QualityManager {
  Map<String, String> getParameters(QualityPreset preset) {
    switch (preset) {
      case QualityPreset.highQuality:
        return {'bitrate': '320k', 'ar': 'original'};
      case QualityPreset.standard:
        return {'bitrate': '192k', 'ar': '44100'};
      case QualityPreset.compressed:
        return {'bitrate': '128k', 'ar': '44100'};
      default:
        return {};
    }
  }
}
```

### 5.4 OutputManager - 输出管理

**职责**：管理输出目录和文件命名

```dart
class OutputManager {
  static String defaultOutputPath =
      path.join(homeDirectory, 'Downloads', 'ExtractAudio');

  static Future<String> generateOutputPath(
    String videoPath,
    String outputDirectory,
  ) async {
    final videoName = path.basenameWithoutExtension(videoPath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return path.join(outputDirectory, '${videoName}_audio_$timestamp.mp3');
  }

  static Future<void> ensureOutputDirectory(String path) async {
    // 创建输出目录（如果不存在）
  }
}
```

## 6. 状态管理

### 6.1 ExtractionProvider

```dart
class ExtractionProvider extends ChangeNotifier {
  // 文件状态
  File? selectedVideo;
  List<AudioTrack> tracks = [];

  // 设置状态
  QualityPreset preset = QualityPreset.highQuality;
  String outputDirectory = OutputManager.defaultOutputPath;

  // 处理状态
  bool isAnalyzing = false;
  bool isExtracting = false;
  double progress = 0.0;
  String? currentStatus;

  // 错误状态
  String? errorMessage;

  // 方法
  Future<void> analyzeVideo(String path) async;
  Future<void> startExtraction() async;
  Future<void> cancelExtraction() async;
  void updateProgress(double value);
  void setError(String error);
  void reset();
}
```

### 6.2 状态生命周期

```
初始化
  ↓
[Idle] selectedVideo=null, tracks=[]
  ↓ (拖入文件)
[Analyzing] isAnalyzing=true, 显示加载动画
  ↓ (分析完成)
[Analyzed] tracks=[...], 显示音轨列表和配置
  ↓ (开始提取)
[Extracting] isExtracting=true, progress更新
  ↓ (完成/失败)
[Completed/Error] 显示结果或错误信息
```

## 7. 错误处理

### 7.1 错误分类

| 错误类型 | 示例 | 处理方式 |
|---------|------|----------|
| 文件验证 | 不支持的格式、损坏的文件 | 提示用户检查文件 |
| 处理失败 | FFmpeg 执行失败 | 显示错误日志 |
| 系统错误 | 磁盘空间不足、权限错误 | 具体解决方案提示 |
| 用户取消 | 中途取消操作 | 清理临时文件 |

### 7.2 错误提示策略

```dart
class ErrorMessage {
  static String getUserFriendlyMessage(dynamic error) {
    if (error is FFmpegException) {
      if (error.message.contains('Permission denied')) {
        return '无法访问输出目录，请检查权限设置';
      }
      if (error.message.contains('No space left')) {
        return '磁盘空间不足，请清理空间后重试';
      }
      return '音频提取失败: ${error.message}';
    }
    return '发生未知错误，请重试';
  }
}
```

### 7.3 边界情况处理

- **超大文件**（>2GB）：显示警告但允许处理
- **多音轨视频**（>8个音轨）：列表滚动，全选/取消全选
- **无语言标签**：显示"音轨 1"、"音轨 2"
- **未知编码**：显示"未知编码"，尝试提取
- **采样率不匹配**：FFmpeg 自动重采样

## 8. 性能优化

### 8.1 分析优化

- 使用 `-hide_banner -nostats` 减少输出
- 设置超时机制（30秒）
- 仅探测音频流：`-select_streams a`

### 8.2 提取优化

- 异步执行，不阻塞 UI
- 进度更新频率限制（每200ms）
- 允许后台运行

### 8.3 内存优化

- 大文件流式读取
- 音轨列表虚拟化（如果超过20个）
- 及时释放资源

### 8.4 性能目标

| 指标 | 目标值 |
|------|--------|
| 分析音轨 | < 1秒 |
| 提取音频 | 1-5分钟/GB |
| 内存占用 | < 200MB |
| 应用启动 | < 2秒 |

## 9. 测试策略

### 9.1 单元测试

- `AudioTrack` 模型序列化
- `QualityManager` 参数计算
- `OutputManager` 文件命名
- `FFmpegCommandBuilder` 命令构建

### 9.2 集成测试

- FFmpeg 命令执行
- 进度回调
- 错误处理

### 9.3 端到端测试

**测试样本**：
- 单音轨 MP4 (AAC)
- 多音轨 MKV (AAC, AC3)
- DTS 音轨视频
- 大文件（>1GB）

**测试流程**：
1. 拖入视频
2. 验证音轨信息正确显示
3. 选择部分/全部音轨
4. 选择质量预设
5. 开始提取
6. 验证输出文件
7. 播放验证音轨完整性

### 9.4 测试文件准备

使用 FFmpeg 生成测试样本：
```bash
# 单音轨测试视频
ffmpeg -f lavfi -i testsrc=duration=10:size=320x240:rate=1 \
  -f lavfi -i sine=frequency=1000:duration=10 \
  -c:v libx264 -c:a aac single_track.mp4

# 多音轨测试视频
ffmpeg -i single_track.mp4 \
  -i sine_audio.mp3 \
  -map 0:v -map 0:a -map 1:a \
  -c:v copy -c:a aac multi_track.mkv
```

## 10. 依赖和配置

### 10.1 pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter

  # FFmpeg 集成
  ffmpeg_kit_flutter: ^6.0.3

  # 状态管理
  provider: ^6.1.1

  # 文件选择
  file_selector: ^1.0.1

  # 路径处理
  path_provider: ^2.1.1
  path: ^1.8.3

  # macOS 原生风格
  flutter_macos_ui: ^2.0.0

  # 日志
  logger: ^2.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  mockito: ^5.4.4
  build_runner: ^2.4.7
```

### 10.2 macOS 权限配置

**macos/Runner/DebugProfile.entitlements**:
```xml
<key>com.apple.security.files.user-selected.read-only</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
<key>com.apple.security.network.client</key>
<true/>
```

**macos/Runner/Release.entitlements**:
```xml
<key>com.apple.security.files.user-selected.read-only</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
```

### 10.3 FFmpeg Kit 配置

使用 `ffmpeg-kit-audio` 版本（仅音频功能）：
- 包大小：~30-40MB（vs 完整版 80MB+）
- 包含编解码器：MP3、AAC、AC3
- 不包含视频编解码器，减小体积

## 11. 实施计划

### 阶段 1: 项目搭建（1-2天）
- [ ] 配置 pubspec.yaml 依赖
- [ ] 配置 macOS 权限
- [ ] 创建项目目录结构
- [ ] 配置 FFmpeg Kit
- [ ] 验证编译通过

### 阶段 2: 核心模型和服务（2-3天）
- [ ] 创建数据模型
- [ ] 实现 ExtractionProvider
- [ ] 实现 FFmpegService
- [ ] 实现 VideoAnalyzer
- [ ] 单元测试

### 阶段 3: UI 组件开发（3-4天）
- [ ] 实现拖拽区域
- [ ] 实现音轨列表
- [ ] 实现质量选择器
- [ ] 实现目录选择器
- [ ] 实现进度指示器

### 阶段 4: 业务逻辑集成（2-3天）
- [ ] 集成分析流程
- [ ] 集成提取流程
- [ ] 实现错误处理
- [ ] 实现取消功能
- [ ] 端到端测试

### 阶段 5: 优化和打磨（1-2天）
- [ ] 性能优化
- [ ] UI 美化
- [ ] 添加日志
- [ ] 编写文档
- [ ] 准备应用图标

**总预计时间**: 9-14 天

### 依赖关系
```
阶段1 → 阶段2 → 阶段3/4（可并行）→ 阶段5
```

## 12. 部署和发布

### 12.1 构建配置

```yaml
# macos/Runner.xcconfig
MACOSX_DEPLOYMENT_TARGET = 11.0
```

### 12.2 构建命令

```bash
# Debug 构建
flutter build macos --debug

# Release 构建
flutter build macos --release

# 生成的应用位置
# build/macos/Build/Products/Release/extract_audio.app
```

### 12.3 代码签名

```bash
# 开发者签名
codesign --force --deep --sign "Developer ID Application: Your Name" \
  build/macos/Build/Products/Release/extract_audio.app
```

### 12.4 分发方式

- 直接下载 .app 文件
- 创建 DMG 镜像文件
- GitHub Releases 发布

## 13. 未来扩展

### 13.1 潜在功能
- 批量处理多个视频
- 自定义 FFmpeg 参数
- 音轨预览播放
- 转换为其他格式（AAC、FLAC）
- 编辑音频元数据
- 音频剪辑（提取片段）

### 13.2 其他平台
- Windows 版本
- Linux 版本
- 命令行工具

---

## 附录

### A. FFmpeg 进度解析

FFmpeg 输出示例：
```
frame=  123 fps= 45 q=28.0 size=    1234kB time=00:00:05.12 bitrate=1976.5kbits/s speed=1.23x
```

解析正则：
```dart
final progressRegex = RegExp(r'time=(\d+):(\d+):(\d+\.\d+)');
final match = progressRegex.firstMatch(logMessage);
if (match != null) {
  final hours = int.parse(match.group(1)!);
  final minutes = int.parse(match.group(2)!);
  final seconds = double.parse(match.group(3)!);
  final currentTime = Duration(hours: hours, minutes: minutes, seconds: seconds.toInt());
  final progress = currentTime.inMilliseconds / totalDuration.inMilliseconds;
  return progress;
}
```

### B. 音轨语言代码映射

```dart
const Map<String, String> languageNames = {
  'eng': 'English',
  'chi': '中文',
  'jpn': '日本語',
  'kor': '한국어',
  'fre': 'Français',
  'ger': 'Deutsch',
  'spa': 'Español',
  // ... 更多语言
};
```

### C. 常见问题

**Q: 为什么选择 MP3 而不是其他格式？**
A: MP3 兼容性最好，几乎所有设备都支持。未来可扩展支持其他格式。

**Q: 应用体积有多大？**
A: 使用 ffmpeg-kit-audio 版本，预计应用体积约 50-60MB。

**Q: 支持哪些视频格式？**
A: FFmpeg 支持几乎所有格式（MP4、MKV、AVI、MOV 等）。

**Q: 可以提取特定时间段吗？**
A: 当前版本不支持，计划在后续版本添加。

---

**文档版本**: 1.0
**最后更新**: 2026-03-11
**作者**: Claude Sonnet
**状态**: 已批准，准备实施
