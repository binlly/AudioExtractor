# 视频预览界面重设计方案

**日期**: 2025-03-11
**版本**: 2.0.0
**状态**: 设计阶段

## 1. 概述

将音频提取应用的拖拽区域升级为视频预览播放器，支持时间范围选择和实时预览功能。用户可以通过可视化界面精确选择要提取的音频片段，大大提升用户体验。

## 2. 核心需求

### 2.1 功能需求

1. **视频播放器**
   - 点击视频区域切换播放/暂停状态
   - 显示当前播放位置和总时长
   - 拖动滑块时暂停播放并预览

2. **双滑块进度条**
   - 两个滑块分别控制开始时间和结束时间
   - 高亮显示选中区域
   - 滑块冲突检测（开始 < 结束）

3. **精确时间输入**
   - 毫秒级精度（HH:MM:SS.mmm）
   - 与滑块双向同步
   - 实时验证和错误提示

4. **质量选择**
   - 下拉框选择（高质量、标准、压缩）
   - 简洁直观的选项展示

5. **输出目录**
   - AppBar 右角下拉菜单
   - 常用目录快捷访问
   - 不显示当前完整路径

### 2.2 UI 布局

```
┌─────────────────────────────────────────────────────┐
│  ExtractAudio                    [📁 输出目录 ▼]   │
├─────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────┐   │
│  │          视频预览播放器 (400px)              │   │
│  │           [播放/暂停]                        │   │
│  └─────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────┐   │
│  │  [开始]━━━━●━━━━━━━━━●━━━[结束]            │   │
│  │   00:01:23.456      00:05:30.789            │   │
│  └─────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────┐   │
│  │  开始: [00:01:23.456]  结束: [00:05:30.789] │   │
│  │  持续: 04:07.333                             │   │
│  └─────────────────────────────────────────────┘   │
│  ┌──────────────────────┬──────────────────────┐   │
│  │  音轨列表 (60%)      │  质量 (40%)          │   │
│  │  ☑ 音轨 1 (中文)    │  [高质量 320kbps ▼]  │   │
│  │  ☑ 音轨 2 (英文)    │                       │   │
│  └──────────────────────┴──────────────────────┘   │
│  ┌─────────────────────────────────────────────┐   │
│  │  提取进度: 45.3% (剩余: 2m 15s)             │   │
│  │  ████████████░░░░░░░░░░░░░░░░░░             │   │
│  └─────────────────────────────────────────────┘   │
│  [━━━━━ 开始提取 ━━━━━]                           │
└─────────────────────────────────────────────────────┘
```

## 3. 技术架构

### 3.1 组件结构

```
HomePage
├── AppBar
│   └── OutputDirectorySelector
├── VideoPlayerWidget
│   └── VideoPlayerController
├── DualSliderProgressBar
│   ├── StartSlider
│   └── EndSlider
├── TimeRangeInputs
│   ├── StartTimeInput
│   └── EndTimeInput
├── Row
│   ├── TrackList (60%)
│   └── QualityDropdown (40%)
├── ExtractionProgress
└── ActionButtons
```

### 3.2 状态管理

```dart
// 新增：VideoPlayerProvider
class VideoPlayerProvider extends ChangeNotifier {
  VideoPlayerController? controller;
  bool isPlaying = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  Duration rangeStart = Duration.zero;
  Duration rangeEnd = Duration.zero;
  bool isDraggingSlider = false;

  Future<void> loadVideo(String path);
  void togglePlayPause();
  void seekTo(Duration position, {bool lowRes = false});
  void setRangeStart(Duration start);
  void setRangeEnd(Duration end);
}

// 更新：ExtractionProvider
class ExtractionProvider extends ChangeNotifier {
  // 移除旧的 TimeRange，使用 VideoPlayerProvider
  final VideoPlayerProvider videoPlayerProvider;

  // 保留原有功能
  List<AudioTrack> tracks;
  QualityPreset preset;
  String outputDirectory;
  // ...
}
```

### 3.3 数据流

```
用户拖拽视频
  ↓
DropZone.onDragDone
  ↓
ExtractionProvider.selectVideoFile
  ↓
VideoPlayerProvider.loadVideo
  ↓
VideoPlayerController.initialize
  ↓
更新 totalDuration
  ↓
初始化滑块范围 (0 到 totalDuration)
```

```
用户拖动开始滑块
  ↓
DualSliderProgressBar.onDragStart
  ↓
VideoPlayerProvider.onSliderDragStart
  ↓
暂停播放 (isPlaying = false)
  ↓
用户拖动滑块
  ↓
DualSliderProgressBar.onDragUpdate
  ↓
VideoPlayerProvider.onSliderDragUpdate
  ↓
节流预览 (200ms)
  ↓
VideoPlayerController.seekTo (低分辨率)
  ↓
更新 currentPosition
  ↓
同步 TimeRangeInputs
```

```
用户修改输入框
  ↓
TimeRangeInputs.onChanged
  ↓
验证时间合法性
  ↓
VideoPlayerProvider.setRangeStart/End
  ↓
更新 DualSliderProgressBar 位置
  ↓
触发预览
```

```
用户点击提取
  ↓
ExtractionProvider.startExtraction
  ↓
获取时间范围 (rangeStart, rangeEnd)
  ↓
构建 FFmpeg 命令
  ↓
AudioExtractor.extractAudio
  ↓
生成文件名 (video_00-01-23-456-00-05-30-789.mp3)
```

## 4. 核心组件设计

### 4.1 VideoPlayerWidget

**职责**：
- 封装 VideoPlayerController 管理视频播放
- 处理点击事件切换播放/暂停状态
- 提供低分辨率预览接口（拖动时调用）
- 显示当前播放位置和视频总时长

**关键属性**：
```dart
class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;
  final Duration currentPosition;
  final bool isPlaying;
  final Function(Duration)? onPositionChanged;
  final Function(bool)? onPlayPauseChanged;
}
```

**视觉设计**：
- 视频区域：16:9 比例，最大高度 400px
- 暂停时：中央播放图标（半透明叠加层）
- 播放时：无图标，底部简洁进度指示器
- 鼠标悬停：显示"点击播放/暂停"提示文本

### 4.2 DualSliderProgressBar

**职责**：
- 渲染双滑块 UI（开始/结束时间）
- 处理滑块拖动逻辑和冲突检测
- 高亮显示选中区域
- 提供拖动事件回调

**关键属性**：
```dart
class DualSliderProgressBar extends StatefulWidget {
  final Duration totalDuration;
  final Duration startTime;
  final Duration endTime;
  final Function(Duration, Duration)? onTimeRangeChanged;
  final Function(Duration)? onSeekPreview;
}
```

**视觉设计**：
- 轨道高度：8px，圆角
- 滑块：圆形，直径 20px（拖动时 24px），主题色
- 选中区域：主题色高亮
- 未选中区域：灰色
- 滑块上方：时间标签（HH:MM:SS）

**交互逻辑**：
- 两个滑块不能交叉（开始时间 < 结束时间）
- 拖动任一滑块时，暂停视频播放
- 拖动过程中触发 onSeekPreview 回调（低分辨率预览）
- 释放滑块时触发 onTimeRangeChanged 回调

### 4.3 TimeRangeInputs

**职责**：
- 提供毫秒级精确的时间输入框
- 实时验证时间合法性
- 与滑块同步更新

**UI 设计**：
```
[ 开始时间 ] [ HH:MM:SS.mmm ]  [ 结束时间 ] [ HH:MM:SS.mmm ]
   持续: 01:23.456
```

- 输入框：等宽字体，右对齐，聚焦时蓝色边框
- 实时验证：非法值显示橙色边框 + 错误提示
- 格式提示：placeholder 显示 "00:00:00.000"

### 4.4 QualityDropdown

**UI 设计**：
```dart
DropdownButton<QualityPreset>(
  items: [
    DropdownMenuItem(value: highQuality, child: Text('高质量 (320 kbps)')),
    DropdownMenuItem(value: standard, child: Text('标准 (192 kbps)')),
    DropdownMenuItem(value: compressed, child: Text('压缩 (128 kbps)')),
  ],
)
```

- 下拉框宽度：180px
- 当前选中项：主题色文本
- 展开时：圆角菜单，阴影效果

### 4.5 OutputDirectorySelector

**菜单结构**：
```
📁 输出目录 ▼
  ├─ 📥 下载目录 (默认)
  ├─ 📄 文档目录
  ├─ 🖥️ 桌面
  ├─ 🎬 影片目录
  └─ ⚙️ 自定义...
```

## 5. 低分辨率预览实现

### 5.1 预览策略

**方案：VideoPlayerController + 智能节流**

```dart
class VideoPlayerProvider extends ChangeNotifier {
  Timer? _previewTimer;

  void onSliderDragStart() {
    isDraggingSlider = true;
    if (isPlaying) pause();
  }

  void onSliderDragUpdate(Duration position) {
    // 节流：200ms 内只触发一次预览
    _previewTimer?.cancel();
    _previewTimer = Timer(const Duration(milliseconds: 200), () {
      controller?.seekTo(position);
    });
  }

  void onSliderDragEnd() {
    isDraggingSlider = false;
    _previewTimer?.cancel();
    // 确保跳转到最终位置
    controller?.seekTo(currentPosition);
  }
}
```

### 5.2 性能优化

- **缩略图缓存**：最近访问的 10 帧缓存在内存中
- **懒加载**：视频首次加载时只初始化，不预解码
- **内存管理**：Provider dispose 时释放视频资源

## 6. 文件命名规则

### 6.1 命名算法

```dart
String generateOutputFileName(String videoPath, TimeRange range) {
  final baseName = path.basenameWithoutExtension(videoPath);

  if (!range.isEnabled ||
      range.startMs == 0 &&
      range.endMs == totalDurationMs) {
    // 完整视频
    return '$baseName.mp3';
  }

  // 片段：将冒号和连字符替换为连字符，避免文件名问题
  final start = TimeRange.formatMs(range.startMs)
      .replaceAll(':', '-')
      .replaceAll('.', '-');
  final end = TimeRange.formatMs(range.endMs)
      .replaceAll(':', '-')
      .replaceAll('.', '-');

  return '${baseName}_$start-$end.mp3';
}
```

### 6.2 示例

**完整视频**：
```
输入：虚拟艺人六六演唱会.mp4
输出：虚拟艺人六六演唱会.mp3
```

**片段提取**：
```
输入：虚拟艺人六六演唱会.mp4
时间：00:01:23.456 - 00:05:30.789
输出：虚拟艺人六六演唱会_00-01-23-456-00-05-30-789.mp3
```

## 7. FFmpeg 集成

### 7.1 命令构建

**片段提取**：
```bash
# 关键：-ss 在 -i 之前（快速定位）
# -t 使用相对时间（从 -ss 位置开始计算的时长）
ffmpeg -ss 00:01:23.456 -i input.mp4 -t 00:04:07.333 \
  -map 0:a:0 -c:a libmp3lame -b:a 320k -y output.mp3
```

**参数说明**：
```dart
final args = <String>[];

if (timeRange.isEnabled) {
  // 开始时间参数（在 -i 之前，快速 seek）
  args.addAll(['-ss', _formatMsForFFmpeg(timeRange.startMs)]);

  // 持续时间参数（相对时间）
  final durationMs = timeRange.endMs - timeRange.startMs;
  args.addAll(['-t', _formatMsForFFmpeg(durationMs)]);
}

// 音频映射和编码
args.addAll([
  '-map', '0:a:$audioIndex',
  '-c:a', 'libmp3lame',
  '-b:a', settings.bitrateParameter,
  '-y',
  outputPath,
]);
```

### 7.2 进度计算修正

```dart
double? _parseProgress(String line, Duration totalDuration) {
  final timeRegex = RegExp(r'time=(\d+):(\d+):(\d+\.\d+)');
  final match = timeRegex.firstMatch(line);

  if (match != null) {
    final currentSeconds = _parseTime(match);

    // 如果是片段提取，基于片段时长计算进度
    if (timeRange.isEnabled) {
      final rangeDuration = timeRange.endMs - timeRange.startMs;
      final progress = currentSeconds / (rangeDuration / 1000);
      return progress.clamp(0.0, 1.0);
    }

    // 完整视频提取
    final progress = currentSeconds / (totalDuration.inSeconds);
    return progress.clamp(0.0, 1.0);
  }
  return null;
}
```

## 8. 错误处理

### 8.1 视频加载错误

**不支持的视频格式**：
```
响应：
- DropZone 显示红色边框
- "不支持的视频格式"提示
- 自动清除（3秒后）
```

**视频文件损坏**：
```
响应：
- VideoPlayerWidget 显示占位图
- "无法加载此视频文件"
- 提供"重新选择"按钮
```

**无音轨视频**：
```
响应：
- TrackList 显示"此视频不包含音轨"
- 禁用"开始提取"按钮
- 播放器仍可播放（无音频预览）
```

### 8.2 时间范围验证

**规则 1：开始时间 < 结束时间**
```
拖动限制：
- 结束滑块不能小于开始滑块
- 最小间隔：1ms
```

**规则 2：不超过视频总时长**
```
输入验证：
- 输入框红色边框
- 自动修正为合法值
```

**规则 3：滑块和输入框同步**
```
双向同步：
- 滑块拖动 → 输入框实时更新（debounced 100ms）
- 输入框修改 → 滑块跳到新位置（失去焦点时验证）
```

## 9. 测试策略

### 9.1 单元测试

```dart
// TimeRange 测试
test('TimeRange file suffix generation', () {
  final range = TimeRange(
    startMs: 83456,  // 00:01:23.456
    endMs: 330789,  // 00:05:30.789
    isEnabled: true,
  );

  expect(range.fileSuffix, '_00-01-23-456-00-05-30-789');
});

// FFmpeg 命令测试
test('FFmpeg args with time range', () {
  final settings = ExtractionSettings(
    timeRange: TimeRange(
      startMs: 60000,  // 00:01:00.000
      endMs: 120000,   // 00:02:00.000
      isEnabled: true,
    ),
  );

  final args = buildFFmpegArgs(settings);

  expect(args, contains('-ss'));
  expect(args, contains('00:01:00.000'));
  expect(args, contains('-t'));
});
```

### 9.2 集成测试

**完整流程测试**：
```
1. 拖拽测试视频 → 加载成功
2. 点击播放 → 视频播放
3. 暂停 → 视频暂停
4. 拖动开始滑块到 00:01:00 → 输入框同步
5. 拖动结束滑块到 00:02:00 → 选中区域高亮
6. 点击提取 → 生成正确文件名
7. 验证输出文件时长为 60 秒
```

### 9.3 性能测试

**视频加载时间**：
- 小视频（< 100MB）：< 2 秒
- 中等视频（100MB-1GB）：< 5 秒
- 大视频（> 1GB）：< 10 秒

**滑块拖动流畅度**：
- 帧率：> 30 FPS
- 预览延迟：< 200ms
- 内存增长：< 50MB

## 10. 实施计划

### 10.1 阶段划分

**阶段 1：基础设施**（1-2天）
- 添加 video_player 依赖
- 创建 VideoPlayerProvider
- 创建组件骨架

**阶段 2：核心功能**（2-3天）
- VideoPlayerWidget 完整实现
- DualSliderProgressBar 交互
- TimeRangeInputs 验证
- 视频加载流程

**阶段 3：UI 改造**（1-2天）
- 移除旧组件
- 创建新布局
- 响应式适配
- 视觉优化

**阶段 4：集成测试**（1-2天）
- FFmpeg 集成
- 性能优化
- 错误场景测试

**阶段 5：文档发布**（1天）
- 更新用户文档
- 更新开发者文档
- 发布准备

**总计：7-11 天**

### 10.2 依赖更新

```yaml
# pubspec.yaml
dependencies:
  # 新增
  video_player: ^2.8.0

  # 保持
  provider: ^6.1.5+1
  desktop_drop: ^0.7.0
  file_selector: ^1.1.0
  path_provider: ^2.1.5
  logger: ^2.6.2
  process_run: ^1.3.1+1
```

### 10.3 文件变更

**新增**：
```
lib/providers/video_player_provider.dart
lib/ui/widgets/video_player_widget.dart
lib/ui/widgets/dual_slider_progress_bar.dart
lib/ui/widgets/time_range_inputs.dart
```

**修改**：
```
lib/providers/extraction_provider.dart
lib/services/audio_extractor.dart
lib/ui/pages/home_page.dart
```

**删除**：
```
lib/ui/widgets/drop_zone.dart (保留文件选择逻辑)
lib/ui/widgets/time_range_selector.dart
lib/ui/widgets/quality_selector.dart
lib/ui/widgets/output_directory_picker.dart
```

### 10.4 回滚计划

**如果出现问题**：
1. VideoPlayerWidget 严重 Bug → 回退到旧 DropZone
2. 性能问题 → 禁用低分辨率预览
3. 兼容性问题 → 添加"经典界面"开关

## 11. 成功标准

✅ 用户可以拖拽视频文件并自动加载到播放器
✅ 点击视频区域可以切换播放/暂停
✅ 拖动滑块可以实时预览视频画面
✅ 滑块和输入框双向同步
✅ 时间范围可以精确到毫秒
✅ 提取的音频文件名包含时间范围
✅ 提取的音频时长与选择的时间范围一致
✅ 界面布局紧凑、美观、易用

## 12. 附录

### 12.1 技术选型对比

| 方案 | 优点 | 缺点 | 选择 |
|------|------|------|------|
| video_player | 官方维护，跨平台 | 性能一般 | ✅ |
| chewie | 功能丰富，UI 完整 | 过于复杂，定制难 | ❌ |
| better_player | 性能好，功能多 | 维护不活跃 | ❌ |

### 12.2 参考资料

- [Flutter Video Player Plugin](https://pub.dev/packages/video_player)
- [FFmpeg Documentation](https://ffmpeg.org/documentation.html)
- [Material Design Guidelines](https://material.io/design)

### 12.3 版本历史

- v1.0.0: 初始版本（拖拽区域 + 音轨选择）
- v2.0.0: 视频预览播放器 + 时间范围选择（本文档）
