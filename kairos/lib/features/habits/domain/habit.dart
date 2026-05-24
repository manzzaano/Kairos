/// Modelo de hábito — almacenado en SharedPreferences como JSON.
/// No requiere Realm (schema change) ni Supabase.
class Habit {
  final String id;
  final String title;
  final String emoji;
  final HabitFrequency frequency;
  final List<DateTime> completions; // fechas en que se completó

  const Habit({
    required this.id,
    required this.title,
    required this.emoji,
    this.frequency = HabitFrequency.daily,
    this.completions = const [],
  });

  bool get completedToday {
    final today = _dateOnly(DateTime.now());
    return completions.any((d) => _dateOnly(d) == today);
  }

  int get streak {
    int count = 0;
    DateTime check = _dateOnly(DateTime.now());
    while (completions.any((d) => _dateOnly(d) == check)) {
      count++;
      check = check.subtract(const Duration(days: 1));
    }
    return count;
  }

  int get totalDone => completions.length;

  static DateTime _dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  Habit copyWith({
    String? id,
    String? title,
    String? emoji,
    HabitFrequency? frequency,
    List<DateTime>? completions,
  }) =>
      Habit(
        id: id ?? this.id,
        title: title ?? this.title,
        emoji: emoji ?? this.emoji,
        frequency: frequency ?? this.frequency,
        completions: completions ?? this.completions,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'emoji': emoji,
        'frequency': frequency.name,
        'completions':
            completions.map((d) => d.toIso8601String()).toList(),
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'] as String,
        title: json['title'] as String,
        emoji: json['emoji'] as String? ?? '✅',
        frequency: HabitFrequency.values.firstWhere(
          (f) => f.name == (json['frequency'] as String? ?? 'daily'),
          orElse: () => HabitFrequency.daily,
        ),
        completions: (json['completions'] as List<dynamic>? ?? [])
            .map((s) => DateTime.parse(s as String))
            .toList(),
      );
}

enum HabitFrequency { daily, weekdays, weekly }
