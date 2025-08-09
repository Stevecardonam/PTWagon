import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _taskService = TaskService();
  final AuthService _authService = AuthService();
  late Future<List<dynamic>> _tasksFuture;
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _fetchTasks() {
    setState(() {
      _tasksFuture = _taskService.getTasks();
    });
  }

  void _createTask() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and description cannot be empty")),
      );
      return;
    }
    
    try {
      await _taskService.createTask(
        _titleController.text, 
        _descriptionController.text,
      );
      
      _titleController.clear();
      _descriptionController.clear();
      
      if (!mounted) return;
      Navigator.of(context).pop();
      _fetchTasks();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _updateTask(String id, String newTitle, String newDescription, String newStatus) async {
    try {
      await _taskService.updateTask(id, newTitle, newDescription, newStatus);
      if (!mounted) return;
      Navigator.of(context).pop();
      _fetchTasks();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _deleteTask(String id) async {
    try {
      await _taskService.deleteTask(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tarea eliminada exitosamente")),
      );
      _fetchTasks();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _showCreateTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nueva Tarea"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Título"),
              ),
              const SizedBox(height: 16), 
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Descripción"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _titleController.clear();
                _descriptionController.clear();
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: _createTask,
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  void _showEditTaskDialog(Map<String, dynamic> task) {
    final titleController = TextEditingController(text: task['title']);
    final descriptionController = TextEditingController(text: task['description']);
    String selectedStatus = task['status'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: const Text("Editar Tarea"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: "Título"),
                    ),
                    const SizedBox(height: 16), 
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: "Descripción"),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: "Estado",
                        border: OutlineInputBorder(),
                      ),
                      items: <String>['PENDING', 'COMPLETED', 'CANCELLED']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setStateSB(() {
                          selectedStatus = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () => _updateTask(
                    task['id'],
                    titleController.text,
                    descriptionController.text,
                    selectedStatus,
                  ),
                  child: const Text("Guardar"),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Tareas"),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTasks,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primary.withOpacity(0.9),
              primary.withOpacity(0.6),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<dynamic>>(
          future: _tasksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "No tienes tareas. ¡Crea una!",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            } else {
              final tasks = snapshot.data!;
              final pendingTasks = tasks.where((t) => t['status'] == 'PENDING').toList();
              final completedTasks = tasks.where((t) => t['status'] == 'COMPLETED').toList();
              final cancelledTasks = tasks.where((t) => t['status'] == 'CANCELLED').toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTaskList(context, "Pendientes", pendingTasks, primary, Icons.pending_actions),
                    const SizedBox(height: 20),
                    _buildTaskList(context, "Realizadas", completedTasks, Colors.green, Icons.check_circle),
                    const SizedBox(height: 20),
                    _buildTaskList(context, "Canceladas", cancelledTasks, Colors.red, Icons.cancel),
                  ],
                ),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, String title, List<dynamic> tasks, Color headerColor, IconData icon) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          tasks.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("No hay tareas en esta categoría."),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(
                        task['title'],
                        style: TextStyle(
                          decoration: task['status'] == 'COMPLETED'
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: task['status'] == 'COMPLETED'
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                      subtitle: Text(task['description']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditTaskDialog(task),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTask(task['id']),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}