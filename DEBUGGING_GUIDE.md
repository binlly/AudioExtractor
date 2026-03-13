# Release 崩溃问题调试指南

## 问题描述

Debug 版本运行正常，但 Release 版本在拖拽视频文件时崩溃。

## 可能的原因

1. **文件访问权限** - Release 应用可能缺少文件读取权限
2. **沙盒限制** - macOS 沙盒可能阻止文件访问
3. **代码签名问题** - Release 构建的签名可能有问题
4. **日志输出** - `debugPrint` 在 Release 模式下不工作

## 已实施的修复

### 1. 增强错误处理

**文件**: `lib/ui/widgets/video_player_widget.dart`

- 添加 try-catch 块包裹拖拽处理
- 检查文件是否存在
- 添加详细的调试日志（使用 `print` 而不是 `debugPrint`）
- 显示友好的错误消息

### 2. 改进视频加载

**文件**: `lib/providers/video_player_provider.dart`

- 添加文件存在性检查
- 使用 `print` 确保在 Release 模式下也能看到日志
- 记录文件大小信息
- 增强异常处理和堆栈跟踪

## 调试步骤

### 1. 使用调试脚本

```bash
chmod +x debug_crash.sh
./debug_crash.sh
```

这个脚本会：
- 检查应用是否运行
- 查找崩溃报告
- 显示系统日志
- 测试文件访问权限
- 检查代码签名

### 2. 直接运行 Release 版本

在终端中直接运行可执行文件以查看实时日志：

```bash
./build/macos/Build/Products/Release/core.app/Contents/MacOS/core
```

### 3. 查看 Console 日志

1. 打开 Console.app
2. 在搜索框输入 "AudioExtractor"
3. 拖拽视频文件到应用
4. 观察控制台输出

### 4. 对比 Debug 和 Release 版本

```bash
# 运行 Debug 版本
flutter run -d macos

# 运行 Release 版本
open build/macos/Build/Products/Release/AudioExtractor.app
```

## 常见问题

### Q1: 应用提示"文件不存在"

**原因**: 可能是文件权限问题或路径问题

**解决**:
```bash
# 检查文件权限
ls -la /path/to/video.mp4

# 确保文件可读
chmod +r /path/to/video.mp4
```

### Q2: 拖拽无反应

**原因**: 可能是拖拽目标没有正确注册

**解决**: 确保拖拽到视频播放器区域，而不是整个窗口

### Q3: 应用直接崩溃

**原因**: 可能是代码签名或沙盒问题

**解决**:
1. 检查 `macos/Runner/Release.entitlements`
2. 确保沙盒已禁用（`com.apple.security.app-sandbox` = `false`）

## 提交崩溃报告

如果问题仍然存在，请提供：

1. **系统信息**:
   ```bash
   sw_vers
   uname -m
   ```

2. **崩溃日志**:
   - Console.app 中的日志
   - 或者 `~/Library/Logs/DiagnosticReports/` 中的 `.crash` 文件

3. **复现步骤**:
   - 详细的操作步骤
   - 使用的视频文件信息

4. **终端输出**:
   ```bash
   ./build/macos/Build/Products/Release/AudioExtractor.app/Contents/MacOS/AudioExtractor
   ```

## 预防措施

### 1. 添加更多日志

在关键位置添加 `print` 语句：

```dart
print('✅ 步骤1完成');
print('📁 文件路径: $path');
print('❌ 错误: $error');
```

### 2. 使用 assert

在 Debug 模式下检查前置条件：

```dart
assert(file.existsSync(), '文件必须存在');
```

### 3. 添加单元测试

为关键功能添加测试：

```dart
test('加载视频文件', () async {
  final provider = VideoPlayerProvider();
  await provider.loadVideo('/path/to/video.mp4');
  expect(provider.isInitialized, true);
});
```

## 下一步

1. ✅ 已添加增强的错误处理
2. ✅ 已添加详细的日志输出
3. ✅ 已创建调试脚本
4. ⏳ 需要用户测试并提供反馈

## 联系方式

如果问题持续存在，请在 GitHub 上提 Issue：
- https://github.com/binlly/AudioExtractor/issues

包含：
- 崩溃报告
- 系统信息
- 复现步骤
- 终端输出
