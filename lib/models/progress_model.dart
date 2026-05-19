import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressModel {
  final String   id;
  final String   projectId;
  final int      weekNumber;
  final String   tasks;
  final String   note;
  final DateTime date;

  ProgressModel({
    required this.id,
    required this.projectId,
    required this.weekNumber,
    required this.tasks,
    required this.note,
    required this.date,
  });

  factory ProgressModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProgressModel(
      id:         docId,
      projectId:  map['projectId']  ?? '',
      weekNumber: map['weekNumber'] ?? 0,
      tasks:      map['tasks']      ?? '',
      note:       map['note']       ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'projectId':  projectId,
    'weekNumber': weekNumber,
    'tasks':      tasks,
    'note':       note,
    'date':       Timestamp.fromDate(date),
  };
}
