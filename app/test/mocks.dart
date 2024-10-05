import 'package:fileflow/provider/persistence_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateNiceMocks([
  MockSpec<PersistenceService>(),
  MockSpec<SharedPreferences>(),
])
void main() {}
