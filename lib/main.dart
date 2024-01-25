// Importing necessary Dart and Flutter packages.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/task-model.dart';

// Main function to run the app.
void main() {
  runApp(const MyApp());
}

// MyApp class - the root of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp is the wrapper of the entire app UI.
    return MaterialApp(
      title: 'My ToDo List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      home: const TodoScreen(),
    );
  }
}

// TodoScreen StatefulWidget - manages the state of the Todo list.
class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

// State class for TodoScreen.
class _TodoScreenState extends State<TodoScreen> {
  // Controllers for text fields.
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  // List to store tasks.
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Load tasks when the widget is initialized.
  }

  // Async function to load tasks from shared preferences.
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> taskData = prefs.getStringList('tasks') ?? [];
    setState(() {
      _tasks = taskData.map((task) => Task.fromMap(json.decode(task))).toList();
    });
  }

  // Async function to save tasks to shared preferences.
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> taskData = _tasks.map((task) => json.encode(task.toMap())).toList();
    await prefs.setStringList('tasks', taskData);
  }

  // Function to add a new task.
  void _addTask() {
    if (_titleController.text.isNotEmpty) {
      setState(() {
        _tasks.add(Task(title: _titleController.text, description: _descriptionController.text));
        _titleController.clear();
        _descriptionController.clear();
        _saveTasks();
      });
    }
  }

  // Function to edit an existing task.
  void _editTask(int index, Task updatedTask) {
    setState(() {
      _tasks[index] = updatedTask;
      _saveTasks();
    });
  }

  // Function to delete a task.
  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
      _saveTasks();
    });
  }

  // Function to toggle task completion status.
  void _toggleCompletion(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      _saveTasks();
    });
  }

  // Async function to show dialog for editing task.
  Future<void> _showEditDialog(int index) async {
    Task currentTask = _tasks[index];

    TextEditingController titleEditController = TextEditingController(text: currentTask.title);
    TextEditingController descriptionEditController = TextEditingController(text: currentTask.description);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: titleEditController,
                  decoration: const InputDecoration(hintText: "Enter task title"),
                ),
                TextField(
                  controller: descriptionEditController,
                  decoration: const InputDecoration(hintText: "Enter task description"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                _editTask(index, Task(
                  title: titleEditController.text,
                  description: descriptionEditController.text,
                  isCompleted: currentTask.isCompleted,
                  dueDate: currentTask.dueDate,
                  priority: currentTask.priority,
                ));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold provides the structure for the app screen.
    return Scaffold(
      appBar: AppBar(title: const Text("Mbali Nkoana - Todo List")),
      body: Column(
        children: <Widget>[
          // Text fields to input task title and description.
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(hintText: "Enter task title"),
              controller: _titleController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(hintText: "Enter task description"),
              controller: _descriptionController,
            ),
          ),
          // Button to add a new task.
          ElevatedButton(
            onPressed: _addTask,
            child: const Text("Add Task"),
          ),
          // List view to display tasks.
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_tasks[index].title),
                  subtitle: Text(_tasks[index].description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit and delete buttons for each task.
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showEditDialog(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteTask(index),
                      ),
                      // Checkbox to mark task as completed.
                      IconButton(
                        icon: Icon(_tasks[index].isCompleted ? Icons.check_box : Icons.check_box_outline_blank),
                        onPressed: () => _toggleCompletion(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


