import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// 文件工具类
class FileUtils {
  /// 获取默认输出目录
  static Future<String> getDefaultOutputDirectory() async {
    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) {
      final extractAudioDir = Directory(path.join(downloadsDir.path, 'ExtractAudio'));
      if (!extractAudioDir.existsSync()) {
        extractAudioDir.createSync(recursive: true);
      }
      return extractAudioDir.path;
    }

    // 回退到应用文档目录
    final appDocDir = await getApplicationDocumentsDirectory();
    final extractAudioDir = Directory(path.join(appDocDir.path, 'ExtractAudio'));
    if (!extractAudioDir.existsSync()) {
      extractAudioDir.createSync(recursive: true);
    }
    return extractAudioDir.path;
  }

  /// 生成输出文件名
  static String generateOutputFileName(String videoPath) {
    final videoName = path.basenameWithoutExtension(videoPath);
    return '$videoName.mp3';
  }

  /// 生成完整的输出文件路径
  static Future<String> generateOutputPath(
    String videoPath,
    String outputDirectory,
  ) async {
    final fileName = generateOutputFileName(videoPath);
    return path.join(outputDirectory, fileName);
  }

  /// 检查文件是否为支持的视频格式
  static bool isSupportedVideoFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    const supportedExtensions = [
      '.mp4',
      '.mkv',
      '.avi',
      '.mov',
      '.wmv',
      '.flv',
      '.webm',
      '.m4v',
      '.mpg',
      '.mpeg',
      '.3gp',
      '.ts',
      '.m2ts',
    ];
    return supportedExtensions.contains(extension);
  }

  /// 获取文件大小（人类可读格式）
  static String getFormattedFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// 格式化时长
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// 检查文件是否存在且可读
  static Future<bool> isFileReadable(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// 获取可用磁盘空间（字节）
  static Future<int?> getAvailableDiskSpace(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      // 注意：dart:io 没有直接获取磁盘空间的方法
      // 这里返回 null，实际应用中可以使用平台特定的方法
      return null;
    } catch (e) {
      return null;
    }
  }
}
