import 'dart:ui';

import 'package:hiddify/core/app_info/app_info_provider.dart';
import 'package:hiddify/core/model/app_info_entity.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/data/portal_session_store.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hiddify/features/profile/data/profile_data_providers.dart';
import 'package:hiddify/features/profile/data/profile_repository.dart';
import 'package:hiddify/features/profile/notifier/active_profile_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final portalTrialActivatorProvider = Provider<PortalTrialActivator>(
  (ref) => PortalTrialActivator(
    portalRepository: ref.watch(portalRepositoryProvider),
    sessionStore: ref.watch(portalSessionStoreProvider),
    loadProfileRepository: () => ref.read(profileRepositoryProvider.future),
    appInfo: ref.watch(appInfoProvider).requireValue,
  ),
);

final portalTrialActivationControllerProvider =
    StateNotifierProvider.autoDispose<PortalTrialActivationController,
        AsyncValue<PortalTrialActivationResult?>>(
  (ref) => PortalTrialActivationController(ref),
);

enum PortalActivationDeliveryPath {
  managed,
  keyBased,
}

class PortalTrialActivationResult {
  const PortalTrialActivationResult({
    required this.experience,
    required this.deliveryPath,
  });

  final PortalExperience experience;
  final PortalActivationDeliveryPath deliveryPath;

  bool get usedKeyBasedFallback =>
      deliveryPath == PortalActivationDeliveryPath.keyBased;
}

class PortalTrialActivationController
    extends StateNotifier<AsyncValue<PortalTrialActivationResult?>> {
  PortalTrialActivationController(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<void> activateTrial({Locale? locale}) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(portalTrialActivatorProvider)
          .activateTrial(locale: locale);
      ref.invalidate(activeProfileProvider);
      ref.invalidate(hasAnyProfileProvider);
      ref.invalidate(portalExperienceProvider);
      return result;
    });
  }
}

class PortalTrialActivator {
  PortalTrialActivator({
    required this.portalRepository,
    required this.sessionStore,
    required this.loadProfileRepository,
    required this.appInfo,
  });

  final PortalRepository portalRepository;
  final PortalSessionStore sessionStore;
  final Future<ProfileRepository> Function() loadProfileRepository;
  final AppInfoEntity appInfo;

  Future<PortalTrialActivationResult> activateTrial({Locale? locale}) async {
    final request = PortalStartTrialRequest(
      installId: await sessionStore.ensureInstallId(),
      deviceName: _deviceNameFrom(appInfo),
      platform: appInfo.operatingSystem,
      operatingSystemVersion: appInfo.operatingSystemVersion,
      appVersion: appInfo.version,
      localeTag: locale?.languageCode ??
          PlatformDispatcher.instance.locale.languageCode,
      timeZone: DateTime.now().timeZoneName,
    );

    final experience = await portalRepository.startTrial(request);
    final subscriptionUrl = experience.importPayload.subscriptionUrl.trim();
    final profileRepository = await loadProfileRepository();
    final managedManifest = experience.importPayload.managedManifest;
    if (managedManifest.isConfigured) {
      try {
        final manifestBody = await portalRepository.fetchManagedManifest(
          managedManifest,
        );
        if (manifestBody.trim().isNotEmpty) {
          await profileRepository
              .addByContent(
                manifestBody,
                name: _managedProfileName(experience, managedManifest),
                markAsActive: true,
              )
              .getOrElse((failure) => throw failure)
              .run();
          return PortalTrialActivationResult(
            experience: experience,
            deliveryPath: PortalActivationDeliveryPath.managed,
          );
        }
      } catch (_) {
        if (subscriptionUrl.isEmpty) rethrow;
      }
    }

    if (subscriptionUrl.isEmpty) {
      throw const FormatException(
        'Trial activation did not return an importable access payload.',
      );
    }

    await profileRepository
        .addByUrl(
          subscriptionUrl,
          markAsActive: true,
        )
        .getOrElse((failure) => throw failure)
        .run();

    return PortalTrialActivationResult(
      experience: experience,
      deliveryPath: PortalActivationDeliveryPath.keyBased,
    );
  }
}

String _deviceNameFrom(AppInfoEntity appInfo) {
  return switch (appInfo.operatingSystem.toLowerCase()) {
    'android' => 'Android device',
    'windows' => 'Windows PC',
    final platform when platform.isEmpty => 'Current device',
    final platform =>
      '${platform[0].toUpperCase()}${platform.substring(1)} device',
  };
}

String _managedProfileName(
  PortalExperience experience,
  PortalManagedManifest manifest,
) {
  final suffix = manifest.profileRevision.isNotEmpty
      ? manifest.profileRevision
      : manifest.transportKind.isNotEmpty
          ? manifest.transportKind
          : experience.session.accountId;
  return 'POKROV managed $suffix';
}
