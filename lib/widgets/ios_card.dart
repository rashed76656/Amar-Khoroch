import 'package:flutter/material.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';

/// A reusable iOS-style card with rounded corners and subtle shadow.
class IosCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool elevated;

  const IosCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final decoration =
        elevated ? AppTheme.elevatedCardDecoration : AppTheme.cardDecoration;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: decoration,
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }

    return card;
  }
}
