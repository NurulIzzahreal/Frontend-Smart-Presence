import 'package:flutter/material.dart';
import 'package:frontend_smart_presence/models/class_model.dart';
import 'package:frontend_smart_presence/services/class_service.dart';
import 'package:frontend_smart_presence/screens/teacher/class_form_screen.dart';

class ClassManagementScreen extends StatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  State<ClassManagementScreen> createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen> {
  List<ClassModel> _classes = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final classService = ClassService();
      final classes = await classService.getAllClasses();
      setState(() {
        _classes = classes;
      });
    } catch (e) {
      print('Error loading classes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load classes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshClasses() async {
    await _loadClasses();
  }

  void _filterClasses(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<ClassModel> _getFilteredClasses() {
    if (_searchQuery.isEmpty) {
      return _classes;
    }

    return _classes.where((classModel) {
      final query = _searchQuery.toLowerCase();
      return classModel.name.toLowerCase().contains(query) ||
          classModel.schedule.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _addClass() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ClassFormScreen()),
    );

    if (result == true) {
      _loadClasses(); // Refresh the list
    }
  }

  Future<void> _editClass(ClassModel classModel) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClassFormScreen(classModel: classModel),
      ),
    );

    if (result == true) {
      _loadClasses(); // Refresh the list
    }
  }

  Future<void> _deleteClass(ClassModel classModel) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content: Text('Are you sure you want to delete ${classModel.name}?'),
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

    if (confirm == true) {
      try {
        final classService = ClassService();
        await classService.deleteClass(classModel.id);
        _loadClasses(); // Refresh the list

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Class deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error deleting class: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete class: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredClasses = _getFilteredClasses();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshClasses,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search classes...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterClasses,
            ),
          ),

          // Class list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredClasses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.class_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No classes found',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Add a new class to get started',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredClasses.length,
                    itemBuilder: (context, index) {
                      final classModel = filteredClasses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            child: const Icon(
                              Icons.class_,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(classModel.name),
                          subtitle: Text(classModel.schedule),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editClass(classModel),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteClass(classModel),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addClass,
        child: const Icon(Icons.add),
      ),
    );
  }
}
