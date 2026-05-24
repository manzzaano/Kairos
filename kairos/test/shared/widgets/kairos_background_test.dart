import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kairos/core/theme/app_theme.dart';
import 'package:kairos/shared/widgets/kairos_background.dart';

void main() {
  testWidgets('KairosBackground renders child without glows', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(const Color(0xFFA0B9D2)),
        home: const KairosBackground(child: Text('content')),
      ),
    );
    expect(find.text('content'), findsOneWidget);
  });

  testWidgets('KairosBackground renders child with glows', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(const Color(0xFFA0B9D2)),
        home: const KairosBackground(
          withGlows: true,
          child: Text('glow content'),
        ),
      ),
    );
    expect(find.text('glow content'), findsOneWidget);
  });
}
