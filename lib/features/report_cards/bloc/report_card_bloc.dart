import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/models/visit_history.dart';
import '../../../core/services/api_service.dart';

part 'report_card_event.dart';
part 'report_card_state.dart';

class ReportCardBloc extends Bloc<ReportCardEvent, ReportCardState> {
  final ApiService apiService;

  ReportCardBloc({required this.apiService}) : super(ReportCardInitial()) {
    on<LoadReportCards>(_onLoadReportCards);
    on<RefreshReportCards>(_onRefreshReportCards);
  }

  Future<void> _onLoadReportCards(
    LoadReportCards event,
    Emitter<ReportCardState> emit,
  ) async {
    emit(ReportCardLoading());
    try {
      final visitHistories = await apiService.getVisitHistories();
      emit(ReportCardLoaded(visitHistories: visitHistories));
    } catch (e) {
      emit(ReportCardError(message: e.toString()));
    }
  }

  Future<void> _onRefreshReportCards(
    RefreshReportCards event,
    Emitter<ReportCardState> emit,
  ) async {
    if (state is ReportCardLoaded) {
      emit(ReportCardLoaded(visitHistories: (state as ReportCardLoaded).visitHistories));
    }
    try {
      final visitHistories = await apiService.getVisitHistories();
      emit(ReportCardLoaded(visitHistories: visitHistories));
    } catch (e) {
      if (state is ReportCardLoaded) {
        emit(state);
      } else {
        emit(ReportCardError(message: e.toString()));
      }
    }
  }
}

