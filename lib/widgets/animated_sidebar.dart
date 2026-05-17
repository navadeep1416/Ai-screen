import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';

/// Animated sidebar for mode selection
class AnimatedSidebar extends StatelessWidget {
  final String activeMode;
  final Function(String) onModeSelected;
  final bool isExpanded;

  const AnimatedSidebar({
    super.key,
    required this.activeMode,
    required this.onModeSelected,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isExpanded) return const SizedBox.shrink();

    return Container(
      width: 140,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: RelationshipMode.values.length,
        itemBuilder: (context, index) {
          final mode = RelationshipMode.values[index];
          final isActive = mode.name == activeMode;

          return _ModeItem(
            mode: mode,
            isActive: isActive,
            onTap: () => onModeSelected(mode.name),
          );
        },
      ),
    );
  }
}

class _ModeItem extends StatefulWidget {
  final RelationshipMode mode;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeItem({
    required this.mode,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_ModeItem> createState() => _ModeItemState();
}

class _ModeItemState extends State<_ModeItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: widget.isActive
              ? AppColors.primaryPink.withOpacity(0.15)
              : _isPressed
                  ? AppColors.surface
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: widget.isActive
              ? Border.all(color: AppColors.primaryPink)
              : null,
        ),
        child: Row(
          children: [
            Text(
              widget.mode.emoji,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.mode.name.replaceAllMapped(
                  RegExp(r'([A-Z])'),
                  (m) => ' ${m.group(1)}',
                ),
                style: TextStyle(
                  color: widget.isActive ? Colors.white : AppColors.textSecondary,
                  fontWeight: widget.isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}