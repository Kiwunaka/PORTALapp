import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/router/app_router.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/features/common/adaptive_root_scaffold.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('desktop tab locations use the canonical portal routes', () {
    expect(
        tabLocations, ['/', '/locations', '/devices', '/profile', '/support']);
  });

  testWidgets('desktop shell shows brand chrome and all primary destinations', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    tester.view.physicalSize = const Size(960, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const AdaptiveRootScaffold(SizedBox.expand()),
        ),
        GoRoute(
          path: '/locations',
          builder: (context, state) =>
              const AdaptiveRootScaffold(SizedBox.expand()),
        ),
        GoRoute(
          path: '/devices',
          builder: (context, state) =>
              const AdaptiveRootScaffold(SizedBox.expand()),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) =>
              const AdaptiveRootScaffold(SizedBox.expand()),
        ),
        GoRoute(
          path: '/support',
          builder: (context, state) =>
              const AdaptiveRootScaffold(SizedBox.expand()),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => prefs),
          translationsProvider.overrideWithValue(AppLocale.en.build()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('POKROV VPN'), findsOneWidget);
    expect(find.text('Network'), findsOneWidget);
    expect(find.text('Locations'), findsOneWidget);
    expect(find.text('Devices'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Support'), findsOneWidget);
  });
}
