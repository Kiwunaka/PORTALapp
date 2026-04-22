import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/widget/premium_surfaces.dart';
import 'package:hiddify/features/portal/config/portal_client_strategy.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hiddify/features/portal/widget/portal_copy.dart';
import 'package:hiddify/features/portal/widget/portal_widgets.dart';

class PortalQuickConnectPanel extends StatelessWidget {
  const PortalQuickConnectPanel({
    required this.experience,
    required this.onOpenLocations,
    required this.onOpenTelegramReward,
    super.key,
  });

  final PortalExperience experience;
  final VoidCallback onOpenLocations;
  final VoidCallback onOpenTelegramReward;

  @override
  Widget build(BuildContext context) {
    final copy = PortalCopy.of(context);
    final theme = Theme.of(context);
    final location = _primaryLocation(experience);
    final heroTitle = copy.heroStatusTitle(
      trialLike: experience.subscription.isTrialLike,
    );
    final transportVariant = resolvePortalTransportVariant(experience);
    final metricWidth = portalAdaptiveTileWidth(context);
    final useCompactLayout = portalUseCompactLayout(context);

    return PortalSectionCard(
      tone: PortalSectionTone.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PortalStatusBadge(
                label: copy.quickConnectBadge,
                icon: Icons.flash_on_rounded,
              ),
              PortalStatusBadge(
                label: copy.routeDeckBadge,
                icon: Icons.auto_awesome_rounded,
              ),
              PortalStatusBadge(
                label: copy.nodesReady(
                  experience.dashboard.connectionPointsLabel,
                ),
                icon: Icons.hub_rounded,
              ),
            ],
          ),
          const Gap(16),
          Text(heroTitle, style: theme.textTheme.headlineSmall),
          const Gap(8),
          Text(
            copy.localizeServerText(experience.dashboard.statusBody),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(20),
          PortalSectionCard(
            tone: PortalSectionTone.muted,
            padding: const EdgeInsets.all(18),
            child: useCompactLayout
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PremiumIconOrb(
                            icon: Icons.travel_explore_rounded,
                            size: 54,
                          ),
                          const Gap(14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  copy.autoRouteTitle,
                                  style: theme.textTheme.titleLarge,
                                ),
                                const Gap(4),
                                Text(
                                  location != null
                                      ? copy.localizeServerText(location.title)
                                      : copy.autoSelectTitle,
                                  style: theme.textTheme.titleMedium,
                                ),
                                const Gap(2),
                                Text(
                                  location?.subtitle.isNotEmpty == true
                                      ? copy.localizeServerText(
                                          location!.subtitle,
                                        )
                                      : copy.bestPathNow,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (transportVariant != null) ...[
                                  const Gap(10),
                                  Text(
                                    copy.transportVariantBadge(
                                      transportVariant.badgeLabel,
                                    ),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Gap(14),
                      OutlinedButton(
                        onPressed: onOpenLocations,
                        child: Text(copy.chooseRouteAction),
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PremiumIconOrb(
                        icon: Icons.travel_explore_rounded,
                        size: 54,
                      ),
                      const Gap(14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              copy.autoRouteTitle,
                              style: theme.textTheme.titleLarge,
                            ),
                            const Gap(4),
                            Text(
                              location != null
                                  ? copy.localizeServerText(location.title)
                                  : copy.autoSelectTitle,
                              style: theme.textTheme.titleMedium,
                            ),
                            const Gap(2),
                            Text(
                              location?.subtitle.isNotEmpty == true
                                  ? copy.localizeServerText(location!.subtitle)
                                  : copy.bestPathNow,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (transportVariant != null) ...[
                              const Gap(10),
                              Text(
                                copy.transportVariantBadge(
                                  transportVariant.badgeLabel,
                                ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Gap(12),
                      OutlinedButton(
                        onPressed: onOpenLocations,
                        child: Text(copy.chooseRouteAction),
                      ),
                    ],
                  ),
          ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.06, end: 0),
          const Gap(16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: metricWidth,
                child: PortalMetricTile(
                  label: copy.protectedUntil,
                  value: formatPortalDate(experience.dashboard.expiresAt),
                  caption: copy.protectedUntilCaption,
                  icon: Icons.event_available_rounded,
                ),
              ),
              SizedBox(
                width: metricWidth,
                child: PortalMetricTile(
                  label: copy.remainingTraffic,
                  value: formatPortalTraffic(experience.usage.remainingGb),
                  caption: copy.remainingTrafficCaption,
                  icon: Icons.shield_outlined,
                ),
              ),
              SizedBox(
                width: metricWidth,
                child: PortalMetricTile(
                  label: copy.liveDevices,
                  value:
                      '${experience.usage.activeSessions}/${experience.usage.deviceLimit}',
                  caption: copy.liveDevicesCaption,
                  icon: Icons.devices_rounded,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.08, end: 0),
          const Gap(16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.tonalIcon(
                onPressed: onOpenTelegramReward,
                icon: const Icon(Icons.card_giftcard_rounded),
                label: Text(copy.bonusDaysAction),
              ),
              TextButton.icon(
                onPressed: onOpenLocations,
                icon: const Icon(Icons.public_rounded),
                label: Text(copy.browseLocationsAction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

LocationRecord? _primaryLocation(PortalExperience experience) {
  for (final location in experience.locations) {
    if (location.isActive) return location;
  }
  return experience.locations.isEmpty ? null : experience.locations.first;
}
