class TaskEntity {
  final String? id;
  final String title;
  final String? description;
  final bool isCompleted;

  const TaskEntity({
    this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
  });
}