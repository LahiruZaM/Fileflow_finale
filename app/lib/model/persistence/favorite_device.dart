import 'package:dart_mappable/dart_mappable.dart';
import 'package:uuid/uuid.dart';

part 'favorite_device.mapper.dart';

// A constant instance of the UUID generator.
const _uuid = Uuid();

/// A class representing a favorite device.
/// This class is annotated with `@MappableClass` for code generation
/// to support JSON serialization and deserialization.
@MappableClass()
class FavoriteDevice with FavoriteDeviceMappable {
  /// A unique identifier for the favorite device.
  final String id;

  /// The fingerprint of the device, typically used for identification.
  final String fingerprint;

  /// The IP address of the device.
  final String ip;

  /// The port number on which the device is accessible.
  final int port;

  /// The alias (or name) of the device.
  final String alias;

  /// Indicates whether the alias was set by the user.
  /// - If `true`, the alias was set by the user and is not automatically updated.
  /// - If `false`, the alias is derived from the original device alias and may be updated.
  final bool customAlias;

  /// Constructor for creating a `FavoriteDevice` instance.
  /// - [id]: Unique identifier for the device.
  /// - [fingerprint]: Device's fingerprint for identification.
  /// - [ip]: IP address of the device.
  /// - [port]: Port number for accessing the device.
  /// - [alias]: Alias (or name) of the device.
  /// - [customAlias]: Whether the alias is user-set (default is `false`).
  const FavoriteDevice({
    required this.id,
    required this.fingerprint,
    required this.ip,
    required this.port,
    required this.alias,
    this.customAlias = false,
  });

  /// Factory constructor to create a `FavoriteDevice` instance from values.
  /// This generates a new unique ID for the device.
  factory FavoriteDevice.fromValues({
    required String fingerprint,
    required String ip,
    required int port,
    required String alias,
  }) {
    return FavoriteDevice(
      id: _uuid.v1(), // Generate a version-1 UUID.
      fingerprint: fingerprint,
      ip: ip,
      port: port,
      alias: alias,
      customAlias: false, // Default to non-custom alias.
    );
  }

  /// A static reference to the generated `fromJson` method.
  /// This method allows creating a `FavoriteDevice` instance from a JSON object.
  static const fromJson = FavoriteDeviceMapper.fromJson;
}
