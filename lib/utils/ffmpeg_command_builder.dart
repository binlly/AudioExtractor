import '../models/extraction_settings.dart';

/// FFmpeg 命令构建器
class FFmpegCommandBuilder {
  /// 构建音频提取命令
  static String buildExtractionCommand({
    required String inputPath,
    required List<int> selectedTrackIndices,
    required ExtractionSettings settings,
    required String outputPath,
  }) {
    if (selectedTrackIndices.isEmpty) {
      throw ArgumentError('至少需要选择一个音轨');
    }

    final args = <String>[];

    // 输入文件（不需要引号，Process.start会自动处理）
    args.add('-i');
    args.add(inputPath);

    // 映射选中的音轨
    for (final index in selectedTrackIndices) {
      args.add('-map');
      args.add('0:a:$index');
    }

    // 全局编码参数（应用于所有音轨）
    args.add('-c:a');
    args.add('libmp3lame'); // 使用libmp3lame编码器

    args.add('-b:a');
    args.add(settings.bitrateParameter);

    // 设置采样率（如果指定）
    final sampleRate = settings.sampleRateParameter;
    if (sampleRate != null) {
      args.add('-ar');
      args.add(sampleRate);
    }

    // 覆盖输出文件
    args.add('-y');

    // 输出文件
    args.add(outputPath);

    // 构建命令字符串（ffmpeg + 参数）
    return 'ffmpeg ${args.map((arg) => '"$arg"').join(' ')}';
  }

  /// 构建单个音轨提取命令
  static String buildSingleTrackExtractionCommand({
    required String inputPath,
    required int trackIndex,
    required ExtractionSettings settings,
    required String outputPath,
  }) {
    final args = <String>[];

    args.add('-i');
    args.add(inputPath);

    args.add('-map');
    args.add('0:a:$trackIndex');

    args.add('-c:a');
    args.add('libmp3lame');

    args.add('-b:a');
    args.add(settings.bitrateParameter);

    // 设置采样率（如果指定）
    final sampleRate = settings.sampleRateParameter;
    if (sampleRate != null) {
      args.add('-ar');
      args.add(sampleRate);
    }

    args.add('-y');
    args.add(outputPath);

    return 'ffmpeg ${args.map((arg) => '"$arg"').join(' ')}';
  }

  /// 从 FFmpeg 日志中解析进度
  static double? parseProgressFromLog(String logMessage) {
    final timeRegex = RegExp(r'time=(\d+):(\d+):(\d+\.\d+)');
    final match = timeRegex.firstMatch(logMessage);

    if (match != null) {
      final hours = int.parse(match.group(1)!);
      final minutes = int.parse(match.group(2)!);
      final seconds = double.parse(match.group(3)!);

      return hours * 3600 + minutes * 60 + seconds;
    }

    return null;
  }
}
