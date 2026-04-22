import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/portal/widget/quick_connect_panel.dart';

import '../../../test_helpers/portal_experience_fixture.dart';

void main() {
  testWidgets('shows premium quick connect summary for an active trial', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: PortalQuickConnectPanel(
              experience: buildPortalExperienceFixture(),
              onOpenLocations: () {},
              onOpenTelegramReward: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Quick start'), findsOneWidget);
    expect(find.text('Route & Speed'), findsOneWidget);
    expect(find.text('Auto route ready'), findsOneWidget);
    expect(find.text('Netherlands'), findsOneWidget);
    expect(find.text('Test-drive is live'), findsOneWidget);
    expect(find.text('+10 bonus days'), findsOneWidget);
    expect(find.text('Choose server'), findsOneWidget);
    expect(find.textContaining('Managed HTTP'), findsOneWidget);
    expect(find.textContaining('gRPC 443'), findsOneWidget);
    expect(find.text('Active until'), findsOneWidget);
  });
}
