import 'package:logger/logger.dart';
import '../models/audio_track.dart';
import '../models/extraction_settings.dart';
import '../models/time_range.dart';
import 'ffmpeg_kit_service.dart';
import 'output_manager.dart';

/// 音频提取服务
class AudioExtractor {
  final FFmpegKitService _ffmpegService;
  final OutputManager _outputManager;
  final Logger _logger = Logger();

  bool _isExtracting = false;

  AudioExtractor({
    FFmpegKitService? ffmpegService,
    OutputManager? outputManager,
  })  : _ffmpegService = ffmpegService ?? FFmpegKitService(),
        _outputManager = outputManager ?? OutputManager();

  /// 提取音频（支持多音轨和时间范围）
  Future<String> extractAudio({
    required String videoPath,
    required List<AudioTrack> selectedTracks,
    required ExtractionSettings settings,
    Function(double)? onProgress,
    Function(String)? onStatusUpdate,
  }) async {
    if (selectedTracks.isEmpty) {
      throw ArgumentError('至少需要选择一个音轨');
    }

    if (_isExtracting) {
      throw StateError('已有提取任务正在进行中');
    }

    _logger.i('开始提取音频');
    onStatusUpdate?.call('准备提取...');
    _isExtracting = true;

    try {
      final outputPath = await _outputManager.generateOutputPath(
        videoPath,
        settings.outputDirectory,
        timeRangeSuffix: settings.timeRange?.fileSuffix,
      );

      final isWritable = await _outputManager.isOutputDirectoryWritable(
        settings.outputDirectory,
      );

      if (!isWritable) {
        throw Exception('输出目录不可写: ${settings.outputDirectory}');
      }

      if (await _outputManager.doesOutputFileExist(outputPath)) {
        onStatusUpdate?.call('删除已存在的文件...');
        await _outputManager.deleteOutputFile(outputPath);
      }

      final selectedIndices = selectedTracks
          .where((track) => track.isSelected)
          .map((track) => track.audioIndex)  // 使用 audioIndex
          .toList();

      _logger.i('选中的音轨音频序号: $selectedIndices');
      onStatusUpdate?.call('构建提取命令...');

      // 构建FFmpeg参数
      final args = <String>[];

      // 添加时间范围参数（如果在输入前添加 -ss 可以更快定位）
      if (settings.timeRange != null && settings.timeRange!.isEnabled) {
        final timeRange = settings.timeRange!;
        if (!timeRange.isValid) {
          throw ArgumentError('时间范围无效：开始时间必须小于结束时间');
        }

        // 添加开始时间参数（在 -i 之前添加可以更快定位）
        args.add('-ss');
        args.add(_formatMsForFFmpeg(timeRange.startMs));

        // 添加持续时间参数（使用 -t 指定从开始时间计算的持续时间）
        final durationMs = timeRange.endMs - timeRange.startMs;
        args.add('-t');
        args.add(_formatMsForFFmpeg(durationMs));

        _logger.i('时间范围: ${timeRange.formattedStart} - ${timeRange.formattedEnd} (持续: ${TimeRange.formatMs(durationMs)})');
      }

      // 映射选中的音轨（使用音频序号）
      for (final audioIndex in selectedIndices) {
        args.add('-map');
        args.add('0:a:$audioIndex');
      }

      // 编码参数
      args.add('-c:a');
      args.add('libmp3lame');
      args.add('-b:a');
      args.add(settings.bitrateParameter);

      // 采样率
      final sampleRate = settings.sampleRateParameter;
      if (sampleRate != null) {
        args.add('-ar');
        args.add(sampleRate);
      }

      _logger.i('FFmpeg 参数: $args');
      onStatusUpdate?.call('开始提取...');

      final startTime = DateTime.now();
      Duration totalDuration = Duration.zero;
      if (selectedTracks.isNotEmpty) {
        totalDuration = selectedTracks.first.duration;
      }

      await _ffmpegService.executeCommand(
        inputPath: videoPath,
        additionalArgs: args,
        outputPath: outputPath,
        onOutput: (line) {
          _logger.d('FFmpeg stdout: $line');
        },
        onError: (line) {
          // FFmpeg 的进度信息在 stderr 中
          final progress = _parseProgress(line, totalDuration);
          if (progress != null && onProgress != null) {
            onProgress(progress);

            final elapsed = DateTime.now().difference(startTime);
            if (progress > 0) {
              final estimatedTotal = elapsed.inMilliseconds / progress;
              final remaining = Duration(
                milliseconds: (estimatedTotal - elapsed.inMilliseconds).toInt(),
              );

              onStatusUpdate?.call(
                '提取中... ${(progress * 100).toStringAsFixed(1)}% '
                '(剩余: ${_formatDuration(remaining)})',
              );
            }
          }
        },
      );

      onStatusUpdate?.call('完成！');
      _logger.i('音频提取完成: $outputPath');

      return outputPath;
    } catch (e) {
      _logger.e('音频提取失败: $e');
      onStatusUpdate?.call('提取失败');
      rethrow;
    } finally {
      _isExtracting = false;
    }
  }

  /// 提取单个音轨
  Future<String> extractSingleTrack({
    required String videoPath,
    required AudioTrack track,
    required ExtractionSettings settings,
    Function(double)? onProgress,
    Function(String)? onStatusUpdate,
  }) async {
    if (_isExtracting) {
      throw StateError('已有提取任务正在进行中');
    }

    _logger.i('开始提取单个音轨: ${track.index}');
    onStatusUpdate?.call('准备提取...');
    _isExtracting = true;

    try {
      final outputPath = await _outputManager.generateOutputPath(
        videoPath,
        settings.outputDirectory,
        timeRangeSuffix: settings.timeRange?.fileSuffix,
      );

      final isWritable = await _outputManager.isOutputDirectoryWritable(
        settings.outputDirectory,
      );

      if (!isWritable) {
        throw Exception('输出目录不可写: ${settings.outputDirectory}');
      }

      if (await _outputManager.doesOutputFileExist(outputPath)) {
        onStatusUpdate?.call('删除已存在的文件...');
        await _outputManager.deleteOutputFile(outputPath);
      }

      _logger.i('执行提取命令...');
      onStatusUpdate?.call('开始提取...');

      final startTime = DateTime.now();

      final args = <String>[];

      // 添加时间范围参数
      if (settings.timeRange != null && settings.timeRange!.isEnabled) {
        final timeRange = settings.timeRange!;
        if (!timeRange.isValid) {
          throw ArgumentError('时间范围无效：开始时间必须小于结束时间');
        }

        args.add('-ss');
        args.add(_formatMsForFFmpeg(timeRange.startMs));

        // 添加持续时间参数（使用 -t 指定从开始时间计算的持续时间）
        final durationMs = timeRange.endMs - timeRange.startMs;
        args.add('-t');
        args.add(_formatMsForFFmpeg(durationMs));

        _logger.i('时间范围: ${timeRange.formattedStart} - ${timeRange.formattedEnd} (持续: ${TimeRange.formatMs(durationMs)})');
      }

      args.addAll([
        '-map', '0:a:${track.audioIndex}',  // 使用 audioIndex
        '-c:a', 'libmp3lame',
        '-b:a', settings.bitrateParameter,
      ]);

      final sampleRate = settings.sampleRateParameter;
      if (sampleRate != null) {
        args.addAll(['-ar', sampleRate]);
      }

      await _ffmpegService.executeCommand(
        inputPath: videoPath,
        additionalArgs: args,
        outputPath: outputPath,
        onOutput: (line) {
          _logger.d('FFmpeg stdout: $line');
        },
        onError: (line) {
          // FFmpeg 的进度信息在 stderr 中
          final progress = _parseProgress(line, track.duration);
          if (progress != null && onProgress != null) {
            onProgress(progress);

            final elapsed = DateTime.now().difference(startTime);
            if (progress > 0) {
              final estimatedTotal = elapsed.inMilliseconds / progress;
              final remaining = Duration(
                milliseconds: (estimatedTotal - elapsed.inMilliseconds).toInt(),
              );

              onStatusUpdate?.call(
                '提取中... ${(progress * 100).toStringAsFixed(1)}% '
                '(剩余: ${_formatDuration(remaining)})',
              );
            }
          }
        },
      );

      onStatusUpdate?.call('完成！');
      _logger.i('音轨提取完成: $outputPath');

      return outputPath;
    } catch (e) {
      _logger.e('音轨提取失败: $e');
      onStatusUpdate?.call('提取失败');
      rethrow;
    } finally {
      _isExtracting = false;
    }
  }

  /// 取消当前提取任务
  Future<void> cancel() async {
    if (_isExtracting) {
      _logger.i('取消提取任务...');
      await _ffmpegService.cancelProcess();
      _isExtracting = false;
    }
  }

  /// 检查是否有正在进行的任务
  bool get isExtracting => _isExtracting;

  /// 解析 FFmpeg 输出中的进度信息
  double? _parseProgress(String line, Duration totalDuration) {
    final timeRegex = RegExp(r'time=(\d+):(\d+):(\d+\.\d+)');
    final match = timeRegex.firstMatch(line);

    if (match != null && totalDuration.inMilliseconds > 0) {
      final hours = int.parse(match.group(1)!);
      final minutes = int.parse(match.group(2)!);
      final seconds = double.parse(match.group(3)!);

      final totalSeconds = hours * 3600 + minutes * 60 + seconds;
      final progress = totalSeconds / (totalDuration.inMilliseconds / 1000);

      return progress.clamp(0.0, 1.0);
    }

    return null;
  }

  /// 格式化时长
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// 将毫秒格式化为 FFmpeg 时间格式 (HH:MM:SS.mmm)
  String _formatMsForFFmpeg(int milliseconds) {
    final hours = milliseconds ~/ (3600 * 1000);
    final minutes = (milliseconds % (3600 * 1000)) ~/ (60 * 1000);
    final seconds = (milliseconds % (60 * 1000)) ~/ 1000;
    final ms = milliseconds % 1000;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}.'
        '${ms.toString().padLeft(3, '0')}';
  }
}
