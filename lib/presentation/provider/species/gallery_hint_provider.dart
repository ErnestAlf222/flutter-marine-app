import 'package:flutter_riverpod/flutter_riverpod.dart';

// El aviso "Desliza para ver más fotos" sale solo la primera vez (en la sesión) que se abre
// una especie con varias fotos
class GalleryHintNotifier extends Notifier<bool> {
  // true = ya se mostró
  @override
  bool build() => false;

  void markShown() => state = true;
}

final galleryHintProvider = NotifierProvider<GalleryHintNotifier, bool>(
  GalleryHintNotifier.new,
);
