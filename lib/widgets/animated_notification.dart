import 'package:flutter/material.dart';

class AnimatedNotification extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final Duration duration;
  final VoidCallback? onDismiss;

  const AnimatedNotification({
    Key? key,
    required this.message,
    this.backgroundColor = Colors.red,
    this.textColor = Colors.white,
    this.icon = Icons.error_outline,
    this.duration = const Duration(seconds: 5),
    this.onDismiss,
  }) : super(key: key);

  static void show(
      BuildContext context, {
        required String message,
        Color backgroundColor = Colors.red,
        Color textColor = Colors.white,
        IconData icon = Icons.error_outline,
        Duration duration = const Duration(seconds: 5),
        VoidCallback? onDismiss,
      }) {
    OverlayState overlayState = Overlay.of(context);

    // Initialize the overlayEntry variable with late to ensure it's assigned before use
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => AnimatedNotification(
        message: message,
        backgroundColor: backgroundColor,
        textColor: textColor,
        icon: icon,
        duration: duration,
        onDismiss: () {
          overlayEntry.remove();
          onDismiss?.call();
        },
      ),
    );

    overlayState.insert(overlayEntry);
  }

  @override
  State<AnimatedNotification> createState() => _AnimatedNotificationState();
}

class _AnimatedNotificationState extends State<AnimatedNotification> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    _controller.forward();

    // Auto-dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: 50.0 + _slideAnimation.value,
          left: 0,
          right: 0,
          child: Center(
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8.0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      color: widget.textColor,
                    ),
                    const SizedBox(width: 12.0),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    GestureDetector(
                      onTap: () {
                        _controller.reverse().then((_) {
                          widget.onDismiss?.call();
                        });
                      },
                      child: Icon(
                        Icons.close,
                        color: widget.textColor.withOpacity(0.8),
                        size: 20.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
