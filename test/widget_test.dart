import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medi_reminder/main.dart';
import 'package:medi_reminder/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MediReminder app starts successfully',
      (WidgetTester tester) async {
    // Provide a test version of local storage.
    SharedPreferences.setMockInitialValues({});

    // Initialize the storage service before showing the app.
    await StorageService.instance.init();

    await tester.pumpWidget(const MediReminderApp());

    // Let the splash screen timer complete.
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(MediReminderApp), findsOneWidget);
  });
}
