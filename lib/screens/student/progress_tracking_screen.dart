import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/project_model.dart';
import '../../models/progress_model.dart';
import '../../providers/project_provider.dart';

class ProgressTrackingScreen extends StatefulWidget {
  final ProjectModel project;

  const ProgressTrackingScreen({super.key, required this.project});

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weekController = TextEditingController();
  final TextEditingController _tasksController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Progress Tracking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<ProgressModel>>(
                stream: provider.projectProgress(widget.project.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final progressList = snapshot.data ?? [];
                  if (progressList.isEmpty) {
                    return const Center(child: Text('No progress entries yet.'));
                  }

                  return ListView.builder(
                    itemCount: progressList.length,
                    itemBuilder: (context, index) {
                      final item = progressList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text('Week ${item.weekNumber}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.tasks),
                              const SizedBox(height: 4),
                              Text(item.note),
                              const SizedBox(height: 4),
                              Text('Date: ${item.date.toLocal().toString().split(' ')[0]}'),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _weekController,
                    decoration: const InputDecoration(
                      labelText: 'Week Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter week number';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _tasksController,
                    decoration: const InputDecoration(
                      labelText: 'Completed Tasks',
                      border: OutlineInputBorder(),
                    ),
                    minLines: 2,
                    maxLines: 4,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Enter completed tasks'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    minLines: 2,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: provider.isSaving ? null : _saveProgress,
                    child: provider.isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Add Progress'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProgress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<ProjectProvider>();
    final progress = ProgressModel(
      id: '',
      projectId: widget.project.id,
      weekNumber: int.parse(_weekController.text.trim()),
      tasks: _tasksController.text.trim(),
      note: _noteController.text.trim(),
      date: DateTime.now(),
    );

    final success = await provider.addProgress(progress);
    if (!mounted || !success) {
      return;
    }

    _weekController.clear();
    _tasksController.clear();
    _noteController.clear();
  }
}
