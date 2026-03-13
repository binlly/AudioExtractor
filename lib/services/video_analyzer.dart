import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';
import '../models/audio_track.dart';
import 'ffmpeg_kit_service.dart';

/// 视频分析服务
class VideoAnalyzer {
  final FFmpegKitService _ffmpegService;
  final Logger _logger = Logger();

  VideoAnalyzer({FFmpegKitService? ffmpegService})
      : _ffmpegService = ffmpegService ?? FFmpegKitService();

  /// 分析视频文件，提取所有音轨信息
  Future<List<AudioTrack>> analyzeVideo(String videoPath) async {
    _logger.i('开始分析视频文件: $videoPath');

    // 首先检查文件是否存在
    final file = File(videoPath);
    if (!await file.exists()) {
      _logger.e('文件不存在: $videoPath');
      throw Exception('文件不存在: $videoPath');
    }

    try {
      final result = await _ffmpegService.analyzeVideo(videoPath);
      final rawOutput = result['raw_output'] as String;

      _logger.d('FFprobe 输出长度: ${rawOutput.length}');

      if (rawOutput.isEmpty) {
        throw Exception('FFprobe 返回空输出');
      }

      // 解析 JSON 输出
      final jsonData = jsonDecode(rawOutput) as Map<String, dynamic>;

      final tracks = <AudioTrack>[];

      // 获取视频总时长
      final format = jsonData['format'] as Map<String, dynamic>?;
      final durationStr = format?['duration'] as String?;
      final totalDuration = durationStr != null && durationStr.isNotEmpty
          ? Duration(milliseconds: (double.parse(durationStr) * 1000).round())
          : Duration.zero;

      _logger.i('视频时长: ${totalDuration.inSeconds}秒');

      // 获取所有流
      final streams = jsonData['streams'] as List<dynamic>?;

      if (streams == null || streams.isEmpty) {
        _logger.w('视频不包含任何流');
        throw Exception('视频不包含任何媒体流');
      }

      _logger.i('发现 ${streams.length} 个媒体流');

      // 解析每个音频流
      int audioIndex = 0;
      for (var i = 0; i < streams.length; i++) {
        final stream = streams[i];
        if (stream is! Map<String, dynamic>) continue;

        final codecType = stream['codec_type'] as String?;
        _logger.d('流 $i: codec_type=$codecType');

        if (codecType != 'audio') continue;

        // 提取音轨信息
        final index = stream['index'] as int? ?? i;
        final language = _getLanguageProperty(stream);
        final codec = _getCodecProperty(stream);
        final sampleRate = _getSampleRateProperty(stream);
        final channels = _getChannelsProperty(stream);
        final bitrate = _getBitrateProperty(stream);

        final track = AudioTrack(
          index: index,
          audioIndex: audioIndex,  // 音频流的序号（从0开始）
          language: language,
          codec: codec,
          sampleRate: sampleRate,
          channels: channels,
          duration: totalDuration,
          bitrate: bitrate,
          isSelected: true,
        );

        tracks.add(track);
        _logger.i('发现音轨: ${track.languageDisplayName} (流索引:$index, 音频序号:$audioIndex) - ${track.codec} ${track.sampleRate}Hz ${track.channels}声道');
        audioIndex++;
      }

      if (tracks.isEmpty) {
        _logger.w('未找到音频流');
        throw Exception('该视频不包含音频流');
      }

      _logger.i('分析完成，共发现 ${tracks.length} 个音轨');
      return tracks;
    } on FormatException catch (e) {
      _logger.e('JSON 解析失败: $e');
      throw Exception('无法解析视频信息，请确保视频文件未损坏');
    } catch (e) {
      _logger.e('视频分析失败: $e');
      throw Exception('视频分析失败: $e');
    }
  }

  /// 从流中提取语言信息
  String? _getLanguageProperty(Map<String, dynamic> stream) {
    try {
      final tags = stream['tags'] as Map<String, dynamic>?;
      if (tags != null) {
        return (tags['language'] as String?) ??
            (tags['LANGUAGE'] as String?) ??
            (tags['title'] as String?);
      }
    } catch (e) {
      _logger.w('获取语言信息失败: $e');
    }
    return null;
  }

  /// 从流中提取编码格式
  String _getCodecProperty(Map<String, dynamic> stream) {
    try {
      final codecName = stream['codec_name'] as String?;
      return codecName ?? 'unknown';
    } catch (e) {
      _logger.w('获取编码格式失败: $e');
      return 'unknown';
    }
  }

  /// 从流中提取采样率
  int _getSampleRateProperty(Map<String, dynamic> stream) {
    try {
      final sampleRate = stream['sample_rate'] as String?;
      return sampleRate != null ? int.parse(sampleRate) : 44100;
    } catch (e) {
      _logger.w('获取采样率失败: $e，使用默认值 44100Hz');
      return 44100;
    }
  }

  /// 从流中提取声道数
  int _getChannelsProperty(Map<String, dynamic> stream) {
    try {
      final channels = stream['channels'] as int?;
      return channels ?? 2;
    } catch (e) {
      _logger.w('获取声道数失败: $e，使用默认值 2');
      return 2;
    }
  }

  /// 从流中提取比特率
  int? _getBitrateProperty(Map<String, dynamic> stream) {
    try {
      final bitrate = stream['bit_rate'] as String?;
      return bitrate != null ? int.parse(bitrate) : null;
    } catch (e) {
      _logger.w('获取比特率失败: $e');
      return null;
    }
  }

  /// 获取视频总时长
  Future<Duration> getVideoDuration(String videoPath) async {
    try {
      final result = await _ffmpegService.analyzeVideo(videoPath);
      final rawOutput = result['raw_output'] as String;
      final jsonData = jsonDecode(rawOutput) as Map<String, dynamic>;

      final format = jsonData['format'] as Map<String, dynamic>?;
      final durationStr = format?['duration'] as String?;

      if (durationStr != null && durationStr.isNotEmpty) {
        return Duration(milliseconds: (double.parse(durationStr) * 1000).round());
      }

      return Duration.zero;
    } catch (e) {
      _logger.e('获取视频时长失败: $e');
      return Duration.zero;
    }
  }
}
