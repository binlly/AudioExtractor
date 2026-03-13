# 🎵 从视频中提取喜欢的音乐，我用AI开发了这款免费开源软件！

> 告别繁琐的命令行操作，一款优雅的 macOS（未来支持Windows、Linux、Android和iOS） 音频提取工具内置ffmpeg，不依赖设备环境，小白也能轻松提取。

---

## 为什么需要音频提取？

你是否遇到过这样的场景：

- 🎬 **视频学习**：在线课程视频太大，只想提取音频在通勤时听
- 🎵 **音乐收藏**：MV 太占空间，只想要音频文件
- 📻 **播客制作**：需要从视频素材中提取高质量音轨
- 🎙️ **语音转写**：提取音频用于语音识别或字幕制作

传统的方法要么使用**在线转换工具**（上传下载慢、有广告、文件大小限制），要么使用**命令行 FFmpeg**（需要技术背景、操作繁琐），要么使用付费专业软件，除了学习成本还需要财力支持。但现在什么年代了？早就不是古法编程的世代的好吗？技术平权，人人有份！说干就干，但是本着授人以渔，我会模拟毕业生、小白、入门者等等新手，着重记录我自己的开发过程，中间遇到的坑，以及我作为一个专业程序员的想法。

---

## 第一章：萌生想法 - 我真的需要一个工具

事情是这样的。上周我在刷 B 站，看到一个超棒的音乐现场视频，那种氛围感太强了，但我只想要音频部分，可以放到手机里循环播放。

我第一反应是：这不简单吗？我学过编程啊！

于是打开终端，熟练地输入：
```bash
ffmpeg -i concert.mp4 -vn -acodec copy concert.aac
```

结果提示：`command not found: ffmpeg`

哦对，我忘了装 FFmpeg。那就装呗：
```bash
brew install ffmpeg
```

等待... 安装... 终于好了。

再次运行，成功了！但是... 等等，我只想要 2:30 到 5:20 那一段精彩的吉他 solo 怎么办？

又要查文档，又要算时间：
```bash
ffmpeg -i concert.mp4 -ss 00:02:30 -to 00:05:20 -vn -acodec copy guitar_solo.aac
```

成功了！但我突然想到：**如果是我的妈妈、我的朋友，他们怎么办？**

他们不会用命令行，也不想学。为什么不做一个**简单的图形界面工具**呢？

---

## 第二章：技术选型 - 我只会一点点编程怎么办？

说实话，我编程基础一般。会一点 Python，懂一点点前端，但对移动开发完全陌生。

我开始了技术选型的痛苦历程：

### 方案一：Electron（JavaScript）
❌ **放弃原因**：
- 打包后应用太大了（几百 MB）
- 我对 JavaScript 不太熟悉
- 感觉太"重"了

### 方案二：Python + Tkinter
❌ **放弃原因**：
- 界面太丑了（不好意思）
- 打包成 .app 也很麻烦
- 分发给别人不方便

### 方案三：Flutter
✅ **最终选择**：
- **语言简单**：Dart 语言，类似 Java/JavaScript，学起来快
- **界面漂亮**：Material Design 3，自带好看的组件
- **一次编写，到处运行**：虽然现在只做 macOS，但理论上未来可以支持 Windows、Linux、Android、iOS
- **打包简单**：一条命令搞定
- **社区活跃**：遇到问题容易找到答案

**所以我决定：用 Flutter + macOS 开发！**

---

## 第三章：第一个版本 - 只要能跑就行

### 3.1 环境搭建的坑

安装 Flutter 还算顺利，但我遇到了第一个坑：

**问题**：`flutter doctor` 提示 macOS 没有安装
**解决**：需要运行 `flutter create --platforms=macos .`
**耗时**：30 分钟 Google + Stack Overflow

### 3.2 最简单的界面

我的第一个目标：**做一个能选择的界面**

```dart
// 我的第一个 Flutter 代码（简化版）
TextField(
  decoration: InputDecoration(
    labelText: '输入视频路径',
  ),
)
ElevatedButton(
  onPressed: () {
    // TODO: 调用 FFmpeg
  },
  child: Text('提取音频'),
)
```

**📸 [截图：第一个版本的界面 - 只有输入框和按钮]**

看起来很简陋，但能运行！我已经很激动了。

### 3.3 调用 FFmpeg 的第一个坑

我找到了一个叫 `process_run` 的包，可以调用系统命令：

```dart
import 'package:process_run/shell_run.dart';

Future<void> extractAudio() async {
  await run('ffmpeg', [
    '-i', videoPath,
    '-ss', startTime,
    '-to', endTime,
    '-vn',
    '-acodec', 'copy',
    outputPath,
  ]);
}
```

**第一次运行成功！** 我提取了一个测试视频的音频，激动得差点跳起来。

但是... 我很快就遇到了更大的问题。

---

## 第四章：第一个重大坑 - 双击运行崩溃

### 4.1 问题发现

我用 `flutter run` 开发时一切正常，但是当我构建 Release 版本，双击 .app 文件时...

**崩溃了！** 💥

没有任何提示，就是直接退出。

### 4.2 问题定位

我开始了漫长的调试过程：

**第一步：查看崩溃报告**
```bash
# macOS 会生成崩溃报告
~/Library/Logs/DiagnosticReports/AudioExtractor*.crash
```

找到了关键信息：
```
Exception Type: EXC_CRASH (SIGABRT)
Exception Codes: 0x0000000000000000, 0x0000000000000000
Termination Reason: Namespace SIGNAL, Code 6 Abort trap: 6
```

还是看不懂... 😭

**第二步：添加日志**
```dart
try {
  await run('ffmpeg', args);
  print('✅ FFmpeg 执行成功');
} catch (e) {
  print('❌ FFmpeg 执行失败: $e');
}
```

发现是找不到 `ffmpeg` 命令！

**第三步：理解问题**

经过大量搜索，我理解了：

- `flutter run` 时，应用继承了终端的环境变量，包括 `$PATH`
- 双击 .app 运行时，macOS 只给应用系统默认的 `$PATH`：
  ```
  /usr/bin:/bin:/usr/sbin:/sbin
  ```
- 我通过 `brew install ffmpeg` 安装的 FFmpeg 在 `/usr/local/bin`，**不在默认路径里**！

所以：开发时能跑，双击运行就崩！

### 4.3 解决方案

我找到了两个方向：

**方案 A：硬编码 FFmpeg 路径**
```dart
final ffmpegPath = '/usr/local/bin/ffmpeg'; // ❌ 不可行
```
- 不同电脑路径不同
- 用户需要自己安装 FFmpeg
- 体验太差

**方案 B：使用内置 FFmpeg 的包**
```dart
// 使用 ffmpeg_kit_flutter_new
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';

await FFmpegKit.execute('-i video.mp4 -vn audio.aac');
```
- FFmpeg 编译在应用内部
- 不依赖外部安装
- 包大小会增加 90MB

**我选择了方案 B**！

虽然应用变大了，但用户体验更好：
- ✅ 开箱即用
- ✅ 不需要任何配置
- ✅ 分发方便

---

## 第五章：第二个坑 - FFprobe 输出解析

### 5.1 功能需求

我想显示视频信息：
- 总时长
- 音轨列表
- 编码格式

### 5.2 遇到问题

使用 FFprobe 获取视频信息：
```dart
final session = await FFmpegKit.execute(
  'ffprobe -v quiet -print_format json -show_format video.mp4'
);
final output = await session.getOutput();
print(output); // 输出 JSON 字符串
```

但我解析时一直出错：
```dart
final data = jsonDecode(output); // ❌ 报错！
```

错误信息：
```
FormatException: Unexpected character
```

### 5.3 问题根源

我打印了原始输出：
```dart
print('原始输出类型: ${output.runtimeType}'); // String
print('原始输出: $output');
```

发现输出是：
```
{
  "streams": [...],
  "format": {...}
}  // 后面有很多空格和换行
```

**问题**：`FFmpegKit.execute()` 返回的不是纯 JSON，而是带了很多额外信息的字符串！

### 5.4 解决方案

经过大量试验，我发现应该用 `executeWithArguments`：
```dart
final session = await FFmpegKit.executeWithArguments([
  '-v', 'quiet',
  '-print_format', 'json',
  '-show_format',
  '-show_streams',
  videoPath,
]);

final output = await session.getOutput();
final data = jsonDecode(output); // ✅ 成功！
```

**关键发现**：
- `execute()` - 执行命令字符串，输出包含调试信息
- `executeWithArguments()` - 执行参数数组，输出纯净

---

## 第六章：第三个坑 - JSON 输出格式

### 6.1 又一个解析问题

即使解决了上面的问题，还是报错：
```dart
final streams = data['streams']; // ❌ TypeError
```

### 6.2 深入调试

我打印了类型：
```dart
print('data 类型: ${data.runtimeType}'); // _InternalLinkedHashMap<String, dynamic>
print('streams: ${data["streams"]}'); // null
```

**发现问题**：`output.toString()` 和 `jsonEncode(output)` 不一样！

```dart
// 错误方式
final output = await session.getOutput();
final data = jsonDecode(output); // ❌ output 已经是 Map，不是 JSON 字符串

// 正确方式
final output = await session.getOutput();
final jsonData = jsonEncode(output); // 先编码
final data = jsonDecode(jsonData); // 再解析
```

**等等，这不对啊！**

我又查了很多文档，终于发现：
- `session.getOutput()` 返回的是 `String?`
- 但这个 String 是 FFmpeg 的日志输出，不是 JSON
- 要获取 JSON，应该用 `session.getAllLogsAsString()` + 过滤

**最终正确方式**：
```dart
final session = await FFmpegKit.executeWithArguments([...]);
final output = await session.getOutput();

// 关键：直接解析，不需要再次 jsonDecode
final data = jsonDecode(output!); // output 就是纯 JSON 字符串
```

**我之前的错误**：文档看错了，混淆了不同的 API。

---

## 第七章：界面进化 - 从丑到美

### 7.1 第一个能用的版本

**📸 [截图：第一个可用版本 - 简陋但能用]**

功能：
- 输入视频路径
- 输入开始时间
- 输入结束时间
- 点击提取

**问题**：
- ❌ 没有视频预览
- ❌ 不知道选择的是哪一段
- ❌ 时间输入太麻烦

### 7.2 添加视频预览

我找到了 `video_player` 包：

```dart
VideoPlayerController _controller;
File _videoFile;

void loadVideo(String path) {
  _videoFile = File(path);
  _controller = VideoPlayerController.file(_videoFile);
  _controller.initialize();
  setState(() {});
}

@override
Widget build(BuildContext context) {
  return VideoPlayer(_controller);
}
```

**📸 [截图：添加视频预览后的界面]**

现在可以：
- ✅ 看到视频内容
- ✅ 播放/暂停
- ✅ 进度条显示

**问题**：
- ❌ 还是无法精确选择范围
- ❌ 进度条不支持双滑块

### 7.3 双滑块时间轴

这是最花时间的部分！

我需要：一个有两个滑块的进度条
- 左滑块：开始时间
- 右滑块：结束时间

**方案一：使用第三方包**

找到了 `range_slider` 包，但...
- 只支持数值，不支持时间
- 样式不好定制

**方案二：自己写**

我参考了 Flutter 的 `Slider` 源码，写了三天...

最终发现：**Flutter 3.12+ 自带 `RangeSlider`！**

```dart
RangeSlider(
  values: RangeValues(_start, _end),
  min: 0.0,
  max: _controller.value.duration.inSeconds.toDouble(),
  labels: RangeLabels(
    _formatTime(_start),
    _formatTime(_end),
  ),
  onChanged: (values) {
    setState(() {
      _start = values.start;
      _end = values.end;
    });
  },
)
```

**📸 [截图：最终的双滑块界面]**

完美！

---

## 第八章：用户体验优化 - 细节决定成败

### 8.1 拖拽加载

每次都要点击"选择文件"太麻烦了。

我找到了 `desktop_drop` 包：
```dart
DropTarget(
  onDragEntered: (details) {
    setState(() => _dragging = true);
  },
  onDragExited: (details) {
    setState(() => _dragging = false);
  },
  onDragDone: (details) {
    final file = details.files.first;
    loadVideo(file.path);
  },
  child: _dragging ? Container(color: Colors.blue) : VideoPlayer(),
)
```

**📸 [截图：拖拽视频到应用窗口]**

现在直接拖拽视频文件到窗口就能加载！

### 8.2 智能文件命名

提取的音频文件名应该包含时间信息，方便管理：
```dart
String generateFileName(String videoName, Duration start, Duration end) {
  final baseName = videoName.replaceAll(RegExp(r'\.\w+$'), '');
  final startStr = _formatDuration(start);
  final endStr = _formatDuration(end);
  return '${baseName}_$startStr-$endStr.m4a';
}

// 输入：concert.mp4, 00:02:30, 00:05:20
// 输出：concert_02m30s-05m20s.m4a
```

### 8.3 实时预览 - 最大的亮点

这是我最骄傲的功能！

**问题**：拖动滑块时，不知道选择的是哪一段

**解决方案**：滑块拖动时，视频实时跳转
```dart
RangeSlider(
  onChanged: (values) {
    // 实时跳转视频
    _controller.seekTo(Duration(seconds: values.start.toInt()));
  },
  onChangeEnd: (values) {
    // 拖动结束，恢复正常播放
    _controller.setPlaybackSpeed(1.0);
  },
)
```

**性能优化**：拖动时用 0.5 倍速，减少卡顿
```dart
Future<void> seekTo(Duration position, {bool lowRes = false}) async {
  if (lowRes) {
    await _controller.setPlaybackSpeed(0.5); // 低速预览
  }
  await _controller.seekTo(position);
}
```

**📸 [截图：拖动滑块实时预览视频]**

现在拖动滑块时，视频会流畅地跳转到对应位置，太爽了！

### 8.4 键盘快捷键

作为键盘党，必须支持快捷键：
```dart
KeyboardHandler(
  onKey: (event) {
    if (event.logicalKey == LogicalKeyboardKey.space) {
      togglePlayPause();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      seekRelative(-5.seconds);
    }
    // ...
  },
  child: VideoPlayer(),
)
```

**支持的快捷键**：
- `空格`：播放/暂停
- `←` `→`：快退/快进 5 秒
- `Shift + ←` `→`：单帧后退/前进
- `R`：从头播放

---

## 第九章：最后的打磨 - 专业感

### 9.1 Material Design 3

升级到 Material Design 3，界面瞬间提升：
```dart
ThemeData(
  useMaterial3: true,
  colorSchemeSeed: Colors.blue,
)
```

**📸 [截图：Material Design 3 界面]**

圆角、阴影、配色，全部现代化！

### 9.2 错误处理

完善的错误提示：
```dart
try {
  await extractAudio();
} on FileSystemException catch (e) {
  showError('文件访问失败', '请检查文件路径和权限');
} on FormatException catch (e) {
  showError('视频格式不支持', '请尝试其他视频文件');
} catch (e) {
  showError('未知错误', e.toString());
}
```

### 9.3 进度显示

提取时显示实时进度：
```dart
FFmpegKit.executeWithArguments([...]).then((session) {
  session.getOutput().then((output) {
    // 解析进度：Duration: 00:00:15.00
    final progress = parseProgress(output);
    setState(() => _progress = progress);
  });
});
```

**📸 [截图：提取进度界面]**

---

## 第十章：发布开源 - 分享给世界

### 10.1 为什么要开源？

开发这个工具的过程中，我学到了太多东西：
- Flutter 开发
- FFmpeg 使用
- 用户体验设计
- 问题调试方法

**如果这些经验只属于我一个人，太浪费了！**

所以我决定：
- ✅ 开源所有代码
- ✅ 写详细的文档
- ✅ 欢迎大家贡献

### 10.2 开源不只是代码

我不仅开源了代码，还写了：
- **README.md**：项目介绍、功能特性、使用指南
- **TECHNICAL_NOTES.md**：技术实现细节、问题解决方案
- **CHANGELOG.md**：版本历史
- **CONTRIBUTING.md**：贡献指南

**希望别人能从我的经验中学习，少走弯路。**

### 10.3 收到的反馈

发布后，收到了一些反馈：

> "太棒了！我一直在找这样的工具，简单好用！"
> —— 一个普通用户

> "代码很规范，学到了很多 Flutter 技巧！"
> —— 一个开发者

> "能加一个批量处理功能吗？"
> —— 一个功能建议

**这些反馈让我觉得，这一切都值得！**

---

## 第十一章：技术平权 - 人人都有创造的权利

### 11.1 我不是专业程序员

说实话，我：
- ❌ 不是计算机专业
- ❌ 没在大厂工作过
- ❌ 没做过大型项目

但我：
- ✅ 有想法
- ✅ 愿意学
- ✅ 不怕遇到问题
- ✅ 会用 AI 辅助

**这，就足够了！**

### 11.2 AI 改变了一切

这个项目，我有 70% 的代码是 AI 帮忙写的：
- 遇到错误 → 问 AI
- 不知道用什么包 → 问 AI
- 想要实现某个功能 → 问 AI

**AI 不是让我变懒，而是让我学得更快。**

传统学习方式：
- 遇到问题 → 搜索 → 看文档 → 试验 → 失败 → 再搜索
- **耗时：几小时到几天**

AI 辅助学习：
- 遇到问题 → 问 AI → 得到答案 → 理解 → 应用
- **耗时：几分钟到几小时**

### 11.3 技术平权的时代

以前，做软件需要：
- ✅ 专业背景
- ✅ 多年经验
- ✅ 团队支持

现在，只需要：
- ✅ 一个想法
- ✅ 基础编程知识
- ✅ AI 辅助
- ✅ 持续学习

**门槛降低了，但可能性无限扩大了！**

---

## 第十二章：人人都能创造的五个故事

### 故事一：老师的自动化工具

我朋友是老师，每天要处理大量学生作业。

她不懂编程，但用 AI + 低代码平台，做了一个：
- 自动批改选择题
- 生成成绩统计
- 发送邮件通知

**节省了每天 2 小时的重复工作！**

### 故事二：妈妈的餐厅系统

我妈妈开了一家小餐厅。

她不会编程，但用：
- Excel 宏
- AI 辅助写脚本
- 简单的表单工具

做了一个：
- 订单管理系统
- 库存预警
- 营收报表

**小餐厅也能有数字化管理！**

### 故事三：学生的科研工具

我表弟是研究生，需要处理大量实验数据。

他学了 3 个月 Python + AI 辅助，做了：
- 数据自动分析
- 图表自动生成
- 报告自动撰写

**科研效率提升 10 倍！**

### 故事四：大爷的智能相册

我邻居大爷，70 岁了，退休后想整理老照片。

他学了智能手机操作 + AI 工具，做了：
- 照片自动分类
- 人脸识别标签
- 生成电子相册

**晚年生活更丰富了！**

### 故事五：我的 AudioExtractor

这就是我：一个普通用户，有了想法，用 AI + 学习，做了一个：

- 优雅的界面
- 完善的功能
- 专业的体验

**从想法到产品，只用了 2 个月！**

---

## 第十三章：未来的无限可能

### 13.1 我的 AudioExtractor 还能做什么？

现在的功能只是开始，未来计划：
- [ ] 批量处理（一次处理多个视频）
- [ ] 更多格式（FLAC、OGG、WAV）
- [ ] 音频编辑（剪切、合并、混音）
- [ ] Windows/Linux 版本
- [ ] 移动端版本

### 13.2 你想创造什么？

不要觉得自己做不到！

想做的工具？
- 痛点就是机会
- 从小功能开始
- 迭代优化

想做的游戏？
- 不要一上来就 3A 大作
- 从小游戏开始
- 逐步复杂化

想做的平台？
- 不要一上来就想做平台
- 从一个工具开始
- 慢慢扩展生态

### 13.3 开始你的创造之旅

**第一步：找到痛点**
- 什么让你烦恼？
- 什么可以更好？
- 什么被忽略了？

**第二步：学习基础**
- 选一个技术栈（推荐 Flutter + AI）
- 跟着教程做第一个项目
- 不要怕犯错误

**第三步：持续迭代**
- 先做能用的版本
- 收集反馈
- 不断改进

**第四步：分享给世界**
- 开源代码
- 写下经验
- 帮助更多人

---

## 结语：技术平权，人人有份

几个月前，我还只是一个想要提取音频的普通用户。

现在，我：
- ✅ 做了一个能用的工具
- ✅ 学会了 Flutter 开发
- ✅ 理解了 FFmpeg 原理
- ✅ 开源帮助了别人
- ✅ 写下了这篇文章

**如果我能做到，你也能！**

这不是关于技术，而是关于：
- 想法
- 行动
- 学习
- 分享

**技术平权的时代，人人都有创造的权利！**

不要等待，不要犹豫。

**你的想法，值得被实现。**

**你的创造，值得被世界看到。**

**现在就开始吧！** 🚀

---

## 📦 试试我做的工具

**AudioExtractor** - 优雅的视频音频提取工具

- ✅ 零配置开箱即用
- ✅ 视频预览 + 精确选择
- ✅ 完全免费开源
- ✅ macOS 11+

**👉 [GitHub 仓库](https://github.com/binlly/AudioExtractor) 👈**

**Star** ⭐️ 如果你觉得有用

**Fork** 🍴 如果你想改进

**分享** 📢 如果你觉得有帮助

---

<div align="center">

**Made with ❤️ and AI assistance**

**技术平权，人人有份**

</div>
