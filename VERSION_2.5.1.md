# 版本 2.5.1 更新摘要

## 发布日期：2025-03-13

## 🎯 版本概述

这是一个重要的修复和改进版本，主要解决了音频提取失败的问题，并添加了多项用户体验改进。

---

## 🐛 关键修复

### 1. 视频解析失败（影响所有提取功能）

**问题**：加载视频后无法获取音轨信息

**根本原因**：
```dart
// 错误代码
final output = info.getAllProperties();
return {'raw_output': output.toString()};  // Dart Map 格式
```

**解决方案**：
```dart
// 正确代码
import 'dart:convert';
return {'raw_output': jsonEncode(output)};  // 有效 JSON
```

**影响**：修复后所有提取功能恢复正常

---

### 2. FFmpeg 执行失败（退出码：null）

**问题**：点击提取音频后立即失败，提示退出码为 null

**根本原因**：
- 使用 `FFmpegKit.executeAsync()` 异步执行
- `getReturnCode()` 在命令完成前被调用

**解决方案**：
```dart
// 迭代 1：改用 execute()
await FFmpegKit.execute(command);  // ❌ 命令字符串解析错误

// 迭代 2：改用 executeWithArguments()
await FFmpegKit.executeWithArguments(args);  // ✅ 参数数组
```

**改进点**：
- ✅ 使用参数数组而不是命令字符串
- ✅ 自动处理路径中的空格和特殊字符
- ✅ 避免命令解析错误

---

### 3. 路径包含中文/空格导致失败

**问题**：文件名如 `塞尔达-过火.mp4` 无法处理

**解决方案**：
- FFmpeg Kit 会自动处理特殊字符
- 无需手动添加引号
- 支持中文、日文、韩文等多字节字符

---

### 4. 输出目录初始化失败

**问题**：
```
FileSystemException: Creation failed, path='desktop'
(OS Error: Read-only file system, errno=30)
```

**根本原因**：
```dart
// 错误代码
_outputDirectory = '~/Downloads/ExtractAudio';  // ~ 未展开
```

**解决方案**：
```dart
// 正确代码
final homeDir = Platform.environment['HOME'];
if (homeDir == null) {
  throw Exception('无法获取主目录路径');
}
_outputDirectory = '$homeDir/Downloads/ExtractAudio';
```

---

## ✨ 新功能

### 1. 拖拽替换提示

**场景**：当已有视频时，拖动新视频文件

**行为**：
- 显示确认对话框："是否要替换当前视频？"
- 用户选择：
  - **取消** - 保持当前视频
  - **替换** - 加载新视频

**代码实现**：
```dart
if (videoProvider.isInitialized) {
  final shouldReplace = await showDialog<bool>(...);
  if (shouldReplace != true) return;
}
```

---

### 2. 点击选择视频

**场景**：占位符区域

**改进**：
- ✅ 添加点击事件处理
- ✅ 添加"选择文件"按钮
- ✅ 使用 `file_selector` 打开文件选择对话框

**UI 变化**：
```
旧版：拖拽视频文件到这里
      支持 MP4, MKV, AVI, MOV 等格式

新版：拖拽或点击选择视频文件
      支持 MP4, MKV, AVI, MOV 等格式
      [选择文件]  ← 新增按钮
```

---

## 🔄 架构变更

### FFmpeg 服务迁移

| 组件 | 旧版本 | 新版本 |
|------|--------|--------|
| **包名** | `ffmpeg_kit_flutter` | `ffmpeg_kit_flutter_new` |
| **版本** | 6.0.3（已废弃） | 2.0.0（活跃维护） |
| **服务类** | `FFmpegService` | `FFmpegKitService` |
| **API** | `Process.run()` | `FFmpegKit.executeWithArguments()` |
| **依赖** | 外部 FFmpeg | 内置 FFmpeg 库 |

### 文件变更

**新增文件**：
- `lib/services/ffmpeg_kit_service.dart` - FFmpeg Kit 封装
- `FIX_SUMMARY.md` - 修复报告
- `IMPROVEMENTS_SUMMARY.md` - 改进说明
- `FFMPEG_FIX_REPORT.md` - 问题诊断
- `RELEASE_TEST_CHECKLIST.md` - 测试清单

**删除文件**：
- `lib/services/ffmpeg_service.dart` - 旧实现

**修改文件**：
- `lib/services/video_analyzer.dart` - 更新服务引用
- `lib/services/audio_extractor.dart` - 更新服务引用
- `lib/ui/widgets/video_player_widget.dart` - 新增功能
- `lib/providers/extraction_provider.dart` - 修复路径问题
- `pubspec.yaml` - 更新依赖

---

## 📊 应用变化

### 体积变化

| 版本 | 大小 | 说明 |
|------|------|------|
| 旧版本 | ~10MB | 依赖外部 FFmpeg |
| 新版本 | ~99MB | 内置 FFmpeg 库 |

### 架构优势

**旧版本（有问题）**：
```
应用启动 → 调用系统 FFmpeg → 依赖 $PATH → 💥 双击运行崩溃
```

**新版本（已修复）**：
```
应用启动 → 使用内置 FFmpeg → 完全独立 → ✅ 双击运行正常
```

---

## 🎓 技术细节

### API 映射

| 功能 | 旧 API | 新 API |
|------|--------|--------|
| 分析视频 | `Process.run('ffprobe', ...)` | `FFprobeKit.getMediaInformation()` |
| 执行命令 | `Process.start('ffmpeg', ...)` | `FFmpegKit.executeWithArguments()` |
| 取消操作 | `process.kill()` | `FFmpegKit.cancel()` |
| 检查可用性 | 尝试运行命令 | 始终返回 `true` |

### 命令构建

```dart
// ❌ 错误：手动拼接字符串
final command = 'ffmpeg -i "$inputPath" -c:a libmp3lame "$outputPath"';
await FFmpegKit.execute(command);

// ✅ 正确：使用参数数组
final args = ['-i', inputPath, '-c:a', 'libmp3lame', outputPath];
await FFmpegKit.executeWithArguments(args);
```

---

## ✅ 测试验证

### 测试清单

- [x] 视频加载和解析
- [x] 音轨列表显示
- [x] 音频提取成功
- [x] 进度显示正常
- [x] 拖拽替换功能
- [x] 点击选择视频
- [x] 中文文件名
- [x] 路径包含空格
- [x] 输出目录创建
- [x] Release 版本双击运行

### 支持的场景

- ✅ 中文文件名：`塞尔达-过火.mp4`
- ✅ 路径空格：`/Users/username/Desktop/My Video.mp4`
- ✅ 特殊字符：`Video (2024) [Final].mp4`
- ✅ 长路径：`/Users/username/.../很长路径/.../file.mp4`

---

## 📦 构建和分发

### 构建命令

```bash
# Debug 版本
flutter build macos --debug

# Release 版本
flutter build macos --release
```

### 输出路径

```
build/macos/Build/Products/Debug/AudioExtractor.app
build/macos/Build/Products/Release/AudioExtractor.app
```

### 架构支持

- Universal Binary (x86_64 + arm64)
- 支持 Intel 和 Apple Silicon Mac

---

## 🐛 已知问题

### 无

所有已知问题均已修复。

---

## 📝 升级建议

### 对于用户

1. **下载新版本** - 替换旧版本应用
2. **无需安装 FFmpeg** - 内置 FFmpeg 库
3. **直接使用** - 双击运行即可

### 对于开发者

1. **更新依赖**：
   ```bash
   flutter pub get
   ```

2. **迁移代码**：
   - 将 `FFmpegService` 替换为 `FFmpegKitService`
   - 更新导入语句
   - 使用新的 API

3. **测试功能**：
   - 验证视频解析
   - 验证音频提取
   - 验证错误处理

---

## 🙏 致谢

感谢 `ffmpeg_kit_flutter_new` 项目维护者，提供了活跃维护的 FFmpeg Kit fork。

---

## 📞 支持

遇到问题？
- 查看 [README.md](README.md) 常见问题部分
- 阅读 [FIX_SUMMARY.md](FIX_SUMMARY.md) 了解修复详情
- 提交 [GitHub Issue](https://github.com/binlly/AudioExtractor/issues)

---

**版本**: 2.5.1
**发布日期**: 2025-03-13
**Flutter**: 3.11+
**Dart**: 3.11+
**Platform**: macOS 11+
