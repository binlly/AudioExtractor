import 'quality_preset.dart';
import 'time_range.dart';

/// 音频提取配置模型
class ExtractionSettings {
  /// 质量预设
  final QualityPreset preset;

  /// 自定义比特率（kbps）
  final int? customBitrate;

  /// 自定义采样率（Hz）
  final int? customSampleRate;

  /// 输出目录路径
  final String outputDirectory;

  /// 时间范围
  final TimeRange? timeRange;

  ExtractionSettings({
    this.preset = QualityPreset.highQuality,
    this.customBitrate,
    this.customSampleRate,
    required this.outputDirectory,
    this.timeRange,
  });

  /// 获取实际使用的比特率（kbps）
  int get bitrate {
    if (preset == QualityPreset.custom && customBitrate != null) {
      return customBitrate!;
    }
    return preset.defaultBitrate;
  }

  /// 获取实际使用的采样率（Hz）
  int? get sampleRate {
    if (preset == QualityPreset.custom && customSampleRate != null) {
      return customSampleRate;
    }
    return preset.defaultSampleRate;
  }

  /// 创建副本
  ExtractionSettings copyWith({
    QualityPreset? preset,
    int? customBitrate,
    int? customSampleRate,
    String? outputDirectory,
    TimeRange? timeRange,
  }) {
    return ExtractionSettings(
      preset: preset ?? this.preset,
      customBitrate: customBitrate ?? this.customBitrate,
      customSampleRate: customSampleRate ?? this.customSampleRate,
      outputDirectory: outputDirectory ?? this.outputDirectory,
      timeRange: timeRange ?? this.timeRange,
    );
  }

  /// 获取 FFmpeg 比特率参数
  String get bitrateParameter {
    return '${bitrate}k';
  }

  /// 获取 FFmpeg 采样率参数（如果不需要改变采样率则返回null）
  String? get sampleRateParameter {
    final rate = sampleRate;
    if (rate == null) {
      return null; // 保持原采样率
    }
    return '$rate';
  }

  @override
  String toString() {
    return 'ExtractionSettings(preset: $preset, bitrate: ${bitrate}k, '
        'sampleRate: ${sampleRate ?? "original"}Hz, '
        'outputDirectory: $outputDirectory, '
        'timeRange: $timeRange)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExtractionSettings &&
        other.preset == preset &&
        other.customBitrate == customBitrate &&
        other.customSampleRate == customSampleRate &&
        other.outputDirectory == outputDirectory &&
        other.timeRange == timeRange;
  }

  @override
  int get hashCode {
    return preset.hashCode ^
        customBitrate.hashCode ^
        customSampleRate.hashCode ^
        outputDirectory.hashCode ^
        timeRange.hashCode;
  }
}
