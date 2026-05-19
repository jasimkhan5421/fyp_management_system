import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/feedback_model.dart';
import '../../models/project_model.dart';
import '../../models/progress_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';

class SupervisorProjectDetailsScreen extends StatefulWidget {
  final ProjectModel project;

  const SupervisorProjectDetailsScreen({super.key, required this.project});

  @override
  State<SupervisorProjectDetailsScreen> createState() => _SupervisorProjectDetailsScreenState();
}

class _SupervisorProjectDetailsScreenState extends State<SupervisorProjectDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _approveFeedback = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final projectProvider = context.watch<ProjectProvider>();
    final supervisor = authProvider.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Review Project')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: supervisor == null
            ? const Center(child: Text('Please login to continue.'))
            : ListView(
                children: [
                  _buildDetailRow('Title', widget.project.title),
                  _buildDetailRow('Student', widget.project.studentName),
                  _buildDetailRow('Description', widget.project.description),
                  _buildDetailRow('Technologies', widget.project.technologies),
                  _buildDetailRow('Status', widget.project.status),
                  _buildDetailRow('Approval', widget.project.isApproved ? 'Approved' : widget.project.isRejected ? 'Rejected' : 'Pending'),
                  const SizedBox(height: 20),
                  const Text('Weekly Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  StreamBuilder<List<ProgressModel>>(
                    stream: projectProvider.projectProgress(widget.project.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      final progressItems = snapshot.data ?? [];
                      if (progressItems.isEmpty) {
                        return const Text('No progress entries available.');
                      }
                      return Column(
                        children: progressItems.map((progress) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text('Week ${progress.weekNumber}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(progress.tasks),
                                  const SizedBox(height: 4),
                                  Text(progress.note),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('Supervisor Feedback', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  StreamBuilder<List<FeedbackModel>>(
                    stream: projectProvider.projectFeedback(widget.project.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      final feedbackItems = snapshot.data ?? [];
                      if (feedbackItems.isEmpty) {
                        return const Text('No feedback provided yet.');
                      }
                      return Column(
                        children: feedbackItems.map((feedback) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text(feedback.comment),
                              subtitle: Text('By ${feedback.supervisorName} — ${feedback.isApproved ? 'Approved' : 'Pending review'}'),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      labelText: 'Add Comment',
                      border: OutlineInputBorder(),
                    ),
                    minLines: 2,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Mark feedback as approved'),
                    value: _approveFeedback,
                    onChanged: (value) {
                      setState(() {
                        _approveFeedback = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: projectProvider.isSaving ? null : _sendFeedback,
                    child: projectProvider.isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit Feedback'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: projectProvider.isSaving ? null : _approveProject,
                    child: const Text('Approve Submission'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: projectProvider.isSaving ? null : _rejectProject,
                    child: const Text('Reject Submission'),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _sendFeedback() async {
    final provider = context.read<ProjectProvider>();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user == null || _commentController.text.trim().isEmpty) {
      return;
    }

    final feedback = FeedbackModel(
      id: '',
      projectId: widget.project.id,
      supervisorId: user.uid,
      supervisorName: user.name,
      comment: _commentController.text.trim(),
      isApproved: _approveFeedback,
      createdAt: DateTime.now(),
    );

    final success = await provider.addFeedback(feedback);
    if (!mounted || !success) {
      return;
    }

    _commentController.clear();
    setState(() {
      _approveFeedback = false;
    });
  }

  Future<void> _approveProject() async {
    final provider = context.read<ProjectProvider>();
    final success = await provider.approveProject(widget.project.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Project approved.')));
    }
  }

  Future<void> _rejectProject() async {
    final provider = context.read<ProjectProvider>();
    final success = await provider.rejectProject(widget.project.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Project rejected.')));
    }
  }
}
