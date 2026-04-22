import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/core/model/app_info_entity.dart';
import 'package:hiddify/core/model/environment.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/data/portal_session_store.dart';
import 'package:hiddify/features/portal/data/portal_trial_activator.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hiddify/features/profile/data/profile_repository.dart';
import 'package:hiddify/features/profile/model/profile_entity.dart';
import 'package:hiddify/features/profile/model/profile_failure.dart';

class _FakePortalRepository implements PortalRepository {
  _FakePortalRepository(
    this.experience, {
    this.managedManifestBody = '',
    this.throwOnManagedManifest = false,
  });

  final PortalExperience experience;
  final String managedManifestBody;
  final bool throwOnManagedManifest;
  PortalStartTrialRequest? capturedRequest;
  PortalManagedManifest? capturedManagedManifest;

  @override
  Future<PortalExperience> getExperience() async => experience;

  @override
  Future<PortalExperience> startTrial(PortalStartTrialRequest request) async {
    capturedRequest = request;
    return experience;
  }

  @override
  Future<TelegramBonusClaimResult> claimTelegramBonus() async {
    return const TelegramBonusClaimResult(
      ok: true,
      alreadyClaimed: false,
      premiumDays: 10,
      linkedTelegramId: 0,
      linkedTelegramUsername: '',
    );
  }

  @override
  Future<TelegramLinkSession> requestTelegramLink() async {
    return const TelegramLinkSession(
      linked: false,
      linkedTelegramId: 0,
      linkedTelegramUsername: '',
      startCode: 'app-test',
      botUrl: 'https://t.me/portal_service_bot?start=app-test',
      channelUrl: 'https://t.me/portal_privacy',
    );
  }

  @override
  Future<String> fetchManagedManifest(PortalManagedManifest manifest) async {
    capturedManagedManifest = manifest;
    if (throwOnManagedManifest) {
      throw StateError('managed manifest unavailable');
    }
    return managedManifestBody;
  }
}

class _MemoryPortalSessionStore implements PortalSessionStore {
  _MemoryPortalSessionStore();

  final String installId = 'install-123';
  String sessionToken = '';

  @override
  Future<void> clearSession() async {
    sessionToken = '';
  }

  @override
  Future<String> ensureInstallId() async => installId;

  @override
  bool get hasSessionAuth => sessionToken.isNotEmpty;

  @override
  String readInstallIdSync() => installId;

  @override
  String readSessionTokenSync() => sessionToken;

  @override
  Future<void> saveSessionToken(String value) async {
    sessionToken = value;
  }
}

class _FakeProfileRepository implements ProfileRepository {
  String? importedUrl;
  String? importedContent;
  String? importedName;
  bool? importedAsActive;

  @override
  Future<ProfileEntity?> getByName(String name) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  TaskEither<ProfileFailure, Unit> addByUrl(
    String url, {
    bool markAsActive = false,
    CancelToken? cancelToken,
  }) {
    importedUrl = url;
    importedAsActive = markAsActive;
    return TaskEither.right(unit);
  }

  @override
  TaskEither<ProfileFailure, Unit> addByContent(
    String content, {
    required String name,
    bool markAsActive = false,
  }) {
    importedContent = content;
    importedName = name;
    importedAsActive = markAsActive;
    return TaskEither.right(unit);
  }
}

void main() {
  test('activateTrial fetches managed manifest first and imports content',
      () async {
    final repository = _FakePortalRepository(
      const PortalExperience(
        isDemo: false,
        session: SessionSummary(
          tgId: 0,
          accountId: 'acc_1001',
          deviceName: 'Android device',
          username: 'guest-acc_1001',
          isAuthorized: true,
        ),
        dashboard: DashboardSummary(
          isActive: true,
          currentPlanLabel: 'Trial',
          statusHeadline: 'Ready to connect',
          statusBody: 'Trial is active on this device.',
          expiresAt: null,
          usedGb: 0,
          totalGb: 15,
          remainingGb: 15,
          activeSessions: 0,
          deviceLimit: 1,
          connectionKey: 'https://portal.example.test/sub/trial',
          healthyNodes: 1,
          totalNodes: 1,
        ),
        subscription: SubscriptionState(
          currentPlanCode: 'trial_5_days',
          currentPlanLabel: 'Trial',
          isTrialLike: true,
          checkoutEnabled: true,
          checkoutUrl: 'https://portal.example.test/checkout',
          payViaBotUrl: 'https://t.me/portal_service_bot',
          plans: [],
        ),
        checkout: null,
        usage: UsageStats(
          usedGb: 0,
          totalGb: 15,
          remainingGb: 15,
          activeSessions: 0,
          deviceLimit: 1,
          healthyNodes: 1,
          totalNodes: 1,
        ),
        supportThreads: [],
        downloads: [],
        importPayload: ImportPayload(
          subscriptionUrl: '',
          smartUrl: '',
          plainUrl: '',
          qrValue: '',
          managedManifest: PortalManagedManifest(
            url: '/api/client/managed-manifest/install-123',
            transportKind: 'managed-http',
            engineHint: 'sing-box',
            profileRevision: 'rev-7',
          ),
        ),
      ),
      managedManifestBody: '{"managed":true}',
    );
    final profileRepository = _FakeProfileRepository();
    final activator = PortalTrialActivator(
      portalRepository: repository,
      sessionStore: _MemoryPortalSessionStore(),
      loadProfileRepository: () async => profileRepository,
      appInfo: const AppInfoEntity(
        name: 'POKROV',
        version: '1.0.0',
        buildNumber: '100',
        release: Release.general,
        operatingSystem: 'android',
        operatingSystemVersion: '14',
        environment: Environment.prod,
      ),
    );

    final result = await activator.activateTrial(
      locale: const Locale('ru'),
    );

    expect(result.deliveryPath, PortalActivationDeliveryPath.managed);
    expect(result.experience.importPayload.subscriptionUrl, isEmpty);
    expect(profileRepository.importedUrl, isNull);
    expect(profileRepository.importedContent, equals('{"managed":true}'));
    expect(profileRepository.importedName, contains('managed'));
    expect(profileRepository.importedAsActive, isTrue);
    expect(repository.capturedRequest, isNotNull);
    expect(repository.capturedManagedManifest, isNotNull);
    expect(
      repository.capturedManagedManifest!.profileRevision,
      equals('rev-7'),
    );
    expect(repository.capturedRequest!.installId, equals('install-123'));
    expect(repository.capturedRequest!.deviceName, equals('Android device'));
    expect(repository.capturedRequest!.localeTag, equals('ru'));
  });

  test(
      'activateTrial falls back to subscription url when managed manifest fetch fails',
      () async {
    final repository = _FakePortalRepository(
      const PortalExperience(
        isDemo: false,
        session: SessionSummary(
          tgId: 0,
          accountId: 'acc_1001',
          deviceName: 'Android device',
          username: 'guest-acc_1001',
          isAuthorized: true,
        ),
        dashboard: DashboardSummary(
          isActive: true,
          currentPlanLabel: 'Trial',
          statusHeadline: 'Ready to connect',
          statusBody: 'Trial is active on this device.',
          expiresAt: null,
          usedGb: 0,
          totalGb: 15,
          remainingGb: 15,
          activeSessions: 0,
          deviceLimit: 1,
          connectionKey: 'https://portal.example.test/sub/trial',
          healthyNodes: 1,
          totalNodes: 1,
        ),
        subscription: SubscriptionState(
          currentPlanCode: 'trial_5_days',
          currentPlanLabel: 'Trial',
          isTrialLike: true,
          checkoutEnabled: true,
          checkoutUrl: 'https://portal.example.test/checkout',
          payViaBotUrl: 'https://t.me/portal_service_bot',
          plans: [],
        ),
        checkout: null,
        usage: UsageStats(
          usedGb: 0,
          totalGb: 15,
          remainingGb: 15,
          activeSessions: 0,
          deviceLimit: 1,
          healthyNodes: 1,
          totalNodes: 1,
        ),
        supportThreads: [],
        downloads: [],
        importPayload: ImportPayload(
          subscriptionUrl: 'https://portal.example.test/sub/trial',
          smartUrl: 'https://portal.example.test/sub/trial?format=smart',
          plainUrl: 'https://portal.example.test/sub/trial?format=plain',
          qrValue: 'https://portal.example.test/sub/trial',
          managedManifest: PortalManagedManifest(
            url: '/api/client/managed-manifest/install-123',
          ),
        ),
      ),
      throwOnManagedManifest: true,
    );
    final profileRepository = _FakeProfileRepository();
    final activator = PortalTrialActivator(
      portalRepository: repository,
      sessionStore: _MemoryPortalSessionStore(),
      loadProfileRepository: () async => profileRepository,
      appInfo: const AppInfoEntity(
        name: 'POKROV',
        version: '1.0.0',
        buildNumber: '100',
        release: Release.general,
        operatingSystem: 'android',
        operatingSystemVersion: '14',
        environment: Environment.prod,
      ),
    );

    final result = await activator.activateTrial(locale: const Locale('en'));

    expect(result.deliveryPath, PortalActivationDeliveryPath.keyBased);
    expect(repository.capturedManagedManifest, isNotNull);
    expect(
      profileRepository.importedUrl,
      equals('https://portal.example.test/sub/trial'),
    );
    expect(profileRepository.importedContent, isNull);
    expect(profileRepository.importedAsActive, isTrue);
  });
}
