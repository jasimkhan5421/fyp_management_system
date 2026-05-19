import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';
import '../models/progress_model.dart';
import '../models/feedback_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── PROJECTS ───────────────────────────────────────────

  // ─── SUPERVISORS ──────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> getSupervisors() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'supervisor')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => {'uid': d.id, ...d.data()})
            .toList());
  }

  Future<void> createProject(ProjectModel project) async {
    final ref = _db.collection('projects').doc();
    final withId = ProjectModel(
      id:             ref.id,
      title:          project.title,
      description:    project.description,
      technologies:   project.technologies,
      supervisorName: project.supervisorName,
      supervisorId:   project.supervisorId,
      studentId:      project.studentId,
      studentName:    project.studentName,
      status:         project.status,
      isApproved:     project.isApproved,
      isRejected:     project.isRejected,
      createdAt:      project.createdAt,
    );
    await ref.set(withId.toMap());
  }

  Future<void> updateProject(ProjectModel project) async {
    await _db.collection('projects').doc(project.id).update(project.toMap());
  }

  Future<void> deleteProject(String projectId) async {
    await _db.collection('projects').doc(projectId).delete();
  }

  Stream<List<ProjectModel>> getStudentProjects(String studentId) {
    return _db
        .collection('projects')
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ProjectModel.fromMap(d.data(), d.id))
            .toList());
  }

  Stream<List<ProjectModel>> getSupervisorProjects(String supervisorId) {
    return _db
        .collection('projects')
        .where('supervisorId', isEqualTo: supervisorId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ProjectModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<void> approveProject(String projectId) async {
    await _db.collection('projects').doc(projectId).update({
      'isApproved': true,
      'isRejected': false,
      'status':     'completed',
    });
  }

  Future<void> rejectProject(String projectId) async {
    await _db.collection('projects').doc(projectId).update({
      'isApproved': false,
      'isRejected': true,
    });
  }

  // ─── PROGRESS ────────────────────────────────────────────

  Future<void> addProgress(ProgressModel progress) async {
    final ref = _db
        .collection('projects')
        .doc(progress.projectId)
        .collection('progress')
        .doc();
    await ref.set(progress.toMap());
  }

  Stream<List<ProgressModel>> getProgress(String projectId) {
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('progress')
        .orderBy('weekNumber')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ProgressModel.fromMap(d.data(), d.id))
            .toList());
  }

  // ─── FEEDBACK ─────────────────────────────────────────────

  Future<void> addFeedback(FeedbackModel feedback) async {
    final ref = _db
        .collection('projects')
        .doc(feedback.projectId)
        .collection('feedback')
        .doc();
    await ref.set(feedback.toMap());
  }

  Stream<List<FeedbackModel>> getFeedback(String projectId) {
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('feedback')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => FeedbackModel.fromMap(d.data(), d.id))
            .toList());
  }
}