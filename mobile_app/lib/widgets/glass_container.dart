import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double opacity;
  final double blur;
  final double? width;
  final double? height;
  final Color? borderColor;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final BoxShape shape;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(20.0),
    this.margin,
    this.opacity = 1.0,
    this.blur = 0.0,
    this.width,
    this.height,
    this.borderColor,
    this.backgroundColor,
    this.boxShadow,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackground =
        backgroundColor ?? Colors.white.withOpacity(opacity.clamp(0.0, 1.0));
    final effectiveBorderColor = borderColor ?? const Color(0xFFE7E9F4);
    final effectiveBoxShadow = boxShadow ??
        const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20.0,
            spreadRadius: 0.0,
            offset: Offset(0, 10),
          ),
        ];

    final effectiveRadius = shape == BoxShape.circle ? 1000.0 : borderRadius;

    Widget content = Container(
      width: width ?? double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBackground,
        shape: shape,
        borderRadius:
            shape == BoxShape.circle ? null : BorderRadius.circular(effectiveRadius),
        border: Border.all(color: effectiveBorderColor, width: 1.0),
        boxShadow: effectiveBoxShadow,
      ),
      child: child,
    );

    if (blur > 0) {
      content = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: content,
      );
    }

    return Container(
      width: width ?? double.infinity,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveRadius),
        child: content,
      ),
    );
  }
}

