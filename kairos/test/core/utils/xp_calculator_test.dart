import 'package:flutter_test/flutter_test.dart';
import 'package:kairos/core/utils/xp_calculator.dart';
import 'package:kairos/features/tasks/domain/entities/task.dart';

void main() {
  // Helper para crear tareas de test rápidamente
  Task makeTask({
    String id = '1',
    String title = 'Test',
    Priority priority = Priority.low,
    int energyLevel = 1,
    bool isDone = true,
  }) =>
      Task(
        id: id,
        title: title,
        priority: priority,
        energyLevel: energyLevel,
        isDone: isDone,
      );

  group('XpCalculator.totalXp', () {
    test('lista vacía → 0 XP', () {
      expect(XpCalculator.totalXp([]), 0);
    });

    test('tarea no completada → 0 XP', () {
      final task = makeTask(isDone: false, priority: Priority.high, energyLevel: 5);
      expect(XpCalculator.totalXp([task]), 0);
    });

    test('tarea low priority + energía 1 → 10 XP (base sin bonus)', () {
      final task = makeTask(priority: Priority.low, energyLevel: 1);
      expect(XpCalculator.totalXp([task]), 10);
    });

    test('tarea medium priority + energía 1 → 20 XP (10 base + 10 priority)', () {
      final task = makeTask(priority: Priority.medium, energyLevel: 1);
      expect(XpCalculator.totalXp([task]), 20);
    });

    test('tarea high priority + energía 5 → 42 XP (10 + 20 + 12)', () {
      final task = makeTask(priority: Priority.high, energyLevel: 5);
      expect(XpCalculator.totalXp([task]), 42);
    });

    test('múltiples tareas suman correctamente', () {
      final tasks = [
        makeTask(id: '1', priority: Priority.high, energyLevel: 5),  // 42
        makeTask(id: '2', priority: Priority.low, energyLevel: 1),   // 10
        makeTask(id: '3', isDone: false, priority: Priority.high, energyLevel: 5), // 0
      ];
      expect(XpCalculator.totalXp(tasks), 52);
    });
  });

  group('XpCalculator.level', () {
    test('0 XP → nivel 0', () => expect(XpCalculator.level(0), 0));
    test('100 XP → nivel 1', () => expect(XpCalculator.level(100), 1));
    test('99 XP → nivel 0 (no alcanza 100)', () => expect(XpCalculator.level(99), 0));
    test('300 XP → nivel 2', () => expect(XpCalculator.level(300), 2));
    test('6000 XP → nivel 10 (máximo)', () => expect(XpCalculator.level(6000), 10));
    test('10000 XP → nivel 10 (no supera máximo)', () => expect(XpCalculator.level(10000), 10));
  });

  group('XpCalculator.levelProgress', () {
    test('0 XP → 0.0 progreso', () => expect(XpCalculator.levelProgress(0), 0.0));
    test('200 XP → 0.5 en nivel 1 (100..300)', () {
      expect(XpCalculator.levelProgress(200), closeTo(0.5, 0.001));
    });
    test('progreso clampeado entre 0.0 y 1.0', () {
      expect(XpCalculator.levelProgress(-10), 0.0);
    });
  });

  group('XpCalculator.xpToNext', () {
    test('0 XP → faltan 100 para nivel 1', () => expect(XpCalculator.xpToNext(0), 100));
    test('50 XP → faltan 50 para nivel 1', () => expect(XpCalculator.xpToNext(50), 50));
    test('100 XP (nivel 1) → faltan 200 para nivel 2', () => expect(XpCalculator.xpToNext(100), 200));
  });

  group('XpCalculator.karmaLabel', () {
    test('sin tareas completadas → inicio motivacional', () {
      expect(XpCalculator.karmaLabel([], 0), 'Comienza tu primer día');
    });

    test('streak ≥ 7 → racha imparable', () {
      final tasks = List.generate(
          7, (i) => makeTask(id: '$i', isDone: true));
      expect(XpCalculator.karmaLabel(tasks, 7), '🔥 En racha imparable');
    });

    test('streak ≥ 3 → momentum activo', () {
      final tasks = List.generate(3, (i) => makeTask(id: '$i'));
      expect(XpCalculator.karmaLabel(tasks, 3), '⚡ Momentum activo');
    });

    test('≥ 50 tareas completadas → productividad élite', () {
      final tasks = List.generate(50, (i) => makeTask(id: '$i'));
      expect(XpCalculator.karmaLabel(tasks, 0), '🏆 Productividad élite');
    });
  });
}
