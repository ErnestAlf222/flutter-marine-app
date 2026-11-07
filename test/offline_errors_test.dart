import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/infrastructure/infrastructure.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

DioException _dio(DioExceptionType type, {int? status}) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: type,
    response: status == null ? null : Response(requestOptions: options, statusCode: status),
  );
}

Widget _host(Widget child, {bool reduceMotion = false}) => MaterialApp(
  theme: ThemeData(extensions: const [OceanPalette.dark]),
  builder: (context, app) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
    child: app!,
  ),
  home: Scaffold(body: child),
);

void main() {
  group('clasificación de errores de Dio', () {
    test('sin respuesta (conexión, tiempo de conexión o de envío): sin conexión', () {
      for (final type in [
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
      ]) {
        expect(errorMessageFor(_dio(type)), ApiConstants.offlineMessage, reason: '$type');
      }
    });

    test('con respuesta 5xx, 429 o tiempo de la respuesta: servidor con problemas', () {
      expect(
        errorMessageFor(_dio(DioExceptionType.badResponse, status: 500)),
        ApiConstants.serverMessage,
      );
      expect(
        errorMessageFor(_dio(DioExceptionType.badResponse, status: 503)),
        ApiConstants.serverMessage,
      );
      expect(
        errorMessageFor(_dio(DioExceptionType.badResponse, status: 429)),
        ApiConstants.serverMessage,
      );
      expect(
        errorMessageFor(_dio(DioExceptionType.receiveTimeout)),
        ApiConstants.serverMessage,
      );
    });

    test('404: no encontrado; un JSON inesperado cuenta como servidor', () {
      expect(
        errorMessageFor(_dio(DioExceptionType.badResponse, status: 404)),
        ApiConstants.notFoundMessage,
      );
      expect(errorMessageFor(const FormatException('x')), ApiConstants.serverMessage);
      expect(errorMessageFor(StateError('x')), ApiConstants.serverMessage);
    });

    test('la función de presentación convierte cada mensaje en su tipo', () {
      expect(failureKindOf(ApiConstants.offlineMessage), FailureKind.offline);
      expect(failureKindOf(ApiConstants.serverMessage), FailureKind.server);
      expect(failureKindOf(ApiConstants.notFoundMessage), FailureKind.notFound);
      // Lo desconocido (otro texto, una excepción, null) se trata como servidor
      expect(failureKindOf('otra cosa'), FailureKind.server);
      expect(failureKindOf(StateError('x')), FailureKind.server);
      expect(failureKindOf(null), FailureKind.server);
    });
  });

  group('estados amigables por tipo de fallo', () {
    testWidgets('cada tipo muestra su texto y su acción', (tester) async {
      int retries = 0;
      int favorites = 0;

      for (final kind in FailureKind.values) {
        await tester.pumpWidget(
          _host(
            FriendlyState(
              kind: kind,
              onRetry: () => retries++,
              onSecondary: kind == FailureKind.offline ? () => favorites++ : null,
              secondaryLabel: kind == FailureKind.offline ? FriendlyConstants.seeFavorites : null,
            ),
          ),
        );

        expect(find.text(FriendlyConstants.messages[kind]!), findsOneWidget, reason: '$kind');
        expect(find.text(FriendlyConstants.retry), findsOneWidget);
        // "Ver mis favoritos" solo aparece sin conexión
        expect(
          find.text(FriendlyConstants.seeFavorites),
          kind == FailureKind.offline ? findsOneWidget : findsNothing,
        );
      }

      await tester.pumpWidget(
        _host(
          FriendlyState(
            kind: FailureKind.offline,
            onRetry: () => retries++,
            onSecondary: () => favorites++,
            secondaryLabel: FriendlyConstants.seeFavorites,
          ),
        ),
      );
      await tester.tap(find.text(FriendlyConstants.retry));
      await tester.tap(find.text(FriendlyConstants.seeFavorites));
      expect(retries, 1);
      expect(favorites, 1);
    });

    testWidgets('los textos son breves y no culpan a quien usa la app', (tester) async {
      for (final text in FriendlyConstants.messages.values) {
        expect(text.length, lessThan(90));
        expect(text.toLowerCase(), isNot(contains('error')));
        expect(text.toLowerCase(), isNot(contains('tu culpa')));
      }
      expect(FriendlyConstants.messages[FailureKind.offline], contains('favoritos'));
    });

    testWidgets('sin acciones no hay botones y la variante compacta también se ve', (tester) async {
      await tester.pumpWidget(_host(const FriendlyState(kind: FailureKind.empty, compact: true)));
      expect(find.text(FriendlyConstants.messages[FailureKind.empty]!), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('el pez se mueve unos vaivenes y con animaciones reducidas queda quieto', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const FriendlyState(kind: FailureKind.server)));
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.hasRunningAnimations, isTrue);

      // Acaba solo: no deja la pantalla animándose para siempre
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);

      await tester.pumpWidget(
        _host(const FriendlyState(kind: FailureKind.server), reduceMotion: true),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
