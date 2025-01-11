import 'package:common/api_route_builder.dart';
import 'package:common/constants.dart';
import 'package:common/model/device.dart';
import 'package:common/model/dto/info_dto.dart';
import 'package:common/src/isolate/child/dio_provider.dart';
import 'package:common/src/isolate/child/sync_provider.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:refena/refena.dart';

// Logger for debugging purposes.
final _logger = Logger('TargetedDiscovery');

// A provider for accessing the HttpTargetDiscoveryService.
final httpTargetDiscoveryProvider = ViewProvider((ref) {
  // Watch the dioProvider and syncProvider for dependencies.
  final dio = ref.watch(dioProvider).discovery;
  final fingerprint = ref.watch(syncProvider).securityContext.certificateHash;
  return HttpTargetDiscoveryService(dio, fingerprint);
});

/// A service for discovering devices through HTTP requests to a given IP and port.
class HttpTargetDiscoveryService {
  final Dio _dio;  // Instance of Dio for making HTTP requests.
  final String _fingerprint;  // Security certificate hash.

  // Constructor to initialize the service with Dio and fingerprint.
  HttpTargetDiscoveryService(this._dio, this._fingerprint);

  /// Discovers a device by sending a request to a target IP and port.
  ///
  /// [ip] The IP address of the target device.
  /// [port] The port on which the target device is accessible.
  /// [https] Whether the connection should use HTTPS.
  /// [onError] A callback function to handle errors.
  Future<Device?> discover({
    required String ip,
    required int port,
    required bool https,
    void Function(String url, Object? error)? onError = defaultErrorPrinter,
  }) async {
    // Construct the URL to the target device's info endpoint using legacy route.
    final url = ApiRoute.info.targetRaw(ip, port, https, peerProtocolVersion);
    try {
      // Make the GET request to fetch the device information.
      final response = await _dio.get(url, queryParameters: {
        'fingerprint': _fingerprint,  // Attach the fingerprint for security.
      });
      // Parse the response data into an InfoDto.
      final dto = InfoDto.fromJson(response.data);
      // Convert the DTO into a Device object and return it.
      return dto.toDevice(ip, port, https);
    } on DioException catch (e) {
      // Handle Dio-specific errors and call the onError callback.
      onError?.call(url, e.error);
      return null;  // Return null in case of error.
    } catch (e) {
      // Handle any other errors and call the onError callback.
      onError?.call(url, e);
      return null;  // Return null in case of error.
    }
  }

  // Default error printing function for logging.
  static void defaultErrorPrinter(String url, Object? error) {
    _logger.warning('$url: $error');  // Log the error with the URL.
  }
}
