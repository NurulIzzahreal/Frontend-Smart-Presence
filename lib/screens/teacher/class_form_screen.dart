import 'package:flutter/material.dart';
import 'package:frontend_smart_presence/models/class_model.dart';
import 'package:frontend_smart_presence/services/class_service.dart';

class ClassFormScreen extends StatefulWidget {
  final ClassModel? classModel;

  const ClassFormScreen({super.key, this.classModel});

  @override
  State<ClassFormScreen> createState() => _ClassFormScreenState();
}

class _ClassFormScreenState extends State<ClassFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _teacherIdController;
  late TextEditingController _scheduleController;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.classModel != null;

    _nameController = TextEditingController(
      text: widget.classModel?.name ?? '',
    );
    _teacherIdController = TextEditingController(
      text: widget.classModel?.teacherId ?? '',
    );
    _scheduleController = TextEditingController(
      text: widget.classModel?.schedule ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teacherIdController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  Future<void> _saveClass() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final classService = ClassService();
        final classModel = ClassModel(
          id: widget.classModel?.id ?? '',
          name: _nameController.text.trim(),
          teacherId: _teacherIdController.text.trim(),
          schedule: _scheduleController.text.trim(),
        );

        if (_isEditing) {
          await classService.updateClass(widget.classModel!.id, classModel);
        } else {
          await classService.createClass(classModel);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? 'Class updated successfully'
                    : 'Class created successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Return true to indicate success
          Navigator.pop(context, true);
        }
      } catch (e) {
        print('Error saving class: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save class: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Class' : 'Add Class'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Class Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.class_),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter class name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _teacherIdController,
                decoration: const InputDecoration(
                  labelText: 'Teacher ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter teacher ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _scheduleController,
                decoration: const InputDecoration(
                  labelText: 'Schedule',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.schedule),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter class schedule';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveClass,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(_isEditing ? 'Update Class' : 'Add Class'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
