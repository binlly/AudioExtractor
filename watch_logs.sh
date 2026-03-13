#!/bin/bash
# 监控 AudioExtractor 应用日志

echo "=================================="
echo "AudioExtractor 日志监控"
echo "=================================="
echo ""
echo "提示: 请在应用中执行以下操作："
echo "  1. 加载视频文件"
echo "  2. 选择音轨"
echo "  3. 点击'提取音频'"
echo ""
echo "按 Ctrl+C 停止监控"
echo "=================================="
echo ""

# 监控日志
log stream --predicate 'process == "AudioExtractor"' --level debug \
  --style compact 2>/dev/null \
  | grep -v "log: Collecting logs" \
  | while read line; do
      # 高亮显示重要日志
      if echo "$line" | grep -q "FFmpeg\|提取\|音频"; then
        echo "✅ $line"
      elif echo "$line" | grep -q "Error\|失败\|Exception"; then
        echo "❌ $line"
      else
        echo "   $line"
      fi
    done
