import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../models/audio_track.dart';
import '../models/extraction_settings.dart';
import '../models/quality_preset.dart';
import '../models/time_range.dart';
import '../services/audio_extractor.dart';
import '../services/output_manager.dart';
import '../services/video_analyzer.dart';
import '../utils/file_utils.dart';

/// 音频提取状态管理 Provider
class ExtractionProvider extends ChangeNotifier {
  final VideoAnalyzer _videoAnalyzer;
  final AudioExtractor _audioExtractor;
  final OutputManager _outputManager;
  final Logger _logger = Logger();

  // 文件状态
  File? _selectedVideo;
  List<AudioTrack> _tracks = [];
  Duration _videoDuration = Duration.zero;

  // 设置状态
  QualityPreset _preset = QualityPreset.highQuality;
  String _outputDirectory = '';
  TimeRange _timeRange = const TimeRange();
  String _customFFmpegArgs = '';

  // 处理状态
  bool _isAnalyzing = false;
  bool _isExtracting = false;
  double _progress = 0.0;
  String? _currentStatus;

  // 错误状态
  String? _errorMessage;

  // 输出文件路径
  String? _outputFilePath;

  ExtractionProvider({
    VideoAnalyzer? videoAnalyzer,
    AudioExtractor? audioExtractor,
    OutputManager? outputManager,
  }) : _videoAnalyzer = videoAnalyzer ?? VideoAnalyzer(),
       _audioExtractor = audioExtractor ?? AudioExtractor(),
       _outputManager = outputManager ?? OutputManager() {
    _initializeDefaultOutputDirectory();
  }

  // ===== Getters =====

  /// 选中的视频文件
  File? get selectedVideo => _selectedVideo;

  /// 音轨列表
  List<AudioTrack> get tracks => _tracks;

  /// 是否有音轨
  bool get hasTracks => _tracks.isNotEmpty;

  /// 质量预设
  QualityPreset get preset => _preset;

  /// 输出目录
  String get outputDirectory => _outputDirectory;

  /// 是否正在分析
  bool get isAnalyzing => _isAnalyzing;

  /// 是否正在提取
  bool get isExtracting => _isExtracting;

  /// 是否正在处理（分析或提取）
  bool get isProcessing => _isAnalyzing || _isExtracting;

  /// 进度（0.0 - 1.0）
  double get progress => _progress;

  /// 当前状态描述
  String? get currentStatus => _currentStatus;

  /// 错误信息
  String? get errorMessage => _errorMessage;

  /// 是否有错误
  bool get hasError => _errorMessage != null;

  /// 输出文件路径
  String? get outputFilePath => _outputFilePath;

  /// 选中的音轨数量
  int get selectedTracksCount => _tracks.where((t) => t.isSelected).length;

  /// 时间范围
  TimeRange get timeRange => _timeRange;

  /// 视频总时长
  Duration get videoDuration => _videoDuration;

  /// 是否可以选择文件
  bool get canSelectFile => !isProcessing;

  /// 是否可以开始提取
  bool get canStartExtraction => !isProcessing && _selectedVideo != null && selectedTracksCount > 0;

  // ===== 初始化 =====

  /// 初始化默认输出目录
  Future<void> _initializeDefaultOutputDirectory() async {
    try {
      _outputDirectory = await _outputManager.getDefaultOutputDirectory();
      notifyListeners();
    } catch (e) {
      _logger.e('初始化输出目录失败: $e');
      // 使用环境变量展开主目录路径
      final homeDir = Platform.environment['HOME'];
      if (homeDir == null) {
        throw Exception('无法获取主目录路径');
      }
      _outputDirectory = '$homeDir/Downloads/ExtractAudio';
      notifyListeners();
    }
  }

  // ===== 文件操作 =====

  /// 选择视频文件
  Future<void> selectVideoFile(String filePath) async {
    clearError();
    _reset();

    if (!FileUtils.isSupportedVideoFile(filePath)) {
      _setError('不支持的视频格式');
      return;
    }

    if (!await FileUtils.isFileReadable(filePath)) {
      _setError('无法读取文件');
      return;
    }

    _selectedVideo = File(filePath);
    notifyListeners();

    await _analyzeVideo();
  }

  /// 分析视频文件
  Future<void> _analyzeVideo() async {
    if (_selectedVideo == null) return;

    _isAnalyzing = true;
    _currentStatus = '正在分析视频...';
    _progress = 0.0;
    notifyListeners();

    try {
      _logger.i('开始分析视频: ${_selectedVideo!.path}');
      _tracks = await _videoAnalyzer.analyzeVideo(_selectedVideo!.path);

      if (_tracks.isEmpty) {
        _setError('视频不包含音轨');
      } else {
        _logger.i('分析完成，发现 ${_tracks.length} 个音轨');
        // 获取视频时长
        if (_tracks.isNotEmpty) {
          _videoDuration = _tracks.first.duration;
          // 重置时间范围为整个视频时长
          _timeRange = TimeRange(
            startMs: 0,
            endMs: _videoDuration.inMilliseconds,
            isEnabled: false,
          );
        }
      }

      _isAnalyzing = false;
      _currentStatus = null;
      notifyListeners();
    } catch (e) {
      _logger.e('视频分析失败: $e');
      _setError('视频分析失败: $e');
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  // ===== 音轨操作 =====

  /// 切换音轨选中状态
  void toggleTrackSelection(int index) {
    if (index >= 0 && index < _tracks.length) {
      _tracks[index] = _tracks[index].copyWith(isSelected: !_tracks[index].isSelected);
      notifyListeners();
    }
  }

  /// 全选音轨
  void selectAllTracks() {
    _tracks = _tracks.map((t) => t.copyWith(isSelected: true)).toList();
    notifyListeners();
  }

  /// 取消全选音轨
  void deselectAllTracks() {
    _tracks = _tracks.map((t) => t.copyWith(isSelected: false)).toList();
    notifyListeners();
  }

  // ===== 设置操作 =====

  /// 设置质量预设
  void setPreset(QualityPreset preset) {
    _preset = preset;
    notifyListeners();
  }

  /// 设置输出目录
  void setOutputDirectory(String directory) {
    _outputDirectory = directory;
    notifyListeners();
  }

  /// 自定义FFmpeg参数
  String get customFFmpegArgs => _customFFmpegArgs;

  /// 设置自定义FFmpeg参数
  void setCustomFFmpegArgs(String args) {
    _customFFmpegArgs = args;
    notifyListeners();
  }

  /// 设置时间范围
  void setTimeRange(TimeRange timeRange) {
    _timeRange = timeRange;
    notifyListeners();
  }

  // ===== 提取操作 =====

  /// 开始提取
  Future<void> startExtraction() async {
    if (!canStartExtraction) {
      _setError('无法开始提取：请先选择视频和音轨');
      return;
    }

    clearError();
    _isExtracting = true;
    _progress = 0.0;
    _currentStatus = '准备提取...';
    notifyListeners();

    try {
      final selectedTracks = _tracks.where((t) => t.isSelected).toList();
      final settings = ExtractionSettings(
        preset: _preset,
        outputDirectory: _outputDirectory,
        timeRange: _timeRange.isEnabled ? _timeRange : null,
      );

      _logger.i('开始提取 ${selectedTracks.length} 个音轨');

      _outputFilePath = await _audioExtractor.extractAudio(
        videoPath: _selectedVideo!.path,
        selectedTracks: selectedTracks,
        settings: settings,
        onProgress: (value) {
          _progress = value;
          notifyListeners();
        },
        onStatusUpdate: (status) {
          _currentStatus = status;
          notifyListeners();
        },
      );

      _logger.i('提取完成: $_outputFilePath');
      _currentStatus = '提取完成！';
      _isExtracting = false;
      notifyListeners();
    } catch (e) {
      _logger.e('提取失败: $e');
      _setError('提取失败: $e');
      _isExtracting = false;
      notifyListeners();
    }
  }

  /// 取消提取
  Future<void> cancelExtraction() async {
    if (_isExtracting) {
      try {
        await _audioExtractor.cancel();
        _isExtracting = false;
        _currentStatus = '已取消';
        notifyListeners();
      } catch (e) {
        _logger.e('取消失败: $e');
        _setError('取消失败: $e');
      }
    }
  }

  /// 打开输出目录
  Future<void> openOutputDirectory() async {
    try {
      await _outputManager.openOutputDirectory(_outputDirectory);
    } catch (e) {
      _logger.e('打开输出目录失败: $e');
      _setError('无法打开输出目录: $e');
    }
  }

  // ===== 重置操作 =====

  /// 重置状态
  void _reset() {
    _selectedVideo = null;
    _tracks = [];
    _outputFilePath = null;
    _progress = 0.0;
    _currentStatus = null;
    _videoDuration = Duration.zero;
    _timeRange = const TimeRange();
    notifyListeners();
  }

  /// 清除错误
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 设置错误
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  @override
  void dispose() {
    // 取消正在进行的任务
    if (_isExtracting) {
      _audioExtractor.cancel();
    }
    super.dispose();
  }
}
