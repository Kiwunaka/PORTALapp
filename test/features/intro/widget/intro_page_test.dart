import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/analytics/analytics_controller.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/features/common/general_pref_tiles.dart';
import 'package:hiddify/features/intro/widget/intro_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../test_helpers/premium_test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('keeps the legacy region selector out of onboarding', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      buildPremiumTestApp(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) => preferences),
          analyticsControllerProvider.overrideWith(_TestAnalyticsController.new),
        ],
        child: const IntroPage(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(RegionPrefTile), findsNothing);
    expect(find.text('Region'), findsNothing);
  });
}

class _TestAnalyticsController extends AnalyticsController {
  @override
  Future<bool> build() async => false;
}
