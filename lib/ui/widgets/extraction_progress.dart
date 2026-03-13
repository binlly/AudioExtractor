import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/extraction_provider.dart';

/// 提取进度显示组件
class ExtractionProgress extends StatelessWidget {
  const ExtractionProgress({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExtractionProvider>();

    if (!provider.isExtracting && provider.currentStatus == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 状态文本
          Row(
            children: [
              if (provider.isExtracting)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              if (provider.isExtracting) const SizedBox(width: 12),
              Expanded(
                child: Text(
                  provider.currentStatus ?? (provider.isExtracting ? '处理中...' : ''),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),

          // 进度条
          if (provider.isExtracting) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: provider.progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 8),
            // 百分比
            Text(
              '${(provider.progress * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],

          // 完成状态
          if (!provider.isExtracting &&
              provider.currentStatus != null &&
              !provider.currentStatus!.contains('提取完成')) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.check_circle_outlined, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provider.currentStatus!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
