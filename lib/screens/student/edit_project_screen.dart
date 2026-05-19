import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/project_model.dart';
import '../../providers/project_provider.dart';

class EditProjectScreen extends StatefulWidget {
  final ProjectModel project;

  const EditProjectScreen({super.key, required this.project});

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _technologiesController;
  late final TextEditingController _supervisorNameController;
  late final TextEditingController _supervisorIdController;
  late String _status;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.project.title);
    _descriptionController = TextEditingController(text: widget.project.description);
    _technologiesController = TextEditingController(text: widget.project.technologies);
    _supervisorNameController = TextEditingController(text: widget.project.supervisorName);
    _supervisorIdController = TextEditingController(text: widget.project.supervisorId);
    _status = widget.project.status;
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Project')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Project Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter the project title'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                minLines: 3,
                maxLines: 5,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter the description'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _technologiesController,
                decoration: const InputDecoration(
                  labelText: 'Technologies Used',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please list the technologies used'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _supervisorNameController,
                decoration: const InputDecoration(
                  labelText: 'Supervisor Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter the supervisor name'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _supervisorIdController,
                decoration: const InputDecoration(
                  labelText: 'Supervisor ID',
                  border: OutlineInputBorder(),
                  helperText: 'Enter supervisor UID if available',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Project Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'in-progress', child: Text('In Progress')),
                  DropdownMenuItem(value: 'completed', child: Text('Completed')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _status = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              if (projectProvider.error != null)
                Text(
                  projectProvider.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: projectProvider.isSaving ? null : _saveProject,
                child: projectProvider.isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Update Project'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final projectProvider = context.read<ProjectProvider>();
    final updatedProject = ProjectModel(
      id: widget.project.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      technologies: _technologiesController.text.trim(),
      supervisorName: _supervisorNameController.text.trim(),
      supervisorId: _supervisorIdController.text.trim(),
      studentId: widget.project.studentId,
      studentName: widget.project.studentName,
      status: _status,
      isApproved: widget.project.isApproved,
      isRejected: widget.project.isRejected,
      createdAt: widget.project.createdAt,
    );

    final success = await projectProvider.updateProject(updatedProject);
    if (!mounted || !success) {
      return;
    }

    Navigator.pop(context);
  }
}
