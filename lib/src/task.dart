class Task {
  final String id;
  final String name;
  final DateTime deadline;

  const Task(this.id, this.name, this.deadline);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          deadline == other.deadline;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ deadline.hashCode;

  @override
  String toString() => 'Task{id: $id, name: $name, deadline: $deadline}';
}
