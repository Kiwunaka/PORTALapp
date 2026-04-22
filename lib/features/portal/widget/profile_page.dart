import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/router/routes.dart';
import 'package:hiddify/core/widget/premium_surfaces.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:hiddify/features/portal/config/portal_client_strategy.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/widget/portal_copy.dart';
import 'package:hiddify/features/portal/widget/portal_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = PortalCopy.of(context);
    final experience = ref.watch(portalExperienceProvider);
    final config = ref.watch(portalPublicConfigProvider);
    final strategy = ref.watch(portalClientStrategyProvider);
    final isLinkingTelegram = useState(false);
    final isClaimingBonus = useState(false);
    final bonusStatus = useState<String?>(null);

    Future<void> handleTelegramLink() async {
      if (isLinkingTelegram.value) return;
      isLinkingTelegram.value = true;
      try {
        final link =
            await ref.read(portalRepositoryProvider).requestTelegramLink();
        if (!context.mounted) return;
        bonusStatus.value = link.linked
            ? copy.telegramAlreadyLinked(link.linkedTelegramUsername)
            : copy.telegramLinkHint;
        final destination =
            link.botUrl.isNotEmpty ? link.botUrl : config.botUrl;
        await launchPortalLink(context, destination);
      } catch (error) {
        if (!context.mounted) return;
        bonusStatus.value = _portalErrorMessage(copy, error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_portalErrorMessage(copy, error))),
        );
      } finally {
        isLinkingTelegram.value = false;
      }
    }

    Future<void> handleBonusClaim() async {
      if (isClaimingBonus.value) return;
      isClaimingBonus.value = true;
      try {
        final result =
            await ref.read(portalRepositoryProvider).claimTelegramBonus();
        ref.invalidate(portalExperienceProvider);
        if (!context.mounted) return;
        final successMessage = result.alreadyClaimed
            ? copy.bonusAlreadyActive
            : copy.bonusApplied(result.premiumDays);
        bonusStatus.value = successMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
      } catch (error) {
        if (!context.mounted) return;
        final message = _portalErrorMessage(copy, error);
        bonusStatus.value = message;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } finally {
        isClaimingBonus.value = false;
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumPageBackground(
        child: CustomScrollView(
          slivers: [
            NestedAppBar(title: Text(copy.profileTitle)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              sliver: SliverToBoxAdapter(
                child: PortalAsyncBody(
                  value: experience,
                  builder: (context, portal) {
                    final metricWidth = portalAdaptiveTileWidth(context);
                    final useCompactActions = portalUseCompactLayout(context);
                    final linkedTelegramLabel = portal
                            .session.linkedTelegramUsername.isNotEmpty
                        ? '@${portal.session.linkedTelegramUsername}'
                        : (portal.session.linkedTelegramId > 0
                            ? '${copy.isRussian ? 'ID' : 'ID'} ${portal.session.linkedTelegramId}'
                            : copy.telegramNotLinked);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PortalSectionCard(
                          tone: PortalSectionTone.accent,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PremiumSectionHeader(
                                eyebrow: copy.accountEyebrow,
                                title: copy.accountTitle,
                                subtitle: copy.accountSubtitle,
                              ),
                              const Gap(16),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  SizedBox(
                                    width: metricWidth,
                                    child: PortalMetricTile(
                                      icon: Icons.data_usage_rounded,
                                      label: copy.remainingTrafficMetric,
                                      value: formatPortalTraffic(
                                        portal.usage.remainingGb,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: metricWidth,
                                    child: PortalMetricTile(
                                      icon: Icons.verified_user_outlined,
                                      label: copy.planMetric,
                                      value: copy.localizeServerText(
                                        portal.subscription.currentPlanLabel,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(14),
                              PortalListRow(
                                title: portal.session.isAuthorized
                                    ? copy.appAccount
                                    : copy.deviceTrial,
                                subtitle: copy.accountDetails(
                                  portal.session.accountId,
                                  portal.session.deviceName,
                                ),
                                leading: const PremiumIconOrb(
                                  icon: Icons.person_outline_rounded,
                                  size: 48,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(16),
                        PortalSectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PremiumSectionHeader(
                                eyebrow: copy.rewardsEyebrow,
                                title: copy.rewardsTitle,
                                subtitle: copy.rewardsSubtitle,
                              ),
                              const Gap(14),
                              PortalListRow(
                                title: copy.telegramStatus,
                                subtitle: portal.session.linkedTelegramId > 0
                                    ? copy.telegramLinked(linkedTelegramLabel)
                                    : copy.telegramNotLinked,
                                leading: const PremiumIconOrb(
                                  icon: Icons.telegram,
                                  size: 48,
                                ),
                              ),
                              const Gap(14),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  FilledButton(
                                    onPressed: isLinkingTelegram.value
                                        ? null
                                        : handleTelegramLink,
                                    child: Text(
                                      isLinkingTelegram.value
                                          ? copy.openingAction
                                          : copy.linkTelegramAction,
                                    ),
                                  ),
                                  OutlinedButton(
                                    onPressed: isClaimingBonus.value
                                        ? null
                                        : handleBonusClaim,
                                    child: Text(
                                      isClaimingBonus.value
                                          ? copy.checkingAction
                                          : copy.checkBonusAction,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => launchPortalLink(
                                      context,
                                      config.newsChannelUrl,
                                    ),
                                    child: Text(copy.openChannelAction),
                                  ),
                                ],
                              ),
                              if ((bonusStatus.value ?? '').isNotEmpty) ...[
                                const Gap(12),
                                Text(
                                  bonusStatus.value!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Gap(16),
                        PortalSectionCard(
                          tone: PortalSectionTone.muted,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PremiumSectionHeader(
                                eyebrow: copy.activationEyebrow,
                                title: copy.activationTitle,
                                subtitle: copy.activationSubtitle,
                              ),
                              const Gap(14),
                              PortalListRow(
                                title: copy.automaticActivationTitle,
                                subtitle: copy.automaticActivationSubtitle(
                                  strategy.automaticActivationPlatformLine,
                                ),
                                leading: const PremiumIconOrb(
                                  icon: Icons.flash_on_rounded,
                                  size: 42,
                                ),
                              ),
                              const Gap(10),
                              PortalListRow(
                                title: copy.redeemAccessTitle,
                                subtitle: copy.redeemAccessSubtitle(
                                  strategy.keyDeliveryPlatformLine,
                                ),
                                leading: const PremiumIconOrb(
                                  icon: Icons.key_rounded,
                                  size: 42,
                                ),
                              ),
                              const Gap(12),
                              Text(
                                copy.freeTierContinuation(
                                  trafficGb: strategy.freeTier.trafficGb,
                                  periodDays: strategy.freeTier.periodDays,
                                  deviceLimit: strategy.freeTier.deviceLimit,
                                  nodePool: strategy.freeTier.nodePool,
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(16),
                        PortalSectionCard(
                          tone: PortalSectionTone.muted,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PremiumSectionHeader(
                                eyebrow: copy.recoveryEyebrow,
                                title: copy.accessReadyTitle,
                                subtitle: copy.accessReadySubtitle,
                              ),
                              const Gap(14),
                              PortalListRow(
                                title: copy.automaticSyncTitle,
                                subtitle: copy.automaticSyncSubtitle,
                                leading: const PremiumIconOrb(
                                  icon: Icons.sync_rounded,
                                  size: 42,
                                ),
                              ),
                              const Gap(10),
                              PortalListRow(
                                title: copy.advancedRecoveryTools,
                                subtitle: copy.advancedRecoveryToolsSubtitle,
                                leading: const PremiumIconOrb(
                                  icon: Icons.settings_suggest_rounded,
                                  size: 42,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(16),
                        PortalSectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PremiumSectionHeader(
                                eyebrow: copy.downloadsEyebrow,
                                title: copy.downloadsTitle,
                                subtitle: copy.downloadsSubtitle,
                              ),
                              const Gap(14),
                              ...portal.downloads.map(
                                (target) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: PortalListRow(
                                    title: copy.localizeServerText(
                                      target.platformLabel,
                                    ),
                                    subtitle: target.primaryUrl.isNotEmpty
                                        ? target.primaryUrl
                                        : target.docsUrl,
                                    leading: const PremiumIconOrb(
                                      icon: Icons.download_rounded,
                                      size: 42,
                                    ),
                                    onTap: () => launchPortalLink(
                                      context,
                                      target.primaryUrl.isNotEmpty
                                          ? target.primaryUrl
                                          : target.docsUrl,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(16),
                        PortalSectionCard(
                          tone: PortalSectionTone.muted,
                          child: useCompactActions
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const PremiumIconOrb(
                                          icon: Icons.tune_rounded,
                                          size: 48,
                                        ),
                                        const Gap(14),
                                        Expanded(
                                          child: PremiumSectionHeader(
                                            eyebrow: copy.advancedEyebrow,
                                            title: copy.advancedTitle,
                                            subtitle: copy.advancedSubtitle,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Gap(16),
                                    FilledButton(
                                      onPressed: () =>
                                          const SettingsRoute().push(context),
                                      child: Text(copy.openAdvancedSettings),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    const PremiumIconOrb(
                                      icon: Icons.tune_rounded,
                                      size: 48,
                                    ),
                                    const Gap(14),
                                    Expanded(
                                      child: PremiumSectionHeader(
                                        eyebrow: copy.advancedEyebrow,
                                        title: copy.advancedTitle,
                                        subtitle: copy.advancedSubtitle,
                                      ),
                                    ),
                                    const Gap(16),
                                    FilledButton(
                                      onPressed: () =>
                                          const SettingsRoute().push(context),
                                      child: Text(copy.openAdvancedSettings),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _portalErrorMessage(PortalCopy copy, Object error) {
  final raw = error.toString().trim();
  if (raw.isEmpty) {
    return copy.isRussian
        ? 'Не удалось выполнить действие. Попробуйте ещё раз.'
        : 'Could not complete the action. Please try again.';
  }
  if (raw.startsWith('Exception: ')) {
    return raw.substring('Exception: '.length).trim();
  }
  final detailIndex = raw.indexOf('"detail":"');
  if (detailIndex >= 0) {
    final detailStart = detailIndex + 10;
    final detailEnd = raw.indexOf('"', detailStart);
    if (detailEnd > detailStart) {
      return raw.substring(detailStart, detailEnd);
    }
  }
  return copy.isRussian
      ? 'Не удалось выполнить действие. Попробуйте ещё раз.'
      : 'Could not complete the action. Please try again.';
}
