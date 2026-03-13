import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import '../models/time_range.dart';

/// 视频播放器状态管理 Provider
class VideoPlayerProvider extends ChangeNotifier {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Duration _rangeStart = Duration.zero;
  Duration _rangeEnd = Duration.zero;
  bool _isDraggingSlider = false;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _previewTimer;
  bool _wasPlayingBeforeDrag = false; // 记住拖动前的播放状态

  // ===== Getters =====

  VideoPlayerController? get controller => _controller;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  Duration get rangeStart => _rangeStart;
  Duration get rangeEnd => _rangeEnd;
  bool get isDraggingSlider => _isDraggingSlider;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isInitialized => _controller != null && _controller!.value.isInitialized;

  /// 获取时间范围模型（用于 FFmpeg）
  TimeRange get timeRange => TimeRange(
    startMs: _rangeStart.inMilliseconds,
    endMs: _rangeEnd.inMilliseconds,
    isEnabled: _rangeStart != Duration.zero || _rangeEnd != _totalDuration,
  );

  /// 是否已选择完整视频
  bool get isFullVideoSelected =>
      _rangeStart == Duration.zero && _rangeEnd == _totalDuration;

  // ===== Public Methods =====

  /// 加载视频文件
  Future<void> loadVideo(String videoPath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 使用 print 而不是 debugPrint，确保在 release 模式下也能看到日志
      print('VideoPlayerProvider: 加载视频 $videoPath');

      // 检查文件是否存在
      final file = File(videoPath);
      if (!await file.exists()) {
        throw Exception('文件不存在: $videoPath');
      }

      print('VideoPlayerProvider: 文件存在，大小: ${await file.length()} bytes');

      // 释放旧控制器
      await _disposeController();

      // 创建新控制器
      _controller = VideoPlayerController.file(file);

      print('VideoPlayerProvider: 控制器已创建，开始初始化...');

      // 初始化视频
      await _controller!.initialize();

      print('VideoPlayerProvider: 初始化完成');

      // 获取视频时长
      _totalDuration = _controller!.value.duration;

      // 初始化时间范围为整个视频
      _rangeStart = Duration.zero;
      _rangeEnd = _totalDuration;

      print('VideoPlayerProvider: 视频加载成功，时长: $_totalDuration');

      // 监听播放位置更新
      _controller!.addListener(_onVideoPositionChanged);

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      print('VideoPlayerProvider: 加载失败 $e');
      print('VideoPlayerProvider: 堆栈跟踪: $stackTrace');
      _errorMessage = '无法加载视频: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// 切换播放/暂停
  Future<void> togglePlayPause() async {
    if (!isInitialized) return;

    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// 播放
  Future<void> play() async {
    if (!isInitialized) return;

    await _controller!.play();
    _isPlaying = true;
    notifyListeners();
  }

  /// 暂停
  Future<void> pause() async {
    if (!isInitialized) return;

    await _controller!.pause();
    _isPlaying = false;
    notifyListeners();
  }

  /// 跳转到指定位置
  Future<void> seekTo(Duration position, {bool lowRes = false}) async {
    if (!isInitialized) return;

    // 限制在合法范围内
    final clampedPosition = Duration(
      milliseconds: position.inMilliseconds.clamp(
        0,
        _totalDuration.inMilliseconds,
      ),
    );

    // 低分辨率预览：降低播放速度
    if (lowRes) {
      await _controller!.setPlaybackSpeed(0.5); // 降低到 0.5 倍速
    } else {
      await _controller!.setPlaybackSpeed(1.0); // 恢复正常速度
    }

    await _controller!.seekTo(clampedPosition);
    _currentPosition = clampedPosition;
    notifyListeners();
  }

  /// 设置开始时间
  void setRangeStart(Duration start) {
    // 确保开始时间 < 结束时间
    final clampedStart = Duration(
      milliseconds: start.inMilliseconds.clamp(
        0,
        _rangeEnd.inMilliseconds - 1,
      ),
    );

    _rangeStart = clampedStart;

    // 如果当前播放位置不在新范围内，跳转到开始位置
    if (_currentPosition < _rangeStart || _currentPosition > _rangeEnd) {
      seekTo(_rangeStart);
    }

    notifyListeners();
  }

  /// 设置结束时间
  void setRangeEnd(Duration end) {
    // 确保结束时间 > 开始时间
    final clampedEnd = Duration(
      milliseconds: end.inMilliseconds.clamp(
        _rangeStart.inMilliseconds + 1,
        _totalDuration.inMilliseconds,
      ),
    );

    _rangeEnd = clampedEnd;

    // 如果当前播放位置不在新范围内，跳转到开始位置
    if (_currentPosition > _rangeEnd) {
      seekTo(_rangeStart);
    }

    notifyListeners();
  }

  /// 设置完整时间范围
  void setFullRange() {
    _rangeStart = Duration.zero;
    _rangeEnd = _totalDuration;
    notifyListeners();
  }

  /// 滑块开始拖动
  void onSliderDragStart() {
    _isDraggingSlider = true;

    // 记住拖动前的播放状态
    _wasPlayingBeforeDrag = _isPlaying;

    // 拖动时暂停播放
    if (_isPlaying) {
      pause();
    }

    notifyListeners();
  }

  /// 滑块拖动更新
  void onSliderDragUpdate(Duration position, {bool isStartSlider = true}) {
    if (_isDraggingSlider) {
      // 实时预览：立即跳转，使用低分辨率模式
      seekTo(position, lowRes: true);
    }

    // 更新时间范围
    if (isStartSlider) {
      setRangeStart(position);
    } else {
      setRangeEnd(position);
    }
  }

  /// 滑块结束拖动
  void onSliderDragEnd() {
    _isDraggingSlider = false;
    _previewTimer?.cancel();

    // 恢复正常播放速度
    if (isInitialized) {
      _controller!.setPlaybackSpeed(1.0);
    }

    // 确保跳转到最终位置（开始时间）
    seekTo(_rangeStart, lowRes: false);

    // 如果拖动前正在播放，恢复播放
    if (_wasPlayingBeforeDrag) {
      play();
      _wasPlayingBeforeDrag = false;
    }

    notifyListeners();
  }

  /// 清除错误
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ===== Private Methods =====

  /// 视频位置变化监听
  void _onVideoPositionChanged() {
    if (_controller == null) return;

    final value = _controller!.value;
    _currentPosition = value.position;

    // 如果播放超出结束时间，暂停
    if (_currentPosition >= _rangeEnd && _isPlaying) {
      pause();
      seekTo(_rangeStart);
    }

    // 只在非拖动状态下通知（避免过度更新）
    if (!_isDraggingSlider) {
      notifyListeners();
    }
  }

  /// 释放控制器
  Future<void> _disposeController() async {
    if (_controller != null) {
      _controller!.removeListener(_onVideoPositionChanged);
      await _controller!.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _disposeController();
    _previewTimer?.cancel();
    super.dispose();
  }
}
