import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';

// Barra de búsqueda con el mismo aspecto en Inicio y en Explorar
class SpeciesSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  // Con onTap el campo no se edita: solo reacciona al toque (Inicio abre Explorar)
  final VoidCallback? onTap;

  const SpeciesSearchField({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);

    final field = ListenableBuilder(
      listenable: controller,
      builder: (context, _) => SearchBar(
        controller: controller,
        focusNode: focusNode,
        hintText: 'Buscar especies',
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(palette.deep),
        textStyle: WidgetStatePropertyAll(TextStyle(color: palette.paper)),
        hintStyle: WidgetStatePropertyAll(
          TextStyle(color: palette.paper.withValues(alpha: 0.6)),
        ),
        leading: Icon(Icons.search, color: palette.paper),
        trailing: [
          if (controller.text.isNotEmpty && onClear != null)
            IconButton(
              icon: Icon(Icons.close, color: palette.paper),
              tooltip: 'Borrar búsqueda',
              onPressed: onClear,
            ),
        ],
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );

    if (onTap == null) return field;

    // AbsorbPointer evita que el campo tome el foco y abra el teclado aquí
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AbsorbPointer(child: field),
    );
  }
}
