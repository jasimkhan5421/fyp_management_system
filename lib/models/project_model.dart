import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String title;
  final String description;
  final String technologies;
  final String supervisorName;
  final String supervisorId;
  final String studentId;
  final String studentName;
  final String status;       // 'pending' | 'in-progress' | 'completed'
  final bool   isApproved;
  final bool   isRejected;
  final DateTime createdAt;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.technologies,
    required this.supervisorName,
    required this.supervisorId,
    required this.studentId,
    required this.studentName,
    required this.status,
    required this.isApproved,
    required this.isRejected,
    required this.createdAt,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProjectModel(
      id:             docId,
      title:          map['title']          ?? '',
      description:    map['description']    ?? '',
      technologies:   map['technologies']   ?? '',
      supervisorName: map['supervisorName'] ?? '',
      supervisorId:   map['supervisorId']   ?? '',
      studentId:      map['studentId']      ?? '',
      studentName:    map['studentName']    ?? '',
      status:         map['status']         ?? 'pending',
      isApproved:     map['isApproved']     ?? false,
      isRejected:     map['isRejected']     ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title':          title,
    'description':    description,
    'technologies':   technologies,
    'supervisorName': supervisorName,
    'supervisorId':   supervisorId,
    'studentId':      studentId,
    'studentName':    studentName,
    'status':         status,
    'isApproved':     isApproved,
    'isRejected':     isRejected,
    'createdAt':      Timestamp.fromDate(createdAt),
  };
}