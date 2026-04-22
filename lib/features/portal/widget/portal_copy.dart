import 'package:flutter/widgets.dart';

class PortalCopy {
  PortalCopy._(this.isRussian);

  final bool isRussian;

  factory PortalCopy.of(BuildContext context) {
    return PortalCopy._(
      Localizations.localeOf(context).languageCode.toLowerCase().startsWith(
            'ru',
          ),
    );
  }

  static final RegExp _daysPattern =
      RegExp(r'^(\d+)\s+days?$', caseSensitive: false);
  static final RegExp _monthsPattern =
      RegExp(r'^(\d+)\s+months?$', caseSensitive: false);

  String get shellVpn => isRussian ? 'Сеть' : 'Network';
  String get shellLocations => isRussian ? 'Локации' : 'Locations';
  String get shellDevices => isRussian ? 'Устройства' : 'Devices';
  String get shellProfile => isRussian ? 'Профиль' : 'Profile';
  String get shellSupport => isRussian ? 'Поддержка' : 'Support';
  String get shellTagline =>
      isRussian ? 'Умная оптимизация интернета' : 'Smart internet optimization';
  String get shellBadge => 'Pearl glass';

  String get loadingServiceData =>
      isRussian ? 'Загружаем настройки сети...' : 'Loading network settings...';
  String get loadingAccessDeck => isRussian
      ? 'Загружаем доступ, устройства и маршруты...'
      : 'Loading access, devices and routes...';
  String get serviceUnavailable => isRussian
      ? 'Сейчас не получается загрузить данные POKROV.'
      : 'POKROV data is not available right now.';
  String get copied =>
      isRussian ? 'Скопировано в буфер обмена.' : 'Copied to clipboard.';
  String get linkOpenFailed =>
      isRussian ? 'Не удалось открыть ссылку.' : 'Could not open the link.';

  String get homeConsoleBadge =>
      isRussian ? 'Центр управления' : 'Control center';
  String get secureOnTapEyebrow =>
      isRussian ? 'Разгон в одно касание' : 'Boost in one tap';
  String homeStageTitle({required bool isActive}) => isRussian
      ? (isActive ? 'Разгон активен' : 'Сеть ждёт запуска')
      : (isActive ? 'Optimization is live' : 'Network is standing by');
  String homeStageBody({required bool isActive}) => isRussian
      ? (isActive
          ? 'Пользуйтесь быстрой почтой, видео и приложениями без лишних пауз.'
          : 'Запустите тест-драйв или подключите профиль, чтобы открыть полный потенциал POKROV.')
      : (isActive
          ? 'Enjoy fast email, video, and apps without unnecessary pauses.'
          : 'Start the test-drive or connect a profile first to unlock the full POKROV potential.');
  String get activeProfileLabel =>
      isRussian ? 'Активный профиль' : 'Active profile';
  String get switchAction => isRussian ? 'Сменить' : 'Switch';
  String get subscriptionExpired =>
      isRussian ? 'Подписка завершена' : 'Subscription expired';
  String get remoteProfileReady =>
      isRussian ? 'Удалённый профиль готов' : 'Remote profile ready';
  String get localProfileReady =>
      isRussian ? 'Локальный профиль готов' : 'Local profile ready';
  String get unlimitedTraffic => isRussian ? 'Полный разгон' : 'Full boost';
  String trafficLeft(String value) =>
      isRussian ? 'Осталось $value' : '$value left';
  String daysRemaining(int value) =>
      isRussian ? '$value дн. осталось' : '$value days remaining';
  String get quickActionLocations => shellLocations;
  String get quickActionDevices => shellDevices;
  String get quickActionProfile => shellProfile;
  String get quickActionSupport => shellSupport;
  String get subscriptionLinkTitle =>
      isRussian ? 'Ссылка подключения' : 'Subscription link';
  String get copyAction => isRussian ? 'Скопировать' : 'Copy';
  String get subscriptionLinkCopied => isRussian
      ? 'Ссылка подключения скопирована.'
      : 'Subscription link copied.';

  String get quickConnectBadge => isRussian ? 'Быстрый старт' : 'Quick start';
  String get routeDeckBadge =>
      isRussian ? 'Маршрут и ускорение' : 'Route & Speed';
  String nodesReady(String value) {
    if (value == '--') {
      return isRussian ? 'Узлы просыпаются' : 'Nodes waking up';
    }
    return isRussian ? '$value узлов готово' : '$value nodes ready';
  }

  String heroStatusTitle({required bool trialLike}) => trialLike
      ? (isRussian ? 'Тест-драйв уже активен' : 'Test-drive is live')
      : (isRussian ? 'Премиум-доступ активен' : 'Premium access is live');
  String get autoRouteTitle =>
      isRussian ? 'Автомаршрут готов' : 'Auto route ready';
  String get bestPathNow =>
      isRussian ? 'Лучший маршрут сейчас' : 'Best path right now';
  String get chooseRouteAction =>
      isRussian ? 'Выбрать сервер' : 'Choose server';
  String get protectedUntil => isRussian ? 'Активно до' : 'Active until';
  String get protectedUntilCaption =>
      isRussian ? 'Тест-драйв или премиум' : 'Test-drive or premium window';
  String get remainingTraffic => isRussian ? 'Осталось трафика' : 'Remaining';
  String get remainingTrafficCaption =>
      isRussian ? 'Доступно на этом устройстве' : 'Available on this device';
  String get liveDevices => isRussian ? 'Живые устройства' : 'Live devices';
  String get liveDevicesCaption => isRussian
      ? 'Сессии, использующие ваш план прямо сейчас'
      : 'Sessions using your plan right now';
  String get bonusDaysAction =>
      isRussian ? '+10 бонусных дней' : '+10 bonus days';
  String get browseLocationsAction =>
      isRussian ? 'Открыть локации' : 'Browse locations';

  String get locationsTitle => shellLocations;
  String get routingEyebrow => isRussian ? 'Маршрутизация' : 'Routing';
  String get autoSelectTitle => isRussian ? 'Автовыбор' : 'Auto-select';
  String get bestServerNow =>
      isRussian ? 'Лучший сервер прямо сейчас' : 'Best server right now';
  String get activeRoute => isRussian ? 'Активный маршрут' : 'Active route';
  String get recommended => isRussian ? 'Рекомендуется' : 'Recommended';
  String get selected => isRussian ? 'Выбрано' : 'Selected';
  String get available => isRussian ? 'Доступно' : 'Available';
  String get comingSoon => isRussian ? 'Скоро' : 'Coming soon';
  String get bestAvailable =>
      isRussian ? 'Лучший доступный узел' : 'Best available';
  String get locationsGateTitle => isRussian
      ? 'Локации откроются после запуска'
      : 'Locations unlock after start';
  String get locationsGateBody => isRussian
      ? 'Сначала запустите 5-дневный тест-драйв на этом устройстве. После этого приложение получит настройки и покажет доступные узлы разгона.'
      : 'Start the 5-day test-drive on this device first. After that the app receives settings and shows available optimization nodes.';
  String get openVpnAction =>
      isRussian ? 'Вернуться в приложение' : 'Return to app';
  String get locationsSyncTitle =>
      isRussian ? 'Локации синхронизируются' : 'Locations are syncing';
  String get locationsSyncBody => isRussian
      ? 'Профиль уже активен, но список узлов ещё обновляется. Пока можно пользоваться автомаршрутом.'
      : 'Your profile is active, but the node list is still syncing. Auto-route will keep working in the meantime.';

  String get devicesTitle => shellDevices;
  String get deviceOverviewEyebrow =>
      isRussian ? 'Обзор устройства' : 'Device overview';
  String get currentDeviceTitle =>
      isRussian ? 'Текущее устройство' : 'Current device';
  String get currentDeviceSubtitle => isRussian
      ? 'Живая сессия и лимит вашего плана.'
      : 'Your live device session and plan capacity.';
  String get currentDeviceFallback => isRussian
      ? 'Это устройство уже связано с POKROV.'
      : 'This device is linked to POKROV.';
  String get activeSessions =>
      isRussian ? 'Активные сессии' : 'Active sessions';
  String get availableSlots =>
      isRussian ? 'Свободные слоты' : 'Available slots';
  String get healthyNodes => isRussian ? 'Здоровые узлы' : 'Healthy nodes';
  String get thisDevice => isRussian ? 'Это устройство' : 'This device';
  String get appDownloadsEyebrow => isRussian ? 'Приложения' : 'Apps';
  String get appDownloadsTitle =>
      isRussian ? 'Скачать приложения' : 'App downloads';
  String get appDownloadsSubtitle => isRussian
      ? 'Прямые установщики и зеркала для ваших устройств.'
      : 'Direct installers and fallback links for your devices.';
  String get primaryAction => isRussian ? 'Основная' : 'Primary';
  String get mirrorAction => isRussian ? 'Зеркало' : 'Mirror';
  String get noPrimaryLinkYet => isRussian
      ? 'Основная ссылка пока не настроена'
      : 'No primary link configured yet';

  String get profileTitle => shellProfile;
  String get accountEyebrow => isRussian ? 'Аккаунт' : 'Account';
  String get accountTitle => isRussian ? 'Аккаунт POKROV' : 'POKROV account';
  String get accountSubtitle => isRussian
      ? 'Доступ, трафик и продление для этого устройства.'
      : 'Your device-linked access, traffic and renewal context.';
  String get remainingTrafficMetric =>
      isRussian ? 'Остаток трафика' : 'Remaining traffic';
  String get planMetric => isRussian ? 'План' : 'Plan';
  String get appAccount => isRussian ? 'Личный профиль' : 'User profile';
  String get deviceTrial =>
      isRussian ? 'Тест-драйв устройства' : 'Device test-drive';
  String accountDetails(String accountId, String deviceName) => isRussian
      ? 'ID аккаунта: $accountId\nУстройство: $deviceName'
      : 'Account ID: $accountId\nDevice: $deviceName';
  String get rewardsEyebrow => isRussian ? 'Бонус' : 'Rewards';
  String get rewardsTitle =>
      isRussian ? '+10 дней через Telegram' : '+10 bonus days with Telegram';
  String get rewardsSubtitle => isRussian
      ? 'Привяжите Telegram, подпишитесь на @pokrov_vpn и активируйте бонус.'
      : 'Link Telegram, join @pokrov_vpn, then claim 10 extra days.';
  String get telegramStatus =>
      isRussian ? 'Статус Telegram' : 'Telegram status';
  String telegramLinked(String label) =>
      isRussian ? 'Telegram привязан: $label' : 'Telegram linked: $label';
  String get telegramNotLinked =>
      isRussian ? 'Telegram пока не привязан' : 'Not linked yet';
  String get linkTelegramAction =>
      isRussian ? 'Привязать Telegram' : 'Link Telegram';
  String get openingAction => isRussian ? 'Открываем...' : 'Opening...';
  String get checkingAction => isRussian ? 'Проверяем...' : 'Checking...';
  String get checkBonusAction => isRussian ? 'Проверить бонус' : 'Check bonus';
  String get openChannelAction => isRussian ? 'Открыть канал' : 'Open channel';
  String telegramAlreadyLinked(String username) => isRussian
      ? 'Telegram уже привязан${username.isNotEmpty ? ' как @$username' : ''}.'
      : 'Telegram is already linked${username.isNotEmpty ? ' as @$username' : ''}.';
  String get telegramLinkHint => isRussian
      ? 'Откройте бота, привяжите Telegram и вернитесь за бонусом.'
      : 'Open the bot to link Telegram, then come back and tap Check bonus.';
  String bonusApplied(int days) => isRussian
      ? 'Бонус активирован: +$days дней к доступу.'
      : 'Bonus applied: +$days days added to your access.';
  String get bonusAlreadyActive => isRussian
      ? 'Бонус Telegram уже активирован для этого аккаунта.'
      : 'The Telegram bonus is already active for this account.';
  String get recoveryEyebrow => isRussian ? 'Настройки' : 'Settings';
  String get recoveryTitle =>
      isRussian ? 'Восстановление настроек' : 'Settings recovery';
  String get recoverySubtitle => isRussian
      ? 'Держите главную ссылку подключения под рукой. Ручные инструменты остаются в расширенных настройках.'
      : 'Keep your primary connection link handy. Manual recovery stays in Advanced settings.';
  String get primaryConnectionLink =>
      isRussian ? 'Главная ссылка доступа' : 'Primary access link';
  String get noConnectionLinkYet => isRussian
      ? 'Пока нет активной ссылки доступа'
      : 'No active access link yet';
  String get automaticSyncTitle =>
      isRussian ? 'Автосинхронизация' : 'Automatic sync';
  String get automaticSyncSubtitle => isRussian
      ? 'Доступ на этом устройстве остаётся готовым. Инструменты совместимости можно не трогать.'
      : 'Access stays ready on this device. Compatibility tools stay optional.';
  String get manualRecovery =>
      isRussian ? 'Ручное восстановление' : 'Manual recovery';
  String get manualRecoverySubtitle => isRussian
      ? 'Ручной импорт и аварийные инструменты остаются в расширенных настройках.'
      : 'Plain import and advanced recovery tools stay in Advanced settings.';
  String get downloadsEyebrow => isRussian ? 'Загрузки' : 'Downloads';
  String get downloadsTitle =>
      isRussian ? 'Приложения и документы' : 'Apps and documents';
  String get downloadsSubtitle => isRussian
      ? 'Установщики и документы для Android, Windows и сценариев восстановления.'
      : 'Install help, docs and recovery flows for Android, iOS, macOS and Windows.';
  String get advancedEyebrow => isRussian ? 'Расширенные' : 'Advanced';
  String get advancedTitle => isRussian ? 'Расширенные настройки' : 'Advanced';
  String get advancedSubtitle => isRussian
      ? 'Сетевые тонкости остаются здесь и не мешают основному сценарию разгона.'
      : 'Advanced networking tools stay here, away from the main optimization flow.';
  String get openAdvancedSettings =>
      isRussian ? 'Открыть расширенные настройки' : 'Open advanced settings';

  String get supportTitle => shellSupport;
  String get needHelpEyebrow => isRussian ? 'Нужна помощь?' : 'Need help?';
  String get getHelpFast =>
      isRussian ? 'Помощь за пару шагов' : 'Get help fast';
  String get supportSubtitle => isRussian
      ? 'Открывайте поддержку уже с подготовленным аккаунтом и данными устройства.'
      : 'Open support with your account and device context already prepared.';
  String get preparedContext =>
      isRussian ? 'Подготовленный контекст' : 'Prepared context';
  String get openTelegramSupport =>
      isRussian ? 'Открыть поддержку в Telegram' : 'Open Telegram support';
  String get emailSupport => isRussian ? 'Написать на почту' : 'Email support';
  String get copyDiagnostics =>
      isRussian ? 'Скопировать диагностику' : 'Copy diagnostics';
  String get diagnosticsCopied =>
      isRussian ? 'Диагностика скопирована.' : 'Diagnostics copied.';
  String get deviceContext =>
      isRussian ? 'Контекст устройства' : 'Device context';
  String deviceContextDetails(String deviceName, String accountId) => isRussian
      ? '$deviceName\nАккаунт $accountId'
      : '$deviceName\nAccount $accountId';

  String get subscriptionTitle => isRussian ? 'Подписка' : 'Subscription';
  String get subscriptionSubtitleTrial => isRussian
      ? 'Запустите тест-драйв из приложения, а оплату безопасно завершите в браузере.'
      : 'Start the test-drive from the app and finish payment securely in your browser.';
  String get subscriptionSubtitlePaid => isRussian
      ? 'Управляйте продлением, оплатой и доступом из одного места.'
      : 'Manage renewal, payment and access from one place.';
  String get expiresMetric => isRussian ? 'Истекает' : 'Expires';
  String get deviceLimitMetric =>
      isRussian ? 'Лимит устройств' : 'Device limit';
  String get openSecureCheckout =>
      isRussian ? 'Открыть безопасную оплату' : 'Open secure checkout';
  String get continueInTelegram =>
      isRussian ? 'Продолжить в Telegram' : 'Continue in Telegram';
  String choosePlan(String label) =>
      isRussian ? 'Выбрать $label' : 'Choose $label';
  String get continuationEyebrow => isRussian ? 'Продолжение' : 'Continuation';
  String get continuationTitle => isRussian
      ? 'Подключайтесь удобным для вас способом'
      : 'Stay connected your way';
  String get continuationSubtitle => isRussian
      ? 'Апгрейд остается основным путем, но сообщество, free fallback и bridge-сценарии с ключом тоже остаются понятными.'
      : 'Upgrade stays primary, while community bonus, free fallback, and the access-key bridge remain clear continuation paths.';
  String get communityContinuationTitle =>
      isRussian ? 'Сообщество +10 дней' : 'Community +10 days';
  String get communityContinuationSubtitle => isRussian
      ? 'Подпишитесь на публичный канал, а потом подтвердите бонус в профиле, когда вам удобно.'
      : 'Join the public channel, then confirm the +10-day bonus from Profile whenever you are ready.';
  String get redeemAccessEntrySubtitle => isRussian
      ? 'Откройте bridge-сценарий: вставьте ключ, отсканируйте QR или добавьте доступ вручную без поиска сырой ссылки подписки.'
      : 'Open the bridge flow to paste a key, scan a QR, or finish manual add without hunting for a raw subscription link.';
  String get openAccessFlowAction =>
      isRussian ? 'Открыть bridge' : 'Open access flow';
  String freeTierContinuationExtended({
    required int trafficGb,
    required int periodDays,
    required int deviceLimit,
    required String nodePool,
  }) =>
      isRussian
          ? 'Если апгрейд пока не нужен, легкий free fallback остается: $trafficGb ГБ каждые $periodDays дней на $deviceLimit ${deviceLimit == 1 ? 'устройстве' : 'устройствах'} через $nodePool.'
          : 'If you are not ready to upgrade yet, free fallback stays available with $trafficGb GB every $periodDays days on $deviceLimit ${deviceLimit == 1 ? 'device' : 'devices'} via $nodePool.';
  String transportVariantBadge(String variant) =>
      isRussian ? 'Транспорт: $variant' : 'Transport: $variant';
  String planSummary({
    required int amountRub,
    required int days,
    required int deviceLimit,
  }) {
    if (!isRussian) {
      return '$amountRub RUB / $days days / $deviceLimit devices';
    }
    return '$amountRub ₽ • ${daysLabel(days)} • ${deviceLabel(deviceLimit)}';
  }

  String get trialReadyToast => isRussian
      ? 'Тест-драйв запущен, магия скорости началась.'
      : 'Test-drive started. The magic is here.';
  String get trialReadyFallbackToast => isRussian
      ? 'Тест-драйв запущен. POKROV завершил настройку через совместимую схему ключевой доставки.'
      : 'Test-drive started. POKROV finished setup through a compatible key-delivery path.';
  String trialError(Object error) => isRussian
      ? 'Не удалось запустить тест-драйв: $error'
      : 'Could not start the test-drive: $error';
  String get emptyStateTitle => isRussian
      ? 'Пять дней магии без настройки'
      : 'Zero setup. Five days of speed.';
  String get emptyStateBody => isRussian
      ? 'Один тап запускает реальный тест-драйв прямо на этом устройстве. Попробуйте наш разгон в деле.'
      : 'One tap starts a real test-drive on this device. Try our speed boost in action.';
  String get emptyStateBonusTitle => isRussian
      ? 'Бонус Telegram даёт ещё +10 дней'
      : 'Telegram bonus adds 10 more days';
  String get emptyStateBonusBody => isRussian
      ? 'Активируйте бонус после подписки на канал, когда вам будет удобно.'
      : '+10 extra days are available after joining our Telegram channel.';
  String get emptyStatePrimaryAction =>
      isRussian ? 'Запустить тест-драйв на 5 дней' : 'Start 5-day test-drive';
  String get emptyStateSecondaryAction => isRussian
      ? 'Добавить ключ или подписку вручную'
      : 'Redeem or add access key';
  String get profilesEyebrow => isRussian ? 'Профили' : 'Profiles';
  String get chooseActiveProfileTitle => isRussian
      ? 'Сначала выберите активный профиль'
      : 'Choose an active profile first';
  String get trialPlatformsBadge =>
      isRussian ? 'Цель: 4 платформы' : '4-platform target';
  String get activationEyebrow => isRussian ? 'Активация' : 'Activation';
  String get activationTitle => isRussian
      ? 'Автоматическая активация и ключевая доставка'
      : 'Automatic activation and key delivery';
  String get activationSubtitle => isRussian
      ? 'POKROV держит автоматический app-first путь основным, а redeem и ключевая доставка остаются совместимым мостом для всех целевых платформ.'
      : 'POKROV keeps the managed path first, while redeem and access-key delivery stay available as a compatibility bridge across the public target.';
  String get automaticActivationTitle => isRussian
      ? 'Автоматическая активация в приоритете'
      : 'Automatic activation first';
  String automaticActivationSubtitle(String platforms) => isRussian
      ? '$platforms остаются на app-managed пути, когда активация доступна.'
      : '$platforms stay on the app-managed path when activation is available.';
  String get redeemAccessTitle => isRussian
      ? 'Ввести код или добавить ключ доступа'
      : 'Redeem or add access key';
  String redeemAccessSubtitle(String platforms) => isRussian
      ? 'Ключевая доставка сохраняет bridge- и recovery-сценарии на $platforms.'
      : 'Key-based delivery keeps bridge and recovery access available on $platforms.';
  String freeTierContinuation({
    required int trafficGb,
    required int periodDays,
    required int deviceLimit,
    required String nodePool,
  }) =>
      isRussian
          ? 'После премиум-периода бесплатный доступ сохраняется: $trafficGb ГБ каждые $periodDays дней, $deviceLimit ${deviceLimit == 1 ? 'устройство' : 'устройства'}, узел $nodePool.'
          : 'After premium time ends, free access continues with $trafficGb GB every $periodDays days on $deviceLimit ${deviceLimit == 1 ? 'device' : 'devices'} via $nodePool.';
  String get accessReadyTitle =>
      isRussian ? 'Доступ уже готов' : 'Access stays ready';
  String get accessReadySubtitle => isRussian
      ? 'POKROV поддерживает доступ на этом устройстве. Редкие сценарии восстановления остаются в расширенных настройках.'
      : 'POKROV keeps this device in sync. Edge-case recovery tools stay in Advanced settings.';
  String get advancedRecoveryTools =>
      isRussian ? 'Инструменты восстановления' : 'Advanced recovery tools';
  String get advancedRecoveryToolsSubtitle => isRussian
      ? 'Совместимый импорт и редкие инструменты восстановления остаются в расширенных настройках.'
      : 'Compatibility import and rare recovery tools stay in Advanced settings.';
  String get supportThreadsTitle =>
      isRussian ? 'Последние обращения' : 'Recent requests';
  String get supportThreadsSubtitle => isRussian
      ? 'Если поддержка уже в работе, последние обновления появятся здесь.'
      : 'If help is already in motion, the latest updates appear here first.';
  String get continueInWebCabinet =>
      isRussian ? 'Продолжить в веб-кабинете' : 'Continue in web cabinet';
  String get telegramSupportFallback =>
      isRussian ? 'Открыть Telegram-поддержку' : 'Open Telegram fallback';

  String supportStatus(String raw) {
    final normalized = raw.trim().toLowerCase();
    switch (normalized) {
      case 'open':
        return isRussian ? 'Открыто' : 'OPEN';
      case 'closed':
        return isRussian ? 'Закрыто' : 'CLOSED';
      case 'pending':
        return isRussian ? 'В работе' : 'PENDING';
      case 'demo':
        return isRussian ? 'Демо' : 'DEMO';
      default:
        return isRussian
            ? localizeServerText(raw).toUpperCase()
            : raw.toUpperCase();
    }
  }

  String localizeServerText(String raw) {
    final value = raw.trim();
    if (!isRussian || value.isEmpty) return value;

    final dayMatch = _daysPattern.firstMatch(value);
    if (dayMatch != null) {
      final days = int.tryParse(dayMatch.group(1) ?? '') ?? 0;
      return daysLabel(days);
    }

    final monthMatch = _monthsPattern.firstMatch(value);
    if (monthMatch != null) {
      final months = int.tryParse(monthMatch.group(1) ?? '') ?? 0;
      return monthsLabel(months);
    }

    switch (value.toLowerCase()) {
      case 'trial':
        return 'Тест-драйв';
      case 'popular':
        return 'Популярно';
      case 'current device':
        return 'Текущее устройство';
      case 'device':
        return 'Устройство';
      case 'ready to connect':
        return 'Готово к подключению';
      case 'your trial is active.':
      case 'your trial is active':
        return 'Тест-драйв уже активен.';
      case 'your service hub is ready':
        return 'Центр сервиса готов';
      case 'connect a profile, then unlock subscription, locations, devices, support and downloads without leaving the app.':
        return 'Подключите профиль, чтобы открыть настройки, локации, устройства, поддержку и загрузки, не выходя из приложения.';
      case 'support and account data will appear here after trial activation.':
        return 'Данные поддержки и аккаунта появятся здесь после запуска тест-драйва.';
      case 'welcome to pokrov':
      case 'welcome to pokrov vpn':
        return 'Добро пожаловать в POKROV';
      case 'available after activation':
        return 'Доступно после запуска';
      case 'primary access point':
        return 'Основная точка доступа';
      case 'secondary access point':
        return 'Резервная точка доступа';
      case 'billing issue':
        return 'Вопрос по оплате';
      case 'need help with my renewal.':
        return 'Нужна помощь с продлением.';
      case 'netherlands':
        return 'Нидерланды';
      case 'germany':
        return 'Германия';
      case 'poland':
        return 'Польша';
      case 'france':
        return 'Франция';
      case 'sweden':
        return 'Швеция';
      case 'norway':
        return 'Норвегия';
      case 'finland':
        return 'Финляндия';
      case 'singapore':
        return 'Сингапур';
      case 'japan':
        return 'Япония';
      case 'turkey':
        return 'Турция';
      case 'united states':
        return 'США';
      case 'united kingdom':
        return 'Великобритания';
      case 'romania':
        return 'Румыния';
      case 'estonia':
        return 'Эстония';
      case 'latvia':
        return 'Латвия';
      case 'lithuania':
        return 'Литва';
      case 'amsterdam':
        return 'Амстердам';
      case 'frankfurt':
        return 'Франкфурт';
    }

    return value;
  }

  String daysLabel(int days) {
    if (!isRussian) return '$days days';
    return '$days ${_plural(days, one: 'день', few: 'дня', many: 'дней')}';
  }

  String deviceLabel(int count) {
    if (!isRussian) return '$count devices';
    return '$count ${_plural(count, one: 'устройство', few: 'устройства', many: 'устройств')}';
  }

  String monthsLabel(int months) {
    if (!isRussian) return '$months months';
    return '$months ${_plural(months, one: 'месяц', few: 'месяца', many: 'месяцев')}';
  }

  String _plural(
    int value, {
    required String one,
    required String few,
    required String many,
  }) {
    final mod10 = value % 10;
    final mod100 = value % 100;
    if (mod10 == 1 && mod100 != 11) return one;
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return few;
    return many;
  }
}
