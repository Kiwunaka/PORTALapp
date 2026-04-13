import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/features/config_option/data/config_option_repository.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConfigOptions.singboxConfigOptions', () {
    test('defaults to all_except_ru routing for the consumer path', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => preferences),
        ],
      );
      addTearDown(container.dispose);
      await container.read(sharedPreferencesProvider.future);
      final config =
          await container.read(ConfigOptions.singboxConfigOptions.future);

      expect(
          container.read(ConfigOptions.routingMode), RoutingMode.allExceptRu);
      expect(
        container.read(ConfigOptions.remoteDnsAddress),
        'https://1.1.1.1/dns-query',
      );
      expect(container.read(ConfigOptions.directDnsAddress), 'local');
      expect(config.routingMode, RoutingMode.allExceptRu);
      expect(config.remoteDnsAddress, 'https://1.1.1.1/dns-query');
      expect(config.directDnsAddress, 'local');
    });

    test('disables Clash API and LAN sharing by default', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => preferences),
        ],
      );
      addTearDown(container.dispose);
      await container.read(sharedPreferencesProvider.future);

      final config =
          await container.read(ConfigOptions.singboxConfigOptions.future);

      expect(config.enableClashApi, isFalse);
      expect(config.allowConnectionFromLan, isFalse);
    });

    test('allows explicit advanced opt-in for Clash API', () async {
      SharedPreferences.setMockInitialValues({
        'enable-clash-api': true,
      });
      final preferences = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => preferences),
        ],
      );
      addTearDown(container.dispose);
      await container.read(sharedPreferencesProvider.future);

      final config =
          await container.read(ConfigOptions.singboxConfigOptions.future);

      expect(config.enableClashApi, isTrue);
      expect(config.allowConnectionFromLan, isFalse);
    });

    test('sanitizes local listener ports for Android release builds', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => preferences),
        ],
      );
      addTearDown(container.dispose);
      await container.read(sharedPreferencesProvider.future);

      final config =
          await container.read(ConfigOptions.singboxConfigOptions.future);
      final sanitized = applyReleaseLocalSurfacePolicy(
        config.copyWith(
          enableClashApi: true,
          allowConnectionFromLan: true,
          mixedPort: 12334,
          tproxyPort: 12335,
          localDnsPort: 16450,
        ),
        isAndroid: true,
        isReleaseMode: true,
      );

      expect(sanitized.enableClashApi, isFalse);
      expect(sanitized.allowConnectionFromLan, isFalse);
      expect(sanitized.mixedPort, equals(0));
      expect(sanitized.tproxyPort, equals(0));
      expect(sanitized.localDnsPort, equals(0));
    });

    test('keeps blocked-only preset out of the public picker', () {
      expect(
        consumerRoutingChoices(selected: RoutingMode.global),
        equals(const [RoutingMode.allExceptRu, RoutingMode.global]),
      );
      expect(
        consumerRoutingChoices(
          selected: RoutingMode.blockedOnly,
        ),
        equals(const [RoutingMode.allExceptRu, RoutingMode.global]),
      );
    });

    test('uses public routing labels for the consumer path', () {
      final t = AppLocale.en.build();

      expect(presentConsumerRoutingMode(RoutingMode.global, t), 'Full tunnel');
      expect(
        presentConsumerRoutingMode(RoutingMode.allExceptRu, t),
        'All except RU',
      );
    });

    test('normalizes legacy blocked-only preference back to all_except_ru', () async {
      SharedPreferences.setMockInitialValues({
        'routing-mode': RoutingMode.blockedOnly.name,
      });
      final preferences = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => preferences),
        ],
      );
      addTearDown(container.dispose);
      await container.read(sharedPreferencesProvider.future);

      expect(container.read(ConfigOptions.routingMode), RoutingMode.allExceptRu);
    });
  });
}
