import '../../features/tasks/domain/entities/task.dart';

/// Sistema de progresión basado en tareas completadas.
/// Inspirado en Habitica/Todoist Karma pero orientado a energía.
class XpCalculator {
  // ── XP por tarea ────────────────────────────────────────────────────────────
  static int _xpForTask(Task task) {
    if (!task.isDone) return 0;
    const base = 10;
    final priorityBonus = task.priority == Priority.high
        ? 20
        : task.priority == Priority.medium
            ? 10
            : 0;
    final energyBonus = (task.energyLevel - 1) * 3; // 0-12
    return base + priorityBonus + energyBonus;
  }

  static int totalXp(List<Task> tasks) =>
      tasks.fold<int>(0, (xp, t) => xp + _xpForTask(t));

  // ── Niveles ─────────────────────────────────────────────────────────────────
  static const _thresholds = [0, 100, 300, 600, 1000, 1500, 2100, 2800, 3600, 4500, 6000];
  static const _names = [
    '', 'Aprendiz', 'Explorador', 'Enfocado', 'Estratega',
    'Maestro', 'Experto', 'Élite', 'Leyenda', 'Trascendente', 'KAIROS'
  ];

  static int level(int xp) {
    for (int i = _thresholds.length - 1; i >= 0; i--) {
      if (xp >= _thresholds[i]) return i;
    }
    return 0;
  }

  static String levelName(int lvl) {
    if (lvl < 0 || lvl >= _names.length) return 'KAIROS';
    return _names[lvl];
  }

  /// XP mínimo del nivel actual.
  static int xpFloor(int lvl) {
    if (lvl <= 0) return 0;
    if (lvl >= _thresholds.length) return _thresholds.last;
    return _thresholds[lvl];
  }

  /// XP necesario para subir al siguiente nivel.
  static int xpCeiling(int lvl) {
    final next = lvl + 1;
    if (next >= _thresholds.length) return _thresholds.last;
    return _thresholds[next];
  }

  /// Progreso 0.0 → 1.0 dentro del nivel actual.
  static double levelProgress(int xp) {
    final lvl = level(xp);
    final floor = xpFloor(lvl);
    final ceiling = xpCeiling(lvl);
    if (ceiling == floor) return 1.0;
    return ((xp - floor) / (ceiling - floor)).clamp(0.0, 1.0);
  }

  /// XP que falta para el siguiente nivel.
  static int xpToNext(int xp) {
    final lvl = level(xp);
    return (xpCeiling(lvl) - xp).clamp(0, 9999);
  }

  /// Karma label — refleja consistencia además de cantidad.
  static String karmaLabel(List<Task> tasks, int streak) {
    final done = tasks.where((t) => t.isDone).length;
    if (done == 0) return 'Comienza tu primer día';
    if (streak >= 7) return '🔥 En racha imparable';
    if (streak >= 3) return '⚡ Momentum activo';
    if (done >= 50) return '🏆 Productividad élite';
    if (done >= 20) return '💪 Alto rendimiento';
    if (done >= 10) return '📈 Creciendo';
    return '🌱 Construyendo hábito';
  }
}
