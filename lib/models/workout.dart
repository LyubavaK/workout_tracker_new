import 'exercise.dart';

class Workout {
  final String id;
  final DateTime date;
  final List<Exercise> exercises;
  final String notes;

  Workout({
    required this.id,
    required this.date,
    required this.exercises,
    this.notes = '',
  });

  int get totalDuration {
    return exercises.fold(0, (sum, e) => sum + e.durationMinutes);
  }

  int get totalCalories {
    return exercises.fold(0, (sum, e) => sum + e.caloriesBurned);
  }
}
