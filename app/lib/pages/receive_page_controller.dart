import 'package:common/model/device.dart';
import 'package:common/model/session_status.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:fileflow/model/persistence/receive_history_entry.dart';
import 'package:fileflow/pages/progress_page.dart';
import 'package:fileflow/pages/receive_page.dart';
import 'package:fileflow/provider/network/server/server_provider.dart';
import 'package:fileflow/provider/selection/selected_receiving_files_provider.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:routerino/routerino.dart';

part 'receive_page_controller.mapper.dart';

/// ViewModel for the Receive Page.
/// Contains all the data needed to display the receive page and handle user actions.
@MappableClass()
class ReceivePageVm with ReceivePageVmMappable {
  final SessionStatus? status; // Current session status.
  final Device sender; // Sender device information.

  /// Flags and configuration.
  final bool showSenderInfo; // Whether to show sender info (hashtag and device model).
  final int fileCount; // Number of files being sent.
  final String? message; // Optional message accompanying the file transfer.
  final bool isLink; // Whether the message contains a valid link.
  final bool showFullIp; // Whether to show the full IP address of the sender.

  /// Callback functions for user actions.
  final void Function() onAccept; // Callback for accepting file transfer.
  final void Function() onDecline; // Callback for declining file transfer.
  final void Function() onClose; // Callback for closing the session.

  ReceivePageVm({
    required this.status,
    required this.sender,
    required this.showSenderInfo,
    required this.fileCount,
    required this.message,
    required this.isLink,
    required this.showFullIp,
    required this.onAccept,
    required this.onDecline,
    required this.onClose,
  });
}

/// Provider for managing the state of the Receive Page controller.
final receivePageControllerProvider = ReduxProvider<ReceivePageController, ReceivePageVm>((ref) {
  return ReceivePageController(
    server: ref.notifier(serverProvider),
    selectedReceivingFiles: ref.notifier(selectedReceivingFilesProvider),
  );
});

/// Controller for the Receive Page.
/// Handles business logic, state management, and interactions with services.
class ReceivePageController extends ReduxNotifier<ReceivePageVm> {
  final ServerService _server; // Service for managing the server's state and actions.
  final SelectedReceivingFilesNotifier _selectedReceivingFiles; // Manages selected files for receiving.

  ReceivePageController({
    required ServerService server,
    required SelectedReceivingFilesNotifier selectedReceivingFiles,
  })  : _server = server,
        _selectedReceivingFiles = selectedReceivingFiles;

  /// Initialize the default state of the Receive Page ViewModel.
  @override
  ReceivePageVm init() {
    return ReceivePageVm(
      status: SessionStatus.waiting,
      sender: const Device(
        ip: '0.0.0.0',
        version: '1.0.0',
        port: 8080,
        https: false,
        fingerprint: 'fingerprint',
        alias: 'alias',
        deviceModel: 'deviceModel',
        deviceType: DeviceType.desktop,
        download: true,
      ),
      showSenderInfo: true,
      fileCount: 1,
      message: 'message',
      isLink: false,
      showFullIp: false,
      onAccept: () {},
      onDecline: () {},
      onClose: () {},
    );
  }

  /// Specifies the initial action to watch for updates to session status.
  @override
  get initialAction => _WatchStatusAction();
}

/// Action to watch and update the session status in the state.
class _WatchStatusAction extends WatchAction<ReceivePageController, ReceivePageVm> {
  @override
  ReceivePageVm reduce() {
    return state.copyWith(
      status: ref.watch(serverProvider.select((state) => state?.session?.status)),
    );
  }
}

/// Action to initialize the Receive Page with data from the current session.
class InitReceivePageAction extends ReduxAction<ReceivePageController, ReceivePageVm> {
  @override
  ReceivePageVm reduce() {
    final receiveSession = notifier._server.state?.session;
    if (receiveSession == null) {
      return state; // If no session exists, return the current state.
    }

    return state.copyWith(
      sender: receiveSession.sender,
      showSenderInfo: true,
      fileCount: receiveSession.files.length,
      message: receiveSession.message,
      isLink: receiveSession.message != null && (receiveSession.message!.isLink),
      showFullIp: false,
      onAccept: () async {
        if (state.message != null) {
          // If a message exists, accept the file transfer without any files.
          notifier._server.acceptFileRequest({});
          return;
        }

        final sessionId = notifier._server.state?.session?.sessionId;
        if (sessionId == null) {
          return; // If no session ID exists, do nothing.
        }

        final selectedFiles = notifier._selectedReceivingFiles.state;
        notifier._server.acceptFileRequest(selectedFiles);

        // Navigate to the Progress Page to show transfer progress.
        await Routerino.context.pushAndRemoveUntilImmediately(
          removeUntil: ReceivePage,
          builder: () => ProgressPage(
            showAppBar: false,
            closeSessionOnClose: true,
            sessionId: sessionId,
          ),
        );
      },
      onDecline: () {
        notifier._server.declineFileRequest(); // Decline the file transfer.
      },
      onClose: () {
        notifier._server.closeSession(); // Close the file transfer session.
      },
    );
  }
}

/// Action to initialize the Receive Page with data from a history entry.
class InitReceivePageFromHistoryMessageAction extends ReduxAction<ReceivePageController, ReceivePageVm> {
  final ReceiveHistoryEntry entry; // The history entry to initialize the page with.

  InitReceivePageFromHistoryMessageAction({required this.entry});

  @override
  ReceivePageVm reduce() {
    return state.copyWith(
      sender: Device(
        ip: '0.0.0.0',
        version: '1.0.0',
        port: 8080,
        https: false,
        fingerprint: 'fingerprint',
        alias: entry.senderAlias,
        deviceModel: 'deviceModel',
        deviceType: DeviceType.web,
        download: true,
      ),
      showSenderInfo: false, // Don't show sender info for history entries.
      fileCount: 1,
      message: entry.fileName,
      isLink: entry.fileName.isLink, // Determine if the file name is a link.
      showFullIp: false,
      onAccept: () {},
      onDecline: () {},
      onClose: () {},
    );
  }
}

/// Action to toggle the visibility of the full IP address in the state.
class SetShowFullIpAction extends ReduxAction<ReceivePageController, ReceivePageVm> {
  final bool showFullIp; // Whether to show the full IP address.

  SetShowFullIpAction(this.showFullIp);

  @override
  ReceivePageVm reduce() {
    return state.copyWith(
      showFullIp: showFullIp,
    );
  }
}

/// Extension on String to check if it represents a valid link.
extension on String {
  bool get isLink => Uri.tryParse(this)?.isAbsolute ?? false;
}
