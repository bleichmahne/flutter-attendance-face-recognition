import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/models/class_model.dart';
import '../../../core/services/api_service.dart';

part 'class_event.dart';
part 'class_state.dart';

class ClassBloc extends Bloc<ClassEvent, ClassState> {
  final ApiService apiService;

  ClassBloc({required this.apiService}) : super(ClassInitial()) {
    on<LoadClassesByCourse>(_onLoad);
  }

  Future<void> _onLoad(
    LoadClassesByCourse event,
    Emitter<ClassState> emit,
  ) async {
    emit(ClassLoading());
    try {
      final list = await apiService.getClassesByCourse(event.courseId);
      emit(ClassLoaded(classes: list));
    } catch (e) {
      emit(ClassError(message: e.toString()));
    }
  }
}
