import 'dart:math';
import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/widgets/shared/ocean_map_geometry.dart';

// Mapa de las zonas dibujado por nosotros, sin teselas: tierra firme de Natural Earth
// y un círculo que brilla en el centro de cada zona. Tiene dos modos:
// - completo: pan, zoom y toque en las zonas;
// - compacto: sin gestos, encuadrado en las zonas resaltadas y con el resto atenuado.
class OceanMap extends StatefulWidget {
  final List<OceanZone> zones;
  // Anillos de tierra firme; mientras llegan (o si fallan) el mapa se ve sin tierra
  final List<Float64List>? land;
  // Solo en modo compacto: zonas que se resaltan
  final Set<String> highlighted;
  final bool compact;
  final String? selectedId;
  // Alto (px) del borde inferior del mapa que tapa algo, como la hoja de una zona: la zona
  // seleccionada se centra en el resto
  final double focusInset;
  final ValueChanged<OceanZone>? onZoneTap;

  const OceanMap({
    super.key,
    required this.zones,
    this.land,
    this.highlighted = const {},
    this.compact = false,
    this.selectedId,
    this.focusInset = 0,
    this.onZoneTap,
  });

  @override
  State<OceanMap> createState() => _OceanMapState();
}

class _OceanMapState extends State<OceanMap>
    with SingleTickerProviderStateMixin {
  TransformationController? _controller;
  // Anima el acercamiento a la zona seleccionada
  late final AnimationController _move = AnimationController(
    vsync: this,
    duration: MotionConstants.mapFocus,
  );
  ({ViewTransform from, ViewTransform to})? _moveSpan;
  // Vista previa a la selección, para volver a ella al cerrar la hoja
  ViewTransform? _restore;
  Size? _viewport;
  MapProjection? _projection;
  Path? _landPath;

  Size get _worldSize => Size(_projection!.worldWidth, _projection!.height);

  @override
  void initState() {
    super.initState();
    _move.addListener(_onMove);
  }

  @override
  void dispose() {
    _move.dispose();
    _controller?.dispose();
    super.dispose();
  }

  void _onMove() {
    final span = _moveSpan;
    final controller = _controller;
    final viewport = _viewport;
    if (span == null || controller == null || viewport == null) return;

    final t = MotionConstants.curve.transform(_move.value);
    controller.value = _toMatrix(
      clampTransform(
        ViewTransform(
          lerpDouble(span.from.scale, span.to.scale, t)!,
          Offset.lerp(span.from.translation, span.to.translation, t)!,
        ),
        _worldSize,
        viewport,
      ),
    );
  }

  // Lleva la vista a [target], animada salvo con animaciones reducidas o si se pide un salto
  // (al arrastrar la hoja el mapa sigue al dedo sin retraso)
  void _moveTo(ViewTransform target, {required bool animate}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = _controller;
      if (!mounted || controller == null) return;

      _move.stop();
      if (!animate || MediaQuery.disableAnimationsOf(context)) {
        controller.value = _toMatrix(target);
        return;
      }
      _moveSpan = (from: _fromMatrix(controller.value), to: target);
      _move.forward(from: 0);
    });
  }

  @override
  void didUpdateWidget(OceanMap old) {
    super.didUpdateWidget(old);
    final projection = _projection;
    if (projection == null) return;

    // El Path se reconstruye solo si llegan datos de tierra nuevos
    if (!identical(old.land, widget.land)) _landPath = _buildPath(projection);

    if (widget.compact) {
      if (!setEquals(old.highlighted, widget.highlighted) ||
          !identical(old.zones, widget.zones)) {
        _applyAfterFrame(_initialTransform());
      }
    } else if (widget.selectedId != old.selectedId) {
      if (widget.selectedId != null) {
        _restore ??= _fromMatrix(_controller!.value);
        _focusSelected(animate: true);
      } else if (_restore != null) {
        final back = _restore!;
        _restore = null;
        _moveTo(back, animate: true);
      }
    } else if (widget.selectedId != null &&
        widget.focusInset != old.focusInset) {
      _focusSelected(animate: false);
    }
  }

  Path? _buildPath(MapProjection projection) {
    final land = widget.land;
    return land == null ? null : buildLandPath(land, projection);
  }

  Matrix4 _toMatrix(ViewTransform t) =>
      Matrix4.translationValues(t.translation.dx, t.translation.dy, 0)
        ..scaleByDouble(t.scale, t.scale, 1, 1);

  ViewTransform _fromMatrix(Matrix4 m) =>
      ViewTransform(m.storage[0], Offset(m.storage[12], m.storage[13]));

  // Cambiar el controlador durante el build avisaría a sus oyentes en pleno build
  void _applyAfterFrame(ViewTransform t) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller?.value = _toMatrix(t);
    });
  }

  ViewTransform _initialTransform() {
    final projection = _projection!;
    final viewport = _viewport!;

    if (!widget.compact) {
      return centerOn(
        worldPoint: projection.project(
          MapConstants.initialCenterLat,
          MapConstants.initialCenterLon,
        ),
        scale: MapConstants.minScale,
        world: _worldSize,
        viewport: viewport,
      );
    }

    // Compacto: caja de las zonas resaltadas, con margen y un mínimo para no acercar de más
    final focus = widget.zones
        .where((z) => widget.highlighted.contains(z.id))
        .toList();
    final points = focus.isEmpty ? widget.zones : focus;
    if (points.isEmpty) {
      return ViewTransform(1, Offset.zero);
    }

    var lonMin = points.map((z) => z.lon).reduce(min);
    var lonMax = points.map((z) => z.lon).reduce(max);
    var latMin = points.map((z) => z.lat).reduce(min);
    var latMax = points.map((z) => z.lat).reduce(max);
    lonMin -= MapConstants.compactLonPadding;
    lonMax += MapConstants.compactLonPadding;
    latMin -= MapConstants.compactLatPadding;
    latMax += MapConstants.compactLatPadding;

    final lonMid = (lonMin + lonMax) / 2;
    final latMid = (latMin + latMax) / 2;
    final lonHalf = max(lonMax - lonMin, MapConstants.compactMinLonSpan) / 2;
    final latHalf = max(latMax - latMin, MapConstants.compactMinLatSpan) / 2;

    return fitBounds(
      projection: projection,
      lonMin: lonMid - lonHalf,
      lonMax: lonMid + lonHalf,
      latMin: latMid - latHalf,
      latMax: latMid + latHalf,
      box: viewport,
    );
  }

  // Acerca la zona seleccionada y la centra en la parte del mapa que nada tapa
  void _focusSelected({required bool animate}) {
    final zone = widget.zones
        .where((z) => z.id == widget.selectedId)
        .firstOrNull;
    final controller = _controller;
    final viewport = _viewport;
    if (zone == null || controller == null || viewport == null) return;

    final current = _fromMatrix(controller.value);
    final free = max(
      viewport.height - widget.focusInset,
      MapConstants.minFreeHeight,
    );
    _moveTo(
      centerOn(
        worldPoint: _projection!.project(zone.lat, zone.lon),
        scale: min(
          max(current.scale, MapConstants.focusScale),
          MapConstants.maxScale,
        ),
        world: _worldSize,
        viewport: viewport,
        anchor: Offset(viewport.width / 2, free / 2),
      ),
      animate: animate,
    );
  }

  // Se recalcula solo cuando cambia el tamaño del marco
  void _configure(Size size) {
    _viewport = size;
    _projection = MapProjection(
      worldWidth: size.width * MapConstants.worldWidthFactor,
      height: size.height,
    );
    _landPath = _buildPath(_projection!);

    final initial = _initialTransform();
    if (_controller == null) {
      _controller = TransformationController(_toMatrix(initial));
    } else {
      _applyAfterFrame(initial);
    }
  }

  List<ZoneAnchor> _anchors() {
    final projection = _projection!;
    final transform = _fromMatrix(_controller!.value);
    final maxCount = widget.zones.fold<int>(
      0,
      (m, z) => max(m, z.speciesCount),
    );

    return [
      for (final zone in widget.zones)
        ZoneAnchor(
          id: zone.id,
          center: transform.apply(projection.project(zone.lat, zone.lon)),
          radius: zoneRadius(
            count: zone.speciesCount,
            maxCount: maxCount,
            scale: transform.scale,
            compact: widget.compact,
          ),
        ),
    ];
  }

  void _onTap(TapUpDetails details) {
    final id = resolveZoneTap(details.localPosition, _anchors());
    if (id == null) return;
    widget.onZoneTap?.call(widget.zones.firstWhere((z) => z.id == id));
  }

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        if (!size.isFinite || size.isEmpty) return const SizedBox.shrink();
        if (_viewport != size) _configure(size);

        final controller = _controller!;
        final projection = _projection!;

        final map = ClipRect(
          child: DecoratedBox(
            decoration: BoxDecoration(color: palette.abyss),
            child: Stack(
              fit: StackFit.expand,
              children: [
                InteractiveViewer(
                  transformationController: controller,
                  constrained: false,
                  panEnabled: !widget.compact,
                  scaleEnabled: !widget.compact,
                  minScale: widget.compact ? 0.01 : MapConstants.minScale,
                  maxScale: widget.compact ? 100 : MapConstants.maxScale,
                  // Sin margen: el mapa no se arrastra más allá de sus bordes
                  boundaryMargin: widget.compact
                      ? const EdgeInsets.all(double.infinity)
                      : EdgeInsets.zero,
                  child: SizedBox.fromSize(
                    size: _worldSize,
                    child: CustomPaint(
                      painter: _LandPainter(
                        path: _landPath,
                        fill: palette.deep,
                        stroke: palette.reef,
                      ),
                    ),
                  ),
                ),
                // Círculos y etiquetas van en pantalla, no dentro del zoom: así no
                // crecen sin control al acercar
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapUp: widget.compact ? null : _onTap,
                    child: CustomPaint(
                      painter: _ZonesPainter(
                        transform: controller,
                        projection: projection,
                        zones: widget.zones,
                        palette: palette,
                        selectedId: widget.selectedId,
                        highlighted: widget.compact ? widget.highlighted : null,
                        labelStyle: (textTheme.labelMedium ?? const TextStyle())
                            .copyWith(
                              fontSize: MapConstants.labelFontSize,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                ),
                if (!widget.compact)
                  AnimatedBuilder(
                    animation: controller,
                    builder: (context, _) => _ZoneSemantics(
                      anchors: _anchors(),
                      zones: widget.zones,
                      onTap: widget.onZoneTap,
                    ),
                  ),
              ],
            ),
          ),
        );

        if (!widget.compact) return map;

        // El mini mapa es solo informativo: no recibe toques ni gestos
        final names = widget.zones
            .where((z) => widget.highlighted.contains(z.id))
            .map((z) => z.name)
            .join(', ');
        return Semantics(
          label: 'Mapa de las zonas donde vive: $names',
          child: ExcludeSemantics(child: IgnorePointer(child: map)),
        );
      },
    );
  }
}

// Un nodo de accesibilidad por zona, con su nombre y conteo, sobre cada círculo
class _ZoneSemantics extends StatelessWidget {
  final List<ZoneAnchor> anchors;
  final List<OceanZone> zones;
  final ValueChanged<OceanZone>? onTap;

  const _ZoneSemantics({
    required this.anchors,
    required this.zones,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (var i = 0; i < anchors.length; i++)
          Positioned.fromRect(
            rect: Rect.fromCircle(
              center: anchors[i].center,
              radius: anchors[i].radius,
            ),
            child: Semantics(
              container: true,
              button: true,
              label:
                  '${zones[i].name}, ${formatSpeciesCount(zones[i].speciesCount)} especies',
              onTap: onTap == null ? null : () => onTap!(zones[i]),
              child: const SizedBox.expand(),
            ),
          ),
      ],
    );
  }
}

// Tierra firme: el Path ya viene construido y solo se repinta si cambia
class _LandPainter extends CustomPainter {
  final Path? path;
  final Color fill;
  final Color stroke;

  const _LandPainter({
    required this.path,
    required this.fill,
    required this.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final land = path;
    if (land == null) return;

    canvas.drawPath(land, Paint()..color = fill);
    canvas.drawPath(
      land,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6
        ..color = stroke,
    );
  }

  @override
  bool shouldRepaint(_LandPainter old) =>
      !identical(old.path, path) || old.fill != fill || old.stroke != stroke;
}

// Brillo, nombre y conteo de cada zona, en coordenadas de pantalla. Se repinta al
// mover el mapa porque escucha el controlador de la transformación.
class _ZonesPainter extends CustomPainter {
  final TransformationController transform;
  final MapProjection projection;
  final List<OceanZone> zones;
  final OceanPalette palette;
  final String? selectedId;
  // null en el mapa completo; en el compacto, las zonas resaltadas
  final Set<String>? highlighted;
  final TextStyle labelStyle;

  _ZonesPainter({
    required this.transform,
    required this.projection,
    required this.zones,
    required this.palette,
    required this.selectedId,
    required this.highlighted,
    required this.labelStyle,
  }) : super(repaint: transform);

  bool get _compact => highlighted != null;

  bool _isLit(OceanZone zone) => highlighted?.contains(zone.id) ?? true;

  @override
  void paint(Canvas canvas, Size size) {
    final m = transform.value;
    final view = ViewTransform(
      m.storage[0],
      Offset(m.storage[12], m.storage[13]),
    );
    final maxCount = zones.fold<int>(0, (a, z) => max(a, z.speciesCount));

    final items = [
      for (final zone in zones)
        (
          zone: zone,
          center: view.apply(projection.project(zone.lat, zone.lon)),
          radius: zoneRadius(
            count: zone.speciesCount,
            maxCount: maxCount,
            scale: view.scale,
            compact: _compact,
          ),
        ),
    ]..sort((a, b) => b.radius.compareTo(a.radius));

    for (final item in items) {
      final lit = _isLit(item.zone);
      final selected = item.zone.id == selectedId;
      // Con una zona seleccionada, las demás se atenúan para que ella destaque
      final alpha = zoneAlpha(
        lit: lit,
        selectedId: selectedId,
        zoneId: item.zone.id,
      );
      final color = palette.zoneColor(item.zone.id).withValues(alpha: alpha);
      final glow = item.radius * 1.6;

      canvas.drawCircle(
        item.center,
        glow,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: MapConstants.glowAlpha * color.a),
              color.withValues(alpha: 0.4 * color.a),
              color.withValues(alpha: 0),
            ],
            stops: const [0, 0.55, 1],
          ).createShader(Rect.fromCircle(center: item.center, radius: glow)),
      );
      canvas.drawCircle(
        item.center,
        item.radius * MapConstants.coreRadiusFactor,
        Paint()
          ..color = palette.paper.withValues(alpha: lit ? 0.95 * alpha : 0.3),
      );

      if (selected) {
        // Anillo del color de la zona dentro de otro blanco: se ve sobre tierra y sobre mar
        canvas.drawCircle(
          item.center,
          glow,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = MapConstants.selectedRingWidth
            ..color = palette.paper,
        );
        canvas.drawCircle(
          item.center,
          item.radius * MapConstants.coreRadiusFactor * 1.9,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = MapConstants.selectedRingWidth
            ..color = palette.zoneColor(item.zone.id),
        );
      }
    }

    _paintLabels(canvas, size, items);
  }

  void _paintLabels(
    Canvas canvas,
    Size size,
    List<({OceanZone zone, Offset center, double radius})> items,
  ) {
    final shadow = [Shadow(color: palette.ink, blurRadius: 4)];
    final nameStyle = labelStyle.copyWith(
      color: palette.paper,
      shadows: shadow,
    );
    final countStyle = nameStyle.copyWith(
      fontWeight: FontWeight.w400,
      color: palette.paper.withValues(alpha: 0.85),
    );

    TextPainter layout(List<TextSpan> spans) => TextPainter(
      text: TextSpan(children: spans),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    final labelled =
        <
          ({
            OceanZone zone,
            TextPainter full,
            TextPainter short,
            Offset center,
            double radius,
          })
        >[];

    for (final item in items) {
      if (!_isLit(item.zone)) continue;
      final name = TextSpan(text: item.zone.name, style: nameStyle);
      labelled.add((
        zone: item.zone,
        full: layout([
          name,
          TextSpan(
            text: '\n${formatSpeciesCount(item.zone.speciesCount)}',
            style: countStyle,
          ),
        ]),
        short: layout([name]),
        center: item.center,
        radius: item.radius,
      ));
    }

    // Las zonas con más especies eligen sitio primero
    labelled.sort((a, b) => b.zone.speciesCount.compareTo(a.zone.speciesCount));

    final placements = placeLabels([
      for (final l in labelled)
        LabelRequest(
          id: l.zone.id,
          anchor: l.center,
          radius: l.radius * 1.2,
          // El mini mapa solo lleva el nombre
          full: _compact ? l.short.size : l.full.size,
          short: l.short.size,
        ),
    ], bounds: Offset.zero & size);

    for (final placement in placements) {
      final l = labelled.firstWhere((e) => e.zone.id == placement.id);
      final painter = placement.isShort || _compact ? l.short : l.full;
      painter.paint(canvas, placement.rect.topLeft);
    }
  }

  @override
  bool shouldRepaint(_ZonesPainter old) =>
      !identical(old.zones, zones) ||
      old.projection != projection ||
      old.selectedId != selectedId ||
      !setEquals(old.highlighted, highlighted) ||
      old.palette != palette ||
      old.labelStyle != labelStyle;
}
