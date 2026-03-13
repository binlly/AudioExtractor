/// 音频音轨数据模型
class AudioTrack {
  /// 音轨索引（从0开始）
  final int index;

  /// 音频流序号（仅音频流中的序号，从0开始）
  final int audioIndex;

  /// 语言代码（如 "eng", "chi"）
  final String? language;

  /// 编码格式（如 "aac", "ac3", "dts"）
  final String codec;

  /// 采样率（Hz）
  final int sampleRate;

  /// 声道数（1=单声道, 2=立体声）
  final int channels;

  /// 时长
  final Duration duration;

  /// 比特率（bps）
  final int? bitrate;

  /// 是否选中提取（UI状态）
  final bool isSelected;

  AudioTrack({
    required this.index,
    required this.audioIndex,
    this.language,
    required this.codec,
    required this.sampleRate,
    required this.channels,
    required this.duration,
    this.bitrate,
    this.isSelected = true,
  });

  /// 创建副本
  AudioTrack copyWith({
    int? index,
    int? audioIndex,
    String? language,
    String? codec,
    int? sampleRate,
    int? channels,
    Duration? duration,
    int? bitrate,
    bool? isSelected,
  }) {
    return AudioTrack(
      index: index ?? this.index,
      audioIndex: audioIndex ?? this.audioIndex,
      language: language ?? this.language,
      codec: codec ?? this.codec,
      sampleRate: sampleRate ?? this.sampleRate,
      channels: channels ?? this.channels,
      duration: duration ?? this.duration,
      bitrate: bitrate ?? this.bitrate,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  /// 获取语言显示名称
  String get languageDisplayName {
    if (language == null || language!.isEmpty) {
      return '音轨 ${index + 1}';
    }

    const languageMap = {
      'eng': '英语',
      'chi': '中文',
      'zho': '中文',
      'jpn': '日语',
      'kor': '韩语',
      'fre': '法语',
      'fra': '法语',
      'ger': '德语',
      'deu': '德语',
      'spa': '西班牙语',
      'rus': '俄语',
      'ara': '阿拉伯语',
      'por': '葡萄牙语',
      'ita': '意大利语',
    };

    return languageMap[language!.toLowerCase()] ??
        '音轨 ${index + 1} ($language)';
  }

  /// 获取声道显示名称
  String get channelsDisplayName {
    switch (channels) {
      case 1:
        return '单声道';
      case 2:
        return '立体声';
      case 6:
        return '5.1环绕声';
      case 8:
        return '7.1环绕声';
      default:
        return '$channels 声道';
    }
  }

  /// 获取编码显示名称
  String get codecDisplayName {
    return codec.toUpperCase();
  }

  /// 获取完整信息描述
  String get fullDescription {
    final buffer = StringBuffer();
    buffer.write(languageDisplayName);
    buffer.write(' · ');
    buffer.write(codecDisplayName);
    buffer.write(', ');
    buffer.write('${sampleRate}Hz');
    buffer.write(', ');
    buffer.write(channelsDisplayName);
    return buffer.toString();
  }

  @override
  String toString() {
    return 'AudioTrack(index: $index, language: $language, codec: $codec, '
        'sampleRate: $sampleRate, channels: $channels, '
        'duration: $duration, isSelected: $isSelected)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AudioTrack &&
        other.index == index &&
        other.language == language &&
        other.codec == codec &&
        other.sampleRate == sampleRate &&
        other.channels == channels &&
        other.duration == duration &&
        other.isSelected == isSelected;
  }

  @override
  int get hashCode {
    return index.hashCode ^
        language.hashCode ^
        codec.hashCode ^
        sampleRate.hashCode ^
        channels.hashCode ^
        duration.hashCode ^
        isSelected.hashCode;
  }
}
