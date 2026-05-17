import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';

/// Resize handler for popup resizing
class ResizeHandler extends StatelessWidget {
  final PopupSizeMode currentSize;
  final Function(PopupSizeMode) onResize;

  const ResizeHandler({
    super.key,
    required this.currentSize,
    required this.onResize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSizeButton(PopupSizeMode.minimised, Icons.circle, 'Min'),
        const SizedBox(width: 16),
        _buildSizeButton(PopupSizeMode.small, Icons.crop_square, 'Small'),
        const SizedBox(width: 16),
        _buildSizeButton(PopupSizeMode.medium, Icons.crop_square, 'Medium'),
        const SizedBox(width: 16),
        _buildSizeButton(PopupSizeMode.large, Icons.fullscreen, 'Large'),
      ],
    );
  }

  Widget _buildSizeButton(PopupSizeMode size, IconData icon, String label) {
    final isSelected = currentSize == size;

    return GestureDetector(
      onTap: () => onResize(size),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPurple.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryPurple : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primaryPurple : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.primaryPurple : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Edge snapping handler
class EdgeSnappingHandler {
  static const double snapThreshold = 20.0;

  static Offset snapToEdge(Offset position, Size screenSize, Size bubbleSize) {
    // Left edge
    if (position.dx < snapThreshold) {
      return Offset(0, position.dy);
    }
    // Right edge
    if (position.dx > screenSize.width - bubbleSize.width - snapThreshold) {
      return Offset(screenSize.width - bubbleSize.width, position.dy);
    }
    // Top edge
    if (position.dy < snapThreshold) {
      return Offset(position.dx, 0);
    }
    // Bottom edge
    if (position.dy > screenSize.height - bubbleSize.height - snapThreshold) {
      return Offset(position.dx, screenSize.height - bubbleSize.height);
    }
    return position;
  }
}