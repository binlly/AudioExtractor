import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/extraction_provider.dart';
import '../../providers/video_player_provider.dart';
import '../widgets/advanced_settings_panel.dart';
import '../widgets/dual_slider_progress_bar.dart';
import '../widgets/extraction_progress.dart';
import '../widgets/keyboard_handler.dart';
import '../widgets/output_directory_selector.dart';
import '../widgets/quality_selector.dart';
import '../widgets/track_list.dart';
import '../widgets/video_player_widget.dart';

/// 主页面
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VideoPlayerProvider()),
        ChangeNotifierProvider(create: (_) => ExtractionProvider()),
      ],
      child: KeyboardHandler(
        isEnabled: true,
        child: Scaffold(
          appBar: AppBar(
            title: Consumer2<ExtractionProvider, VideoPlayerProvider>(
              builder: (context, extractionProvider, videoProvider, child) {
                // 显示视频文件名或默认标题
                if (extractionProvider.selectedVideo != null) {
                  final fileName = extractionProvider.selectedVideo!.path.split('/').last;
                  return Text(
                    fileName,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  );
                }
                return const Text('ExtractAudio');
              },
            ),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            elevation: 0,
            actions: const [
              // 音频质量选择器
              Padding(padding: EdgeInsets.only(right: 4), child: QualitySelector()),
              // 输出目录选择器
              Padding(padding: EdgeInsets.only(right: 4), child: OutputDirectorySelector()),
              // 键盘快捷键帮助按钮（最右侧）
              Padding(padding: EdgeInsets.only(right: 16), child: _KeyboardHelpButton()),
            ],
          ),
          body: const _HomeContent(),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExtractionProvider, VideoPlayerProvider>(
      builder: (context, extractionProvider, videoProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 视频播放器
              const VideoPlayerWidget(),
              const SizedBox(height: 16),

              // 双滑块进度条
              if (videoProvider.isInitialized) ...[
                const DualSliderProgressBar(),
                const SizedBox(height: 16),
              ],

              // 音轨列表
              if (extractionProvider.hasTracks) const TrackList(),
              const SizedBox(height: 16),

              // 如果没有音轨，显示音轨列表（全宽）
              if (!extractionProvider.hasTracks) const TrackList(),

              const SizedBox(height: 16),

              // 进度显示
              const ExtractionProgress(),
              const SizedBox(height: 12),

              // 高级设置面板
              const AdvancedSettingsPanel(),
              const SizedBox(height: 12),

              // 错误提示
              if (extractionProvider.hasError)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          extractionProvider.errorMessage!,
                          style: const TextStyle(color: Color(0xFFB71C1C), fontSize: 13),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          extractionProvider.clearError();
                        },
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),

              // 操作按钮
              _buildActionButtons(context, extractionProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, ExtractionProvider provider) {
    return Row(
      children: [
        // 取消按钮（仅在提取时显示）
        if (provider.isExtracting)
          Expanded(
            child: FilledButton.tonalIcon(
              onPressed: provider.isExtracting ? () => provider.cancelExtraction() : null,
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('取消'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),

        if (provider.isExtracting) const SizedBox(width: 12),

        // 开始提取按钮
        Expanded(
          flex: provider.isExtracting ? 1 : 2,
          child: FilledButton.icon(
            onPressed: provider.canStartExtraction
                ? () async {
                    // 在开始提取之前，同步 VideoPlayerProvider 的时间范围到 ExtractionProvider
                    final videoProvider = context.read<VideoPlayerProvider>();
                    if (videoProvider.isInitialized) {
                      provider.setTimeRange(videoProvider.timeRange);
                    }
                    await provider.startExtraction();

                    // 提取完成后显示通知
                    if (context.mounted && provider.outputFilePath != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white),
                              const SizedBox(width: 8),
                              const Text('提取完成！'),
                              const Spacer(),
                            ],
                          ),
                          backgroundColor: Colors.green.shade600,
                          duration: const Duration(seconds: 5),
                          action: SnackBarAction(
                            label: '打开',
                            textColor: Colors.white,
                            onPressed: () => provider.openOutputDirectory(),
                          ),
                        ),
                      );
                    }
                  }
                : null,
            icon: Icon(provider.isExtracting ? Icons.downloading : Icons.play_arrow_outlined),
            label: Text(provider.isExtracting ? '提取中...' : '开始提取'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: provider.canStartExtraction ? null : Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }
}

/// 键盘快捷键帮助按钮
class _KeyboardHelpButton extends StatelessWidget {
  const _KeyboardHelpButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.help_outline),
      tooltip: '键盘快捷键',
      onPressed: () {
        showDialog(context: context, builder: (context) => const KeyboardShortcutsDialog());
      },
    );
  }
}
