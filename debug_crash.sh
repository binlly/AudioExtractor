#!/bin/bash

# AudioExtractor 崩溃调试脚本

echo "=== AudioExtractor 崩溃调试工具 ==="
echo ""

# 检查应用是否在运行
if pgrep -x "AudioExtractor" > /dev/null; then
    echo "✅ 应用正在运行"
    echo ""
    echo "进程信息:"
    ps aux | grep -E "AudioExtractor" | grep -v grep
else
    echo "❌ 应用未运行"
fi

echo ""
echo "=== 检查最近的崩溃报告 ==="

# 查找最近的崩溃报告
CRASH_REPORT=$(ls -t ~/Library/Logs/DiagnosticReports/AudioExtractor*.crash 2>/dev/null | head -1)

if [ -n "$CRASH_REPORT" ]; then
    echo "找到崩溃报告: $CRASH_REPORT"
    echo ""
    echo "崩溃原因:"
    grep -A 10 "Exception Type:" "$CRASH_REPORT" | head -20
    echo ""
    echo "崩溃线程:"
    grep -A 20 "Crashed Thread:" "$CRASH_REPORT" | head -30
else
    echo "未找到崩溃报告"
fi

echo ""
echo "=== 检查系统日志 ==="

# 查看最近的系统日志
echo "最近 5 分钟的应用日志:"
log show --predicate 'processImagePath contains "AudioExtractor"' --last 5m --style compact 2>/dev/null | tail -20

echo ""
echo "=== 测试文件访问权限 ==="

# 测试文件访问（请替换为实际的视频文件路径）
TEST_FILE="/path/to/your/test_video.mp4"

if [ -f "$TEST_FILE" ]; then
    echo "✅ 测试文件存在: $TEST_FILE"
    ls -la "$TEST_FILE"
    echo ""

    # 尝试读取文件
    if head -c 100 "$TEST_FILE" > /dev/null 2>&1; then
        echo "✅ 文件可读"
    else
        echo "❌ 文件不可读"
    fi
else
    echo "⚠️  测试文件不存在: $TEST_FILE"
fi

echo ""
echo "=== 检查应用签名 ==="

APP_PATH="build/macos/Build/Products/Release/AudioExtractor.app"

if [ -d "$APP_PATH" ]; then
    echo "应用路径: $APP_PATH"
    codesign -d -v "$APP_PATH" 2>&1 | head -20
else
    echo "❌ 应用不存在: $APP_PATH"
fi

echo ""
echo "=== 推荐的调试步骤 ==="

echo "1. 在终端中直接运行应用以查看实时日志:"
echo "   ./build/macos/Build/Products/Release/AudioExtractor.app/Contents/MacOS/AudioExtractor"
echo ""
echo "2. 查看 Console.app 的日志:"
echo "   打开 Console.app，过滤 'AudioExtractor' 进程"
echo ""
echo "3. 检查文件权限:"
echo "   确保拖拽的文件有读取权限"
echo ""
echo "4. 测试 Debug 版本:"
echo "   flutter run -d macos"
echo ""

echo "=== 脚本执行完成 ==="
