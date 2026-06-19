import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/models/course.dart';
import '../../../core/services/api_service.dart';

part 'course_event.dart';
part 'course_state.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final ApiService apiService;

  CourseBloc({required this.apiService}) : super(CourseInitial()) {
    on<LoadCourses>(_onLoad);
  }

  Future<void> _onLoad(
    LoadCourses event,
    Emitter<CourseState> emit,
  ) async {
    emit(CourseLoading());
    try {
      final list = await apiService.getCoursesByOrganization(event.organizationId);
      emit(CourseLoaded(courses: list));
    } catch (e) {
      emit(CourseError(message: e.toString()));
    }
  }
}
