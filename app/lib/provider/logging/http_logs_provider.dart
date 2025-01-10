import 'package:fileflow/model/log_entry.dart';
import 'package:logging/logging.dart';
import 'package:refena_flutter/refena_flutter.dart';

final _logger = Logger('HTTP');

/// Contains the discovery logs for debugging purposes.
final httpLogsProvider = NotifierProvider<HttpLogsService, List<LogEntry>>((ref) {
  return HttpLogsService();
});

class HttpLogsService extends Notifier<List<LogEntry>> {
  @override
  List<LogEntry> init() {
    return [];
  }

  void addLog(String log) {
    _logger.info(log);
    state = [
      ...state, // Add the new log entry to the existing state
      LogEntry(timestamp: DateTime.now(), log: log), // New log entry with timestamp
    ].take(200).toList(); // Ensure the list does not exceed 200 logs
  }

  void clear() {
    state = []; // Clears the current state, effectively removing all logs
  }

  @override
  String describeState(List<LogEntry> state) => '${state.length} logs'; // Describes the current state by showing the number of logs
}
