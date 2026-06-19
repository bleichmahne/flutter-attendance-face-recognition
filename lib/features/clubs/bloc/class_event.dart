part of 'class_bloc.dart';

abstract class ClassEvent extends Equatable {
  const ClassEvent();

  @override
  List<Object?> get props => [];
}

class LoadClassesByCourse extends ClassEvent {
  final int courseId;

  const LoadClassesByCourse({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}
