import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/models/organization.dart';
import '../../../core/services/api_service.dart';

part 'organization_event.dart';
part 'organization_state.dart';

class OrganizationBloc extends Bloc<OrganizationEvent, OrganizationState> {
  final ApiService apiService;

  OrganizationBloc({required this.apiService}) : super(OrganizationInitial()) {
    on<LoadOrganizations>(_onLoad);
    on<RefreshOrganizations>(_onRefresh);
  }

  Future<void> _onLoad(
    LoadOrganizations event,
    Emitter<OrganizationState> emit,
  ) async {
    emit(OrganizationLoading());
    try {
      final list = await apiService.getOrganizations();
      emit(OrganizationLoaded(organizations: list));
    } catch (e) {
      emit(OrganizationError(message: e.toString()));
    }
  }

  Future<void> _onRefresh(
    RefreshOrganizations event,
    Emitter<OrganizationState> emit,
  ) async {
    if (state is OrganizationLoaded) {
      emit(OrganizationLoaded(
        organizations: (state as OrganizationLoaded).organizations,
      ));
    }
    try {
      final list = await apiService.getOrganizations();
      emit(OrganizationLoaded(organizations: list));
    } catch (e) {
      if (state is OrganizationLoaded) {
        emit(state);
      } else {
        emit(OrganizationError(message: e.toString()));
      }
    }
  }
}
