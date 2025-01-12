import 'package:common/model/device_info_result.dart';
import 'package:common/model/dto/multicast_dto.dart';
import 'package:common/model/stored_security_context.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:meta/meta.dart';
import 'package:refena/refena.dart';

part 'sync_provider.mapper.dart';

/// Represents the state that is synchronized from the main isolate to the child isolate.
/// In other words, the main isolate sends this state to the child isolate.
@MappableClass() // Annotation to enable mapping functionality for SyncState class.
class SyncState with SyncStateMappable {
  final StoredSecurityContext securityContext; // Security context that stores authentication/connection details.
  final DeviceInfoResult deviceInfo; // Information about the device.
  final String alias; // Alias name for the device.
  final int port; // Port used for communication.
  final ProtocolType protocol; // Protocol type (e.g., TCP, UDP) used for communication.
  final String multicastGroup; // Multicast group for networking.
  final int discoveryTimeout; // Timeout duration for device discovery.

  final bool serverRunning; // Indicates if the server is running.
  final bool download; // Indicates if download is enabled or in progress.

  // Constructor for initializing SyncState with necessary parameters.
  SyncState({
    required this.securityContext,
    required this.deviceInfo,
    required this.alias,
    required this.port,
    required this.protocol,
    required this.multicastGroup,
    required this.discoveryTimeout,
    required this.serverRunning,
    required this.download,
  });

  @override
  String toString() {
    // Custom toString method for better debugging and logging of SyncState.
    return 'SyncState(securityContext: <SecurityContext>, deviceInfo: $deviceInfo, alias: $alias, port: $port, protocol: $protocol, multicastGroup: $multicastGroup, discoveryTimeout: $discoveryTimeout, serverRunning: $serverRunning, download: $download)';
  }
}

/// A provider for accessing the SyncService and its state via Redux.
@internal // Marks this as for internal use within the package.
final syncProvider = ReduxProvider<SyncService, SyncState>((ref) {
  // Throws an error if accessed before being initialized.
  throw 'Not initialized';
});

/// A service class responsible for managing and providing the SyncState.
class SyncService extends ReduxNotifier<SyncState> {
  final SyncState initial; // The initial state to be used for SyncService.

  // Constructor to initialize SyncService with the initial state.
  SyncService({
    required this.initial,
  });

  @override
  SyncState init() => initial; // Initializes the SyncService with the provided initial state.
}

/// An action to update the SyncState within the SyncService.
class UpdateSyncStateAction extends ReduxAction<SyncService, SyncState> {
  final SyncState newState; // The new state to update the SyncState.

  // Constructor to initialize UpdateSyncStateAction with the new state.
  UpdateSyncStateAction(this.newState);

  @override
  SyncState reduce() {
    // Returns the new state to update the current SyncState.
    return newState;
  }
}
