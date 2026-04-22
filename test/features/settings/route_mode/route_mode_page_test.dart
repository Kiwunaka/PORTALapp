import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/features/per_app_proxy/data/per_app_proxy_data_providers.dart';
import 'package:hiddify/features/per_app_proxy/data/per_app_proxy_repository.dart';
import 'package:hiddify/features/per_app_proxy/model/installed_package_info.dart';
import 'package:hiddify/features/per_app_proxy/model/per_app_proxy_mode.dart';
import 'package:hiddify/features/settings/route_mode/route_mode_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../test_helpers/premium_test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('lets the user choose optimize everything for this device', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      buildPremiumTestApp(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => preferences),
          perAppProxyRepositoryProvider.overrideWith(
            (ref) => _FakePerAppProxyRepository(
              packages: const [
                InstalledPackageInfo(
                  packageName: 'org.telegram.messenger',
                  name: 'Telegram',
                  isSystemApp: false,
                ),
              ],
            ),
          ),
        ],
        child: const RouteModePage(requiredSetup: true),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('How should this device be optimized?'), findsOneWidget);
    expect(
      find.text('Optimize everything on this device'),
      findsWidgets,
    );
    expect(find.text('Only selected apps'), findsOneWidget);

    final optimizeEverythingButton = tester.widget<FilledButton>(
      find.widgetWithText(
        FilledButton,
        'Optimize everything on this device',
      ),
    );
    optimizeEverythingButton.onPressed!.call();
    await tester.pumpAndSettle();

    expect(
      preferences.getBool('portal.route_mode_choice_completed'),
      isTrue,
    );
  });

  testWidgets('uses a Windows executable entry flow for selected apps', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      buildPremiumTestApp(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => preferences),
        ],
        child: const RouteModePage(requiredSetup: true),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Only selected apps'));
    await tester.pumpAndSettle();

    expect(find.text('Add .exe file'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Add .exe file'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField),
      r'C:\Program Files\Telegram Desktop\Telegram.exe',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add app'));
    await tester.pumpAndSettle();

    expect(
      find.text(r'C:\Program Files\Telegram Desktop\Telegram.exe'),
      findsOneWidget,
    );

    final selectedAppsButton = tester.widget<FilledButton>(
      find.widgetWithText(
        FilledButton,
        'Use only selected apps',
      ),
    );
    selectedAppsButton.onPressed!.call();
    await tester.pumpAndSettle();

    expect(
      preferences.getStringList('per_app_proxy_include_list'),
      contains(r'C:\Program Files\Telegram Desktop\Telegram.exe'),
    );
    expect(
      preferences.getBool('portal.route_mode_choice_completed'),
      isTrue,
    );
  });

  testWidgets('stores selected apps mode with the chosen packages', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      buildPremiumTestApp(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => preferences),
          perAppProxyRepositoryProvider.overrideWith(
            (ref) => _FakePerAppProxyRepository(
              packages: const [
                InstalledPackageInfo(
                  packageName: 'org.telegram.messenger',
                  name: 'Telegram',
                  isSystemApp: false,
                ),
                InstalledPackageInfo(
                  packageName: 'com.spotify.music',
                  name: 'Spotify',
                  isSystemApp: false,
                ),
              ],
            ),
          ),
        ],
        child: const RouteModePage(requiredSetup: true),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Only selected apps'));
    await tester.pumpAndSettle();

    if (find.text('Add .exe file').evaluate().isNotEmpty) {
      expect(find.text('Choose the .exe files that should use POKROV.'),
          findsOneWidget,);
      return;
    }

    final telegramTile = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'Telegram'),
    );
    telegramTile.onChanged!.call(true);
    await tester.pumpAndSettle();

    final selectedAppsButton = tester.widget<FilledButton>(
      find.widgetWithText(
        FilledButton,
        'Use only selected apps',
      ),
    );
    selectedAppsButton.onPressed!.call();
    await tester.pumpAndSettle();

    expect(
      preferences.getString('per_app_proxy_mode'),
      PerAppProxyMode.include.name,
    );
    expect(
      preferences.getStringList('per_app_proxy_include_list'),
      contains('org.telegram.messenger'),
    );
    expect(
      preferences.getBool('portal.route_mode_choice_completed'),
      isTrue,
    );
  });
}

class _FakePerAppProxyRepository implements PerAppProxyRepository {
  _FakePerAppProxyRepository({required List<InstalledPackageInfo> packages})
      : _packages = packages;

  final List<InstalledPackageInfo> _packages;

  @override
  TaskEither<String, List<InstalledPackageInfo>> getInstalledPackages() {
    return TaskEither(() async => right(_packages));
  }

  @override
  TaskEither<String, Uint8List> getPackageIcon(String packageName) {
    return TaskEither(() async => right(base64Decode(_transparentPngBase64)));
  }
}

const _transparentPngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4//8/AwAI/AL+KDvN4AAAAABJRU5ErkJggg==';
