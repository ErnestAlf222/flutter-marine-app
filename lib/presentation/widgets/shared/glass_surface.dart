import 'dart:ui';

import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';

/// Superficie de cristal: translúcida con desenfoque de lo que hay detrás, un borde fino
/// y una luz suave en la esquina superior. Los colores salen de la paleta del tema.
class GlassSurface extends StatelessWidget {
  final Widget child;
  // Con forma circular se ignora [borderRadius]
  final bool circle;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  // Más alfa = más oscuro y opaco; sube en superficies grandes donde importa el contraste
  final double tintAlpha;
  // Color del cristal; por defecto la tinta oscura del tema. Con el acento del tema
  // el cristal se distingue incluso sobre fondos casi negros
  final Color? tint;
  // Opacidad del borde; sube cuando el cristal debe destacar sobre un fondo oscuro
  final double borderAlpha;

  const GlassSurface({
    super.key,
    required this.child,
    this.circle = false,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(DesignConstants.tileRadius),
    ),
    this.padding,
    this.tintAlpha = DesignConstants.glassAlpha,
    this.tint,
    this.borderAlpha = DesignConstants.glassBorderAlpha,
  });

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);

    final decoration = BoxDecoration(
      shape: circle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: circle ? null : borderRadius,
      color: (tint ?? palette.ink).withValues(alpha: tintAlpha),
      // Luz suave: más clara arriba a la izquierda, se apaga hacia abajo
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          palette.paper.withValues(alpha: DesignConstants.glassLightAlpha),
          palette.paper.withValues(alpha: 0),
        ],
      ),
      border: Border.all(
        color: palette.paper.withValues(alpha: borderAlpha),
        width: DesignConstants.glassBorderWidth,
      ),
    );

    final content = DecoratedBox(
      decoration: decoration,
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );

    final blurred = BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: DesignConstants.glassBlur,
        sigmaY: DesignConstants.glassBlur,
      ),
      child: content,
    );

    return circle
        ? ClipOval(child: blurred)
        : ClipRRect(borderRadius: borderRadius, child: blurred);
  }
}
