import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/extraction_provider.dart';

/// 高级设置面板（自定义FFmpeg参数）
class AdvancedSettingsPanel extends StatelessWidget {
  const AdvancedSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExtractionProvider>(
      builder: (context, provider, child) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ExpansionTile(
            leading: const Icon(Icons.settings, size: 20),
            title: const Text(
              '高级设置',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: const Text(
              '自定义FFmpeg参数',
              style: TextStyle(fontSize: 12),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FFmpeg参数说明
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'FFmpeg参数说明',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '这些参数将直接传递给FFmpeg。除非你熟悉FFmpeg，否则建议保持默认设置。',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 自定义参数输入
                    TextField(
                      controller: TextEditingController(text: provider.customFFmpegArgs),
                      decoration: const InputDecoration(
                        labelText: '自定义参数',
                        hintText: '-qscale:a 2 -ar 48000',
                        helperText: '示例：-qscale:a 2 设置VBR质量',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.none,
                      onChanged: (value) {
                        provider.setCustomFFmpegArgs(value.trim());
                      },
                      onSubmitted: (value) {
                        provider.setCustomFFmpegArgs(value.trim());
                      },
                    ),
                    const SizedBox(height: 12),

                    // 常用参数预设
                    const Text(
                      '常用预设',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildPresetChip(
                          context,
                          'VBR高质量',
                          '-qscale:a 0',
                          provider,
                        ),
                        _buildPresetChip(
                          context,
                          'VBR标准',
                          '-qscale:a 2',
                          provider,
                        ),
                        _buildPresetChip(
                          context,
                          '保持原采样率',
                          '-ar 48000',
                          provider,
                        ),
                        _buildPresetChip(
                          context,
                          '双声道',
                          '-ac 2',
                          provider,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 预览命令
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.code, size: 14, color: Colors.grey.shade700),
                              const SizedBox(width: 6),
                              Text(
                                '命令预览',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ffmpeg ${provider.customFFmpegArgs.isNotEmpty ? provider.customFFmpegArgs : '[使用默认参数]'}',
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 重置按钮
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: provider.customFFmpegArgs.isNotEmpty
                            ? () {
                                provider.setCustomFFmpegArgs('');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('已重置为默认参数')),
                                );
                              }
                            : null,
                        icon: const Icon(Icons.restore, size: 16),
                        label: const Text('重置为默认'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPresetChip(
    BuildContext context,
    String label,
    String args,
    ExtractionProvider provider,
  ) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      onPressed: () {
        final currentArgs = provider.customFFmpegArgs;
        final newArgs = currentArgs.isEmpty ? args : '$currentArgs $args';
        provider.setCustomFFmpegArgs(newArgs);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已添加: $args'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      backgroundColor: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
