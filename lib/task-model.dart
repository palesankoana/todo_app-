class Task {
  String title;
  String description;
  bool isCompleted;
  DateTime dueDate;
  int priority;// Can be 1 (High), 2 (Medium), 3 (Low)

  Task({
    required this.title,
    this.description = '',
    this.isCompleted = false,
    DateTime? dueDate,
  this.priority = 2,
  }) : dueDate = dueDate ?? DateTime.now();

  // Convert a Task to a Map.
  // The keys must correspond to the names
  //of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'dueDate' : dueDate.toIso8601String(),
      'priority' : priority,
    };
  }

  // Implement a method to deserialize
  // a map from the database to a Task object.
  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
      dueDate: DateTime.parse(map['dueDate']),
      priority: map['priority'],
    );
  }
  }