import 'dart:async';

import 'package:hive_ce_flutter/adapters.dart';

const String kGalleryBoxName = 'trimflow_gallery_box';

class LocalStorageProvider {
  LocalStorageProvider._();

  static bool _initialized = false;
  static Future<void>? _initializing;

  static Future<void> ensureInitialized() {
    if (_initialized) return Future.value();
    _initializing ??= _initInternal();
    return _initializing!;
  }

  static Future<void> _initInternal() async {
    await Hive.initFlutter('trimflow_local');
    _initialized = true;
  }

  static Future<Box<Map>> openGalleryBox() async {
    await ensureInitialized();
    if (Hive.isBoxOpen(kGalleryBoxName)) {
      return Hive.box<Map>(kGalleryBoxName);
    }
    return Hive.openBox<Map>(kGalleryBoxName);
  }

  static Future<void> closeAll() async {
    if (!_initialized) return;
    await Hive.close();
    _initialized = false;
    _initializing = null;
  }
}
