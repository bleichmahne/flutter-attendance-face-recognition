import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/models/class_model.dart';
import '../../../core/services/api_service.dart';

part 'club_event.dart';
part 'club_state.dart';

class ClubBloc extends Bloc<ClubEvent, ClubState> {
  final ApiService apiService;

  ClubBloc({required this.apiService}) : super(ClubInitial()) {
    on<LoadClubs>(_onLoadClubs);
    on<RefreshClubs>(_onRefreshClubs);
  }

  Future<void> _onLoadClubs(
    LoadClubs event,
    Emitter<ClubState> emit,
  ) async {
    emit(ClubLoading());
    try {
      final classes = await apiService.getClasses();
      emit(ClubLoaded(classes: classes));
    } catch (e) {
      emit(ClubError(message: e.toString()));
    }
  }

  Future<void> _onRefreshClubs(
    RefreshClubs event,
    Emitter<ClubState> emit,
  ) async {
    if (state is ClubLoaded) {
      emit(ClubLoaded(classes: (state as ClubLoaded).classes));
    }
    try {
      final classes = await apiService.getClasses();
      emit(ClubLoaded(classes: classes));
    } catch (e) {
      if (state is ClubLoaded) {
        emit(state);
      } else {
        emit(ClubError(message: e.toString()));
      }
    }
  }
}

