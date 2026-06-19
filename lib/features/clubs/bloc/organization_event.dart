part of 'organization_bloc.dart';

abstract class OrganizationEvent extends Equatable {
  const OrganizationEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrganizations extends OrganizationEvent {
  const LoadOrganizations();
}

class RefreshOrganizations extends OrganizationEvent {
  const RefreshOrganizations();
}
