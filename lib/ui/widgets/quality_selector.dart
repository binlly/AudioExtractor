import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/quality_preset.dart';
import '../../providers/extraction_provider.dart';

/// 标题栏音频质量选择器（下拉菜单样式）
class QualitySelector extends StatelessWidget {
  const QualitySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExtractionProvider>(
      builder: (context, provider, child) {
        return PopupMenuButton<QualityPreset>(
          icon: const Row(
            children: [
              Icon(Icons.high_quality_outlined, size: 20),
              SizedBox(width: 4),
              Text('质量', style: TextStyle(fontSize: 14)),
              SizedBox(width: 2),
              Icon(Icons.keyboard_arrow_down, size: 18),
            ],
          ),
          tooltip: '音频质量',
          onSelected: (QualityPreset? preset) {
            if (preset != null) {
              provider.setPreset(preset);
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<QualityPreset>(
              value: QualityPreset.highQuality,
              child: Row(
                children: [
                  const Icon(Icons.star, size: 18, color: Color(0xFFFFB900)),
                  const SizedBox(width: 12),
                  const Text('高质量'),
                  const SizedBox(width: 8),
                  Text(
                    '320 kbps',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const Spacer(),
                  if (provider.preset == QualityPreset.highQuality)
                    Icon(Icons.check, size: 18, color: Theme.of(context).primaryColor),
                ],
              ),
            ),
            PopupMenuItem<QualityPreset>(
              value: QualityPreset.standard,
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 18, color: Color(0xFF0078D4)),
                  const SizedBox(width: 12),
                  const Text('标准'),
                  const SizedBox(width: 8),
                  Text(
                    '192 kbps',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const Spacer(),
                  if (provider.preset == QualityPreset.standard)
                    Icon(Icons.check, size: 18, color: Theme.of(context).primaryColor),
                ],
              ),
            ),
            PopupMenuItem<QualityPreset>(
              value: QualityPreset.compressed,
              child: Row(
                children: [
                  const Icon(Icons.compress, size: 18, color: Color(0xFF107C10)),
                  const SizedBox(width: 12),
                  const Text('压缩'),
                  const SizedBox(width: 8),
                  Text(
                    '128 kbps',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const Spacer(),
                  if (provider.preset == QualityPreset.compressed)
                    Icon(Icons.check, size: 18, color: Theme.of(context).primaryColor),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
