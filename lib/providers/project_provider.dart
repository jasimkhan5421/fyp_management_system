import 'package:flutter/material.dart';

import '../models/feedback_model.dart';
import '../models/project_model.dart';
import '../models/progress_model.dart';
import '../services/firestore_service.dart';

class ProjectProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  bool isSaving = false;
  String? error;

  Stream<List<ProjectModel>> studentProjects(String studentId) {
    return _firestoreService.getStudentProjects(studentId);
  }

  Stream<List<ProjectModel>> supervisorProjects(String supervisorId) {
    return _firestoreService.getSupervisorProjects(supervisorId);
  }

  Stream<List<Map<String, dynamic>>> getSupervisors() {
    return _firestoreService.getSupervisors();
  }

  Stream<List<ProgressModel>> projectProgress(String projectId) {
    return _firestoreService.getProgress(projectId);
  }

  Stream<List<FeedbackModel>> projectFeedback(String projectId) {
    return _firestoreService.getFeedback(projectId);
  }

  Future<bool> createProject(ProjectModel project) async {
    return _execute(() => _firestoreService.createProject(project));
  }

  Future<bool> updateProject(ProjectModel project) async {
    return _execute(() => _firestoreService.updateProject(project));
  }

  Future<bool> deleteProject(String projectId) async {
    return _execute(() => _firestoreService.deleteProject(projectId));
  }

  Future<bool> approveProject(String projectId) async {
    return _execute(() => _firestoreService.approveProject(projectId));
  }

  Future<bool> rejectProject(String projectId) async {
    return _execute(() => _firestoreService.rejectProject(projectId));
  }

  Future<bool> addProgress(ProgressModel progress) async {
    return _execute(() => _firestoreService.addProgress(progress));
  }

  Future<bool> addFeedback(FeedbackModel feedback) async {
    return _execute(() => _firestoreService.addFeedback(feedback));
  }

  Future<bool> _execute(Future<void> Function() action) async {
    error = null;
    isSaving = true;
    notifyListeners();

    try {
      await action();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
