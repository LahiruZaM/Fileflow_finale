import 'package:cli/main.dart' as m; 
// Imports the main.dart file from the 'cli' package and aliases it as 'm'.

Future<void> main(List<String> arguments) async {
  // The entry point for the application. Accepts a list of command-line arguments.
  
  await m.main(arguments);
  // Calls the main method from the imported 'main.dart' file, passing along the arguments.
}
