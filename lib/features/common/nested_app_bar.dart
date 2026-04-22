import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/features/common/adaptive_root_scaffold.dart';
import 'package:hiddify/utils/utils.dart';

bool showDrawerButton(BuildContext context) {
  if (!useMobileRouter) return true;
  final String location = GoRouterState.of(context).uri.path;
  if (location == const ProfilesOverviewRoute().location) return true;
  return tabLocations.any((tab) => location == tab || location.startsWith(tab));
}

class NestedAppBar extends StatelessWidget {
  const NestedAppBar({
    super.key,
    this.title,
    this.actions,
    this.pinned = true,
    this.forceElevated = false,
    this.bottom,
  });

  final Widget? title;
  final List<Widget>? actions;
  final bool pinned;
  final bool forceElevated;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    final canUseDrawer =
        (RootScaffold.stateKey.currentState?.hasDrawer ?? false) &&
            showDrawerButton(context);

    return SliverAppBar(
      leadingWidth: 72,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      toolbarHeight: 72,
      leading: canUseDrawer
          ? Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _AppBarIconButton(
                icon: Icons.menu_rounded,
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                onPressed: () {
                  RootScaffold.stateKey.currentState?.openDrawer();
                },
              ),
            )
          : (Navigator.of(context).canPop()
              ? Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: _AppBarIconButton(
                    icon: context.isRtl
                        ? Icons.arrow_forward_rounded
                        : Icons.arrow_back_rounded,
                    tooltip:
                        MaterialLocalizations.of(context).backButtonTooltip,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                )
              : null),
      title: title,
      actions: [
        if (actions != null)
          ...actions!.map(
            (action) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: action,
            ),
          ),
        const SizedBox(width: 8),
      ],
      pinned: pinned,
      forceElevated: forceElevated,
      bottom: bottom,
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  const _AppBarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Theme.of(context).colorScheme.surface.withOpacity(
              Theme.of(context).brightness == Brightness.light ? 0.82 : 0.68,
            ),
        shape: const CircleBorder(),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
        ),
      ),
    );
  }
}
