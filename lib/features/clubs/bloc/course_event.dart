part of 'course_bloc.dart';

abstract class CourseEvent extends Equatable {
  const CourseEvent();

  @override
  List<Object?> get props => [];
}

class LoadCourses extends CourseEvent {
  final int organizationId;

  const LoadCourses({required this.organizationId});

  @override
  List<Object?> get props => [organizationId];
}
