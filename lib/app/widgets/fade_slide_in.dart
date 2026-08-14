import 'package:flutter/material.dart';

/// Staggered entrance animation: fades and slides a child up into place.
/// Give list items an increasing [index] so they cascade in one after
/// another instead of all popping in at once.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.delayPerIndex = const Duration(milliseconds: 60),
    this.duration = const Duration(milliseconds: 420),
    this.offset = 24,
  });

  final Widget child;
  final int index;
  final Duration delayPerIndex;
  final Duration duration;
  final double offset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _fade = curved;
    _slide = Tween<Offset>(
      begin: Offset(0, widget.offset / 100),
      end: Offset.zero,
    ).animate(curved);

    Future.delayed(widget.delayPerIndex * widget.index, () {
      if (mounted) _controller.forward();
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
      builder: (context, child) => Opacity(
        opacity: _fade.value,
        child: FractionalTranslation(
          translation: _slide.value,
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
