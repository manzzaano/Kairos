import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kairos/core/theme/app_theme.dart';
import 'package:kairos/shared/widgets/glass_card.dart';

void main() {
  testWidgets('GlassCard renders child', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(const Color(0xFFA0B9D2)),
        home: const Scaffold(
          body: GlassCard(child: Text('hello')),
        ),
      ),
    );
    expect(find.text('hello'), findsOneWidget);
    expect(find.byType(GlassCard), findsOneWidget);
  });

  testWidgets('GlassCard uses custom padding', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(const Color(0xFFA0B9D2)),
        home: const Scaffold(
          body: GlassCard(
            padding: EdgeInsets.all(8),
            child: Text('padded'),
          ),
        ),
      ),
    );
    expect(find.text('padded'), findsOneWidget);
  });
}
