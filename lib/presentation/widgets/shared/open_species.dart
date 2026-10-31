import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';

/// Abre el Detalle de una especie. Antes suelta el foco del teclado: si el buscador
/// seguía enfocado, Flutter se lo devolvía al volver y el teclado se abría solo.
void openSpecies(BuildContext context, Species species) {
  FocusManager.instance.primaryFocus?.unfocus();
  context.push(RouteConstants.speciesLocation(species.slug), extra: species);
}
