import 'dart:core';

/// 时间范围模型
class TimeRange {
  /// 开始时间（毫秒）
  final int startMs;

  /// 结束时间（毫秒）
  final int endMs;

  /// 是否启用时间范围选择
  final bool isEnabled;

  const TimeRange({
    this.startMs = 0,
    this.endMs = 0,
    this.isEnabled = false,
  });

  /// 复制并修改部分字段
  TimeRange copyWith({
    int? startMs,
    int? endMs,
    bool? isEnabled,
  }) {
    return TimeRange(
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  /// 获取持续时间（毫秒）
  int get durationMs => endMs - startMs;

  /// 是否有效（开始时间小于结束时间）
  bool get isValid => startMs < endMs;

  /// 将毫秒转换为 HH:MM:SS.mmm 格式
  static String formatMs(int milliseconds) {
    final hours = milliseconds ~/ (3600 * 1000);
    final minutes = (milliseconds % (3600 * 1000)) ~/ (60 * 1000);
    final seconds = (milliseconds % (60 * 1000)) ~/ 1000;
    final ms = milliseconds % 1000;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}.'
          '${ms.toString().padLeft(3, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}.'
          '${ms.toString().padLeft(3, '0')}';
    }
  }

  /// 格式化开始时间
  String get formattedStart => formatMs(startMs);

  /// 格式化结束时间
  String get formattedEnd => formatMs(endMs);

  /// 生成文件名后缀
  String get fileSuffix {
    if (!isEnabled || !isValid) return '';

    final start = formatMs(startMs).replaceAll(':', '-').replaceAll('.', '-');
    final end = formatMs(endMs).replaceAll(':', '-').replaceAll('.', '-');
    return '_$start-$end';
  }

  @override
  String toString() {
    return 'TimeRange(start: $formattedStart, end: $formattedEnd, enabled: $isEnabled)';
  }
}
