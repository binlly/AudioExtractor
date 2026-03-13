/// 音频质量预设枚举
enum QualityPreset {
  /// 高质量 (320kbps, 保持原采样率)
  highQuality,

  /// 标准质量 (192kbps, 44.1kHz)
  standard,

  /// 压缩质量 (128kbps, 44.1kHz)
  compressed,

  /// 自定义参数
  custom,
}

/// QualityPreset 扩展方法
extension QualityPresetExtension on QualityPreset {
  /// 获取预设显示名称
  String get displayName {
    switch (this) {
      case QualityPreset.highQuality:
        return '高质量';
      case QualityPreset.standard:
        return '标准';
      case QualityPreset.compressed:
        return '压缩';
      case QualityPreset.custom:
        return '自定义';
    }
  }

  /// 获取预设描述
  String get description {
    switch (this) {
      case QualityPreset.highQuality:
        return '320kbps, 保持原采样率';
      case QualityPreset.standard:
        return '192kbps, 44.1kHz';
      case QualityPreset.compressed:
        return '128kbps, 44.1kHz';
      case QualityPreset.custom:
        return '自定义参数';
    }
  }

  /// 获取默认比特率 (kbps)
  int get defaultBitrate {
    switch (this) {
      case QualityPreset.highQuality:
        return 320;
      case QualityPreset.standard:
        return 192;
      case QualityPreset.compressed:
        return 128;
      case QualityPreset.custom:
        return 192;
    }
  }

  /// 获取默认采样率 (Hz)
  int? get defaultSampleRate {
    switch (this) {
      case QualityPreset.highQuality:
        return null; // 保持原采样率
      case QualityPreset.standard:
      case QualityPreset.compressed:
      case QualityPreset.custom:
        return 44100;
    }
  }
}
