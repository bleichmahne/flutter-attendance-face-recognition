import 'package:equatable/equatable.dart';

///Swagger models.Child
class Child extends Equatable {
  final int? id;
  final int? age;
  final String? birthDate;
  final String? created;
  final String? firstName;
  final int? hSexTypeId;
  final String? iin;
  final bool? hasImage;
  final bool? isFfDataUseAgreement;
  final bool? isQfDataUseAgreement;
  final bool? isSuitable;
  final String? kbUuid;
  final String? lastName;
  final String? middleName;
  final String? updated;

  const Child({
    this.id,
    this.age,
    this.birthDate,
    this.created,
    this.firstName,
    this.hSexTypeId,
    this.iin,
    this.hasImage,
    this.isFfDataUseAgreement,
    this.isQfDataUseAgreement,
    this.isSuitable,
    this.kbUuid,
    this.lastName,
    this.middleName,
    this.updated,
  });

  String get fullName {
    final parts = [firstName, middleName, lastName].whereType<String>().toList();
    return parts.join(' ');
  }

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] as int?,
      age: json['age'] as int?,
      birthDate: json['birth_date'] as String?,
      created: json['created'] as String?,
      firstName: json['first_name'] as String?,
      hSexTypeId: json['h_sex_type_id'] as int?,
      iin: json['iin'] as String?,
      hasImage: json['has_image'] as bool?,
      isFfDataUseAgreement: json['is_ff_data_use_agreement'] as bool?,
      isQfDataUseAgreement: json['is_qf_data_use_agreement'] as bool?,
      isSuitable: json['is_suitable'] as bool?,
      kbUuid: json['kb_uuid'] as String?,
      lastName: json['last_name'] as String?,
      middleName: json['middle_name'] as String?,
      updated: json['updated'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (age != null) 'age': age,
      if (birthDate != null) 'birth_date': birthDate,
      if (created != null) 'created': created,
      if (firstName != null) 'first_name': firstName,
      if (hSexTypeId != null) 'h_sex_type_id': hSexTypeId,
      if (iin != null) 'iin': iin,
      if (hasImage != null) 'has_image': hasImage,
      if (isFfDataUseAgreement != null) 'is_ff_data_use_agreement': isFfDataUseAgreement,
      if (isQfDataUseAgreement != null) 'is_qf_data_use_agreement': isQfDataUseAgreement,
      if (isSuitable != null) 'is_suitable': isSuitable,
      if (kbUuid != null) 'kb_uuid': kbUuid,
      if (lastName != null) 'last_name': lastName,
      if (middleName != null) 'middle_name': middleName,
      if (updated != null) 'updated': updated,
    };
  }

  @override
  List<Object?> get props => [
        id,
        age,
        birthDate,
        created,
        firstName,
        hSexTypeId,
        iin,
        hasImage,
        isFfDataUseAgreement,
        isQfDataUseAgreement,
        isSuitable,
        kbUuid,
        lastName,
        middleName,
        updated,
      ];
}
