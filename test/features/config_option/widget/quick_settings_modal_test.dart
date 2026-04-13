import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/features/config_option/widget/quick_settings_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../test_helpers/premium_test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'routing-mode': 'global',
    });
  });

  testWidgets('shows Full tunnel instead of the legacy Global label', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      buildPremiumTestApp(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) => preferences),
        ],
        child: const Scaffold(
          body: QuickSettingsModal(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Routing preset'), findsOneWidget);
    expect(find.text('Full tunnel'), findsOneWidget);
    expect(find.text('Global'), findsNothing);
  });
}
