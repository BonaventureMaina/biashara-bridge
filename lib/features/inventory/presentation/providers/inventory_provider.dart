export 'inventory_provider_stub.dart'
    if (dart.library.html) 'inventory_provider_web.dart'
    if (dart.library.io) 'inventory_provider_io.dart';
