import 'package:common/model/device.dart';
import 'package:common/src/discovery/http_scan_discovery.dart';
import 'package:common/src/isolate/child/main.dart';
import 'package:common/src/isolate/dto/isolate_task.dart';
import 'package:common/src/isolate/dto/isolate_task_stream_result.dart';
import 'package:common/src/isolate/dto/send_to_isolate_data.dart';
import 'package:meta/meta.dart';

/// A sealed class representing the type of HTTP scan task.
sealed class HttpScanTask {}

/// Represents a task for scanning devices on a specific network interface.
class HttpInterfaceScanTask implements HttpScanTask {
  final String networkInterface; // The network interface to scan.
  final int port; // The port to scan on the specified network interface.
  final bool https; // Indicates if HTTPS should be used for the scan.

  HttpInterfaceScanTask({
    required this.networkInterface,
    required this.port,
    required this.https,
  });
}

/// Represents a task for scanning a list of favorite devices.
class HttpFavoriteScanTask implements HttpScanTask {
  final List<(String, int)> favorites; // A list of favorite devices (IP and port) to scan.
  final bool https; // Indicates if HTTPS should be used for the scan.

  HttpFavoriteScanTask({
    required this.favorites,
    required this.https,
  });
}

/// Sets up the HTTP Scan Discovery isolate.
///
/// This function is responsible for managing the communication between the main isolate
/// and the child isolate that performs HTTP scanning tasks. It processes incoming tasks
/// from the main isolate and sends results back.
@internal
Future<void> setupHttpScanDiscoveryIsolate(
  Stream<SendToIsolateData<IsolateTask<HttpScanTask>>> receiveFromMain, // Stream of tasks sent from the main isolate.
  void Function(IsolateTaskStreamResult<Device>) sendToMain, // Callback to send results back to the main isolate.
  InitialData initialData, // Initial data for setting up the isolate.
) async {
  // Set up the child isolate helper to process tasks.
  await setupChildIsolateHelper(
    debugLabel: 'HttpScanDiscoveryIsolate', // Debug label for the isolate.
    receiveFromMain: receiveFromMain,
    sendToMain: sendToMain,
    initialData: initialData,
    handler: (task) async {
      // Determine which scan to run based on the task type (interface or favorite scan).
      final stream = switch (task.data) {
        // For an interface scan task, retrieve the device stream for the specified network interface.
        HttpInterfaceScanTask data => isolateContainer.read(httpScanDiscoveryProvider).getStream(
              networkInterface: data.networkInterface,
              port: data.port,
              https: data.https,
            ),
        // For a favorite scan task, retrieve the device stream for the favorite devices.
        HttpFavoriteScanTask data => isolateContainer.read(httpScanDiscoveryProvider).getFavoriteStream(
              devices: data.favorites,
              https: data.https,
            ),
      };

      // Process the stream of devices and send results to the main isolate.
      await for (final device in stream) {
        sendToMain(IsolateTaskStreamResult(
          id: task.id, // Task ID for tracking.
          done: false, // Indicates the task is not yet complete.
          data: device, // The discovered device.
        ));
      }

      // Send a final message indicating the task is complete.
      sendToMain(IsolateTaskStreamResult(
        id: task.id, // Task ID for tracking.
        done: true, // Indicates the task is complete.
        data: null, // No more data to send.
      ));
    },
  );
}
