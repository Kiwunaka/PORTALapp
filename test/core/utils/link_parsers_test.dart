import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/utils/link_parsers.dart';

void main() {
  group('LinkParser branded deep links', () {
    test('registers pokrovvpn protocol for runtime deep links', () {
      expect(LinkParser.protocols, contains('pokrovvpn'));
    });

    test('parses pokrovvpn install-config links like legacy branded links', () {
      final link = LinkParser.deep(
        'pokrovvpn://install-config?url=https%3A%2F%2Fapi.pokrov.space%2Fsub%2Falpha&name=POKROV',
      );

      expect(link, isNotNull);
      expect(link!.url, equals('https://api.pokrov.space/sub/alpha'));
      expect(link.name, equals('POKROV'));
    });

    test('parses pokrovvpn install-sub links like hiddify compatibility links',
        () {
      final link = LinkParser.deep(
        'pokrovvpn://install-sub?url=https%3A%2F%2Fconnect.pokrov.space%2Fsmart&name=Starter',
      );

      expect(link, isNotNull);
      expect(link!.url, equals('https://connect.pokrov.space/smart'));
      expect(link.name, equals('Starter'));
    });

    test('parses pokrovvpn import links like hiddify import links', () {
      final brandedLink = LinkParser.deep(
        'pokrovvpn://import/https://connect.pokrov.space/smart#POKROV VPN',
      );
      final legacyLink = LinkParser.deep(
        'hiddify://import/https://connect.pokrov.space/smart#POKROV VPN',
      );

      expect(brandedLink, isNotNull);
      expect(legacyLink, isNotNull);
      expect(brandedLink!.url, equals(legacyLink!.url));
      expect(brandedLink.name, equals(legacyLink.name));
    });
  });
}
