import 'package:refena_flutter/refena_flutter.dart';

/// Provides the arguments passed to the app at the time of startup.
final appArgumentsProvider = Provider(
  (ref) => <String>[],
  debugLabel: 'appArgumentsProvider',
);
