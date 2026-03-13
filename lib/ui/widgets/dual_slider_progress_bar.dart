import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/video_player_provider.dart';

/// 双滑块进度条组件（使用 TimeRangeSlider）
class DualSliderProgressBar extends StatelessWidget {
  const DualSliderProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoPlayerProvider>(
      builder: (context, provider, child) {
        if (!provider.isInitialized) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 时间范围信息
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '时间范围',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const Spacer(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Text(
                      '${_formatDuration(provider.rangeStart)} - ${_formatDuration(provider.rangeEnd)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Text(
                      '持续: ${_formatDurationShort(Duration(
                        milliseconds: provider.rangeEnd.inMilliseconds - provider.rangeStart.inMilliseconds,
                      ))}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 双滑块进度条（使用新的 TimeRangeSlider）
              _TimeRangeSliderAdapter(
                totalDuration: provider.totalDuration,
                startTime: provider.rangeStart,
                endTime: provider.rangeEnd,
                onStartTimeChanged: (position) {
                  provider.onSliderDragUpdate(position, isStartSlider: true);
                },
                onEndTimeChanged: (position) {
                  provider.onSliderDragUpdate(position, isStartSlider: false);
                },
                onDragStart: () {
                  provider.onSliderDragStart();
                },
                onDragEnd: () {
                  provider.onSliderDragEnd();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
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

  String _formatDurationShort(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

/// 适配器：将 Duration 转换为毫秒数，用于 TimeRangeSlider
class _TimeRangeSliderAdapter extends StatefulWidget {
  final Duration totalDuration;
  final Duration startTime;
  final Duration endTime;
  final ValueChanged<Duration> onStartTimeChanged;
  final ValueChanged<Duration> onEndTimeChanged;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;

  const _TimeRangeSliderAdapter({
    required this.totalDuration,
    required this.startTime,
    required this.endTime,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
    required this.onDragStart,
    required this.onDragEnd,
  });

  @override
  State<_TimeRangeSliderAdapter> createState() => _TimeRangeSliderAdapterState();
}

class _TimeRangeSliderAdapterState extends State<_TimeRangeSliderAdapter> {
  late int _totalMilliseconds;
  late int _startMilliseconds;
  late int _endMilliseconds;

  @override
  void initState() {
    super.initState();
    _updateMilliseconds();
  }

  @override
  void didUpdateWidget(_TimeRangeSliderAdapter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalDuration != widget.totalDuration ||
        oldWidget.startTime != widget.startTime ||
        oldWidget.endTime != widget.endTime) {
      setState(() {
        _updateMilliseconds();
      });
    }
  }

  void _updateMilliseconds() {
    _totalMilliseconds = widget.totalDuration.inMilliseconds;
    _startMilliseconds = widget.startTime.inMilliseconds;
    _endMilliseconds = widget.endTime.inMilliseconds;
  }

  Duration _millisecondsToDuration(int milliseconds) {
    return Duration(milliseconds: milliseconds);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return TimeRangeSlider(
      initialStartMilliseconds: _startMilliseconds,
      initialEndMilliseconds: _endMilliseconds,
      minMilliseconds: 0,
      maxMilliseconds: _totalMilliseconds,
      activeTrackColor: primaryColor,
      inactiveTrackColor: Colors.grey.shade300,
      thumbColor: Colors.white,
      tooltipColor: primaryColor,
      tooltipTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      onChanging: (startMs, endMs) {
        // 拖动中：只更新视频预览，不更新时间范围
        widget.onDragStart();
        widget.onStartTimeChanged(_millisecondsToDuration(startMs));
      },
      onChanged: (startMs, endMs, startStr, endStr) {
        // 拖动结束：更新时间范围
        widget.onDragEnd();
        widget.onStartTimeChanged(_millisecondsToDuration(startMs));
        widget.onEndTimeChanged(_millisecondsToDuration(endMs));
      },
    );
  }
}

/// 自定义双头拖动时间条（毫秒级精度）
class TimeRangeSlider extends StatefulWidget {
  final int initialStartMilliseconds;
  final int initialEndMilliseconds;
  final int minMilliseconds;
  final int maxMilliseconds;
  final Color activeTrackColor;
  final Color inactiveTrackColor;
  final Color thumbColor;
  final Color tooltipColor;
  final TextStyle tooltipTextStyle;
  final Function(int startMs, int endMs)? onChanging; // 拖动中回调
  final Function(int startMs, int endMs, String startStr, String endStr)? onChanged; // 拖动结束回调

  const TimeRangeSlider({
    Key? key,
    this.initialStartMilliseconds = 0,
    this.initialEndMilliseconds = 86400000, // 24小时
    this.minMilliseconds = 0,
    this.maxMilliseconds = 86400000,
    this.activeTrackColor = Colors.blue,
    this.inactiveTrackColor = Colors.black12,
    this.thumbColor = Colors.white,
    this.tooltipColor = Colors.black87,
    this.tooltipTextStyle = const TextStyle(color: Colors.white, fontSize: 14),
    this.onChanging,
    this.onChanged,
  }) : super(key: key);

  @override
  State<TimeRangeSlider> createState() => _TimeRangeSliderState();
}

class _TimeRangeSliderState extends State<TimeRangeSlider> {
  late RangeValues _currentValues;

  @override
  void initState() {
    super.initState();
    _updateValues();
  }

  @override
  void didUpdateWidget(TimeRangeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当参数变化时（替换视频），更新滑块位置
    if (oldWidget.initialStartMilliseconds != widget.initialStartMilliseconds ||
        oldWidget.initialEndMilliseconds != widget.initialEndMilliseconds ||
        oldWidget.maxMilliseconds != widget.maxMilliseconds) {
      setState(() {
        _updateValues();
      });
    }
  }

  void _updateValues() {
    _currentValues = RangeValues(
      widget.initialStartMilliseconds.toDouble(),
      widget.initialEndMilliseconds.toDouble(),
    );
  }

  /// 将毫秒数转换为 HH:MM:SS 格式
  String _formatTime(double value) {
    final int totalMilliseconds = value.toInt();
    final int hours = (totalMilliseconds ~/ (1000 * 60 * 60)).clamp(0, 23);
    final int minutes = ((totalMilliseconds % (1000 * 60 * 60)) ~/ (1000 * 60)).clamp(0, 59);
    final int seconds = ((totalMilliseconds % (1000 * 60)) ~/ 1000).clamp(0, 59);

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // 计算合适的 divisions 数量，平衡精度和性能
    // 对于长时间视频，使用较大的 division 间隔以保持性能
    final totalMs = widget.maxMilliseconds - widget.minMilliseconds;
    final divisions = totalMs > 600000 // 10分钟以上
        ? (totalMs / 1000).toInt() // 每秒一个刻度
        : totalMs; // 短视频：每毫秒一个刻度

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: widget.activeTrackColor,
        inactiveTrackColor: widget.inactiveTrackColor,
        thumbColor: widget.thumbColor,
        overlayColor: widget.activeTrackColor.withValues(alpha: 0.2),
        valueIndicatorColor: widget.tooltipColor,
        valueIndicatorTextStyle: widget.tooltipTextStyle,
        showValueIndicator: ShowValueIndicator.onlyForDiscrete,
        trackHeight: 8.0,
        rangeThumbShape: const RoundRangeSliderThumbShape(
          enabledThumbRadius: 14.0,
          elevation: 4.0,
        ),
        rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
        overlappingShapeStrokeColor: widget.thumbColor,
      ),
      child: RangeSlider(
        values: _currentValues,
        min: widget.minMilliseconds.toDouble(),
        max: widget.maxMilliseconds.toDouble(),
        divisions: divisions > 0 ? divisions : null,
        labels: RangeLabels(
          _formatTime(_currentValues.start),
          _formatTime(_currentValues.end),
        ),
        onChanged: (RangeValues values) {
          setState(() {
            _currentValues = values;
          });

          // 拖动中：只调用 onChanging，用于实时预览
          if (widget.onChanging != null) {
            widget.onChanging!(
              values.start.toInt(),
              values.end.toInt(),
            );
          }
        },
        onChangeEnd: (RangeValues values) {
          // 拖动结束：调用 onChanged，用于更新时间范围
          if (widget.onChanged != null) {
            widget.onChanged!(
              values.start.toInt(),
              values.end.toInt(),
              _formatTime(values.start),
              _formatTime(values.end),
            );
          }
        },
      ),
    );
  }
}
