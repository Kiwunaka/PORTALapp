import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/model/region.dart';
import 'package:hiddify/features/config_option/data/config_option_repository.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';
import 'package:hiddify/singbox/model/singbox_rule.dart';

void main() {
  group('buildRoutingRules', () {
    test('returns no extra rules for global mode', () {
      final rules = buildRoutingRules(
        routingMode: RoutingMode.global,
        region: null,
      );

      expect(rules, isEmpty);
    });

    test('routes RU and private traffic direct in all_except_ru mode', () {
      final rules = buildRoutingRules(
        routingMode: RoutingMode.allExceptRu,
        region: Region.ru,
      );

      expect(
        rules,
        containsAll([
          const SingboxRule(
            ip: 'geoip:private',
            outbound: RuleOutbound.bypass,
          ),
          const SingboxRule(
            domains: 'domain:.ru',
            ip: 'geoip:ru',
            outbound: RuleOutbound.bypass,
          ),
          const SingboxRule(
            domains: 'domain:.\u0440\u0444',
            outbound: RuleOutbound.bypass,
          ),
          const SingboxRule(
            domains: 'domain:.su',
            outbound: RuleOutbound.bypass,
          ),
        ]),
      );
    });

    test('routes only blocked destinations through proxy in blocked_only mode',
        () {
      final rules = buildRoutingRules(
        routingMode: RoutingMode.blockedOnly,
        region: Region.ru,
      );

      expect(
        rules,
        equals([
          const SingboxRule(
            ruleSetUrl: kBlockedOnlyRuleSetUrl,
          ),
        ]),
      );
    });
  });
}
