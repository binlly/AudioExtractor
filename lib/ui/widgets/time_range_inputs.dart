import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/video_player_provider.dart';

/// 精确时间输入组件
class TimeRangeInputs extends StatelessWidget {
  const TimeRangeInputs({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoPlayerProvider>(
      builder: (context, provider, child) {
        if (!provider.isInitialized) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              // 开始时间输入
              Expanded(
                child: _TimeInputField(
                  label: '开始时间',
                  timeMs: provider.rangeStart.inMilliseconds,
                  maxMs: provider.totalDuration.inMilliseconds,
                  onChanged: (ms) {
                    provider.setRangeStart(Duration(milliseconds: ms));
                  },
                ),
              ),
              const SizedBox(width: 12),

              // 分隔符
              Text(
                '至',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),

              // 结束时间输入
              Expanded(
                child: _TimeInputField(
                  label: '结束时间',
                  timeMs: provider.rangeEnd.inMilliseconds,
                  maxMs: provider.totalDuration.inMilliseconds,
                  onChanged: (ms) {
                    provider.setRangeEnd(Duration(milliseconds: ms));
                  },
                ),
              ),
              const SizedBox(width: 12),

              // 持续时间显示
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatDuration(Duration(
                    milliseconds: provider.rangeEnd.inMilliseconds - provider.rangeStart.inMilliseconds,
                  )),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'monospace',
                  ),
                ),
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
    final milliseconds = duration.inMilliseconds.remainder(1000);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}.${milliseconds.toString().padLeft(3, '0')}s';
    }
  }
}

/// 时间输入字段组件
class _TimeInputField extends StatefulWidget {
  final String label;
  final int timeMs;
  final int maxMs;
  final ValueChanged<int> onChanged;

  const _TimeInputField({
    required this.label,
    required this.timeMs,
    required this.maxMs,
    required this.onChanged,
  });

  @override
  State<_TimeInputField> createState() => _TimeInputFieldState();
}

class _TimeInputFieldState extends State<_TimeInputField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatMs(widget.timeMs));
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(_TimeInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 只在非编辑状态下更新文本
    if (!_focusNode.hasFocus && oldWidget.timeMs != widget.timeMs) {
      _controller.text = _formatMs(widget.timeMs);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatMs(int milliseconds) {
    final hours = milliseconds ~/ (3600 * 1000);
    final minutes = (milliseconds % (3600 * 1000)) ~/ (60 * 1000);
    final seconds = (milliseconds % (60 * 1000)) ~/ 1000;
    final ms = milliseconds % 1000;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}.'
          '${ms.toString().padLeft(3, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}.'
          '${ms.toString().padLeft(3, '0')}';
    }
  }

  int? _parseTime(String text) {
    try {
      final parts = text.split(':');
      if (parts.length == 2) {
        // MM:SS.mmm
        final minutes = int.parse(parts[0]);
        final secondsParts = parts[1].split('.');
        final seconds = int.parse(secondsParts[0]);
        final ms = secondsParts.length > 1
            ? int.parse(secondsParts[1].padRight(3, '0').substring(0, 3))
            : 0;
        return minutes * 60 * 1000 + seconds * 1000 + ms;
      } else if (parts.length == 3) {
        // HH:MM:SS.mmm
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final secondsParts = parts[2].split('.');
        final seconds = int.parse(secondsParts[0]);
        final ms = secondsParts.length > 1
            ? int.parse(secondsParts[1].padRight(3, '0').substring(0, 3))
            : 0;
        return hours * 3600 * 1000 + minutes * 60 * 1000 + seconds * 1000 + ms;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  void _validateAndUpdate(String text) {
    final parsed = _parseTime(text);

    if (parsed != null && parsed >= 0 && parsed <= widget.maxMs) {
      setState(() {
        _hasError = false;
      });
      widget.onChanged(parsed);
    } else {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: const TextInputType.numberWithOptions(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: _hasError ? Colors.orange.shade300 : Colors.grey.shade300,
                width: _hasError ? 2 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: _hasError ? Colors.orange.shade500 : Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: _hasError ? Colors.orange.shade50 : Colors.white,
            hintText: '00:00:00.000',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.:]')),
          ],
          onSubmitted: (value) {
            _validateAndUpdate(value);
            if (_hasError) {
              // 恢复原值
              _controller.text = _formatMs(widget.timeMs);
            }
            _focusNode.unfocus();
          },
          onChanged: (value) {
            // 实时验证
            _validateAndUpdate(value);
          },
          onEditingComplete: () {
            _focusNode.unfocus();
          },
        ),
        if (_hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '格式: HH:MM:SS.mmm 或 MM:SS.mmm',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }
}
