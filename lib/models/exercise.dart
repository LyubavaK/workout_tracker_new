class Exercise {
  final String id;
  final String name;
  final int durationMinutes;
  final int caloriesPerMinute;

  Exercise({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.caloriesPerMinute,
  });

  int get caloriesBurned => durationMinutes * caloriesPerMinute;
}
