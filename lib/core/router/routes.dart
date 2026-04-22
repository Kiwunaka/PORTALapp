import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/router/app_router.dart';
import 'package:hiddify/features/common/adaptive_root_scaffold.dart';
import 'package:hiddify/features/config_option/widget/quick_settings_modal.dart';
import 'package:hiddify/features/home/widget/home_page.dart';
import 'package:hiddify/features/intro/widget/intro_page.dart';
import 'package:hiddify/features/per_app_proxy/overview/per_app_proxy_page.dart';
import 'package:hiddify/features/portal/widget/devices_page.dart';
import 'package:hiddify/features/portal/widget/locations_page.dart';
import 'package:hiddify/features/portal/widget/profile_page.dart';
import 'package:hiddify/features/portal/widget/subscription_page.dart';
import 'package:hiddify/features/portal/widget/support_page.dart';
import 'package:hiddify/features/profile/add/add_profile_modal.dart';
import 'package:hiddify/features/profile/details/profile_details_page.dart';
import 'package:hiddify/features/profile/overview/profiles_overview_page.dart';
import 'package:hiddify/features/settings/overview/settings_overview_page.dart';
import 'package:hiddify/features/settings/route_mode/route_mode_page.dart';
import 'package:hiddify/utils/utils.dart';

part 'routes.g.dart';

GlobalKey<NavigatorState>? get _dynamicRootKey =>
    useMobileRouter ? rootNavigatorKey : null;

@TypedShellRoute<MobileWrapperRoute>(
  routes: [
    TypedGoRoute<HomeRoute>(
      path: "/",
      name: HomeRoute.name,
      routes: [
        TypedGoRoute<AddProfileRoute>(
          path: "add",
          name: AddProfileRoute.name,
        ),
        TypedGoRoute<ProfilesOverviewRoute>(
          path: "profiles",
          name: ProfilesOverviewRoute.name,
        ),
        TypedGoRoute<NewProfileRoute>(
          path: "profiles/new",
          name: NewProfileRoute.name,
        ),
        TypedGoRoute<ProfileDetailsRoute>(
          path: "profiles/:id",
          name: ProfileDetailsRoute.name,
        ),
        TypedGoRoute<SubscriptionRoute>(
          path: "subscription",
          name: SubscriptionRoute.name,
        ),
        TypedGoRoute<QuickSettingsRoute>(
          path: "quick-settings",
          name: QuickSettingsRoute.name,
        ),
      ],
    ),
    TypedGoRoute<LocationsRoute>(
      path: "/locations",
      name: LocationsRoute.name,
    ),
    TypedGoRoute<DevicesRoute>(
      path: "/devices",
      name: DevicesRoute.name,
    ),
    TypedGoRoute<SettingsRoute>(
      path: "/settings",
      name: SettingsRoute.name,
      routes: [
        TypedGoRoute<PerAppProxyRoute>(
          path: "per-app-proxy",
          name: PerAppProxyRoute.name,
        ),
      ],
    ),
    TypedGoRoute<SupportRoute>(
      path: "/support",
      name: SupportRoute.name,
    ),
    TypedGoRoute<ProfileRoute>(
      path: "/profile",
      name: ProfileRoute.name,
    ),
  ],
)
class MobileWrapperRoute extends ShellRouteData {
  const MobileWrapperRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return AdaptiveRootScaffold(navigator);
  }
}

@TypedShellRoute<DesktopWrapperRoute>(
  routes: [
    TypedGoRoute<HomeRoute>(
      path: "/",
      name: HomeRoute.name,
      routes: [
        TypedGoRoute<AddProfileRoute>(
          path: "add",
          name: AddProfileRoute.name,
        ),
        TypedGoRoute<ProfilesOverviewRoute>(
          path: "profiles",
          name: ProfilesOverviewRoute.name,
        ),
        TypedGoRoute<NewProfileRoute>(
          path: "profiles/new",
          name: NewProfileRoute.name,
        ),
        TypedGoRoute<ProfileDetailsRoute>(
          path: "profiles/:id",
          name: ProfileDetailsRoute.name,
        ),
        TypedGoRoute<SubscriptionRoute>(
          path: "subscription",
          name: SubscriptionRoute.name,
        ),
        TypedGoRoute<QuickSettingsRoute>(
          path: "quick-settings",
          name: QuickSettingsRoute.name,
        ),
      ],
    ),
    TypedGoRoute<LocationsRoute>(
      path: "/locations",
      name: LocationsRoute.name,
    ),
    TypedGoRoute<DevicesRoute>(
      path: "/devices",
      name: DevicesRoute.name,
    ),
    TypedGoRoute<SettingsRoute>(
      path: "/settings",
      name: SettingsRoute.name,
    ),
    TypedGoRoute<SupportRoute>(
      path: "/support",
      name: SupportRoute.name,
    ),
    TypedGoRoute<ProfileRoute>(
      path: "/profile",
      name: ProfileRoute.name,
    ),
  ],
)
class DesktopWrapperRoute extends ShellRouteData {
  const DesktopWrapperRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return AdaptiveRootScaffold(navigator);
  }
}

@TypedGoRoute<IntroRoute>(path: "/intro", name: IntroRoute.name)
class IntroRoute extends GoRouteData {
  const IntroRoute();
  static const name = "Intro";

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const MaterialPage(
      fullscreenDialog: true,
      name: name,
      child: IntroPage(),
    );
  }
}

@TypedGoRoute<RouteModeRoute>(path: "/route-mode", name: RouteModeRoute.name)
class RouteModeRoute extends GoRouteData {
  const RouteModeRoute({this.requiredSetup = false});

  final bool requiredSetup;

  static const name = "Route Mode";

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return MaterialPage(
      fullscreenDialog: true,
      name: name,
      child: RouteModePage(requiredSetup: requiredSetup),
    );
  }
}

class HomeRoute extends GoRouteData {
  const HomeRoute();
  static const name = "Home";

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(
      name: name,
      child: HomePage(),
    );
  }
}

class SubscriptionRoute extends GoRouteData {
  const SubscriptionRoute();
  static const name = "Subscription";

  static final GlobalKey<NavigatorState>? $parentNavigatorKey = _dynamicRootKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    if (useMobileRouter) {
      return const MaterialPage(
        name: name,
        child: SubscriptionPage(),
      );
    }
    return const NoTransitionPage(name: name, child: SubscriptionPage());
  }
}

class LocationsRoute extends GoRouteData {
  const LocationsRoute();
  static const name = "Locations";

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(name: name, child: LocationsPage());
  }
}

class AddProfileRoute extends GoRouteData {
  const AddProfileRoute({this.url});

  final String? url;

  static const name = "Add Profile";

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return BottomSheetPage(
      fixed: true,
      name: name,
      builder: (controller) => AddProfileModal(
        url: url,
        scrollController: controller,
      ),
    );
  }
}

class ProfilesOverviewRoute extends GoRouteData {
  const ProfilesOverviewRoute();
  static const name = "Profiles";

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return BottomSheetPage(
      name: name,
      builder: (controller) =>
          ProfilesOverviewModal(scrollController: controller),
    );
  }
}

class NewProfileRoute extends GoRouteData {
  const NewProfileRoute();
  static const name = "New Profile";

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const MaterialPage(
      fullscreenDialog: true,
      name: name,
      child: ProfileDetailsPage("new"),
    );
  }
}

class ProfileDetailsRoute extends GoRouteData {
  const ProfileDetailsRoute(this.id);
  final String id;
  static const name = "Profile Details";

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return MaterialPage(
      fullscreenDialog: true,
      name: name,
      child: ProfileDetailsPage(id),
    );
  }
}

class DevicesRoute extends GoRouteData {
  const DevicesRoute({this.section});
  final String? section;
  static const name = "Devices";

  static final GlobalKey<NavigatorState>? $parentNavigatorKey = _dynamicRootKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    if (useMobileRouter) {
      return const MaterialPage(
        name: name,
        child: DevicesPage(),
      );
    }
    return const NoTransitionPage(name: name, child: DevicesPage());
  }
}

class QuickSettingsRoute extends GoRouteData {
  const QuickSettingsRoute();
  static const name = "Quick Settings";

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return BottomSheetPage(
      fixed: true,
      name: name,
      builder: (controller) => const QuickSettingsModal(),
    );
  }
}

class SettingsRoute extends GoRouteData {
  const SettingsRoute();
  static const name = "Settings";

  static final GlobalKey<NavigatorState>? $parentNavigatorKey = _dynamicRootKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    if (useMobileRouter) {
      return const MaterialPage(
        name: name,
        child: SettingsOverviewPage(),
      );
    }
    return const NoTransitionPage(name: name, child: SettingsOverviewPage());
  }
}

class SupportRoute extends GoRouteData {
  const SupportRoute();
  static const name = "Support";

  static final GlobalKey<NavigatorState>? $parentNavigatorKey = _dynamicRootKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    if (useMobileRouter) {
      return const MaterialPage(
        name: name,
        child: SupportPage(),
      );
    }
    return const NoTransitionPage(name: name, child: SupportPage());
  }
}

class PerAppProxyRoute extends GoRouteData {
  const PerAppProxyRoute();
  static const name = "Per-app Proxy";

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const MaterialPage(
      fullscreenDialog: true,
      name: name,
      child: PerAppProxyPage(),
    );
  }
}

class ProfileRoute extends GoRouteData {
  const ProfileRoute();
  static const name = "Profile";

  static final GlobalKey<NavigatorState>? $parentNavigatorKey = _dynamicRootKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    if (useMobileRouter) {
      return const MaterialPage(
        name: name,
        child: ProfilePage(),
      );
    }
    return const NoTransitionPage(name: name, child: ProfilePage());
  }
}

@Deprecated('Use LocationsRoute instead.')
class ProxiesRoute {
  @Deprecated('Use LocationsRoute instead.')
  const ProxiesRoute();

  static const name = LocationsRoute.name;

  String get location => const LocationsRoute().location;

  void go(BuildContext context) => const LocationsRoute().go(context);

  Future<T?> push<T>(BuildContext context) =>
      const LocationsRoute().push<T>(context);

  void pushReplacement(BuildContext context) =>
      const LocationsRoute().pushReplacement(context);

  void replace(BuildContext context) => const LocationsRoute().replace(context);
}

@Deprecated('Use DevicesRoute instead.')
class ConfigOptionsRoute {
  @Deprecated('Use DevicesRoute instead.')
  const ConfigOptionsRoute({this.section});

  final String? section;

  static const name = DevicesRoute.name;

  DevicesRoute get _route => DevicesRoute(section: section);

  String get location => _route.location;

  void go(BuildContext context) => _route.go(context);

  Future<T?> push<T>(BuildContext context) => _route.push<T>(context);

  void pushReplacement(BuildContext context) => _route.pushReplacement(context);

  void replace(BuildContext context) => _route.replace(context);
}

@Deprecated('Use SupportRoute instead.')
class LogsOverviewRoute {
  @Deprecated('Use SupportRoute instead.')
  const LogsOverviewRoute();

  static const name = SupportRoute.name;

  String get location => const SupportRoute().location;

  void go(BuildContext context) => const SupportRoute().go(context);

  Future<T?> push<T>(BuildContext context) =>
      const SupportRoute().push<T>(context);

  void pushReplacement(BuildContext context) =>
      const SupportRoute().pushReplacement(context);

  void replace(BuildContext context) => const SupportRoute().replace(context);
}

@Deprecated('Use ProfileRoute instead.')
class AboutRoute {
  @Deprecated('Use ProfileRoute instead.')
  const AboutRoute();

  static const name = ProfileRoute.name;

  String get location => const ProfileRoute().location;

  void go(BuildContext context) => const ProfileRoute().go(context);

  Future<T?> push<T>(BuildContext context) =>
      const ProfileRoute().push<T>(context);

  void pushReplacement(BuildContext context) =>
      const ProfileRoute().pushReplacement(context);

  void replace(BuildContext context) => const ProfileRoute().replace(context);
}
