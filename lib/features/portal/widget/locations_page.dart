import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/core/widget/premium_surfaces.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:hiddify/features/portal/config/portal_client_strategy.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hiddify/features/portal/widget/portal_copy.dart';
import 'package:hiddify/features/portal/widget/portal_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LocationsPage extends HookConsumerWidget {
  const LocationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = PortalCopy.of(context);
    final experience = ref.watch(portalExperienceProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumPageBackground(
        child: CustomScrollView(
          slivers: [
            NestedAppBar(title: Text(copy.locationsTitle)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              sliver: SliverToBoxAdapter(
                child: PortalAsyncBody(
                  value: experience,
                  builder: (context, portal) {
                    if (!portal.hasProvisionedAccess) {
                      return _LocationsLockedState(copy: copy);
                    }

                    if (portal.locations.isEmpty) {
                      return _LocationsSyncState(copy: copy);
                    }

                    final primary = _primaryLocation(portal);
                    final transportVariant =
                        resolvePortalTransportVariant(portal);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PortalSectionCard(
                          tone: PortalSectionTone.accent,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PremiumSectionHeader(
                                eyebrow: copy.routingEyebrow,
                                title: copy.autoSelectTitle,
                                subtitle: copy.bestServerNow,
                              ),
                              const Gap(16),
                              PortalListRow(
                                title: primary != null
                                    ? copy.localizeServerText(primary.title)
                                    : copy.bestAvailable,
                                subtitle: primary != null
                                    ? copy.localizeServerText(primary.subtitle)
                                    : copy.bestServerNow,
                                leading: const PremiumIconOrb(
                                  icon: Icons.auto_awesome_rounded,
                                  size: 48,
                                ),
                                trailing: PortalStatusBadge(
                                  label: primary?.isActive == true
                                      ? copy.activeRoute
                                      : copy.recommended,
                                  icon: primary?.isActive == true
                                      ? Icons.check_rounded
                                      : Icons.auto_awesome_rounded,
                                ),
                              ),
                              if (transportVariant != null) ...[
                                const Gap(12),
                                Text(
                                  copy.transportVariantBadge(
                                    transportVariant.badgeLabel,
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
                            ],
                          ),
                        ),
                        const Gap(16),
                        ...portal.locations.map(
                          (location) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _LocationCard(
                              location: location,
                              copy: copy,
                            ),
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

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.location,
    required this.copy,
  });

  final LocationRecord location;
  final PortalCopy copy;

  @override
  Widget build(BuildContext context) {
    final tone = location.isActive
        ? PortalSectionTone.accent
        : PortalSectionTone.neutral;

    if (location.variants.isEmpty) {
      return PortalSectionCard(
        tone: tone,
        child: PortalListRow(
          title: copy.localizeServerText(location.title),
          subtitle: copy.localizeServerText(location.subtitle),
          leading: _LocationIcon(location: location),
          trailing: _LocationBadge(location: location, copy: copy),
        ),
      );
    }

    return PortalSectionCard(
      tone: tone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PortalListRow(
            title: copy.localizeServerText(location.title),
            subtitle: copy.localizeServerText(location.subtitle),
            leading: _LocationIcon(location: location),
            trailing: _LocationBadge(location: location, copy: copy),
          ),
          const Gap(14),
          ..._buildVariantRows(context),
        ],
      ),
    );
  }

  List<Widget> _buildVariantRows(BuildContext context) {
    final rows = <Widget>[];
    for (var index = 0; index < location.variants.length; index++) {
      if (index > 0) rows.add(const Gap(10));
      rows.add(
        _LocationVariantRow(
          variant: location.variants[index],
          copy: copy,
        ),
      );
    }
    return rows;
  }
}

class _LocationIcon extends StatelessWidget {
  const _LocationIcon({required this.location});

  final LocationRecord location;

  @override
  Widget build(BuildContext context) {
    return PremiumIconOrb(
      icon: location.isActive
          ? Icons.radio_button_checked_rounded
          : Icons.radio_button_off_rounded,
      size: 46,
      accent: location.isActive
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}

class _LocationBadge extends StatelessWidget {
  const _LocationBadge({
    required this.location,
    required this.copy,
  });

  final LocationRecord location;
  final PortalCopy copy;

  @override
  Widget build(BuildContext context) {
    return PortalStatusBadge(
      label: location.isActive ? copy.selected : copy.available,
      icon: location.isActive ? Icons.check_rounded : Icons.place_outlined,
    );
  }
}

class _LocationVariantRow extends StatelessWidget {
  const _LocationVariantRow({
    required this.variant,
    required this.copy,
  });

  final LocationVariantRecord variant;
  final PortalCopy copy;

  @override
  Widget build(BuildContext context) {
    final isComingSoon = variant.isComingSoon || !variant.isEnabled;
    final statusLabel = isComingSoon
        ? copy.comingSoon
        : (variant.isActive ? copy.activeRoute : copy.available);
    final statusIcon = isComingSoon
        ? Icons.lock_clock_rounded
        : (variant.isActive ? Icons.check_rounded : Icons.flash_on_rounded);

    return PortalListRow(
      title: variant.label,
      leading: PremiumIconOrb(
        icon: isComingSoon ? Icons.lock_clock_rounded : Icons.alt_route_rounded,
        size: 38,
      ),
      trailing: PortalStatusBadge(
        label: statusLabel,
        icon: statusIcon,
      ),
    );
  }
}

class _LocationsLockedState extends StatelessWidget {
  const _LocationsLockedState({required this.copy});

  final PortalCopy copy;

  @override
  Widget build(BuildContext context) {
    return PortalSectionCard(
      tone: PortalSectionTone.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumSectionHeader(
            eyebrow: copy.routingEyebrow,
            title: copy.locationsGateTitle,
            subtitle: copy.locationsGateBody,
          ),
          const Gap(18),
          FilledButton.icon(
            onPressed: () => const HomeRoute().go(context),
            icon: const Icon(Icons.shield_rounded),
            label: Text(copy.openVpnAction),
          ),
        ],
      ),
    );
  }
}

class _LocationsSyncState extends StatelessWidget {
  const _LocationsSyncState({required this.copy});

  final PortalCopy copy;

  @override
  Widget build(BuildContext context) {
    return PortalSectionCard(
      tone: PortalSectionTone.muted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumSectionHeader(
            eyebrow: copy.routingEyebrow,
            title: copy.locationsSyncTitle,
            subtitle: copy.locationsSyncBody,
          ),
          const Gap(18),
          OutlinedButton.icon(
            onPressed: () => const HomeRoute().go(context),
            icon: const Icon(Icons.shield_outlined),
            label: Text(copy.openVpnAction),
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
