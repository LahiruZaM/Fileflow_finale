# app_group_directory

[![pub package][pub-badge]][pub-link] [![build status][build-badge]][build-link]

A Flutter plugin to access shared application group container on iOS.

On iOS, this uses the `NSFileManager`'s [containerURLForSecurityApplicationGroupIdentifier](https://developer.apple.com/documentation/foundation/nsfilemanager/1412643-containerurlforsecurityapplicati) API to get app group container URL.

## Migration from `ios_app_group` package

- Change `package:ios_app_group/ios_app_group.dart` imports to `package:app_group_directory/app_group_directory.dart`.
- Change `ios_app_group:` `pubspec.yaml` dependency to `app_group_directory: ^2.0.0`.
- Change `IosAppGroup` class references to `AppGroupDirectory`.

## Usage

```dart
import 'dart:io';

import 'package:app_group_directory/app_group_directory.dart';

Directory? sharedDirectory = await AppGroupDirectory.getAppGroupDirectory('com.example.app');
```

[pub-badge]: https://img.shields.io/pub/v/app_group_directory.svg
[pub-link]: https://pub.dev/packages/app_group_directory
[build-badge]: https://img.shields.io/github/workflow/status/Albert221/app_group_directory/Test
[build-link]: https://github.com/Albert221/app_group_directory/actions?query=workflow%3A%22Test%22
