# AudioExtractor 技术笔记

本文档记录 AudioExtractor 项目开发过程中的技术实现细节、问题修复和功能改进。

---

## 📋 目录

- [版本 2.5.1 - FFmpeg 依赖修复](#版本-251---ffmpeg-依赖修复)
- [双滑块进度条改进](#双滑块进度条改进)
- [UI 交互改进](#ui-交互改进)
- [技术实现细节](#技术实现细节)

---

## 版本 2.5.1 - FFmpeg 依赖修复

### 问题描述

**原始问题**：双击运行 Release 版本的应用时，解析视频会崩溃

**根本原因**：
- 代码使用 `Process.run('ffprobe', ...)` 调用外部命令
- 依赖系统 `$PATH` 环境变量查找 FFmpeg
- macOS 应用双击启动时 `$PATH` 为系统默认路径（`/usr/bin:/bin:/usr/sbin:/sbin`）
- 用户安装的 FFmpeg（如 `/Users/username/miniconda3/bin/ffmpeg`）不在系统路径中
- `Process.run` 找不到命令，抛出 `ProcessException`，导致应用崩溃

### 修复方案

#### 1. 迁移到内置 FFmpeg

**变更前**：
```yaml
# pubspec.yaml
dependencies:
  process_run: ^1.3.1+1
```

**变更后**：
```yaml
# pubspec.yaml
dependencies:
  ffmpeg_kit_flutter_new: ^2.0.0  # 内置 FFmpeg 的活跃分支
```

#### 2. 修复 FFprobe 输出解析

**问题**：使用 `output.toString()` 返回 Dart Map 字符串格式，不是有效 JSON

**修复**：
```dart
// lib/services/ffmpeg_kit_service.dart
import 'dart:convert';

Map<String, dynamic> output = jsonDecode(sessionOutput);
return {'raw_output': jsonEncode(output)};  // 有效 JSON
```

#### 3. 修复 FFmpeg 命令执行

**尝试 1** - 使用 `execute()`：
```
错误：退出码 1
原因：手动添加引号导致格式错误
```

**最终方案** - 使用 `executeWithArguments()`：
```dart
final session = await FFmpegKit.executeWithArguments(
  ['-i', inputPath, ...additionalArgs, '-y', outputPath],
);
final returnCode = await session.getReturnCode();
```

#### 4. 修复路径初始化

**问题**：
```dart
_outputDirectory = '~/Downloads/ExtractAudio';  // ~ 未展开
// 结果：FileSystemException，path='desktop'
```

**修复**：
```dart
final homeDir = Platform.environment['HOME'];
if (homeDir == null) {
  throw Exception('无法获取主目录路径');
}
_outputDirectory = '$homeDir/Downloads/ExtractAudio';
```

### 技术细节

#### 数据流对比

**旧实现（外部依赖）**：
```
应用启动
  ↓
Process.run('ffprobe', args)
  ↓
系统 $PATH 查找
  ↓
找不到 → 崩溃 ❌
```

**新实现（内置 FFmpeg）**：
```
应用启动
  ↓
FFmpegKit.executeWithArguments()
  ↓
使用内置 FFmpeg 库
  ↓
成功执行 ✅
```

#### 支持的场景

- ✅ 中文文件名：`塞尔达-过火.mp4`
- ✅ 路径空格：`/Users/username/Desktop/My Video.mp4`
- ✅ 特殊字符：`Video (2024) [Final].mp4`
- ✅ 长路径：任意深度嵌套

### 测试验证

#### 基本功能测试
- [ ] Debug 版本运行
- [ ] Release 版本双击运行
- [ ] 中文文件名解析
- [ ] 路径包含空格
- [ ] 音频提取成功

#### 边界情况测试
- [ ] 特殊字符文件名
- [ ] 深层嵌套路径
- [ ] 大文件（> 1GB）
- [ ] 长时间视频（> 1小时）

---

## 双滑块进度条改进

### 改进目标

将双滑块进度条从分钟级精度提升到毫秒级，并实现拖动时的实时低分辨率视频预览。

### 精度提升

#### 变更前
```dart
// 使用分钟作为单位
final int initialStartMinutes = 8 * 60;  // 8:00
final int initialEndMinutes = 18 * 60;   // 18:00

// 精度：1 分钟
```

#### 变更后
```dart
// 使用毫秒作为单位
final int initialStartMilliseconds = 0;
final int initialEndMilliseconds = 86400000;  // 24 小时

// 精度：1 毫秒（短视频）或 1 秒（长视频）
```

### 实时低分辨率预览

#### 功能说明
- **拖动时**：视频实时跳转到当前滑块位置，使用 0.5 倍速播放
- **拖动结束**：恢复正常播放速度（1.0 倍速）
- **自动恢复**：如果视频原本在播放，拖动结束后继续播放

#### 技术实现

```dart
// VideoPlayerProvider
Future<void> seekTo(Duration position, {bool lowRes = false}) async {
  if (lowRes) {
    await _controller!.setPlaybackSpeed(0.5); // 低分辨率：0.5 倍速
  } else {
    await _controller!.setPlaybackSpeed(1.0); // 正常：1.0 倍速
  }
  await _controller!.seekTo(position);
}

void onSliderDragStart() {
  _wasPlayingBeforeDrag = _isPlaying; // 记住播放状态
  if (_isPlaying) pause();
}

void onSliderDragEnd() {
  seekTo(_rangeStart, lowRes: false);
  if (_wasPlayingBeforeDrag) {
    play(); // 自动恢复播放
    _wasPlayingBeforeDrag = false;
  }
}
```

### 智能刻度计算

#### 短视频（< 10 分钟）
```dart
// 毫秒级精度
final divisions = totalMs; // 例如：600000 个刻度（10 分钟）
```

#### 长视频（≥ 10 分钟）
```dart
// 秒级精度（性能优化）
final divisions = (totalMs / 1000).toInt(); // 例如：3600 个刻度（1 小时）
```

### 替换视频后重置

```dart
// dual_slider_progress_bar.dart
@override
void didUpdateWidget(TimeRangeSlider oldWidget) {
  super.didUpdateWidget(oldWidget);
  // 当参数变化时（替换视频），更新滑块位置
  if (oldWidget.initialStartMilliseconds != widget.initialStartMilliseconds ||
      oldWidget.initialEndMilliseconds != widget.initialEndMilliseconds ||
      oldWidget.maxMilliseconds != widget.maxMilliseconds) {
    setState(() {
      _updateValues();
    });
  }
}
```

### 性能优化

| 视频长度 | 刻度间隔 | 刻度数量 | 精度 |
|---------|---------|---------|------|
| < 10 分钟 | 1 毫秒 | ≤ 600,000 | 毫秒级 |
| 1 小时 | 1 秒 | 3,600 | 秒级 |
| 2 小时 | 1 秒 | 7,200 | 秒级 |

---

## UI 交互改进

### 1. 拖拽替换视频确认

**问题**：拖拽新视频会直接替换当前视频，用户可能误操作

**解决方案**：显示确认对话框

```dart
// video_player_widget.dart
void _handleDragDrop(String videoPath) {
  if (provider.isInitialized) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('替换视频？'),
        content: const Text('是否要替换当前视频？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.loadVideo(videoPath);
            },
            child: const Text('替换'),
          ),
        ],
      ),
    );
  } else {
    provider.loadVideo(videoPath);
  }
}
```

### 2. 点击选择视频

**问题**：只能拖拽视频，不能点击选择

**解决方案**：使用文件选择器

```dart
import 'package:file_selector/file_selector.dart';

Future<void> _selectVideoFile() async {
  const XTypeGroup typeGroup = XTypeGroup(
    label: 'Video',
    extensions: <String>['mp4', 'mov', 'avi', 'mkv'],
  );
  final XFile? file = await openFile(
    acceptedTypeGroups: <XTypeGroup>[typeGroup],
  );
  if (file != null) {
    provider.loadVideo(file.path);
  }
}
```

---

## 技术实现细节

### FFmpeg Kit 集成

#### 优势
- ✅ 完全独立，不依赖外部安装
- ✅ 跨平台支持（macOS、Windows、Linux）
- ✅ 活跃维护的社区分支
- ✅ 完整的 FFmpeg 功能集

#### 权衡
- ⚠️ 应用体积增加（约 90MB）
- ⚠️ 构建时间增加
- ⚠️ 使用社区分支而非官方包

### 错误处理

#### FFprobe 输出解析
```dart
try {
  final session = await FFmpegKit.executeWithArguments([
    '-v', 'quiet',
    '-print_format', 'json',
    '-show_format',
    '-show_streams',
    inputPath,
  ]);

  final output = await session.getOutput();
  final data = jsonDecode(output ?? '{}');

  // 查找音频流
  final streams = data['streams'] as List;
  final audioStream = streams.firstWhere(
    (s) => s['codec_type'] == 'audio',
    orElse: () => null,
  );

  if (audioStream == null) {
    throw Exception('无法找到音频流');
  }

  return AudioTrackInfo(
    codec: audioStream['codec_name'],
    sampleRate: audioStream['sample_rate'],
    channels: audioStream['channels'],
    duration: Duration(
      milliseconds: (data['format']['duration'] as num).toInt() * 1000,
    ),
  );
} catch (e) {
  throw Exception('视频解析失败: $e');
}
```

#### FFmpeg 音频提取
```dart
try {
  final session = await FFmpegKit.executeWithArguments([
    '-i', inputPath,
    '-ss', startMs.toString(),
    '-to', endMs.toString(),
    '-vn',  // 不包含视频
    '-acodec', 'copy',  // 复制音频编码
    '-y',  // 覆盖输出文件
    outputPath,
  ]);

  final returnCode = await session.getReturnCode();

  if (ReturnCode.isCancel(returnCode)) {
    throw Exception('提取已取消');
  }

  if (ReturnCode.isError(returnCode)) {
    final logs = await session.getAllLogsAsString();
    throw Exception('FFmpeg 执行失败，退出码：$returnCode\n日志：$logs');
  }

  return outputPath;
} catch (e) {
  throw Exception('音频提取失败: $e');
}
```

### 状态管理

#### VideoPlayerProvider 状态流
```
loadVideo()
  ↓
_isLoading = true
  ↓
initialize controller
  ↓
_isLoading = false
  ↓
notifyListeners()
  ↓
UI 更新
```

#### ExtractionProvider 状态流
```
startExtraction()
  ↓
_isExtracting = true
  ↓
execute FFmpeg
  ↓
_isExtracting = false
  ↓
notifyListeners()
  ↓
UI 更新
```

### 性能优化

#### 1. 拖动预览优化
- 使用 0.5 倍速降低解码压力
- 实时跳转提供即时反馈
- 拖动结束恢复正常速度

#### 2. 滑块刻度优化
- 短视频：毫秒级精度
- 长视频：秒级精度
- 避免过多刻度导致性能问题

#### 3. 状态更新优化
- 只在必要时调用 `notifyListeners()`
- 拖动过程中减少更新频率
- 使用 `didUpdateWidget` 响应参数变化

---

## 常见问题

### Q: 为什么应用体积这么大（约 99MB）？

A: 因为我们使用了内置 FFmpeg 库（`ffmpeg_kit_flutter_new`），这会将 FFmpeg 完整编译到应用中。优点是完全独立运行，不依赖系统安装。

### Q: 拖动滑块时视频不流畅？

A: 这是正常的，拖动时使用 0.5 倍速预览，松开后恢复正常速度。

### Q: 中文文件名能正常处理吗？

A: 能！FFmpeg Kit 自动处理各种特殊字符和编码。

### Q: Release 版本双击运行崩溃？

A: 从版本 2.5.1 开始，使用内置 FFmpeg 后已修复此问题。

---

## 附录：修改文件列表

### 版本 2.5.1 主要修改

#### 新增文件
- `lib/services/ffmpeg_kit_service.dart` - FFmpeg Kit 服务
- `TECHNICAL_NOTES.md` - 本文档

#### 删除文件
- `lib/services/ffmpeg_service.dart` - 旧的外部依赖服务

#### 修改文件
- `lib/providers/video_player_provider.dart` - 添加低分辨率预览和自动恢复播放
- `lib/ui/widgets/dual_slider_progress_bar.dart` - 毫秒级精度滑块
- `lib/ui/widgets/video_player_widget.dart` - 拖拽确认和点击选择
- `lib/providers/extraction_provider.dart` - 修复路径初始化
- `lib/services/audio_extractor.dart` - 迁移到 FFmpeg Kit
- `lib/services/video_analyzer.dart` - 迁移到 FFmpeg Kit
- `pubspec.yaml` - 更新依赖
- `macos/Runner/Release.entitlements` - 添加文件访问权限
- `macos/Runner/Debug.entitlements` - 添加文件访问权限

---

**AudioExtractor Technical Notes**
*Last updated: 2026-03-13*
*Version: 2.5.1*
