import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/analytics/analytics_controller.dart';
import 'package:hiddify/core/app_info/app_info_provider.dart';
import 'package:hiddify/core/model/app_info_entity.dart';
import 'package:hiddify/core/model/environment.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/features/auto_start/notifier/auto_start_notifier.dart';
import 'package:hiddify/features/settings/notifier/platform_settings_notifier.dart';
import 'package:hiddify/features/settings/overview/settings_overview_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../test_helpers/premium_test_app.dart';

class _TestAnalyticsController extends AnalyticsController {
  @override
  Future<bool> build() async => false;
}

class _TestAppInfo extends AppInfo {
  @override
  Future<AppInfoEntity> build() async => const AppInfoEntity(
        name: 'POKROV',
        version: '1.0.0',
        buildNumber: '1',
        release: Release.general,
        operatingSystem: 'windows',
        operatingSystemVersion: '11',
        environment: Environment.prod,
      );
}

class _TestAutoStartNotifier extends AutoStartNotifier {
  @override
  Future<bool> build() async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
      'shows a consumer-first preferences shell with hidden compatibility tools',
      (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      buildPremiumTestApp(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => preferences),
          analyticsControllerProvider
              .overrideWith(_TestAnalyticsController.new),
          appInfoProvider.overrideWith(_TestAppInfo.new),
          environmentProvider.overrideWith((ref) => Environment.prod),
          autoStartNotifierProvider.overrideWith(_TestAutoStartNotifier.new),
        ],
        child: const SettingsOverviewPage(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Preferences'), findsWidgets);
    expect(find.text('Everyday comfort'), findsWidgets);
    expect(find.text('Route mode'), findsWidgets);
    expect(
      find.text('Choose how this device should use POKROV.'),
      findsWidgets,
    );
    expect(find.text('Compatibility tools'), findsWidgets);
    expect(find.text('Reveal compatibility tools'), findsOneWidget);
    expect(find.text('Advanced'), findsNothing);
  });

  testWidgets(
      'shows desktop optimization guidance with a direct support shortcut',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'service-mode': 'vpn',
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      buildPremiumTestApp(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => preferences),
          analyticsControllerProvider
              .overrideWith(_TestAnalyticsController.new),
          appInfoProvider.overrideWith(_TestAppInfo.new),
          environmentProvider.overrideWith((ref) => Environment.prod),
          autoStartNotifierProvider.overrideWith(_TestAutoStartNotifier.new),
          desktopPrivilegeProvider.overrideWith((ref) async => false),
        ],
        child: const SettingsOverviewPage(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Desktop optimization'), findsOneWidget);
    expect(
      find.text(
        'Restart POKROV as Administrator before optimizing the whole device.',
      ),
      findsOneWidget,
    );
    expect(find.text('Open support'), findsOneWidget);
  });
}
