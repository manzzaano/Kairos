// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_object.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class TaskObject extends _TaskObject
    with RealmEntity, RealmObjectBase, RealmObject {
  TaskObject(
    ObjectId id,
    String title,
    String priority,
    int energyLevel,
    int estimateMinutes,
    bool isDone,
    bool isSynced,
    String project, {
    String? description,
    String? dueLabel,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'title', title);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'priority', priority);
    RealmObjectBase.set(this, 'energyLevel', energyLevel);
    RealmObjectBase.set(this, 'dueLabel', dueLabel);
    RealmObjectBase.set(this, 'estimateMinutes', estimateMinutes);
    RealmObjectBase.set(this, 'isDone', isDone);
    RealmObjectBase.set(this, 'isSynced', isSynced);
    RealmObjectBase.set(this, 'project', project);
    RealmObjectBase.set(this, 'completedAt', completedAt);
    RealmObjectBase.set(this, 'createdAt', createdAt);
  }

  TaskObject._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get title => RealmObjectBase.get<String>(this, 'title') as String;
  @override
  set title(String value) => RealmObjectBase.set(this, 'title', value);

  @override
  String? get description =>
      RealmObjectBase.get<String>(this, 'description') as String?;
  @override
  set description(String? value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  String get priority =>
      RealmObjectBase.get<String>(this, 'priority') as String;
  @override
  set priority(String value) => RealmObjectBase.set(this, 'priority', value);

  @override
  int get energyLevel => RealmObjectBase.get<int>(this, 'energyLevel') as int;
  @override
  set energyLevel(int value) =>
      RealmObjectBase.set(this, 'energyLevel', value);

  @override
  String? get dueLabel =>
      RealmObjectBase.get<String>(this, 'dueLabel') as String?;
  @override
  set dueLabel(String? value) => RealmObjectBase.set(this, 'dueLabel', value);

  @override
  int get estimateMinutes =>
      RealmObjectBase.get<int>(this, 'estimateMinutes') as int;
  @override
  set estimateMinutes(int value) =>
      RealmObjectBase.set(this, 'estimateMinutes', value);

  @override
  bool get isDone => RealmObjectBase.get<bool>(this, 'isDone') as bool;
  @override
  set isDone(bool value) => RealmObjectBase.set(this, 'isDone', value);

  @override
  bool get isSynced => RealmObjectBase.get<bool>(this, 'isSynced') as bool;
  @override
  set isSynced(bool value) => RealmObjectBase.set(this, 'isSynced', value);

  @override
  String get project => RealmObjectBase.get<String>(this, 'project') as String;
  @override
  set project(String value) => RealmObjectBase.set(this, 'project', value);

  @override
  DateTime? get completedAt =>
      RealmObjectBase.get<DateTime>(this, 'completedAt') as DateTime?;
  @override
  set completedAt(DateTime? value) =>
      RealmObjectBase.set(this, 'completedAt', value);

  @override
  DateTime? get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime?;
  @override
  set createdAt(DateTime? value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  Stream<RealmObjectChanges<TaskObject>> get changes =>
      RealmObjectBase.getChanges<TaskObject>(this);

  @override
  Stream<RealmObjectChanges<TaskObject>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<TaskObject>(this, keyPaths);

  @override
  TaskObject freeze() => RealmObjectBase.freezeObject<TaskObject>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'title': title.toEJson(),
      'description': description.toEJson(),
      'priority': priority.toEJson(),
      'energyLevel': energyLevel.toEJson(),
      'dueLabel': dueLabel.toEJson(),
      'estimateMinutes': estimateMinutes.toEJson(),
      'isDone': isDone.toEJson(),
      'isSynced': isSynced.toEJson(),
      'project': project.toEJson(),
      'completedAt': completedAt.toEJson(),
      'createdAt': createdAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(TaskObject value) => value.toEJson();
  static TaskObject _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'title': EJsonValue title,
        'priority': EJsonValue priority,
        'energyLevel': EJsonValue energyLevel,
        'estimateMinutes': EJsonValue estimateMinutes,
        'isDone': EJsonValue isDone,
        'isSynced': EJsonValue isSynced,
        'project': EJsonValue project,
      } =>
        TaskObject(
          fromEJson(id),
          fromEJson(title),
          fromEJson(priority),
          fromEJson(energyLevel),
          fromEJson(estimateMinutes),
          fromEJson(isDone),
          fromEJson(isSynced),
          fromEJson(project),
          description: fromEJson(ejson['description']),
          dueLabel: fromEJson(ejson['dueLabel']),
          completedAt: fromEJson(ejson['completedAt']),
          createdAt: fromEJson(ejson['createdAt']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(TaskObject._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, TaskObject, 'TaskObject', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('title', RealmPropertyType.string),
      SchemaProperty('description', RealmPropertyType.string, optional: true),
      SchemaProperty('priority', RealmPropertyType.string),
      SchemaProperty('energyLevel', RealmPropertyType.int),
      SchemaProperty('dueLabel', RealmPropertyType.string, optional: true),
      SchemaProperty('estimateMinutes', RealmPropertyType.int),
      SchemaProperty('isDone', RealmPropertyType.bool),
      SchemaProperty('isSynced', RealmPropertyType.bool),
      SchemaProperty('project', RealmPropertyType.string),
      SchemaProperty('completedAt', RealmPropertyType.timestamp,
          optional: true),
      SchemaProperty('createdAt', RealmPropertyType.timestamp, optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
