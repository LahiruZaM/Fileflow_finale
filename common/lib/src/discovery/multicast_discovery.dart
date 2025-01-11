import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:common/api_route_builder.dart';
import 'package:common/constants.dart';
import 'package:common/isolate.dart';
import 'package:common/model/device.dart';
import 'package:common/model/dto/multicast_dto.dart';
import 'package:common/model/dto/register_dto.dart';
import 'package:common/src/isolate/child/dio_provider.dart';
import 'package:common/util/sleep.dart';
import 'package:logging/logging.dart';
import 'package:refena/refena.dart';

// Logger to capture logs for multicast-related events.
final _logger = Logger('Multicast');

// Provider that exposes an instance of the MulticastService.
final multicastDiscoveryProvider = Provider((ref) {
  return MulticastService(ref);
});

/// A service for discovering devices on the network using UDP multicast.
class MulticastService {
  // Constructor initializing the service with a reference to the provider.
  MulticastService(this._ref);

  final Ref _ref;
  bool _listening = false; // Flag to check if multicast listener is active.

  /// Starts listening for incoming multicast messages.
  /// If a device is found, it will trigger a response.
  Stream<Device> startListener() async* {
    // Prevent starting the listener if it's already running.
    if (_listening) {
      _logger.info('Already listening to multicast');
      return;
    }

    _listening = true;

    // Create a stream controller to emit discovered devices.
    final streamController = StreamController<Device>();
    final syncState = _ref.read(syncProvider); // Get synchronization state.

    // Get the available multicast sockets for listening.
    final sockets = await _getSockets(syncState.multicastGroup, syncState.port);
    for (final socket in sockets) {
      // Listen for incoming datagrams.
      socket.socket.listen((_) {
        final datagram = socket.socket.receive();
        if (datagram == null) {
          return; // If no data, return early.
        }

        try {
          // Parse the incoming datagram as a MulticastDto.
          final dto = MulticastDto.fromJson(jsonDecode(utf8.decode(datagram.data)));
          
          // Skip processing if the fingerprint matches the device's fingerprint.
          if (dto.fingerprint == syncState.securityContext.certificateHash) {
            return;
          }

          final ip = datagram.address.address; // Get IP address from datagram.
          final peer = dto.toDevice(ip, syncState.port, syncState.protocol == ProtocolType.https);
          
          // Add the discovered device to the stream.
          streamController.add(peer);
          
          // Respond to announcements if the server is running.
          if ((dto.announcement == true || dto.announce == true) && syncState.serverRunning) {
            _answerAnnouncement(peer);
          }
        } catch (e) {
          _logger.warning('Could not parse multicast message', e);
        }
      });
      
      // Log the UDP multicast socket binding.
      _logger.info(
        'Bind UDP multicast port (ip: ${socket.interface.addresses.map((a) => a.address).toList()}, group: ${syncState.multicastGroup}, port: ${syncState.port})',
      );
    }

    // Announce this device's presence on the network.
    sendAnnouncement(); // Send announcement without waiting for the result.

    // Yield discovered devices to the stream.
    yield* streamController.stream;
  }

  /// Sends a multicast announcement to inform other devices of this device's presence.
  Future<void> sendAnnouncement() async {
    final syncState = _ref.read(syncProvider);
    
    // Get available sockets to send the announcement.
    final sockets = await _getSockets(syncState.multicastGroup);
    
    // Create the MulticastDto for the announcement message.
    final dto = _getMulticastDto(announcement: true);
    
    // Send the announcement in intervals (100ms, 500ms, 2000ms).
    for (final wait in [100, 500, 2000]) {
      await sleepAsync(wait); // Wait before sending the next announcement.

      _logger.info('Announce via UDP');
      for (final socket in sockets) {
        try {
          // Send the announcement via the multicast socket.
          socket.socket.send(dto, InternetAddress(syncState.multicastGroup), syncState.port);
          socket.socket.close(); // Close the socket after sending.
        } catch (e) {
          _logger.warning('Could not send multicast message', e);
        }
      }
    }
  }

  /// Responds to an announcement from another device.
  Future<void> _answerAnnouncement(Device peer) async {
    try {
      // Attempt to respond via TCP by sending a registration message.
      await _ref.read(dioProvider).discovery.post(
            ApiRoute.register.target(peer),
            data: _getRegisterDto().toJson(),
          );
      _logger.info('Respond to announcement of ${peer.alias} (${peer.ip}, model: ${peer.deviceModel}) via TCP');
    } catch (e) {
      // Fallback: Respond via UDP if TCP fails.
      final syncState = _ref.read(syncProvider);
      final sockets = await _getSockets(syncState.multicastGroup);
      final dto = _getMulticastDto(announcement: false);
      
      for (final socket in sockets) {
        try {
          socket.socket.send(dto, InternetAddress(syncState.multicastGroup), syncState.port);
          socket.socket.close(); // Close the socket after sending.
        } catch (e) {
          _logger.warning('Could not send multicast message', e);
        }
      }
      _logger.info('Respond to announcement of ${peer.alias} (${peer.ip}, model: ${peer.deviceModel}) with UDP because TCP failed');
    }
  }

  /// Returns a multicast message as a list of bytes.
  List<int> _getMulticastDto({required bool announcement}) {
    final syncState = _ref.read(syncProvider);
    
    // Create a MulticastDto to represent this device's information.
    final dto = MulticastDto(
      alias: syncState.alias,
      version: protocolVersion,
      deviceModel: syncState.deviceInfo.deviceModel,
      deviceType: syncState.deviceInfo.deviceType,
      fingerprint: syncState.securityContext.certificateHash,
      port: syncState.port,
      protocol: syncState.protocol,
      download: syncState.download,
      announcement: announcement,
      announce: announcement,
    );
    
    // Convert the DTO to JSON and encode it to bytes.
    return utf8.encode(jsonEncode(dto.toJson()));
  }

  // Create a RegisterDto for device registration with details.
  RegisterDto _getRegisterDto() {
    final syncState = _ref.read(syncProvider);
    return RegisterDto(
      alias: syncState.alias,
      version: protocolVersion,
      deviceModel: syncState.deviceInfo.deviceModel,
      deviceType: syncState.deviceInfo.deviceType,
      fingerprint: syncState.securityContext.certificateHash,
      port: syncState.port,
      protocol: syncState.protocol,
      download: syncState.download,
    );
  }
}

// A helper class to store network interface and socket details.
class _SocketResult {
  final NetworkInterface interface;
  final RawDatagramSocket socket;

  _SocketResult(this.interface, this.socket);
}

// A helper function to get the list of multicast sockets for the specified group and port.
Future<List<_SocketResult>> _getSockets(String multicastGroup, [int? port]) async {
  final interfaces = await NetworkInterface.list(); // List all network interfaces.
  final sockets = <_SocketResult>[];
  
  // Iterate over each network interface and create multicast sockets.
  for (final interface in interfaces) {
    try {
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port ?? 0);
      socket.joinMulticast(InternetAddress(multicastGroup), interface);
      sockets.add(_SocketResult(interface, socket)); // Add the socket to the list.
    } catch (e) {
      _logger.warning(
        'Could not bind UDP multicast port (ip: ${interface.addresses.map((a) => a.address).toList()}, group: $multicastGroup, port: $port)',
        e,
      );
    }
  }

  return sockets; // Return the list of multicast sockets.
}
