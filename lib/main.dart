import 'fingo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize service locator dependencies
  await init();

  // Safeguarded Firebase initialization
  try {
    await Firebase.initializeApp();
    AppLogger.i('Firebase has been successfully initialized.');
  } catch (e, stackTrace) {
    AppLogger.w(
      'Firebase initialization bypassed. This is expected if Firebase '
      'configuration files (google-services.json / GoogleService-Info.plist) are missing.',
    );
    AppLogger.e('Firebase Init Error Details:', e, stackTrace);
  }

  runApp(const FingoApp());
}
