# Release 版本测试清单

## 🎯 测试目标
验证修复是否成功：**双击运行 Release 应用不再崩溃**

## 📍 构建信息
- **应用路径**：`build/macos/Build/Products/Release/AudioExtractor.app`
- **应用大小**：99MB
- **架构**：Universal Binary (x86_64 + arm64)
- **FFmpeg**：内置（ffmpeg_kit_flutter_new）

## 🧪 测试步骤

### 步骤 1：双击运行（决定性测试）
```bash
# 方法 1：命令行打开
open build/macos/Build/Products/Release/AudioExtractor.app

# 方法 2：Finder 中双击
# 在 Finder 中导航到上述路径，双击 AudioExtractor.app
```

**预期结果**：
- ✅ 应用正常启动
- ✅ 不再出现 "FFprobe 执行失败" 崩溃
- ✅ 应用界面正常显示

**如果失败**：
- ❌ 应用崩溃
- ❌ 弹出错误对话框
- ❌ 应用闪退

### 步骤 2：加载视频文件
1. 点击 "选择视频" 按钮
2. 选择一个视频文件（.mp4, .mov 等）
3. 观察应用行为

**预期结果**：
- ✅ 视频成功加载
- ✅ 显示视频时长
- ✅ 显示音轨列表
- ✅ 能播放视频预览

**如果失败**：
- ❌ 加载时崩溃
- ❌ 显示 "FFprobe 返回空输出" 错误

### 步骤 3：提取音频测试
1. 选择一个音轨
2. 点击 "提取音频" 按钮
3. 观察提取过程

**预期结果**：
- ✅ 显示提取进度
- ✅ 提取完成提示
- ✅ 能打开输出目录

**如果失败**：
- ❌ 提取时崩溃
- ❌ 显示 "FFmpeg 执行失败" 错误

### 步骤 4：检查日志（如果出现问题）
```bash
# 查看系统日志
log stream --predicate 'process == "AudioExtractor"' --level debug

# 或者查看 Console.app
open /Applications/Utilities/Console.app
```

## 🔍 验证成功的标志

### 核心验证点
- [ ] **双击运行不再崩溃** ← 最重要
- [ ] 能加载视频文件
- [ ] 能解析视频信息（FFprobe 工作正常）
- [ ] 能提取音频（FFmpeg 工作正常）
- [ ] 进度显示正常
- [ ] 不依赖系统 FFmpeg

### 技术验证
```bash
# 检查应用是否包含 FFmpeg 库
ls build/macos/Build/Products/Release/AudioExtractor.app/Contents/Frameworks/

# 应该看到：
# - ffmpeg_kit_flutter_new.framework
# - 其他 Flutter 框架
```

## 🐛 如果仍然出现问题

### 可能的问题 1：权限问题
**症状**：应用启动但无法访问文件
**解决**：
```bash
# 检查 entitlements
cat macos/Runner/Release.entitlements
```

### 可能的问题 2：代码签名问题
**症状**：应用无法启动，显示"已损坏"
**解决**：
```bash
# 重新签名
codesign --force --deep --sign - build/macos/Build/Products/Release/AudioExtractor.app
```

### 可能的问题 3：Gatekeeper 阻止
**症状**：首次启动时被阻止
**解决**：
```bash
# 右键点击 → 打开 → 点击"打开"按钮
# 或者在系统设置中允许
```

## 📊 成功标准

### 修复前 vs 修复后
| 场景 | 修复前 | 修复后 |
|------|--------|--------|
| 双击运行 | 💥 崩溃 | ✅ 正常 |
| 加载视频 | - | ✅ 正常 |
| 提取音频 | - | ✅ 正常 |
| 依赖 FFmpeg | ❌ 系统 $PATH | ✅ 内置库 |

## 🎉 测试完成

如果所有测试通过：
1. ✅ 问题已修复
2. ✅ 应用可以分发
3. ✅ 用户无需安装 FFmpeg

如果测试失败：
1. 📝 记录错误信息
2. 🔍 查看系统日志
3. 💬 提供错误详情以便进一步诊断
