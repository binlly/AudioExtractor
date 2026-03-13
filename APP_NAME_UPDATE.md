# 应用名称更新总结

## ✅ 已完成的更改

### 1. 应用名称和包名
- ✅ `pubspec.yaml`: `core` → `audio_extractor`
- ✅ `macos/Runner/Configs/AppInfo.xcconfig`: `PRODUCT_NAME = AudioExtractor`
- ✅ `macos/Runner/Info.plist`: `CFBundleDisplayName = AudioExtractor`
- ✅ `lib/main.dart`: 应用标题更新为 `AudioExtractor`

### 2. Bundle Identifier
- ✅ 主应用: `com.zxy.audioextractor`
- ✅ 测试: `com.example.audioextractor.RunnerTests`

### 3. 可执行文件
- ✅ 应用名称: `AudioExtractor.app`
- ✅ 可执行文件: `AudioExtractor` (之前是 `core`)

### 4. 构建产物
- ✅ Debug: `build/macos/Build/Products/Debug/AudioExtractor.app`
- ✅ Release: `build/macos/Build/Products/Release/AudioExtractor.app`

## 📋 检查清单

### Xcode 项目
- [x] PRODUCT_NAME 已更新
- [x] CFBundleDisplayName 已设置
- [x] Bundle Identifier 已更新
- [x] 测试 Bundle Identifier 已更新

### 构建配置
- [x] Debug.xcconfig
- [x] Release.xcconfig
- [x] AppInfo.xcconfig

### Info.plist
- [x] CFBundleName 引用 PRODUCT_NAME
- [x] CFBundleDisplayName 设置为 AudioExtractor
- [x] CFBundleIdentifier 引用 PRODUCT_BUNDLE_IDENTIFIER

### 代码
- [x] 无硬编码的 "core" 字符串
- [x] 应用标题使用变量

### 文档
- [x] README.md 已更新
- [x] DEBUGGING_GUIDE.md 已更新
- [x] debug_crash.sh 已更新
- [x] RELEASE_GUIDE.md 已更新

## 🎯 验证步骤

### 1. 检查应用名称
```bash
ls -la build/macos/Build/Products/Release/
```

应该看到 `AudioExtractor.app`

### 2. 检查可执行文件
```bash
ls -la build/macos/Build/Products/Release/AudioExtractor.app/Contents/MacOS/
```

应该看到 `AudioExtractor*`

### 3. 检查 Bundle Identifier
```bash
defaults read build/macos/Build/Products/Release/AudioExtractor.app/Contents/Info.plist CFBundleIdentifier
```

应该返回 `com.zxy.audioextractor`

### 4. 检查显示名称
```bash
defaults read build/macos/Build/Products/Release/AudioExtractor.app/Contents/Info.plist CFBundleDisplayName
```

应该返回 `AudioExtractor`

## 🚀 下一步

### 测试应用
1. 双击 `AudioExtractor.app` 打开应用
2. 拖拽视频文件测试
3. 验证所有功能正常

### 安装到 Applications
```bash
# 复制到 Applications 文件夹
cp -R build/macos/Build/Products/Release/AudioExtractor.app /Applications/

# 或创建符号链接
ln -s $(pwd)/build/macos/Build/Products/Release/AudioExtractor.app /Applications/AudioExtractor.app
```

### 提交更改
```bash
git add -A
git commit -m "chore: 更新应用名称为 AudioExtractor

- 更新 Bundle Identifier 为 com.zxy.audioextractor
- 更新可执行文件名为 AudioExtractor
- 更新所有相关配置文件
- 清理并重新构建 Release 版本

应用现在在 /Applications 中将显示为 AudioExtractor"
```

## 📝 备注

- 所有测试 Bundle Identifier 已从 `com.example.core` 更新
- 可执行文件名已从 `core` 更新为 `AudioExtractor`
- 应用包名已从 `core.app` 更新为 `AudioExtractor.app`
- 应用显示名称为 `AudioExtractor`

---

**状态**: ✅ 所有必要更改已完成
**版本**: v2.5.0
**应用名称**: AudioExtractor
**Bundle ID**: com.zxy.audioextractor
