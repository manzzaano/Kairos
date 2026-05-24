// Widget smoke tests para KAIROS.
//
// KairosApp requiere Realm (DLL nativo) en runtime, que no está disponible
// en el runner headless de flutter test en Windows.
// Se testean aquí widgets aislados que no dependen de Realm ni GetIt.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kairos/core/theme/kairos_logo.dart';
import 'package:kairos/core/utils/xp_calculator.dart';
import 'package:kairos/features/tasks/domain/entities/task.dart';

void main() {
  // ── KairosLogoMark ─────────────────────────────────────────────────────────
  group('KairosLogoMark', () {
    testWidgets('renderiza sin error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: KairosLogoMark(size: 80),
            ),
          ),
        ),
      );
      expect(find.byType(KairosLogoMark), findsOneWidget);
    });

    testWidgets('acepta color y strokeWidth personalizados', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KairosLogoMark(
              size: 40,
              color: Color(0xFFFF6600),
              strokeWidth: 2.0,
            ),
          ),
        ),
      );
      expect(find.byType(KairosLogoMark), findsOneWidget);
    });
  });

  // ── XpCalculator (lógica pura) ─────────────────────────────────────────────
  // Aunque ya existen tests en xp_calculator_test.dart, aquí validamos
  // que el cálculo de nivel es consistente con las etiquetas de nivel.
  group('XpCalculator nivel-nombre consistencia', () {
    test('niveles 1-10 tienen nombre válido (nivel 0 sin nombre es intencional)', () {
      // Nivel 0 (sin tareas) devuelve '' — comportamiento esperado
      expect(XpCalculator.levelName(0), isEmpty);
      // Niveles 1-10 tienen nombre definido
      for (int lvl = 1; lvl <= 10; lvl++) {
        final name = XpCalculator.levelName(lvl);
        expect(name, isNotEmpty, reason: 'Nivel $lvl sin nombre');
      }
    });

    test('progreso entre 0.0 y 1.0 para cualquier XP', () {
      for (int xp = 0; xp <= 7000; xp += 200) {
        final progress = XpCalculator.levelProgress(xp);
        expect(progress, inInclusiveRange(0.0, 1.0),
            reason: 'Progreso fuera de rango para xp=$xp');
      }
    });
  });

  // ── Task entity ─────────────────────────────────────────────────────────────
  group('Task entity', () {
    const t1 = Task(
      id: 'a',
      title: 'T1',
      priority: Priority.high,
      energyLevel: 3,
    );
    const t2 = Task(
      id: 'a',
      title: 'T1',
      priority: Priority.high,
      energyLevel: 3,
    );
    const t3 = Task(
      id: 'b',
      title: 'T2',
      priority: Priority.low,
      energyLevel: 1,
    );

    test('mismo id y props → iguales (Equatable)', () {
      expect(t1, equals(t2));
    });

    test('distinto id → no iguales', () {
      expect(t1, isNot(equals(t3)));
    });

    test('isDone por defecto es false', () {
      expect(t1.isDone, isFalse);
    });

    test('dueLabel por defecto es "Hoy"', () {
      expect(t1.dueLabel, 'Hoy');
    });
  });
}
