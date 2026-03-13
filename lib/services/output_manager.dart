import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import '../utils/file_utils.dart';

/// 输出目录和文件管理器
class OutputManager {
  final Logger _logger = Logger();

  /// 默认输出目录名称
  static const String defaultDirectoryName = 'ExtractAudio';

  /// 获取默认输出目录
  Future<String> getDefaultOutputDirectory() async {
    try {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        final extractAudioDir = Directory(
          path.join(downloadsDir.path, defaultDirectoryName),
        );
        await _ensureDirectoryExists(extractAudioDir);
        return extractAudioDir.path;
      }

      // 回退到应用文档目录
      final appDocDir = await getApplicationDocumentsDirectory();
      final extractAudioDir = Directory(
        path.join(appDocDir.path, defaultDirectoryName),
      );
      await _ensureDirectoryExists(extractAudioDir);
      return extractAudioDir.path;
    } catch (e) {
      _logger.e('获取默认输出目录失败: $e');
      // 最后的回退：使用临时目录
      final tempDir = await getTemporaryDirectory();
      final extractAudioDir = Directory(
        path.join(tempDir.path, defaultDirectoryName),
      );
      await _ensureDirectoryExists(extractAudioDir);
      return extractAudioDir.path;
    }
  }

  /// 确保目录存在
  Future<void> _ensureDirectoryExists(Directory directory) async {
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
      _logger.i('创建输出目录: ${directory.path}');
    }
  }

  /// 生成输出文件名（支持时间范围）
  String generateOutputFileName(String videoPath, {String? timeRangeSuffix}) {
    final videoName = path.basenameWithoutExtension(videoPath);
    if (timeRangeSuffix != null && timeRangeSuffix.isNotEmpty) {
      return '$videoName$timeRangeSuffix.mp3';
    }
    return '$videoName.mp3';
  }

  /// 生成完整的输出文件路径（支持时间范围）
  Future<String> generateOutputPath(
    String videoPath,
    String outputDirectory, {
    String? timeRangeSuffix,
  }) async {
    // 确保输出目录存在
    final dir = Directory(outputDirectory);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
      _logger.i('创建输出目录: ${dir.path}');
    }

    final fileName = generateOutputFileName(videoPath, timeRangeSuffix: timeRangeSuffix);
    return path.join(outputDirectory, fileName);
  }

  /// 检查输出目录是否可写
  Future<bool> isOutputDirectoryWritable(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (!directory.existsSync()) {
        await directory.create(recursive: true);
      }

      // 尝试创建一个测试文件
      final testFile = File(path.join(directoryPath, '.write_test'));
      await testFile.writeAsString('test');
      await testFile.delete();

      return true;
    } catch (e) {
      _logger.e('输出目录不可写: $e');
      return false;
    }
  }

  /// 检查输出文件是否已存在
  Future<bool> doesOutputFileExist(String outputPath) async {
    try {
      final file = File(outputPath);
      return await file.exists();
    } catch (e) {
      _logger.e('检查输出文件失败: $e');
      return false;
    }
  }

  /// 删除已存在的输出文件
  Future<void> deleteOutputFile(String outputPath) async {
    try {
      final file = File(outputPath);
      if (await file.exists()) {
        await file.delete();
        _logger.i('删除已存在的输出文件: $outputPath');
      }
    } catch (e) {
      _logger.e('删除输出文件失败: $e');
      rethrow;
    }
  }

  /// 获取输出目录的可用空间
  Future<int> getAvailableDiskSpace(String directoryPath) async {
    try {
      // 注意：dart:io 没有直接获取磁盘空间的方法
      // 这里返回一个估算值或使用平台特定的方法
      // 暂时返回 10GB 作为默认值
      return 10 * 1024 * 1024 * 1024;
    } catch (e) {
      _logger.e('获取可用磁盘空间失败: $e');
      return 0;
    }
  }

  /// 打开输出目录（在文件管理器中）
  Future<void> openOutputDirectory(String directoryPath) async {
    try {
      // 使用 Process.run 打开 Finder
      await Process.run('open', [directoryPath]);
      _logger.i('打开输出目录: $directoryPath');
    } catch (e) {
      _logger.e('打开输出目录失败: $e');
      rethrow;
    }
  }

  /// 清理临时文件
  Future<void> cleanupTempFiles(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (!directory.existsSync()) {
        return;
      }

      final files = directory.listSync();
      int cleanedCount = 0;

      for (var file in files) {
        if (file is File && file.path.endsWith('.tmp')) {
          await file.delete();
          cleanedCount++;
        }
      }

      if (cleanedCount > 0) {
        _logger.i('清理了 $cleanedCount 个临时文件');
      }
    } catch (e) {
      _logger.e('清理临时文件失败: $e');
    }
  }

  /// 获取输出目录中的所有音频文件
  Future<List<File>> getAudioFiles(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (!directory.existsSync()) {
        return [];
      }

      final files = directory.listSync();
      final audioFiles = <File>[];

      const audioExtensions = ['.mp3', '.aac', '.m4a', '.wav', '.flac'];

      for (var file in files) {
        if (file is File) {
          final extension = path.extension(file.path).toLowerCase();
          if (audioExtensions.contains(extension)) {
            audioFiles.add(file);
          }
        }
      }

      return audioFiles;
    } catch (e) {
      _logger.e('获取音频文件列表失败: $e');
      return [];
    }
  }

  /// 格式化文件大小
  String formatFileSize(int bytes) {
    return FileUtils.getFormattedFileSize(bytes);
  }
}
