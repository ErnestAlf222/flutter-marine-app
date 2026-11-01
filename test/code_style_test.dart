import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Regla de código: las variables se declaran final o const; si una debe cambiar de valor
// lleva tipo explícito (int total = 0;). Ningún linter prohíbe la palabra clave de tipo
// inferido por completo, así que esta prueba recorre lib/ y test/ y falla si la encuentra.
// El patrón se arma en dos partes para que este archivo no se detecte a sí mismo.
final _forbidden = RegExp(r'\bva' r'r\s+[A-Za-z_]');

bool _isGenerated(File file) => file.path.endsWith('.g.dart');

List<String> _violations() {
  final found = <String>[];
  for (final root in ['lib', 'test']) {
    for (final entity in Directory(root).listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart') || _isGenerated(entity)) continue;

      final lines = entity.readAsLinesSync();
      for (int i = 0; i < lines.length; i++) {
        // Los comentarios pueden hablar de la regla
        if (lines[i].trimLeft().startsWith('//')) continue;
        if (_forbidden.hasMatch(lines[i])) {
          found.add('${entity.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }
  }
  return found;
}

void main() {
  test('ninguna declaración usa la palabra clave de tipo inferido (lib/ y test/)', () {
    final violations = _violations();

    expect(violations, isEmpty, reason: violations.take(20).join('\n'));
  });

  test('el detector sí reconoce las formas prohibidas', () {
    const keyword = 'va${'r'}';

    expect(_forbidden.hasMatch('$keyword total = 0;'), isTrue);
    expect(_forbidden.hasMatch('for ($keyword i = 0; i < 3; i++) {}'), isTrue);
    expect(_forbidden.hasMatch('final total = 0;'), isFalse);
    expect(_forbidden.hasMatch('int total = 0;'), isFalse);
    expect(_forbidden.hasMatch('final variable = 1;'), isFalse);
  });
}
