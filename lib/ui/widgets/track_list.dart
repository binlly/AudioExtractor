import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/extraction_provider.dart';
import 'track_list_item.dart';

/// 音轨列表组件
class TrackList extends StatelessWidget {
  const TrackList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExtractionProvider>();

    if (!provider.hasTracks) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题和操作按钮
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                '音轨信息',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              // 全选/取消全选按钮
              TextButton(
                onPressed: provider.isProcessing
                    ? null
                    : () {
                        final allSelected = provider.selectedTracksCount ==
                            provider.tracks.length;
                        if (allSelected) {
                          provider.deselectAllTracks();
                        } else {
                          provider.selectAllTracks();
                        }
                      },
                child: Text(
                  provider.selectedTracksCount == provider.tracks.length
                      ? '取消全选'
                      : '全选',
                ),
              ),
            ],
          ),
        ),

        // 音轨列表
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: provider.tracks.length,
              itemBuilder: (context, index) {
                final track = provider.tracks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TrackListItem(
                    track: track,
                    isProcessing: provider.isProcessing,
                    onTap: () {
                      provider.toggleTrackSelection(index);
                    },
                  ),
                );
              },
            ),
          ),
        ),

        // 选中的音轨数量提示
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '已选择 ${provider.selectedTracksCount}/${provider.tracks.length} 个音轨',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ),
      ],
    );
  }
}
