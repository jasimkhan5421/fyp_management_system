import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/project_model.dart';
import '../../providers/project_provider.dart';
import 'edit_project_screen.dart';
import 'feedback_screen.dart';
import 'progress_tracking_screen.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final ProjectModel project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Project Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailRow('Title', project.title),
            _buildDetailRow('Description', project.description),
            _buildDetailRow('Technologies', project.technologies),
            _buildDetailRow('Supervisor', project.supervisorName),
            _buildDetailRow('Status', project.status),
            _buildDetailRow('Approval', project.isApproved ? 'Approved' : project.isRejected ? 'Rejected' : 'Pending'),
            _buildDetailRow('Submitted by', project.studentName),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProjectScreen(project: project),
                  ),
                );
              },
              child: const Text('Edit Project'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProgressTrackingScreen(project: project),
                  ),
                );
              },
              child: const Text('View Progress'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FeedbackScreen(project: project),
                  ),
                );
              },
              child: const Text('View Feedback'),
            ),
            const SizedBox(height: 16),
            if (projectProvider.error != null)
              Text(
                projectProvider.error!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: projectProvider.isSaving
                  ? null
                  : () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Project'),
                          content: const Text('Are you sure you want to delete this project?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed != true) return;

                      final success = await projectProvider.deleteProject(project.id);
                      if (success && context.mounted) {
                        Navigator.pop(context);
                      }
                    },
              child: projectProvider.isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Delete Project'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
