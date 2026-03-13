#!/bin/bash
# Release 版本验证测试脚本

echo "=================================="
echo "AudioExtractor Release 版本测试"
echo "=================================="
echo ""

APP_PATH="build/macos/Build/Products/Release/AudioExtractor.app"

# 检查应用是否存在
if [ ! -d "$APP_PATH" ]; then
    echo "❌ 应用不存在: $APP_PATH"
    echo "请先运行: flutter build macos --release"
    exit 1
fi

echo "✅ 找到应用: $APP_PATH"
echo ""

# 显示应用信息
echo "📊 应用信息："
echo "  - 大小: $(du -sh "$APP_PATH" | cut -f1)"
echo "  - 架构: $(file "$APP_PATH/Contents/MacOS/AudioExtractor" | grep -o 'universal binary\|x86_64\|arm64')"
echo ""

# 检查 FFmpeg 框架
echo "🔍 检查 FFmpeg 库："
FFMPEG_FRAMEWORKS=$(find "$APP_PATH" -name "*ffmpeg*" -o -name "libav*.framework" | wc -l)
echo "  - 找到 $FFMPEG_FRAMEWORKS 个 FFmpeg 相关框架"

if [ $FFMPEG_FRAMEWORKS -gt 0 ]; then
    echo "  ✅ FFmpeg 已打包"
    echo ""
    echo "  包含的库："
    ls "$APP_PATH/Contents/Frameworks/" | grep -E "ffmpeg|libav"
else
    echo "  ❌ FFmpeg 未找到"
    exit 1
fi

echo ""
echo "=================================="
echo "🧪 开始功能测试"
echo "=================================="
echo ""

# 启动应用
echo "🚀 启动应用..."
echo "提示: 应用将在后台启动"
echo "请执行以下测试："
echo ""
echo "1. ✅ 应用是否正常启动？"
echo "2. ✅ 能否加载视频文件？"
echo "3. ✅ 能否看到音轨列表？"
echo "4. ✅ 能否提取音频？"
echo ""

open "$APP_PATH"

echo ""
echo "=================================="
echo "✅ 测试完成"
echo "=================================="
echo ""
echo "如果所有测试通过，说明修复成功！"
echo ""
echo "🐛 如果出现问题，请查看日志："
echo "   log stream --predicate 'process == \"AudioExtractor\"' --level debug"
