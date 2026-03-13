import 'dart:convert';
import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:logger/logger.dart';

/// FFmpeg 服务封装类（使用 ffmpeg_kit_flutter 内置库）
///
/// 优势：
/// - 完全独立，不依赖外部 FFmpeg 安装
/// - 解决双击运行时的 PATH 问题
/// - 跨平台支持
class FFmpegKitService {
  final Logger _logger = Logger();

  /// 分析视频文件，获取媒体信息
  Future<Map<String, dynamic>> analyzeVideo(String videoPath) async {
    _logger.i('开始分析视频: $videoPath');

    try {
      final file = File(videoPath);
      if (!await file.exists()) {
        throw Exception('文件不存在: $videoPath');
      }

      // 使用 FFprobeKit 获取媒体信息
      final session = await FFprobeKit.getMediaInformation(videoPath);
      final info = session.getMediaInformation();

      if (info == null) {
        throw Exception('FFprobe 返回空信息');
      }

      final output = info.getAllProperties();
      _logger.i('视频分析完成');

      // 使用 jsonEncode 而不是 toString()，确保返回有效的 JSON 字符串
      return {'raw_output': jsonEncode(output)};
    } catch (e) {
      _logger.e('视频分析失败: $e');
      rethrow;
    }
  }

  /// 执行 FFmpeg 命令
  ///
  /// 使用参数数组执行，支持日志回调（onOutput/onError）
  Future<void> executeCommand({
    required String inputPath,
    required List<String> additionalArgs,
    required String outputPath,
    Function(String)? onOutput,
    Function(String)? onError,
  }) async {
    // 构建完整的参数列表
    final args = [
      '-i',
      inputPath,
      ...additionalArgs,
      '-y',
      outputPath,
    ];

    _logger.i('执行 FFmpeg 命令: ffmpeg ${args.join(' ')}');

    try {
      // 使用 FFmpegKit.executeWithArguments() 执行命令
      // 这个方法接受参数数组，会正确处理路径中的空格和特殊字符
      final session = await FFmpegKit.executeWithArguments(
        args,
      );

      // 获取返回码
      final returnCode = await session.getReturnCode();

      if (returnCode == null) {
        _logger.e('FFmpeg 返回码为 null');
        throw Exception('FFmpeg 执行失败：未收到返回码');
      }

      if (!returnCode.isValueSuccess()) {
        // 获取错误日志
        final output = await session.getOutput();
        _logger.e('FFmpeg 执行失败，退出码: $returnCode');
        _logger.e('FFmpeg 输出: $output');
        throw Exception('FFmpeg 执行失败，退出码: $returnCode');
      }

      _logger.i('FFmpeg 执行完成');

      // 获取完整日志用于进度解析
      final output = await session.getOutput();
      if (output != null && onError != null) {
        // 将输出传递给回调进行进度解析
        final lines = output.split('\n');
        for (final line in lines) {
          if (line.isNotEmpty) {
            onError.call(line);
          }
        }
      }
    } catch (e) {
      _logger.e('FFmpeg 执行异常: $e');
      rethrow;
    }
  }

  /// 取消正在执行的 FFmpeg 进程
  Future<void> cancelProcess() async {
    try {
      await FFmpegKit.cancel();
      _logger.i('FFmpeg 进程已取消');
    } catch (e) {
      _logger.e('取消 FFmpeg 进程失败: $e');
    }
  }

  /// 检查 FFmpeg 是否可用
  ///
  /// 使用 ffmpeg_kit_flutter 时始终可用
  Future<bool> isFFmpegAvailable() async {
    return true;
  }
}
