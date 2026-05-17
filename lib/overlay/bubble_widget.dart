import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Floating bubble widget for minimized state
class BubbleWidget extends StatefulWidget {
  final VoidCallback onTap;
  final bool isActive;

  const BubbleWidget({
    super.key,
    required this.onTap,
    this.isActive = true,
  });

  @override
  State<BubbleWidget> createState() => _BubbleWidgetState();
}

class _BubbleWidgetState extends State<BubbleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BubbleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(color: AppColors.primaryPurple, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPink.withOpacity(_glowAnimation.value),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.primaryPink,
                size: 28,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Draggable bubble with position persistence
class DraggableBubble extends StatefulWidget {
  final VoidCallback onExpand;
  final bool isActive;

  const DraggableBubble({
    super.key,
    required this.onExpand,
    this.isActive = true,
  });

  @override
  State<DraggableBubble> createState() => _DraggableBubbleState();
}

class _DraggableBubbleState extends State<DraggableBubble> {
  Offset _position = const Offset(20, 100);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
          });
        },
        onTap: widget.onExpand,
        child: BubbleWidget(
          onTap: widget.onExpand,
          isActive: widget.isActive,
        ),
      ),
    );
  }
}