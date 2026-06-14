import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker_app/app.dart';
import 'package:expense_tracker_app/core/core.dart';
import 'package:expense_tracker_app/di/injection_container.dart' as di;
import 'package:get_it/get_it.dart';

void main() {
  setUp(() async {
    // Reset service locator before each test
    await GetIt.instance.reset();
    await di.init();
  });

  testWidgets('Fingo App dashboard renders weekly transaction header', (WidgetTester tester) async {
    // Force authenticated override state so router goes to dashboard
    GetIt.instance<AuthNotifier>().setAuthenticatedOverride(true);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const FingoApp());

    // Let routing settle
    await tester.pumpAndSettle();

    // Verify that the clean weekly dashboard starts up correctly
    expect(find.text('THIS WEEK'), findsOneWidget);
  });
}

