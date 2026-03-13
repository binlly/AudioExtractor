import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../providers/extraction_provider.dart';
import '../../providers/video_player_provider.dart';

/// 视频播放器组件
class VideoPlayerWidget extends StatelessWidget {
  const VideoPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<VideoPlayerProvider, ExtractionProvider>(
      builder: (context, videoProvider, extractionProvider, child) {
        // 用 DropTarget 包装整个组件
        return DropTarget(
          onDragEntered: (details) {
            // 只在未初始化时响应拖拽
            if (!videoProvider.isInitialized) {
              // 可以添加视觉反馈
            }
          },
          onDragExited: (details) {
            // 清除视觉反馈
          },
          onDragDone: (details) async {
            if (details.files.isEmpty) return;

            final filePath = details.files.first.path;

            // 如果已有视频，询问是否替换
            if (videoProvider.isInitialized) {
              if (!context.mounted) return;

              final shouldReplace = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('替换视频'),
                  content: const Text('是否要替换当前视频？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('取消'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('替换'),
                    ),
                  ],
                ),
              );

              if (shouldReplace != true) return;
            }

            try {
              await _loadVideoFile(
                context,
                filePath,
                videoProvider,
                extractionProvider,
              );
            } catch (e, stackTrace) {
              // 捕获所有异常并记录
              print('❌ 拖拽文件出错: $e');
              print('📚 堆栈跟踪: $stackTrace');

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('加载文件失败: $e')),
                );
              }
            }
          },
          child: _buildContent(context, videoProvider),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, VideoPlayerProvider provider) {
    if (provider.isLoading) {
      return _buildLoadingIndicator();
    }

    if (provider.hasError) {
      return _buildError(context, provider);
    }

    if (!provider.isInitialized) {
      return _buildPlaceholder(context);
    }

    return _buildVideoPlayer(context, provider);
  }

  /// 构建加载指示器
  Widget _buildLoadingIndicator() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(),
            ),
            SizedBox(height: 16),
            Text(
              '正在加载视频...',
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建错误提示
  Widget _buildError(BuildContext context, VideoPlayerProvider provider) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                provider.errorMessage ?? '无法加载视频',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () {
                provider.clearError();
              },
              child: const Text('关闭'),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建占位符
  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _selectVideoFile(
          context,
          context.read<VideoPlayerProvider>(),
          context.read<ExtractionProvider>(),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                '拖拽或点击选择视频文件',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '支持 MP4, MKV, AVI, MOV 等格式',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () => _selectVideoFile(
                  context,
                  context.read<VideoPlayerProvider>(),
                  context.read<ExtractionProvider>(),
                ),
                child: const Text('选择文件'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 选择视频文件
  Future<void> _selectVideoFile(
    BuildContext context,
    VideoPlayerProvider videoProvider,
    ExtractionProvider extractionProvider,
  ) async {
    try {
      // 使用 file_selector 选择文件
      const XTypeGroup typeGroup = XTypeGroup(
        label: '视频文件',
        extensions: <String>['mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'webm', 'm4v', 'mpg', 'mpeg', '3gp', 'ts', 'm2ts'],
      );

      final file = await openFile(
        acceptedTypeGroups: <XTypeGroup>[typeGroup],
      );

      if (file == null) return;

      await _loadVideoFile(
        context,
        file.path,
        videoProvider,
        extractionProvider,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择文件失败: $e')),
        );
      }
    }
  }

  /// 加载视频文件（复用逻辑）
  Future<void> _loadVideoFile(
    BuildContext context,
    String filePath,
    VideoPlayerProvider videoProvider,
    ExtractionProvider extractionProvider,
  ) async {
    // 添加调试日志
    print('📁 加载文件: $filePath');

    // 检查文件是否存在
    final file = File(filePath);
    if (!await file.exists()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('文件不存在，请重试')),
        );
      }
      return;
    }

    // 检查文件格式
    final extension = filePath.split('.').last.toLowerCase();
    print('📝 文件扩展名: .$extension');

    const supportedFormats = [
      'mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'webm', 'm4v',
      'mpg', 'mpeg', '3gp', 'ts', 'm2ts',
    ];

    if (!supportedFormats.contains(extension)) {
      print('❌ 不支持的文件格式');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('不支持的文件格式: .$extension')),
        );
      }
      return;
    }

    if (extractionProvider.canSelectFile) {
      print('✅ 开始加载视频');
      // 同时通知 ExtractionProvider 和 VideoPlayerProvider
      extractionProvider.selectVideoFile(filePath);
      await videoProvider.loadVideo(filePath);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('正在处理中，请稍后')),
        );
      }
    }
  }

  /// 构建视频播放器
  Widget _buildVideoPlayer(BuildContext context, VideoPlayerProvider provider) {
    final controller = provider.controller!;
    final size = controller.value.size;
    final videoAspectRatio = size.width / size.height;

    return GestureDetector(
      onTap: () {
        provider.togglePlayPause();
      },
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 视频显示
              Center(
                child: AspectRatio(
                  aspectRatio: videoAspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),

              // 播放/暂停图标叠加层
              if (!provider.isPlaying)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      size: 80,
                      color: Colors.white70,
                    ),
                  ),
                ),

              // 顶部信息栏
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        provider.isPlaying
                            ? Icons.play_circle_filled
                            : Icons.pause_circle_filled,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        provider.isPlaying ? '播放中' : '已暂停',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatPosition(provider.currentPosition),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const Text(
                        ' / ',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        _formatPosition(provider.totalDuration),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 底部提示
              if (!provider.isPlaying)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                      ),
                    ),
                    child: const Text(
                      '点击视频播放/暂停',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

              // 视频进度指示器
              if (controller.value.isInitialized)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      // 进度条
                      if (provider.isPlaying)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                          child: VideoProgressIndicator(
                            controller,
                            allowScrubbing: false,
                            colors: VideoProgressColors(
                              playedColor: Theme.of(context).primaryColor,
                              bufferedColor: Colors.white24,
                              backgroundColor: Colors.white12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 格式化时间位置
  String _formatPosition(Duration position) {
    final hours = position.inHours;
    final minutes = position.inMinutes.remainder(60);
    final seconds = position.inSeconds.remainder(60);

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
