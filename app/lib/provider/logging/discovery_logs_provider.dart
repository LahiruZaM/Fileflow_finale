import 'package:fileflow/model/log_entry.dart';
import 'package:logging/logging.dart';
import 'package:refena_flutter/refena_flutter.dart';

// Logger instance specifically for the Discovery module.
final _logger = Logger('Discovery');

/// Provider for managing discovery logs, useful for debugging.
/// It maintains a list of log entries and supports adding or clearing logs.
final discoveryLoggerProvider = NotifierProvider<DiscoveryLogger, List<LogEntry>>((ref) {
  return DiscoveryLogger();
});

/// A notifier class for managing a list of discovery log entries.
/// It supports adding new log entries and clearing the current logs.
class DiscoveryLogger extends Notifier<List<LogEntry>> {
  DiscoveryLogger();

  /// Initializes the state with an empty list of log entries.
  @override
  List<LogEntry> init() {
    return [];
  }

  /// Adds a log entry with the current timestamp and updates the state.
  /// Retains only the latest 200 log entries to prevent excessive memory usage.
  void addLog(String log) {
    _logger.info(log);
    state = [
      ...state,
      LogEntry(timestamp: DateTime.now(), log: log),
    ].take(200).toList();
  }

  /// Clears all the log entries, resetting the state to an empty list.
  void clear() {
    state = [];
  }
}
