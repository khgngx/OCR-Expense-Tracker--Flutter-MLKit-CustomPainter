// Picks the web or mobile/desktop implementations at compile time so that
// dart:io / ML Kit never end up in the web build and vice versa.
export 'platform_services_stub.dart'
    if (dart.library.js_interop) 'platform_services_web.dart'
    if (dart.library.io) 'platform_services_io.dart';
