import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';
import '../../providers/extraction_provider.dart';

/// 输出目录选择器组件
class OutputDirectoryPicker extends StatelessWidget {
  const OutputDirectoryPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExtractionProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '输出目录',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),

        // 输出目录路径显示和操作按钮
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.folder_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '文件将保存到：',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatPath(provider.outputDirectory),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 更改目录按钮
                TextButton.icon(
                  onPressed: provider.isProcessing
                      ? null
                      : () async {
                          await _selectDirectory(context, provider);
                        },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('更改'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(width: 4),
                // 打开目录按钮
                IconButton(
                  icon: const Icon(Icons.folder_open_outlined),
                  onPressed: provider.isProcessing
                      ? null
                      : () {
                          provider.openOutputDirectory();
                        },
                  tooltip: '打开目录',
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDirectory(
    BuildContext context,
    ExtractionProvider provider,
  ) async {
    try {
      final directory = await getDirectoryPath();

      if (directory != null) {
        provider.setOutputDirectory(directory);
      }
    } catch (e) {
      debugPrint('选择目录失败: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择目录失败: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _formatPath(String path) {
    // 将 ~ 替换为 Home
    if (path.startsWith('/Users/')) {
      final parts = path.split('/');
      if (parts.length > 2) {
        return '~/${parts.sublist(3).join('/')}';
      }
    }
    return path;
  }
}
