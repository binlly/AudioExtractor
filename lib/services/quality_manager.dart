import '../models/quality_preset.dart';

/// 音频质量预设管理器
class QualityManager {
  /// 获取质量预设的显示名称
  static String getDisplayName(QualityPreset preset) {
    return preset.displayName;
  }

  /// 获取质量预设的描述
  static String getDescription(QualityPreset preset) {
    return preset.description;
  }

  /// 获取质量预设的默认比特率（kbps）
  static int getDefaultBitrate(QualityPreset preset) {
    return preset.defaultBitrate;
  }

  /// 获取质量预设的默认采样率（Hz）
  /// 返回 null 表示保持原采样率
  static int? getDefaultSampleRate(QualityPreset preset) {
    return preset.defaultSampleRate;
  }

  /// 获取 FFmpeg 比特率参数
  static String getBitrateParameter(QualityPreset preset, {int? customBitrate}) {
    final bitrate = customBitrate ?? getDefaultBitrate(preset);
    return '${bitrate}k';
  }

  /// 获取 FFmpeg 采样率参数
  /// 返回 null 表示不改变原采样率
  static String? getSampleRateParameter(QualityPreset preset, {int? customSampleRate}) {
    if (preset == QualityPreset.custom && customSampleRate != null) {
      return '$customSampleRate';
    }
    return getDefaultSampleRate(preset)?.toString();
  }

  /// 获取所有可用的质量预设
  static List<QualityPreset> getAllPresets() {
    return QualityPreset.values;
  }

  /// 获取推荐的比特率（基于原音频比特率）
  static int getRecommendedBitrate(int? originalBitrate) {
    if (originalBitrate == null || originalBitrate <= 0) {
      return 192; // 默认标准质量
    }

    // 如果原比特率低于 128k，保持原比特率
    if (originalBitrate < 128000) {
      return 128;
    }

    // 如果原比特率在 128k-192k 之间，使用 192k
    if (originalBitrate < 192000) {
      return 192;
    }

    // 如果原比特率在 192k-320k 之间，使用 320k
    if (originalBitrate < 320000) {
      return 320;
    }

    // 如果原比特率高于 320k，使用 320k（MP3 最大推荐比特率）
    return 320;
  }

  /// 验证自定义比特率是否有效
  static bool isValidBitrate(int bitrate) {
    // MP3 比特率范围：32kbps - 320kbps
    return bitrate >= 32 && bitrate <= 320;
  }

  /// 验证自定义采样率是否有效
  static bool isValidSampleRate(int sampleRate) {
    // 常见采样率：8000, 11025, 12000, 16000, 22050, 24000, 32000, 44100, 48000
    const validRates = [
      8000, 11025, 12000, 16000, 22050, 24000, 32000, 44100, 48000
    ];
    return validRates.contains(sampleRate);
  }

  /// 获取推荐的采样率（基于原音频采样率）
  static int? getRecommendedSampleRate(int? originalSampleRate) {
    if (originalSampleRate == null || originalSampleRate <= 0) {
      return null; // 保持原采样率
    }

    // 如果原采样率已经是标准采样率，保持不变
    if (isValidSampleRate(originalSampleRate)) {
      return originalSampleRate;
    }

    // 否则使用 44.1kHz（最通用的采样率）
    return 44100;
  }
}
