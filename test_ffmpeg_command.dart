import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';

/// 测试 FFmpeg 命令
void main() async {
  // 测试 FFprobe
  print('=== 测试 FFprobe ===');
  try {
    final session = await FFprobeKit.getMediaInformation('/path/to/video.mp4');
    final info = session.getMediaInformation();
    print('FFprobe 结果: ${info?.getAllProperties()}');
  } catch (e) {
    print('FFprobe 错误: $e');
  }

  // 测试 FFmpeg
  print('\n=== 测试 FFmpeg ===');
  try {
    // 测试命令
    final command = 'ffmpeg -version';
    print('执行命令: $command');

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();
    final output = await session.getOutput();

    print('返回码: $returnCode (${returnCode?.getValue()})');
    print('输出:\n$output');
  } catch (e) {
    print('FFmpeg 错误: $e');
  }

  // 测试带引号的路径
  print('\n=== 测试带引号的路径 ===');
  final testPath = '/Users/test/My Video.mp4';
  final commandWithPath = 'ffmpeg -i "$testPath"';
  print('命令: $commandWithPath');

  // 测试不带引号的路径
  print('\n=== 测试不带引号的路径 ===');
  final commandWithoutQuotes = 'ffmpeg -i $testPath';
  print('命令: $commandWithoutQuotes');
}
