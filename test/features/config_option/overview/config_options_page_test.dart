import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/features/config_option/overview/config_options_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../test_helpers/premium_test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows only the consumer routing presets and hides region picker', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      buildPremiumTestApp(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) => preferences),
        ],
        child: ConfigOptionsPage(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Routing preset'), findsOneWidget);
    expect(find.text('Region'), findsNothing);
    expect(find.text('All except RU'), findsOneWidget);

    await tester.tap(find.text('Routing preset'));
    await tester.pumpAndSettle();

    expect(find.text('Full tunnel'), findsOneWidget);
    expect(find.text('All except RU'), findsWidgets);
    expect(find.text('Blocked only'), findsNothing);
  });
}
