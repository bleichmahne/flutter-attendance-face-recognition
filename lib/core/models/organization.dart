import 'package:equatable/equatable.dart';

//swagger: /organizations
class Organization extends Equatable {
  final int id;
  final String? kbUuid;
  final String? uid;
  final String? idn;
  final String? nameKz;
  final String? nameRu;
  final String? farFaceEventCode;
  final int? farFaceEventId;
  final String? farFaceRegCode;
  final String? created;
  final String? updated;

  const Organization({
    required this.id,
    this.kbUuid,
    this.uid,
    this.idn,
    this.nameKz,
    this.nameRu,
    this.farFaceEventCode,
    this.farFaceEventId,
    this.farFaceRegCode,
    this.created,
    this.updated,
  });

  //display name: prefer russian, fallback to kazakh
  String get name => nameRu ?? nameKz ?? '';

  factory Organization.fromJson(Map<String, dynamic> json) {
    int? orgId;
    if (json['id'] != null) {
      orgId = json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString());
    }
    if (orgId == null && json['kb_uuid'] != null) {
      orgId = 0;
    }

    return Organization(
      id: orgId ?? 0,
      kbUuid: (json['kb_uuid'] ?? json['uuid']) as String?,
      uid: json['uid'] as String?,
      idn: json['idn'] as String?,
      nameKz: json['name_kz'] as String?,
      nameRu: json['name_ru'] as String? ?? json['name'] as String?,
      farFaceEventCode: json['far_face_event_code'] as String?,
      farFaceEventId: json['far_face_event_id'] as int?,
      farFaceRegCode: json['far_face_reg_code'] as String?,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (kbUuid != null) 'kb_uuid': kbUuid,
      if (uid != null) 'uid': uid,
      if (idn != null) 'idn': idn,
      if (nameKz != null) 'name_kz': nameKz,
      if (nameRu != null) 'name_ru': nameRu,
      if (farFaceEventCode != null) 'far_face_event_code': farFaceEventCode,
      if (farFaceEventId != null) 'far_face_event_id': farFaceEventId,
      if (farFaceRegCode != null) 'far_face_reg_code': farFaceRegCode,
      if (created != null) 'created': created,
      if (updated != null) 'updated': updated,
    };
  }

  @override
  List<Object?> get props => [id, kbUuid, uid, idn, nameKz, nameRu, farFaceEventCode, farFaceEventId, farFaceRegCode, created, updated];
}
