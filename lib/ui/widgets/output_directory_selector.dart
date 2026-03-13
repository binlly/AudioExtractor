import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/extraction_provider.dart';

/// 输出目录选择器（AppBar 下拉菜单）
class OutputDirectorySelector extends StatelessWidget {
  const OutputDirectorySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExtractionProvider>(
      builder: (context, provider, child) {
        return PopupMenuButton<String>(
          icon: const Row(
            children: [
              Icon(Icons.folder_outlined, size: 20),
              SizedBox(width: 4),
              Text('输出目录', style: TextStyle(fontSize: 14)),
              SizedBox(width: 2),
              Icon(Icons.keyboard_arrow_down, size: 18),
            ],
          ),
          tooltip: '选择输出目录',
          onSelected: (path) async {
            if (path == 'custom') {
              // TODO: 打开自定义目录选择对话框
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('自定义目录选择功能开发中')),
              );
            } else {
              provider.setOutputDirectory(path);
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'downloads',
              child: Row(
                children: [
                  Icon(Icons.download_outlined, size: 18),
                  SizedBox(width: 12),
                  Text('下载目录'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'documents',
              child: Row(
                children: [
                  Icon(Icons.description_outlined, size: 18),
                  SizedBox(width: 12),
                  Text('文档目录'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'desktop',
              child: Row(
                children: [
                  Icon(Icons.desktop_mac_outlined, size: 18),
                  SizedBox(width: 12),
                  Text('桌面'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'movies',
              child: Row(
                children: [
                  Icon(Icons.movie_outlined, size: 18),
                  SizedBox(width: 12),
                  Text('影片目录'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'custom',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, size: 18),
                  SizedBox(width: 12),
                  Text('自定义...'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 输出目录路径工具类
class OutputDirectoryPaths {
  static Future<String> getDownloadsPath() async {
    final dir = await getDownloadsDirectory();
    return '${dir!.path}/ExtractAudio';
  }

  static Future<String> getDocumentsPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/ExtractAudio';
  }

  static Future<String> getDesktopPath() async {
    // macOS 桌面路径
    return '${_homeDirectory()}/Desktop/ExtractAudio';
  }

  static Future<String> getMoviesPath() async {
    // macOS 影片路径
    return '${_homeDirectory()}/Movies/ExtractAudio';
  }

  static String _homeDirectory() {
    // 获取用户主目录
    return '/Users/${_currentUser()}';
  }

  static String _currentUser() {
    // 简单实现：从环境变量或使用固定路径
    // 在实际应用中应该使用更可靠的方法
    return Process.runSync('whoami', []).stdout.toString().trim();
  }
}
