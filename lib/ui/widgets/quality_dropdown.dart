import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/quality_preset.dart';
import '../../providers/extraction_provider.dart';

/// 质量下拉选择器
class QualityDropdown extends StatelessWidget {
  const QualityDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExtractionProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.high_quality,
                    size: 18,
                    color: const Color(0xFF666666),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '音频质量',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF333333),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonHideUnderline(
                child: DropdownButton<QualityPreset>(
                  value: provider.preset,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: QualityPreset.highQuality,
                      child: Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Color(0xFFFFB900)),
                          SizedBox(width: 8),
                          Text('高质量 (320 kbps)'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: QualityPreset.standard,
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 16, color: Color(0xFF0078D4)),
                          SizedBox(width: 8),
                          Text('标准 (192 kbps)'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: QualityPreset.compressed,
                      child: Row(
                        children: [
                          Icon(Icons.compress, size: 16, color: Color(0xFF107C10)),
                          SizedBox(width: 8),
                          Text('压缩 (128 kbps)'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (QualityPreset? preset) {
                    if (preset != null) {
                      provider.setPreset(preset);
                    }
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return const [
                      DropdownMenuItem(
                        value: QualityPreset.highQuality,
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Color(0xFFFFB900)),
                            SizedBox(width: 8),
                            Text('高质量 (320 kbps)'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: QualityPreset.standard,
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 16, color: Color(0xFF0078D4)),
                            SizedBox(width: 8),
                            Text('标准 (192 kbps)'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: QualityPreset.compressed,
                        child: Row(
                          children: [
                            Icon(Icons.compress, size: 16, color: Color(0xFF107C10)),
                            SizedBox(width: 8),
                            Text('压缩 (128 kbps)'),
                          ],
                        ),
                      ),
                    ];
                  },
                  icon: const Icon(Icons.keyboard_arrow_down),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF333333),
                      ),
                  dropdownColor: Colors.white,
                  menuMaxHeight: 200,
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    // 关闭键盘
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getPresetDescription(provider.preset),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getPresetDescription(QualityPreset preset) {
    switch (preset) {
      case QualityPreset.highQuality:
        return '最佳音质，文件较大';
      case QualityPreset.standard:
        return '平衡质量与大小，推荐';
      case QualityPreset.compressed:
        return '节省空间，适合长视频';
      case QualityPreset.custom:
        return '自定义设置';
    }
  }
}
