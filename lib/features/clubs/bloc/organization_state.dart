part of 'organization_bloc.dart';

abstract class OrganizationState extends Equatable {
  const OrganizationState();

  @override
  List<Object?> get props => [];
}

class OrganizationInitial extends OrganizationState {}

class OrganizationLoading extends OrganizationState {}

class OrganizationLoaded extends OrganizationState {
  final List<Organization> organizations;

  const OrganizationLoaded({required this.organizations});

  @override
  List<Object?> get props => [organizations];
}

class OrganizationError extends OrganizationState {
  final String message;

  const OrganizationError({required this.message});

  @override
  List<Object?> get props => [message];
}
