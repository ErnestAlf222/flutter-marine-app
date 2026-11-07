import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:marine_app/domain/domain.dart';

class ConnectivityRepositoryImpl extends ConnectivityRepository {
  final Connectivity _connectivity;

  ConnectivityRepositoryImpl({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  static bool _hasNetwork(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  // Si el sistema no responde se supone que hay red: el fallo real lo dirá la petición
  @override
  Future<bool> isOnline() async {
    try {
      return _hasNetwork(await _connectivity.checkConnectivity());
    } catch (_) {
      return true;
    }
  }

  @override
  Stream<bool> watchOnline() => _connectivity.onConnectivityChanged
      .map(_hasNetwork)
      .handleError((Object _) {})
      .distinct();
}
