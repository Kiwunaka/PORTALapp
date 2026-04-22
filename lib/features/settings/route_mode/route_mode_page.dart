import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/router/app_router.dart';
import 'package:hiddify/core/widget/premium_surfaces.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:hiddify/features/per_app_proxy/model/installed_package_info.dart';
import 'package:hiddify/features/per_app_proxy/overview/per_app_proxy_notifier.dart';
import 'package:hiddify/features/portal/widget/portal_widgets.dart';
import 'package:hiddify/features/settings/data/route_mode_preferences.dart';
import 'package:hiddify/features/settings/notifier/platform_settings_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<void> showRouteModePage(
  BuildContext context, {
  bool requiredSetup = false,
}) async {
  final navigatorContext = rootNavigatorKey.currentContext ?? context;
  final router = GoRouter.maybeOf(navigatorContext);
  if (router != null) {
    final location = Uri(
      path: '/route-mode',
      queryParameters: requiredSetup
          ? const {'requiredSetup': 'true'}
          : const <String, String>{},
    ).toString();
    await router.push<void>(location);
    return;
  }

  if (!navigatorContext.mounted) return;
  await Navigator.of(navigatorContext).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => RouteModePage(requiredSetup: requiredSetup),
    ),
  );
}

class RouteModePage extends HookConsumerWidget {
  const RouteModePage({
    super.key,
    this.requiredSetup = false,
  });

  final bool requiredSetup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = _RouteModeCopy.of(context);
    final pickerSupport = ref.watch(routeModePickerSupportProvider);
    final completed =
        ref.watch(routeModeChoiceCompletedProvider).valueOrNull ?? false;
    final currentMode = ref.watch(consumerRouteModeProvider);
    final selectedTargets = ref.watch(consumerSelectedAppsProvider);
    final desktopPrivilege = ref.watch(desktopPrivilegeProvider).valueOrNull;
    final packagesAsync =
        pickerSupport.kind == RouteModePickerKind.installedApps
            ? ref.watch(installedPackagesInfoProvider)
            : null;

    final selectedMode = useState<ConsumerRouteMode?>(null);
    final draftSelection = useState<Set<String>>(<String>{});
    final hasLocalEdits = useState(false);
    final isSaving = useState(false);

    useEffect(() {
      if (hasLocalEdits.value || isSaving.value) return null;
      selectedMode.value =
          completed ? currentMode : ConsumerRouteMode.allTraffic;
      draftSelection.value = selectedTargets.toSet();
      return null;
    }, [
      completed,
      currentMode,
      selectedTargets,
      hasLocalEdits.value,
      isSaving.value,
    ]);

    Future<void> saveAllTraffic() async {
      if (isSaving.value) return;
      isSaving.value = true;
      await ref.read(routeModePreferencesProvider).chooseAllTraffic();
      isSaving.value = false;
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }

    Future<void> saveSelectedApps() async {
      if (isSaving.value || draftSelection.value.isEmpty) return;
      isSaving.value = true;
      await ref
          .read(routeModePreferencesProvider)
          .chooseSelectedApps(draftSelection.value.toList());
      isSaving.value = false;
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }

    void selectMode(ConsumerRouteMode mode) {
      hasLocalEdits.value = true;
      selectedMode.value = mode;
    }

    return PopScope(
      canPop: !requiredSetup || completed,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: PremiumPageBackground(
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                NestedAppBar(
                  title: Text(copy.pageTitle),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PortalSectionCard(
                          tone: PortalSectionTone.accent,
                          child: PremiumSectionHeader(
                            eyebrow: requiredSetup
                                ? copy.requiredEyebrow
                                : copy.pageEyebrow,
                            title: copy.heroTitle,
                            subtitle: copy.heroSubtitle,
                          ),
                        ),
                        const Gap(16),
                        _RouteModeOptionCard(
                          title: copy.allTrafficTitle,
                          body: copy.allTrafficBody,
                          selected: selectedMode.value ==
                              ConsumerRouteMode.allTraffic,
                          onTap: () => selectMode(ConsumerRouteMode.allTraffic),
                        ),
                        const Gap(12),
                        _RouteModeOptionCard(
                          title: copy.selectedAppsTitle,
                          body: copy.selectedAppsBody(pickerSupport.kind),
                          selected: selectedMode.value ==
                              ConsumerRouteMode.selectedApps,
                          onTap: () =>
                              selectMode(ConsumerRouteMode.selectedApps),
                        ),
                        if (Platform.isWindows &&
                            selectedMode.value ==
                                ConsumerRouteMode.allTraffic &&
                            desktopPrivilege == false) ...[
                          const Gap(16),
                          PortalSectionCard(
                            tone: PortalSectionTone.muted,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PremiumSectionHeader(
                                  eyebrow: copy.desktopEyebrow,
                                  title: copy.desktopTitle,
                                  subtitle: copy.desktopBody,
                                ),
                                const Gap(12),
                                OutlinedButton(
                                  onPressed: null,
                                  child: Text(copy.restartAsAdmin),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (selectedMode.value ==
                            ConsumerRouteMode.selectedApps) ...[
                          const Gap(16),
                          PortalSectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PremiumSectionHeader(
                                  eyebrow: copy.selectionEyebrow,
                                  title: copy.selectionTitle(
                                    pickerSupport.kind,
                                  ),
                                  subtitle: copy.selectionSubtitle(
                                    pickerSupport.kind,
                                  ),
                                ),
                                const Gap(12),
                                if (pickerSupport.kind ==
                                    RouteModePickerKind.manualExecutableEntry)
                                  _WindowsExecutableSelection(
                                    targets: draftSelection.value.toList()
                                      ..sort(),
                                    copy: copy,
                                    onAddPressed: () async {
                                      final value =
                                          await _showWindowsExecutableDialog(
                                        context,
                                        copy,
                                      );
                                      if (value == null || !context.mounted) {
                                        return;
                                      }
                                      hasLocalEdits.value = true;
                                      draftSelection.value =
                                          normalizeRouteTargets(
                                        [...draftSelection.value, value],
                                        caseInsensitive: true,
                                      ).toSet();
                                    },
                                    onRemove: (value) {
                                      hasLocalEdits.value = true;
                                      final next = draftSelection.value.toSet()
                                        ..remove(value);
                                      draftSelection.value = next;
                                    },
                                  )
                                else
                                  switch (packagesAsync) {
                                    AsyncData(:final value) =>
                                      _PackageSelectionList(
                                        packages: value,
                                        selectedPackages: draftSelection.value,
                                        onToggle: (packageName) {
                                          hasLocalEdits.value = true;
                                          final next =
                                              draftSelection.value.toSet();
                                          if (!next.add(packageName)) {
                                            next.remove(packageName);
                                          }
                                          draftSelection.value = next;
                                        },
                                      ),
                                    AsyncLoading() => const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                          ),
                                        ),
                                      ),
                                    AsyncError() => Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(copy.selectionError),
                                      ),
                                    _ => const SizedBox.shrink(),
                                  },
                                const Gap(12),
                                Text(
                                  copy.selectedCount(
                                    draftSelection.value.length,
                                    pickerSupport.kind,
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                        const Gap(16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            FilledButton(
                              onPressed: isSaving.value
                                  ? null
                                  : selectedMode.value ==
                                          ConsumerRouteMode.selectedApps
                                      ? (draftSelection.value.isEmpty
                                          ? null
                                          : saveSelectedApps)
                                      : selectedMode.value ==
                                              ConsumerRouteMode.allTraffic
                                          ? saveAllTraffic
                                          : null,
                              child: Text(
                                selectedMode.value ==
                                        ConsumerRouteMode.selectedApps
                                    ? copy.selectedAppsAction
                                    : copy.allTrafficAction,
                              ),
                            ),
                            if (!requiredSetup)
                              OutlinedButton(
                                onPressed: isSaving.value
                                    ? null
                                    : () => Navigator.of(context).maybePop(),
                                child: Text(copy.cancelAction),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<String?> _showWindowsExecutableDialog(
  BuildContext context,
  _RouteModeCopy copy,
) {
  final controller = TextEditingController();
  String? errorText;

  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(copy.addExecutableDialogTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(copy.addExecutableDialogBody),
                const Gap(12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: copy.addExecutableHint,
                    errorText: errorText,
                  ),
                ),
                const Gap(12),
                Text(
                  copy.addExecutableExample,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(copy.cancelAction),
              ),
              FilledButton(
                onPressed: () {
                  final candidate = controller.text.trim();
                  if (!isWindowsExecutableTarget(candidate)) {
                    setState(() {
                      errorText = copy.addExecutableValidation;
                    });
                    return;
                  }
                  Navigator.of(dialogContext).pop(candidate);
                },
                child: Text(copy.addAppAction),
              ),
            ],
          );
        },
      );
    },
  );
}

class _RouteModeOptionCard extends StatelessWidget {
  const _RouteModeOptionCard({
    required this.title,
    required this.body,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String body;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PortalSectionCard(
      tone: selected ? PortalSectionTone.accent : PortalSectionTone.muted,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<bool>(
              value: true,
              groupValue: selected,
              onChanged: (_) => onTap(),
            ),
            const Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const Gap(6),
                  Text(body, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WindowsExecutableSelection extends StatelessWidget {
  const _WindowsExecutableSelection({
    required this.targets,
    required this.copy,
    required this.onAddPressed,
    required this.onRemove,
  });

  final List<String> targets;
  final _RouteModeCopy copy;
  final Future<void> Function() onAddPressed;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          copy.windowsExecutableHint,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const Gap(12),
        FilledButton(
          onPressed: onAddPressed,
          child: Text(copy.addExecutableAction),
        ),
        const Gap(12),
        if (targets.isEmpty)
          Text(
            copy.windowsExecutableEmpty,
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final target in targets)
                InputChip(
                  label: Text(target),
                  onDeleted: () => onRemove(target),
                ),
            ],
          ),
      ],
    );
  }
}

class _PackageSelectionList extends StatelessWidget {
  const _PackageSelectionList({
    required this.packages,
    required this.selectedPackages,
    required this.onToggle,
  });

  final List<InstalledPackageInfo> packages;
  final Set<String> selectedPackages;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final visiblePackages = packages
        .where((package) => !package.isSystemApp)
        .toList()
      ..sort((left, right) => left.name.compareTo(right.name));

    return Column(
      children: [
        for (final package in visiblePackages)
          CheckboxListTile(
            value: selectedPackages.contains(package.packageName),
            onChanged: (_) => onToggle(package.packageName),
            title: Text(package.name),
            subtitle: Text(package.packageName),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
      ],
    );
  }
}

class _RouteModeCopy {
  _RouteModeCopy._(this.isRussian);

  final bool isRussian;

  factory _RouteModeCopy.of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return _RouteModeCopy._(code.startsWith('ru'));
  }

  String get pageTitle => isRussian ? 'Route mode' : 'Route mode';
  String get pageEyebrow => isRussian ? 'Device route' : 'Device route';
  String get requiredEyebrow => isRussian
      ? 'Required before first connect'
      : 'Required before first connect';
  String get heroTitle => isRussian
      ? 'How should this device be optimized?'
      : 'How should this device be optimized?';
  String get heroSubtitle => isRussian
      ? 'Choose one calm default for this device. You can change it later in Settings.'
      : 'Choose one calm default for this device. You can change it later in Settings.';
  String get allTrafficTitle => isRussian
      ? 'Optimize everything on this device'
      : 'Optimize everything on this device';
  String get allTrafficBody => isRussian
      ? 'Recommended for most devices. POKROV keeps supported traffic optimized across this device.'
      : 'Recommended for most devices. POKROV keeps supported traffic optimized across this device.';
  String get selectedAppsTitle =>
      isRussian ? 'Only selected apps' : 'Only selected apps';

  String selectedAppsBody(RouteModePickerKind pickerKind) {
    if (pickerKind == RouteModePickerKind.manualExecutableEntry) {
      return 'Choose the app .exe files that should use POKROV.';
    }
    return 'Choose the apps that should use POKROV.';
  }

  String get selectionEyebrow => 'App selection';

  String selectionTitle(RouteModePickerKind pickerKind) {
    if (pickerKind == RouteModePickerKind.manualExecutableEntry) {
      return 'Choose the .exe files that should use POKROV.';
    }
    return 'Which apps should use POKROV?';
  }

  String selectionSubtitle(RouteModePickerKind pickerKind) {
    if (pickerKind == RouteModePickerKind.manualExecutableEntry) {
      return 'Add at least one app executable. The rest of this PC stays direct.';
    }
    return 'Pick at least one app. The rest of the device stays direct.';
  }

  String get selectionError =>
      'Could not load installed apps right now. You can still optimize the whole device.';

  String selectedCount(int count, RouteModePickerKind pickerKind) {
    if (pickerKind == RouteModePickerKind.manualExecutableEntry) {
      return 'Selected .exe files: $count';
    }
    return 'Selected apps: $count';
  }

  String get allTrafficAction => 'Optimize everything on this device';
  String get selectedAppsAction => 'Use only selected apps';
  String get addExecutableAction => 'Add .exe file';
  String get addAppAction => 'Add app';
  String get addExecutableDialogTitle => 'Add an app .exe';
  String get addExecutableDialogBody =>
      'Enter the app .exe file that should use POKROV.';
  String get addExecutableHint => r'For example: C:\Program Files\App\App.exe';
  String get addExecutableExample =>
      r'Example: C:\Program Files\Telegram Desktop\Telegram.exe';
  String get addExecutableValidation => 'Enter a valid .exe file path.';
  String get windowsExecutableHint =>
      'Add the app .exe files that should use POKROV.';
  String get windowsExecutableEmpty => 'No .exe files selected yet.';
  String get cancelAction => 'Cancel';
  String get desktopEyebrow => 'Desktop optimization';
  String get desktopTitle =>
      'Whole-device optimization needs Administrator rights';
  String get desktopBody =>
      'Restart POKROV as Administrator before optimizing the whole device.';
  String get restartAsAdmin => 'Restart as Administrator';
}
