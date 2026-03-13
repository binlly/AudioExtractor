import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/video_player_provider.dart';

/// 键盘快捷键处理器
class KeyboardHandler extends StatefulWidget {
  final Widget child;
  final bool isEnabled;

  const KeyboardHandler({
    super.key,
    required this.child,
    this.isEnabled = true,
  });

  @override
  State<KeyboardHandler> createState() => _KeyboardHandlerState();
}

class _KeyboardHandlerState extends State<KeyboardHandler> {
  final FocusNode _focusNode = FocusNode();
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    // 请求焦点以接收键盘事件
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (!widget.isEnabled) return;

    final provider = context.read<VideoPlayerProvider>();
    if (!provider.isInitialized) return;

    // 处理按键按下事件
    if (event is KeyDownEvent) {
      final isShiftPressed = HardwareKeyboard.instance.logicalKeysPressed.contains(
        LogicalKeyboardKey.shiftLeft,
      ) || HardwareKeyboard.instance.logicalKeysPressed.contains(
        LogicalKeyboardKey.shiftRight,
      );

      switch (event.logicalKey) {
        // 空格：播放/暂停
        case LogicalKeyboardKey.space:
          provider.togglePlayPause();
          break;

        // R：从头播放
        case LogicalKeyboardKey.keyR:
          provider.seekTo(Duration.zero);
          provider.play();
          _showSnackBar('从头开始播放');
          break;

        // 左方向键：快退
        case LogicalKeyboardKey.arrowLeft:
          if (isShiftPressed) {
            // Shift + 左：单帧后退
            _seekByFrame(provider, -1);
          } else {
            // 左：快退 5 秒
            final currentPos = provider.currentPosition;
            final newPosition = Duration(
              milliseconds: (currentPos.inMilliseconds - 5000).clamp(0, provider.totalDuration.inMilliseconds),
            );
            provider.seekTo(newPosition);
            _showSnackBar('快退 5 秒');
          }
          break;

        // 右方向键：快进
        case LogicalKeyboardKey.arrowRight:
          if (isShiftPressed) {
            // Shift + 右：单帧前进
            _seekByFrame(provider, 1);
          } else {
            // 右：快进 5 秒
            final currentPos = provider.currentPosition;
            final newPosition = Duration(
              milliseconds: (currentPos.inMilliseconds + 5000).clamp(
                0,
                provider.totalDuration.inMilliseconds,
              ),
            );
            provider.seekTo(newPosition);
            _showSnackBar('快进 5 秒');
          }
          break;

        // 上方向键：不使用（保留未来功能）
        case LogicalKeyboardKey.arrowUp:
          // 暂时不做任何反应
          break;

        // 下方向键：不使用（保留未来功能）
        case LogicalKeyboardKey.arrowDown:
          // 暂时不做任何反应
          break;
      }
    }
  }

  void _seekByFrame(VideoPlayerProvider provider, int frameDirection) {
    // 单帧跳跃（约 1/30 秒，假设 30fps）
    final frameDuration = provider.totalDuration.inMilliseconds ~/ (provider.totalDuration.inSeconds * 30);
    final currentPos = provider.currentPosition;
    final newPosition = Duration(
      milliseconds: (currentPos.inMilliseconds + frameDirection * frameDuration.clamp(33, 100)).clamp(
        0,
        provider.totalDuration.inMilliseconds,
      ),
    );
    provider.seekTo(newPosition);
    provider.pause();
    _showSnackBar(frameDirection > 0 ? '单帧前进' : '单帧后退');
  }

  void _updateVolume() {
    // 注意：video_player 包不支持直接设置音量
    // 这是一个占位符实现
    // 实际应用中可能需要使用其他音量控制方法
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 20,
          right: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: widget.child,
    );
  }
}

/// 键盘快捷键帮助对话框
class KeyboardShortcutsDialog extends StatelessWidget {
  const KeyboardShortcutsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('键盘快捷键'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShortcutItem('空格', '播放 / 暂停'),
            _buildShortcutItem('←', '快退 5 秒'),
            _buildShortcutItem('→', '快进 5 秒'),
            _buildShortcutItem('Shift + ←', '单帧后退'),
            _buildShortcutItem('Shift + →', '单帧前进'),
            _buildShortcutItem('R', '从头开始播放'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }

  Widget _buildShortcutItem(String key, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Text(
              key,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(description),
          ),
        ],
      ),
    );
  }
}
