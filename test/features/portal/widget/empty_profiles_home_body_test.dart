import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/home/widget/empty_profiles_home_body.dart';
import 'package:hiddify/features/portal/data/portal_trial_activator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('shows the premium empty home state in English', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          translationsProvider.overrideWithValue(AppLocale.en.build()),
          portalTrialActivationControllerProvider.overrideWith(
            (ref) => PortalTrialActivationController(ref),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          supportedLocales: [Locale('en'), Locale('ru')],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                EmptyProfilesHomeBody(),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('POKROV'), findsOneWidget);
    expect(find.text('POKROV VPN'), findsNothing);
    expect(find.text('PORTAL VPN'), findsNothing);
    expect(find.text('Zero setup. Five days of speed.'), findsOneWidget);
    expect(find.text('Start 5-day test-drive'), findsOneWidget);
    expect(find.text('Telegram bonus adds 10 more days'), findsOneWidget);
    expect(find.text('4-platform target'), findsOneWidget);
    expect(find.text('Automatic activation and key delivery'), findsOneWidget);
    expect(find.text('Automatic activation first'), findsOneWidget);
    expect(find.textContaining('Android / Windows'), findsOneWidget);
    expect(find.text('Redeem or add access key'), findsWidgets);
    expect(find.textContaining('NL-free'), findsOneWidget);
  });

  testWidgets('shows premium empty home state in Russian', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          translationsProvider.overrideWithValue(AppLocale.ru.build()),
          portalTrialActivationControllerProvider.overrideWith(
            (ref) => PortalTrialActivationController(ref),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('ru'),
          supportedLocales: [Locale('en'), Locale('ru')],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                EmptyProfilesHomeBody(),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Пять дней магии без настройки'), findsOneWidget);
    expect(find.text('Запустить тест-драйв на 5 дней'), findsOneWidget);
    expect(find.text('Бонус Telegram даёт ещё +10 дней'), findsOneWidget);
  });
}
