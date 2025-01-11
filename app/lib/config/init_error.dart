import 'package:fileflow/util/native/platform_check.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_manager/window_manager.dart';

final _logger = Logger('Init'); // Logger to log errors during app initialization

/// Shows an alternative app if the initialization failed.
void showInitErrorApp({
  required Object error, // Error that occurred during initialization
  required StackTrace stackTrace, // Stack trace for debugging the error
}) async {
  _logger.severe('Error during init', error, stackTrace); // Log the error and stack trace

  if (checkPlatformIsDesktop()) { // Check if the platform is a desktop (Windows, macOS, Linux)
    await WindowManager.instance.ensureInitialized(); // Ensure the window manager is initialized
    await WindowManager.instance.show(); // Show the window if it's a desktop platform
  }

  // Run the error app and pass the error and stack trace
  runApp(_ErrorApp(
    error: error,
    stackTrace: stackTrace,
  ));
}

class _ErrorApp extends StatefulWidget {
  final Object error; // Error passed to the widget
  final StackTrace stackTrace; // Stack trace passed to the widget

  const _ErrorApp({
    required this.error, // Constructor to initialize error
    required this.stackTrace, // Constructor to initialize stack trace
  });

  @override
  State<_ErrorApp> createState() => _ErrorAppState(); // Create state for the error app
}

class _ErrorAppState extends State<_ErrorApp> {
  final _controller = TextEditingController(); // Controller to manage text input in the text field
  String? version; // Variable to store the version of the app

  @override
  void initState() {
    super.initState();

    // Set the initial error and stack trace text in the controller
    _controller.text = 'Error: ${widget.error}\n\n${widget.stackTrace}';

    // Fetch the app's version information after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final info = await PackageInfo.fromPlatform(); // Get app's version and build number
      // Update the controller's text with the app version, error, and stack trace
      _controller.text = 'FileFlow ${info.version} (${info.buildNumber})\n\nError: ${widget.error}\n\n${widget.stackTrace}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FileFlow: Error', // Set the app's title
      debugShowCheckedModeBanner: false, // Disable the debug banner
      home: Scaffold(
        body: TextFormField(
          controller: _controller, // Bind the text controller to the text field
          maxLines: null, // Allow the text field to expand vertically for multiple lines
          readOnly: true, // Make the text field read-only
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(10), // Set padding inside the text field
            border: OutlineInputBorder( // Set border style for the text field
              borderSide: BorderSide(),
            ),
          ),
        ),
      ),
    );
  }
}
