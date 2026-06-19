import 'package:equatable/equatable.dart';
import 'organization.dart';

///Swagger models.Course
class Course extends Equatable {
  final int? id;
  final int? applicationId;
  final int? capacity;
  final int? childAgeFrom;
  final int? childAgeTo;
  final String? created;
  final String? descriptionKz;
  final String? descriptionRu;
  final int? hRegionId;
  final String? kbUuid;
  final String? nameKz;
  final String? nameRu;
  final int? organizationId;
  final int? placeId;
  final String? updated;
  final Organization? organization;

  const Course({
    this.id,
    this.applicationId,
    this.capacity,
    this.childAgeFrom,
    this.childAgeTo,
    this.created,
    this.descriptionKz,
    this.descriptionRu,
    this.hRegionId,
    this.kbUuid,
    this.nameKz,
    this.nameRu,
    this.organizationId,
    this.placeId,
    this.updated,
    this.organization,
  });

  String get displayName => nameRu ?? nameKz ?? '';

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int?,
      applicationId: json['application_id'] as int?,
      capacity: json['capacity'] as int?,
      childAgeFrom: json['child_age_from'] as int?,
      childAgeTo: json['child_age_to'] as int?,
      created: json['created'] as String?,
      descriptionKz: json['description_kz'] as String?,
      descriptionRu: json['description_ru'] as String?,
      hRegionId: json['h_region_id'] as int?,
      kbUuid: json['kb_uuid'] as String?,
      nameKz: json['name_kz'] as String?,
      nameRu: json['name_ru'] as String?,
      organizationId: json['organization_id'] as int?,
      placeId: json['place_id'] as int?,
      updated: json['updated'] as String?,
      organization: json['organization'] != null
          ? Organization.fromJson(json['organization'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (applicationId != null) 'application_id': applicationId,
      if (capacity != null) 'capacity': capacity,
      if (childAgeFrom != null) 'child_age_from': childAgeFrom,
      if (childAgeTo != null) 'child_age_to': childAgeTo,
      if (created != null) 'created': created,
      if (descriptionKz != null) 'description_kz': descriptionKz,
      if (descriptionRu != null) 'description_ru': descriptionRu,
      if (hRegionId != null) 'h_region_id': hRegionId,
      if (kbUuid != null) 'kb_uuid': kbUuid,
      if (nameKz != null) 'name_kz': nameKz,
      if (nameRu != null) 'name_ru': nameRu,
      if (organizationId != null) 'organization_id': organizationId,
      if (placeId != null) 'place_id': placeId,
      if (updated != null) 'updated': updated,
      if (organization != null) 'organization': organization?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        applicationId,
        capacity,
        childAgeFrom,
        childAgeTo,
        created,
        descriptionKz,
        descriptionRu,
        hRegionId,
        kbUuid,
        nameKz,
        nameRu,
        organizationId,
        placeId,
        updated,
        organization,
      ];
}
