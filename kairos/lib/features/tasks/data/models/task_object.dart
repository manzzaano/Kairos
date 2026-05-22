import 'package:realm/realm.dart';

part 'task_object.realm.dart';

@RealmModel()
class _TaskObject {
  @PrimaryKey()
  late ObjectId id;
  late String title;
  late String? description;
  late String priority; // 'high' | 'medium' | 'low'
  late int energyLevel;
  late String? dueLabel;
  late int estimateMinutes;
  late bool isDone;
  late bool isSynced;
  late String project;
  late DateTime? completedAt;
  late DateTime? createdAt;
}
