# 🎵 从视频中提取喜欢的音乐，我用AI开发了这款免费开源软件！

> 告别繁琐的命令行操作，一款优雅的 macOS（未来支持Windows、Linux、Android和iOS）
> 音频提取工具内置ffmpeg，不依赖设备环境，小白也能轻松提取。

---

## 为什么需要音频提取？

你是否遇到过这样的场景：

- 🎬 **视频学习**：在线课程视频太大，只想提取音频在通勤时听
- 🎵 **音乐收藏**：MV 太占空间，只想要音频文件
- 📻 **播客制作**：需要从视频素材中提取高质量音轨
- 🎙️ **语音转写**：提取音频用于语音识别或字幕制作

传统的方法要么使用**在线转换工具**（上传下载慢、有广告、文件大小限制），要么使用**命令行 FFmpeg**
（需要技术背景、操作繁琐），要么使用付费专业软件，除了学习成本还需要财力支持。但现在什么年代了？早就不是古法编程的世代的好吗？技术平权，人人有份！说干就干，但是本着授人以渔，我会模拟毕业生、小白、入门者等等新手，着重记录我自己的开发过程，中间遇到的坑，以及我作为一个专业程序员的想法。

---

## 第一章：萌生想法 - 我真的需要一个工具

事情是这样的。上周我在刷 B 站，看到一个超棒的音乐现场视频，那种氛围感太强了，但我只想要音频部分，可以放到手机里循环播放。

我第一反应是：这不简单吗？我学过编程啊！

于是打开终端，熟练地输入：

```bash
ffmpeg -i 一个视频.mp4 -vn -acodec copy 提取的音乐.aac
```

结果提示：`command not found: ffmpeg`

哦对，我忘了装 FFmpeg。那就装呗：

```bash
brew install ffmpeg
```

结果提示：`command not found: brew`

...有完没完，疯了。

其实以上这些东西对程序员来说是标配，但是环境安装恰恰是普通用户最大的门槛。所以我想起了AI，用自然语言告诉他，我想做什么，结果它问了我几句自己就安装好了。到这其实已经成功了一半，继续。

再次运行，成功了！但是... 等等，我只想要 2:30 到 5:20 那一段精彩的吉他 solo 怎么办？

又要查文档，又要算时间，终于还是硬着头皮搞定了：

```bash
ffmpeg -i 一个视频.mp4 -ss 00:02:30 -to 00:05:20 -vn -acodec copy 提取的音乐.mp3
```

成功了！但我突然想到：**如果是我的妈妈、我的朋友，他们怎么办？**

他们不会用命令行，也不想学。那我为什么不做一个**简单的图形界面工具**呢？

---

## 第二章：AI是我的编程导师 - 从零开始的对话式开发

### 2.1 第一次对话：我该用什么技术？

说实话，我当时完全懵了。想做桌面应用，但完全不知道从哪开始。

于是我问AI：

> **我**：我想做一个 macOS 桌面应用，从视频中提取音频。但我只会一点点 Python，不知道该用什么技术。能帮我推荐一下吗？

**AI**：对于你的需求，我推荐几个方案：
1. **Electron + JavaScript**：跨平台，但打包后体积大
2. **Python + Tkinter/PyQt**：你熟悉 Python，但界面不够现代化
3. **Flutter**：Google 的跨平台框架，界面漂亮，性能好，未来还能支持 Windows/Linux/移动端

考虑到你想要"现代化界面"和"未来跨平台"，我推荐 **Flutter**。

**我**：Flutter 听起来很复杂，我不会 Dart 语言啊...

**AI**：别担心！Dart 语言非常简单，类似 Java/JavaScript。而且我会一步步教你。更重要的是，**Flutter 的热重载功能让你能立即看到代码效果**，学习曲线很平缓。

**我**：那...就选 Flutter 吧！从哪里开始？

### 2.2 AI手把手教我搭建环境

**AI**：很好！让我们一步步来：

**第一步：安装 Flutter SDK**
```bash
# 下载 Flutter
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:`pwd`/flutter/bin"

# 验证安装
flutter doctor
```

**我**：运行 `flutter doctor` 后，提示 macOS 没有安装，怎么办？

**AI**：这是因为你还没有创建 macOS 项目。先创建项目：
```bash
flutter create --platforms=macos audio_extractor
cd audio_extractor
```

**我**：好的，创建成功了！接下来呢？

**AI**：现在运行项目看看效果：
```bash
flutter run -d macos
```

**📸 [截图：第一个 Flutter 应用运行成功]**

当我第一次看到那个自动生成的计数器应用时，我激动坏了！**真的只是一个命令，一个完整的 macOS 应用就运行起来了！**

以前我觉得开发桌面应用是遥不可及的事情，现在感觉...好像也没那么难？

### 2.3 AI帮我写第一个界面

**我**：现在我想要一个界面，可以选择视频文件，然后点击按钮提取音频。我完全不知道怎么写...

**AI**：没问题！我来帮你。首先，我们需要一个文本框显示视频路径，一个按钮选择文件，还有一个按钮开始提取。

**这是代码**：
```dart
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Audio Extractor')),
        body: const AudioExtractorPage(),
      ),
    );
  }
}

class AudioExtractorPage extends StatefulWidget {
  const AudioExtractorPage({super.key});

  @override
  State<AudioExtractorPage> createState() => _AudioExtractorPageState();
}

class _AudioExtractorPageState extends State<AudioExtractorPage> {
  String? _videoPath;

  Future<void> _selectVideo() async {
    final result = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(
          label: 'Videos',
          extensions: ['mp4', 'mov', 'avi', 'mkv'],
        ),
      ],
    );
    if (result != null) {
      setState(() {
        _videoPath = result.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: '视频路径',
              border: OutlineInputBorder(),
            ),
            controller: TextEditingController(text: _videoPath),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _selectVideo,
            child: const Text('选择视频'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _videoPath != null ? _extractAudio : null,
            child: const Text('提取音频'),
          ),
        ],
      ),
    );
  }

  void _extractAudio() {
    // TODO: 实现音频提取
    print('提取音频：$_videoPath');
  }
}
```

**我**：哇，这么多代码... 我能看懂大概，但有些地方不太明白。

**AI**：没关系，我解释一下关键部分：

1. **StatefulWidget**：这是 Flutter 的有状态组件，可以记住用户选择的视频路径
2. **setState()**：当用户选择视频后，调用这个方法更新界面
3. **Future<void>**：异步函数，文件选择需要时间
4. **Column**：垂直排列多个组件

你只需要复制这段代码，替换 `lib/main.dart` 的内容，然后按 `r` 热重载就能看到效果。

**📸 [截图：第一个界面 - 文本框和按钮]**

我照着做了，界面真的出现了！虽然很简单，但**那是我人生中第一个自己写的桌面应用界面**！

---

## 第三章：让AI帮我写代码 - 只要会提问就能编程

### 3.1 第一次遇到技术难题

**我**：界面有了，但我不知道怎么调用 FFmpeg 提取音频。我查了一些资料，好像有个叫 `process_run` 的包？

**AI**：没错！`process_run` 可以让你在 Dart 中调用系统命令。不过，我有个更好的建议：使用 `ffmpeg_kit_flutter_new`，这是内置 FFmpeg 的包，用户不需要自己安装 FFmpeg。

让我帮你添加依赖和实现代码：

**第一步：添加依赖**（在 `pubspec.yaml`）：
```yaml
dependencies:
  flutter:
    sdk: flutter
  ffmpeg_kit_flutter_new: ^6.0.0
  file_selector: ^1.0.0
```

**第二步：实现音频提取**：
```dart
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

Future<void> _extractAudio() async {
  if (_videoPath == null) return;

  // 生成输出文件名
  final outputPath = '${_videoPath!.replaceAll(RegExp(r'\.\w+$'), '')}.m4a';

  // 构建 FFmpeg 命令
  final command = '-i "$_videoPath" -vn -acodec aac -b:a 256k "$outputPath"';

  // 执行提取
  final session = await FFmpegKit.execute(command);
  final returnCode = await session.getReturnCode();

  if (ReturnCode.isSuccess(returnCode)) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('成功'),
        content: Text('音频已保存到：$outputPath'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  } else {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('失败'),
        content: Text('音频提取失败，请检查视频文件'),
      ),
    );
  }
}
```

**我**：这...这么多代码，我完全看不懂。能解释一下吗？

**AI**：当然可以！我用通俗的语言解释：

**这部分**：
```dart
final session = await FFmpegKit.execute(command);
```
就像是你在终端输入命令并等待结果。

**这部分**：
```dart
final returnCode = await session.getReturnCode();
```
是检查命令是否成功（返回 0 表示成功）。

**这部分**：
```dart
if (ReturnCode.isSuccess(returnCode))
```
是判断成功后显示成功对话框，否则显示失败对话框。

你不需要完全理解每一行代码，只要知道**这段代码的作用就是调用 FFmpeg 提取音频，然后告诉用户成功或失败**。

**我**：那我照抄就行了？

**AI**：是的！复制这段代码，替换 `_extractAudio()` 函数。如果遇到问题，随时问我。

**📸 [截图：第一次成功提取音频]**

我颤抖着手点击了"提取音频"按钮...

几秒钟后，弹出了"成功"对话框！**我真的做到了！**

那一刻，我感觉自己像魔法师一样，竟然真的做出了一个能用的工具！

### 3.2 不懂就问，AI是最耐心的老师

在开发过程中，我遇到了无数"小白问题"：

**问题1：什么是异步？**

**我**：代码里有 `async` 和 `await`，这是什么意思？

**AI**：很好的问题！让我用生活例子解释：

**同步**就像是排队买东西，你必须等前面的人买完才能轮到你。
**异步**就像是取号，拿了号就可以去做别的事，等到号了再回来。

在代码中，提取音频需要几秒钟，如果是同步，界面会卡死。用异步，界面不会卡，用户还能继续操作。

**问题2：什么是 StatefulWidget？**

**我**：为什么一定要用 StatefulWidget？

**AI**：想想看，当你点击"选择视频"按钮后，视频路径需要在界面上显示出来。如果界面不能"记住"这个路径，怎么显示呢？

**StatefulWidget** 就是有记忆的组件，它能记住数据（比如视频路径），并在数据改变时更新界面。

**StatelessWidget** 是没有记忆的组件，用于显示静态内容（比如标题）。

**我**：哦！我明白了！就像有记忆和无记忆的区别！

**AI**：完全正确！你理解得很快。

---

## 第四章：遇到错误不怕 - AI是最好的调试助手

### 4.1 第一个错误：双击运行崩溃

**我**：用 `flutter run` 开发时一切正常，但当我构建 Release 版本，双击 .app 文件时... 崩溃了！没有任何提示，就是直接退出。

**AI**：别慌！这是开发桌面应用常见的问题。让我们一步步排查：

**第一步：查看崩溃报告**
```bash
# macOS 会生成崩溃报告
ls -t ~/Library/Logs/DiagnosticReports/AudioExtractor*.crash | head -1
```

把崩溃报告内容发给我。

**我**：[粘贴崩溃报告]

**AI**：我看到问题了！崩溃是因为找不到 FFmpeg 命令。这是因为：

- `flutter run` 时，应用继承了你终端的环境变量，包括 `$PATH`，能找到通过 `brew install ffmpeg` 安装的 FFmpeg
- 双击 .app 运行时，macOS 只给应用系统默认的 `$PATH`（`/usr/bin:/bin:/usr/sbin:/sbin`），找不到用户安装的 FFmpeg

**解决方案**：使用内置 FFmpeg 的包。

把 `process_run` 替换成 `ffmpeg_kit_flutter_new`，FFmpeg 会编译在应用内部，不依赖外部安装。

**我**：但是这样应用会不会变得很大？

**AI**：会的，会增加大约 90MB。但这是值得的权衡：

| 方案 | 应用大小 | 用户体验 |
|------|----------|----------|
| 外部 FFmpeg | ~10 MB | ❌ 用户需要自己安装，体验差 |
| 内置 FFmpeg | ~99 MB | ✅ 开箱即用，体验好 |

对于普通用户来说，**零配置的体验比 90MB 更重要**。

**我**：有道理！那我怎么改呢？

**AI**：我来帮你，一步步来：

**第一步：修改 pubspec.yaml**
```yaml
dependencies:
  ffmpeg_kit_flutter_new: ^6.0.0  # 添加这个
```

**第二步：修改代码**
```dart
// 删除 process_run，改用这个
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';

Future<void> _extractAudio() async {
  final session = await FFmpegKit.executeWithArguments([
    '-i', _videoPath,
    '-vn',
    '-acodec', 'aac',
    '-b:a', '256k',
    outputPath,
  ]);

  final returnCode = await session.getReturnCode();
  // ... 后续代码
}
```

**第三步：重新构建**
```bash
flutter clean
flutter pub get
flutter build macos --release
```

**我**：照着做了，真的成功了！双击运行不再崩溃！

**AI**：太棒了！你看，遇到错误不可怕，**关键是要懂得排查，并且愿意学习解决方案**。这个过程你学到的知识，比直接给你答案更有价值。

### 4.2 第二个错误：JSON 解析失败

**我**：我想显示视频信息（总时长、音轨列表），但解析 JSON 一直失败。

我的代码：
```dart
final session = await FFmpegKit.execute(
  'ffprobe -v quiet -print_format json -show_format "$_videoPath"'
);
final output = await session.getOutput();
final data = jsonDecode(output); // ❌ 报错！
```

错误：`FormatException: Unexpected character`

**AI**：这个问题很常见！让我帮你调试：

**调试步骤1：打印原始输出**
```dart
print('原始输出: $output');
print('输出类型: ${output.runtimeType}');
```

把结果发给我。

**我**：[粘贴输出]

**AI**：我看到问题了！`FFmpegKit.execute()` 返回的不是纯 JSON，而是带了很多额外信息的字符串。你需要用 `FFmpegKit.executeWithArguments()`：

```dart
final session = await FFmpegKit.executeWithArguments([
  '-v', 'quiet',
  '-print_format', 'json',
  '-show_format',
  '-show_streams',
  _videoPath,
]);

final output = await session.getOutput();
final data = jsonDecode(output); // ✅ 现在是纯 JSON 了
```

**关键区别**：
- `execute()` - 执行命令字符串，输出包含调试信息
- `executeWithArguments()` - 执行参数数组，输出纯净

**我**：原来如此！但是... 我怎么会知道这些？文档里没写清楚啊。

**AI**：这就是 AI 的优势！文档可能不完整，或者写得比较晦涩，但 AI 可以：
1. 理解你的问题
2. 分析错误的根本原因
3. 给出通俗易懂的解释
4. 提供正确的解决方案

**你不需要成为专家，只要会提问，AI 就会成为你的私人导师。**

---

## 第五章：超越想象 - AI激发的创造力

### 5.1 从"能用"到"好用"

**我**：现在工具能用了，但我觉得不够... 怎么说呢，不够优雅。

**AI**：很好的想法！让我帮你分析可以改进的地方：

**当前问题**：
1. ❌ 用户不知道视频里是什么内容
2. ❌ 无法精确选择要提取的时间段
3. ❌ 提取时没有进度显示

**改进方案**：
1. ✅ 添加视频预览功能
2. ✅ 添加双滑块时间轴
3. ✅ 添加实时进度条

**我**：这些听起来都很复杂啊...

**AI**：别担心，我们一步步来。先从视频预览开始：

**第一步：添加视频播放器**
```dart
import 'package:video_player/video_player.dart';

class _AudioExtractorPageState extends State<AudioExtractorPage> {
  VideoPlayerController? _controller;

  Future<void> _selectVideo() async {
    // ... 选择视频
    if (result != null) {
      setState(() {
        _videoPath = result.path;
        _controller = VideoPlayerController.file(File(_videoPath!))
          ..initialize().then((_) {
            setState(() {}); // 刷新界面
          });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 视频预览
        _controller != null && _controller!.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            )
          : Container(height: 200, color: Colors.grey),
        // ... 其他组件
      ],
    );
  }
}
```

**📸 [截图：添加视频预览后的界面]**

**我**：天哪！视频真的能在应用里播放了！

**AI**：是的！而且你可以添加播放控制：
```dart
Row(
  children: [
    IconButton(
      icon: Icon(_controller!.value.isPlaying ? Icons.pause : Icons.play_arrow),
      onPressed: () {
        setState(() {
          _controller!.value.isPlaying
            ? _controller!.pause()
            : _controller!.play();
        });
      },
    ),
  ],
)
```

**我**：这太神奇了！我只是想要一个工具，结果做出了一个视频播放器？

**AI**：这就是创造的魅力！**当你开始动手，你会发现自己的潜力远超想象。**

### 5.2 AI不仅解决问题，还提出建议

**我**：现在功能差不多了，但我觉得用户可能不知道怎么用...

**AI**：好想法！我建议添加：
1. **拖拽支持** - 直接拖拽视频文件到窗口
2. **智能文件命名** - 输出文件名包含时间范围
3. **键盘快捷键** - 空格播放/暂停，方向键快进快退
4. **错误提示** - 友好的错误信息，告诉用户怎么解决

**我**：这些都是我想不到的... 你怎么知道用户需要这些？

**AI**：这是基于常见 UX 最佳实践。但我不是替代你的思考，而是**给你启发，让你有能力做出更好的产品**。

最终的决定权在你，你可以根据实际需求选择实现哪些功能。

---

## 第六章：从想法到产品 - AI陪伴的完整旅程

### 6.1 两个月的变化

回想两个月前，我：
- ❌ 只会简单的 Python 脚本
- ❌ 从未做过桌面应用
- ❌ 不懂 Dart 语言
- ❌ 没听过 Flutter

现在，我：
- ✅ 做了一个完整的 macOS 应用
- ✅ 学会了 Flutter 和 Dart
- ✅ 理解了 FFmpeg 的使用
- ✅ 掌握了桌面应用开发
- ✅ 开源帮助了其他人

**这不是因为我有天赋，而是因为有 AI 陪伴。**

### 6.2 AI改变了我学习的方式

**传统学习方式**：
```
遇到问题 → 搜索文档 → 看不懂 → 再搜索 → 试错 →
又遇到问题 → 重复循环 → 几小时后解决
```

**AI辅助学习**：
```
遇到问题 → 问AI → 得到答案 → 理解原理 → 应用 →
又遇到问题 → 再问AI → 学到更多 →
形成正向循环 → 几分钟解决 + 学到知识
```

**关键区别**：
- 传统方式：**被动搜索**，自己找答案
- AI辅助：**主动对话**，AI 教你原理

**AI 不是替代你的思考，而是加速你的学习。**

### 6.3 技术平权的真正含义

什么是"技术平权"？

**不是**：让每个人都成为专家
**而是**：让每个人都能用技术解决自己的问题

在过去：
- 想做软件？需要学几年编程
- 想做工具？需要懂计算机原理
- 想做产品？需要组建团队

现在：
- 想做软件？AI 帮你写代码
- 想做工具？AI 教你如何实现
- 想做产品？AI 陪伴你完成

**门槛降低了，但可能性无限扩大了。**

---

## 第七章：无限可能 - 千千万万个例子之一

### 7.1 我的故事只是一个缩影

我的 AudioExtractor 项目，只是 AI 时代普通人创造价值的千千万万例子之一。

让我讲几个真实的故事：

**故事一：老师的自动化工具**

> "我是小学老师，每天要批改 100 多道选择题。以前要花 2 小时，现在用 AI + Python 写了个脚本，5 分钟搞定。我从来没学过编程，是 AI 一步步教我的。"

**故事二：妈妈的餐厅系统**

> "我家开了个小餐厅，妈妈以前用纸笔记账。现在用 AI + 低代码平台做了个订单管理系统，自动统计营收、库存预警。妈妈说比花钱买的软件还好用！"

**故事三：学生的科研助手**

> "我是研究生，要处理大量实验数据。以前用 Excel 手动算，现在用 AI + Python 做了自动化分析工具，数据一导入，图表自动生成，导师都夸我专业！"

**故事四：大爷的智能相册**

> "我爸 70 岁了，想整理老照片。我帮他学了智能手机 + AI 工具，现在他能自动分类照片、识别人脸、生成电子相册，还分享给老伙伴们，可骄傲了！"

**这些故事有什么共同点？**

- 他们都不是专业程序员
- 他们都有 AI 陪伴
- 他们都解决了自己的问题
- 他们都创造了价值

**这就是技术平权的力量。**

### 7.2 你也可以创造

看完我的故事，你可能想：

> "但是... 我还是觉得很难啊"

> "我没时间学啊"

> "我肯定学不会的"

让我告诉你：

**我不比你聪明**
**我不比你时间多**
**我一开始也觉得难**

**但我做了一个决定：开始行动。**

**然后我发现：**

- 遇到问题？问 AI
- 不懂代码？AI 教我
- 想要改进？AI 给建议
- 害怕失败？AI 鼓励我

**最难的不是学习，而是开始。**

### 7.3 AI时代的创造力

在 AI 时代，创造力的定义改变了：

**过去**：
- 创造力 = 专业知识 + 多年经验 + 天赋

**现在**：
- 创造力 = 想法 + 行动 + AI 陪伴

**这意味着什么？**

意味着：
- 🎨 艺术家可以用 AI 创作音乐
- 📝 作家可以用 AI 辅助写作
- 💼 创业者可以用 AI 开发产品
- 🏫 老师可以用 AI 制作课件
- 🏠 家庭主妇可以用 AI 管理家庭
- 👴 退休老人可以用 AI 记录人生

**每个人都能创造，每个人都能实现自己的想法。**

---

## 第八章：技术平权 - 人人有份

### 8.1 从精英到大众

在 AI 之前，软件开发是"精英俱乐部"：
- 🎓 需要计算机学位
- 💻 需要多年编程经验
- 🏢 需要在大公司工作
- 💰 需要大量资金投入

现在，软件开发是"人人都能玩的游戏"：
- 💡 需要一个想法
- 📱 需要一部电脑
- 🤖 需要一个 AI 助手
- ⏰ 需要一点时间

**这不是夸张，而是正在发生的现实。**

### 8.2 AI不是替代，而是赋能

有人担心：AI 会取代程序员吗？

我的看法：**AI 不是替代，而是赋能。**

**AI 替代的是**：
- ❌ 重复性的代码编写
- ❌ 机械的调试工作
- ❌ 记忆性的知识查询

**AI 不能替代的是**：
- ✅ 创造性的想法
- ✅ 对用户需求的理解
- ✅ 对产品的审美和品味
- ✅ 对问题的敏锐洞察

**AI 是工具，不是主人。**
**你是指挥官，AI 是参谋。**

### 8.3 未来的样子

在技术平权的时代，未来会是什么样子？

**学校里**：
- 学生不再是被动接受知识，而是用 AI 创造项目
- 老师不再是知识的唯一来源，而是学习的引导者

**工作中**：
- 员工不再等待 IT 部门开发工具，而是用 AI 自己解决问题
- 公司不再需要大量外包，内部就能快速迭代

**生活中**：
- 父母不再依赖子女解决技术问题
- 退休老人不再被数字时代抛弃
- 每个人都能用技术改善生活

**这不是科幻小说，而是正在发生的现实。**

---

## 结语：你的故事，等待书写

### 我的故事

两个月前，我只是想提取一个视频的音频。

现在，我：
- ✅ 做了一个能用的工具
- ✅ 学会了 Flutter 开发
- ✅ 理解了 FFmpeg 原理
- ✅ 开源帮助了别人
- ✅ 写下了这篇文章

**但这不是我一个人的故事，而是千千万万个在 AI 时代创造价值的人的故事之一。**

### 你的故事

你有什么想法？

- 想做的工具？
- 想解决的问题？
- 想实现的创意？

**不要等待，不要犹豫。**

**打开 AI，开始你的创造之旅。**

**你的故事，等待书写。**

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

## 技术平权，人人有份

## 你的想法，值得被实现

## 你的创造，值得被世界看到

**现在就开始吧！** 🚀

**Made with ❤️ and AI assistance**

</div>
