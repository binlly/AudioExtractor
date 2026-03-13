# 贡献指南

感谢你对 AudioExtractor 项目的关注！我们欢迎所有形式的贡献。

## 🤝 如何贡献

### 报告 Bug

1. 在 [Issues](https://github.com/binlly/AudioExtractor/issues) 中搜索是否已有相同问题
2. 如果没有，创建新的 Issue，包含以下信息：
   - 操作系统和版本
   - 应用版本
   - 重现步骤
   - 预期行为
   - 实际行为
   - 日志输出（如果适用）

### 提交新功能建议

1. 在 [Discussions](https://github.com/binlly/AudioExtractor/discussions) 讨论你的想法
2. 创建 Issue 描述新功能
   - 功能描述
   - 使用场景
   - 实现建议
   - 替代方案

### 提交代码

#### 工作流程

1. **Fork 项目**
   ```bash
   # 在 GitHub 上点击 Fork 按钮
   git clone https://github.com/YOUR_USERNAME/AudioExtractor.git
   cd AudioExtractor
   ```

2. **创建分支**
   ```bash
   git checkout -b feature/your-feature-name
   # 或
   git checkout -b fix/your-bug-fix
   ```

3. **进行更改**
   - 遵循代码规范
   - 添加必要的测试
   - 更新文档
   - 提交清晰的 commit 信息

4. **测试更改**
   ```bash
   flutter test
   flutter analyze
   ```

5. **提交更改**
   ```bash
   git add .
   git commit -m "描述你的更改"
   ```

6. **推送到分支**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **创建 Pull Request**
   - 访问 GitHub 上的你的 fork
   - 点击 "New Pull Request"
   - 提供清晰的描述

#### Commit 信息规范

使用清晰、描述性的 commit 信息：

```
feat: 添加批量处理功能

- 支持选择多个视频文件
- 添加队列管理系统
- 实现并行提取

Closes #123
```

类型标签：
- `feat:` 新功能
- `fix:` Bug 修复
- `docs:` 文档更改
- `style:` 代码格式（不影响功能）
- `refactor:` 代码重构
- `perf:` 性能优化
- `test:` 添加或修改测试
- `chore:` 构建/工具更改

## 📋 开发规范

### 代码风格

- 遵循 [Flutter 风格指南](https://flutter.dev/docs/development/data-and-backend/code-style)
- 使用 `dart format` 格式化代码
- 类名使用 `PascalCase`
- 变量和方法名使用 `camelCase`
- 私有成员使用 `_` 前缀

### 文档要求

- 所有公共 API 必须有文档注释
- 复杂逻辑需要添加解释性注释
- README 需要保持最新
- 重大更改更新 CHANGELOG

### 测试要求

- 新功能需要添加单元测试
- Bug 修复需要添加回归测试
- 确保所有测试通过
- 测试覆盖率不应降低

```dart
// 示例测试
void main() {
  group('AudioTrack', () {
    test('should return correct display name', () {
      final track = AudioTrack(
        index: 0,
        codec: 'aac',
        language: 'zh',
      );
      expect(track.languageDisplayName, '中文');
    });
  });
}
```

## 📂 项目结构

```
lib/
├── main.dart                  # 应用入口
├── models/                    # 数据模型
├── providers/                 # 状态管理
├── services/                  # 业务服务
├── ui/                        # UI 组件
│   ├── pages/                 # 页面
│   └── widgets/               # 可复用组件
└── utils/                     # 工具函数
```

## 🎨 设计原则

- **简单性** - 保持代码简单易懂
- **可维护性** - 编写易于维护的代码
- **性能** - 关注应用性能
- **用户体验** - 优化用户交互流程

## 🔍 代码审查

所有 Pull Request 需要通过代码审查：

- 至少一位维护者批准
- 所有 CI 检查通过
- 没有合并冲突
- 文档已更新

## 🐛 调试技巧

### 启用详细日志

```dart
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
);

logger.i('信息日志');
logger.e('错误日志', error: e);
```

### 使用 Flutter DevTools

```bash
# 安装 DevTools
flutter pub global activate devtools

# 运行 DevTools
flutter pub global run devtools
```

## 📚 资源链接

- [Flutter 文档](https://flutter.dev/docs)
- [Dart 语言指南](https://dart.dev/guides)
- [FFmpeg 文档](https://ffmpeg.org/documentation.html)
- [Material Design 3](https://m3.material.io/)

## ❓ 常见问题

### 如何设置开发环境？

参考 [README.md](README.md#-开发指南) 中的环境设置部分。

### 如何运行测试？

```bash
# 运行所有测试
flutter test

# 运行特定测试文件
flutter test test/widget_test.dart

# 查看测试覆盖率
flutter test --coverage
```

### 如何发布新版本？

1. 更新版本号（`pubspec.yaml`）
2. 更新 CHANGELOG
3. 创建 Git tag
4. 构建发布版本
5. 创建 GitHub Release

## 💬 讨论和沟通

- 对于一般讨论，使用 [Discussions](https://github.com/binlly/AudioExtractor/discussions)
- 对于 Bug 报告，使用 [Issues](https://github.com/binlly/AudioExtractor/issues)
- 对于代码贡献，使用 Pull Requests

## 📜 行为准则

- 尊重所有贡献者
- 欢迎不同观点
- 专注于建设性讨论
- 避免负面评论

---

再次感谢你的贡献！🎉
