// Estado de la conexión del dispositivo
abstract class ConnectivityRepository {
  /// Hay alguna red conectada ahora
  Future<bool> isOnline();

  /// Emite true/false cada vez que cambia el estado
  Stream<bool> watchOnline();
}
