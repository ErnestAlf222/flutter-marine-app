import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';

/// Contenedor de las pestañas: todas siguen montadas (cada una conserva su estado),
/// pero solo se ve la activa. Al cambiar, la nueva se desvanece mientras sube un poco
/// y la anterior se desvanece. Con animaciones reducidas el cambio es instantáneo.
class BranchSwitcher extends StatefulWidget {
  final int currentIndex;
  final List<Widget> children;

  const BranchSwitcher({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  @override
  State<BranchSwitcher> createState() => _BranchSwitcherState();
}

class _BranchSwitcherState extends State<BranchSwitcher>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: MotionConstants.medium,
    value: 1,
  );
  int? _previous;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BranchSwitcher old) {
    super.didUpdateWidget(old);
    if (old.currentIndex == widget.currentIndex) return;

    if (MediaQuery.disableAnimationsOf(context)) {
      _previous = null;
      _controller.value = 1;
      return;
    }
    _previous = old.currentIndex;
    _controller.forward(from: 0).whenComplete(() {
      if (mounted) setState(() => _previous = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = MotionConstants.curve.transform(_controller.value);

        return Stack(
          fit: StackFit.expand,
          children: [
            for (int i = 0; i < widget.children.length; i++)
              _branch(i, t),
          ],
        );
      },
    );
  }

  Widget _branch(int index, double t) {
    final isCurrent = index == widget.currentIndex;
    final isLeaving = index == _previous;

    final opacity = isCurrent ? t : (isLeaving ? 1 - t : 0.0);
    final dy = isCurrent ? (1 - t) * MotionConstants.tabShift : 0.0;

    // El hijo es el mismo widget siempre, para no perder el estado de la pestaña
    return Offstage(
      offstage: !isCurrent && !isLeaving,
      // Las pestañas ocultas no corren animaciones ni participan en los Hero
      child: TickerMode(
        enabled: isCurrent,
        child: IgnorePointer(
          ignoring: !isCurrent,
          child: Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, dy),
              child: widget.children[index],
            ),
          ),
        ),
      ),
    );
  }
}
