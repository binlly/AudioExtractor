import 'package:flutter/material.dart';
import '../../models/audio_track.dart';

/// 音轨列表项组件
class TrackListItem extends StatelessWidget {
  final AudioTrack track;
  final VoidCallback? onTap;
  final bool isProcessing;

  const TrackListItem({
    super.key,
    required this.track,
    this.onTap,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isProcessing ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: track.isSelected
                ? Theme.of(context).primaryColor.withValues(alpha: 0.5)
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
          color: track.isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // 复选框
            Checkbox(
              value: track.isSelected,
              onChanged: isProcessing
                  ? null
                  : (value) {
                      onTap?.call();
                    },
            ),
            const SizedBox(width: 12),

            // 音轨信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 音轨名称
                  Text(
                    track.languageDisplayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),

                  // 详细信息
                  Text(
                    track.fullDescription,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),

            // 时长
            if (track.duration != Duration.zero)
              Text(
                _formatDuration(track.duration),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
          ],
        ),
      ),
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
}
