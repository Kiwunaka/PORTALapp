import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/widget/premium_surfaces.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hiddify/features/portal/widget/portal_copy.dart';
import 'package:hiddify/features/portal/widget/portal_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DevicesPage extends HookConsumerWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = PortalCopy.of(context);
    final experience = ref.watch(portalExperienceProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumPageBackground(
        child: CustomScrollView(
          slivers: [
            NestedAppBar(title: Text(copy.devicesTitle)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              sliver: SliverToBoxAdapter(
                child: PortalAsyncBody(
                  value: experience,
                  builder: (context, portal) {
                    final freeSlots =
                        (portal.usage.deviceLimit - portal.usage.activeSessions)
                            .clamp(0, portal.usage.deviceLimit);
                    final currentDevice = _currentDevice(portal);
                    final metricWidth = portalAdaptiveTileWidth(context);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PortalSectionCard(
                          tone: PortalSectionTone.accent,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PremiumSectionHeader(
                                eyebrow: copy.deviceOverviewEyebrow,
                                title: copy.currentDeviceTitle,
                                subtitle: copy.currentDeviceSubtitle,
                              ),
                              const Gap(16),
                              Text(
                                currentDevice != null
                                    ? copy.localizeServerText(
                                        currentDevice.title,
                                      )
                                    : portal.session.deviceName,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const Gap(6),
                              Text(
                                currentDevice?.subtitle.isNotEmpty == true
                                    ? copy.localizeServerText(
                                        currentDevice!.subtitle,
                                      )
                                    : copy.currentDeviceFallback,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const Gap(18),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  SizedBox(
                                    width: metricWidth,
                                    child: PortalMetricTile(
                                      icon: Icons.link_rounded,
                                      label: copy.activeSessions,
                                      value: portal.usage.activeSessions
                                          .toString(),
                                    ),
                                  ),
                                  SizedBox(
                                    width: metricWidth,
                                    child: PortalMetricTile(
                                      icon: Icons.devices_other_rounded,
                                      label: copy.availableSlots,
                                      value: freeSlots.toString(),
                                    ),
                                  ),
                                  SizedBox(
                                    width: metricWidth,
                                    child: PortalMetricTile(
                                      icon: Icons.cloud_done_outlined,
                                      label: copy.healthyNodes,
                                      value: portal
                                          .dashboard.connectionPointsLabel,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Gap(16),
                        ...portal.devices.map(
                          (device) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: PortalSectionCard(
                              tone: device.title == portal.session.deviceName
                                  ? PortalSectionTone.accent
                                  : PortalSectionTone.neutral,
                              child: PortalListRow(
                                title: copy.localizeServerText(device.title),
                                subtitle: copy.localizeServerText(
                                  device.subtitle,
                                ),
                                leading: PremiumIconOrb(
                                  icon: device.isActive
                                      ? Icons.devices_rounded
                                      : Icons.desktop_windows_outlined,
                                  size: 46,
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      device.platform,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                    if (device.title ==
                                        portal.session.deviceName)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: PortalStatusBadge(
                                          label: copy.thisDevice,
                                          icon: Icons
                                              .check_circle_outline_rounded,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Gap(8),
                        PortalSectionCard(
                          tone: PortalSectionTone.muted,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PremiumSectionHeader(
                                eyebrow: copy.appDownloadsEyebrow,
                                title: copy.appDownloadsTitle,
                                subtitle: copy.appDownloadsSubtitle,
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
                                        : copy.noPrimaryLinkYet,
                                    leading: const PremiumIconOrb(
                                      icon: Icons.download_rounded,
                                      size: 42,
                                    ),
                                    trailing: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        if (target.primaryUrl.isNotEmpty)
                                          OutlinedButton(
                                            onPressed: () => launchPortalLink(
                                              context,
                                              target.primaryUrl,
                                            ),
                                            child: Text(copy.primaryAction),
                                          ),
                                        if (target.mirrorUrl.isNotEmpty)
                                          OutlinedButton(
                                            onPressed: () => launchPortalLink(
                                              context,
                                              target.mirrorUrl,
                                            ),
                                            child: Text(copy.mirrorAction),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
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

DeviceRecord? _currentDevice(PortalExperience portal) {
  for (final device in portal.devices) {
    if (device.title == portal.session.deviceName) return device;
  }
  return portal.devices.isEmpty ? null : portal.devices.first;
}
