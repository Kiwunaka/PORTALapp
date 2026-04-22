import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/app_info/app_info_provider.dart';
import 'package:hiddify/core/model/app_info_entity.dart';
import 'package:hiddify/core/model/environment.dart';
import 'package:hiddify/features/home/widget/home_page.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/profile/model/profile_entity.dart';
import 'package:hiddify/features/profile/notifier/active_profile_notifier.dart';
import 'package:hiddify/features/settings/data/route_mode_preferences.dart';

import '../../../test_helpers/portal_experience_fixture.dart';
import '../../../test_helpers/premium_test_app.dart';

class _TestAppInfo extends AppInfo {
  @override
  Future<AppInfoEntity> build() async => const AppInfoEntity(
        name: 'POKROV',
        version: '0.4.0-beta',
        buildNumber: '1',
        release: Release.general,
        operatingSystem: 'windows',
        operatingSystemVersion: '11',
        environment: Environment.prod,
      );
}

class _TestActiveProfile extends ActiveProfile {
  _TestActiveProfile(this.profile);

  final ProfileEntity profile;

  @override
  Stream<ProfileEntity?> build() async* {
    yield profile;
  }
}

void main() {
  testWidgets(
    'moves the profile switch action below the summary on compact widths',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final profile = ProfileEntity.remote(
        id: 'profile-1',
        active: true,
        name: 'POKROV Access',
        url: 'https://connect.pokrov.space/demo',
        lastUpdate: DateTime(2026, 4, 14),
        subInfo: SubscriptionInfo(
          upload: 0,
          download: 0,
          total: 15 * 1024 * 1024 * 1024,
          expire: DateTime(2026, 5, 14),
        ),
      );

      await tester.pumpWidget(
        buildPremiumTestApp(
          overrides: [
            appInfoProvider.overrideWith(_TestAppInfo.new),
            hasAnyProfileProvider.overrideWith((ref) => Stream.value(true)),
            activeProfileProvider
                .overrideWith(() => _TestActiveProfile(profile)),
            portalExperienceProvider
                .overrideWith((ref) async => buildPortalExperienceFixture()),
            routeModeChoiceCompletedProvider.overrideWith((ref) => false),
          ],
          child: const HomePage(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final profileName = find.text('POKROV Access');
      final switchAction = find.text('Switch');

      expect(profileName, findsOneWidget);
      expect(switchAction, findsOneWidget);
      expect(
        tester.getTopLeft(switchAction).dy,
        greaterThan(tester.getBottomLeft(profileName).dy),
      );
    },
  );
}
