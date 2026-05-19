import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/feedback_model.dart';
import '../../models/project_model.dart';
import '../../providers/project_provider.dart';

class FeedbackScreen extends StatelessWidget {
  final ProjectModel project;

  const FeedbackScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProjectProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<FeedbackModel>>(
          stream: provider.projectFeedback(project.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final feedbackList = snapshot.data ?? [];
            if (feedbackList.isEmpty) {
              return const Center(child: Text('No supervisor feedback yet.'));
            }

            return ListView.builder(
              itemCount: feedbackList.length,
              itemBuilder: (context, index) {
                final feedback = feedbackList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(feedback.supervisorName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(feedback.comment),
                        const SizedBox(height: 4),
                        Text('Status: ${feedback.isApproved ? 'Approved' : 'Review'}'),
                        const SizedBox(height: 4),
                        Text('Date: ${feedback.createdAt.toLocal().toString().split(' ')[0]}'),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
