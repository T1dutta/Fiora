/// Backend base URL (no trailing slash).
///
/// Android emulator cannot reach host `127.0.0.1`; run with:
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000`
const String kFioraApiBase = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8000',
);
