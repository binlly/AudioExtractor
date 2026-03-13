#!/bin/bash
# 获取最近的 AudioExtractor 日志

echo "=================================="
echo "AudioExtractor 最近日志"
echo "=================================="
echo ""

# 获取最近的日志
log show --predicate 'process == "AudioExtractor"' --last 5m --style syslog 2>/dev/null | \
  grep -E "FFmpeg|提取|音频|Error|Exception" | \
  tail -50

echo ""
echo "=================================="
echo "提示: 如果没有日志，请尝试重新提取一次"
echo "=================================="
