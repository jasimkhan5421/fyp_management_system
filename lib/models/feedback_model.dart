import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String   id;
  final String   projectId;
  final String   supervisorId;
  final String   supervisorName;
  final String   comment;
  final bool     isApproved;
  final DateTime createdAt;

  FeedbackModel({
    required this.id,
    required this.projectId,
    required this.supervisorId,
    required this.supervisorName,
    required this.comment,
    required this.isApproved,
    required this.createdAt,
  });

  factory FeedbackModel.fromMap(Map<String, dynamic> map, String docId) {
    return FeedbackModel(
      id:             docId,
      projectId:      map['projectId']      ?? '',
      supervisorId:   map['supervisorId']   ?? '',
      supervisorName: map['supervisorName'] ?? '',
      comment:        map['comment']        ?? '',
      isApproved:     map['isApproved']     ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'projectId':      projectId,
    'supervisorId':   supervisorId,
    'supervisorName': supervisorName,
    'comment':        comment,
    'isApproved':     isApproved,
    'createdAt':      Timestamp.fromDate(createdAt),
  };
}