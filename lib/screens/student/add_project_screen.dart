import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/project_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _technologiesController = TextEditingController();
  
  String? _selectedSupervisorId;
  String? _selectedSupervisorName;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final projectProvider = context.watch<ProjectProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Project')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: user == null
            ? const Center(child: Text('Please login to create a project.'))
            : Form(
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
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: projectProvider.getSupervisors(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Supervisor',
                              border: OutlineInputBorder(),
                            ),
                            items: const [],
                            onChanged: null,
                          );
                        }

                        if (snapshot.hasError) {
                          return TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Supervisor (Error: ${snapshot.error})',
                              border: const OutlineInputBorder(),
                            ),
                            enabled: false,
                          );
                        }

                        final supervisors = snapshot.data ?? [];
                        if (supervisors.isEmpty) {
                          return TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'No supervisors available',
                              border: OutlineInputBorder(),
                            ),
                            enabled: false,
                          );
                        }

                        return DropdownButtonFormField<String>(
                          value: _selectedSupervisorId,
                          decoration: const InputDecoration(
                            labelText: 'Select Supervisor',
                            border: OutlineInputBorder(),
                          ),
                          items: supervisors.map((supervisor) {
                            final uid = supervisor['uid'] as String;
                            final name = supervisor['name'] as String? ?? 'Unknown';
                            return DropdownMenuItem<String>(
                              value: uid,
                              onTap: () {
                                _selectedSupervisorName = name;
                              },
                              child: Text(name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSupervisorId = value;
                            });
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please select a supervisor'
                              : null,
                        );
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
                          : const Text('Save Project'),
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

    final authProvider = context.read<AuthProvider>();
    final projectProvider = context.read<ProjectProvider>();
    final user = authProvider.user;
    if (user == null || _selectedSupervisorId == null || _selectedSupervisorName == null) {
      return;
    }

    final project = ProjectModel(
      id: '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      technologies: _technologiesController.text.trim(),
      supervisorName: _selectedSupervisorName!,
      supervisorId: _selectedSupervisorId!,
      studentId: user.uid,
      studentName: user.name,
      status: 'pending',
      isApproved: false,
      isRejected: false,
      createdAt: DateTime.now(),
    );

    final success = await projectProvider.createProject(project);
    if (!mounted || !success) {
      return;
    }

    Navigator.pop(context);
  }
}
